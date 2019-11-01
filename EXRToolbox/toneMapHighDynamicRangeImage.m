function toneMapHighDynamicRangeImage

    % Set the root directory
    [rootDir, ~] = fileparts(which(mfilename));
    addpath(genpath(rootDir));
    
    % Select the high dynamic range image to import
    imageName = 'Balls.exr';
    inputImageFolder = 'inputEXRImages';
    theRGBSettingsImage = importImage(rootDir, inputImageFolder, imageName);
    
    % The tonemapping factor (try different values to see the effect)
    alpha = 0.04;
    
    % Assume theRGBSettingsImage is corrected for a display gamma of 2.0, i.e. 
    % that it is raised to the power of 1/gamma, so undo this to get
    % theRGBPrimariesImage (linear RGB)
    gamma = 2.5;
    theRGBPrimariesImage = theRGBSettingsImage .^ gamma;
    
    % Load the display on which to present the high dynamic range image
    load('resources/display.mat', 'display');
  
    % Compute display's gun luminances and the XYZ->RGB matrix
    [displayPrimaryLuminances, displayXYZtoRGB] = displayParams(display.spd, display.wave);
    
    % Compute the chroma and luminance components
    [theChromaticitiesVector, theLuminancesVector, nCols,mRows] = chromaLumaChannelsFromRGBPrimaries(theRGBPrimariesImage, displayXYZtoRGB);

    % Tone map theLuminancesVector
    theToneMappedLuminancesVector = toneMapLuminance(theLuminancesVector, alpha, displayPrimaryLuminances);
    
    % Compute the primary values from the tonemapped luminances, and chroma channels
    theRGBPrimariesToneMappedImage = RGBPrimariesFromChromaLumaChannels(theChromaticitiesVector, theToneMappedLuminancesVector, displayXYZtoRGB, nCols,mRows);

    % Compute the RGB settings of the tonemapped image by applying the inverse gamma
    theRGBSettingsToneMappedImage = theRGBPrimariesToneMappedImage .^ (1/gamma);
    
    % Display original and tone mapped image
    figure(1); clf;
    subplot(1,2,1);
    imshow(theRGBSettingsImage)
    title('no tone map');
    
    subplot(1,2,2);
    imshow(theRGBSettingsToneMappedImage);
    title(sprintf('tone mapped, alpha = %2.3f', alpha));
end


function theRGBPrimariesImage = RGBPrimariesFromChromaLumaChannels(theChromaticitiesVector, theLuminancesVector, displayXYZtoRGB, nCols,mRows)
    % Form the xyY (chroma/luma) matrix
    xyY = cat(1, theChromaticitiesVector, theLuminancesVector);
    
    % xyY to XYZ transformation (chroma/luma to XYZ tristimulus coords)
    XYZCalFormat = xyYToXYZ(xyY);
    
    % Apply the XYZ -> RGB transformation
    rgbPrimariesImageCalFormat = displayXYZtoRGB * XYZCalFormat;

    % Correct and report any negative RGB primary values
    rgbPrimariesImageCalFormat = correctNegativeRGBValues(rgbPrimariesImageCalFormat, 'negative after tone mapping');
    
    % Back to image format
    theRGBPrimariesImage = CalFormatToImage(rgbPrimariesImageCalFormat, nCols, mRows);
end

function RGBprimariesCalFormat = correctNegativeRGBValues(RGBprimariesCalFormat, message)
    % Report any negative RGB values
    for channelIndex = 1:3
        switch (channelIndex)
            case 1 
                channelName = 'R';
            case 2
                channelName = 'G';
            case 3
                channelName = 'B';
        end
        negativePrimaryPixelIndices = find(RGBprimariesCalFormat(channelIndex,:)<0);
        if (~isempty(negativePrimaryPixelIndices))
            r1 = min(RGBprimariesCalFormat(channelIndex, negativePrimaryPixelIndices));
            r2 = max(RGBprimariesCalFormat(channelIndex, negativePrimaryPixelIndices));
            fprintf('\n%07d %s pixels %s (range: [%g  %g]. Setting them to 0.', numel(negativePrimaryPixelIndices), channelName, message, r1, r2);
            RGBprimariesCalFormat(channelIndex,negativePrimaryPixelIndices) = 0;
        end
    end
    fprintf('\n');
end


function [displayLuminances, displayXYZtoRGB] = displayParams(displaySPDs, displayWavelengthAxis)
    % Load the '31 XYZ color matching functions
    load('T_xyz1931.mat', 'S_xyz1931', 'T_xyz1931');
    
    % Spline the XYZ '31 CMFs to match the displayWavelengthAxis
    XYZcolorMatchingFunctions = SplineCmf(S_xyz1931, T_xyz1931, WlsToS(displayWavelengthAxis));
    
    % One watt of light at 555 nm has luminous flux of 683 lumens.
    wattsToLumensConversionFactor = 683;

    % Compute the max luminances of the display
    displayLuminances = wattsToLumensConversionFactor * XYZcolorMatchingFunctions(2,:) * displaySPDs;
    
    % Compute the XYZ tristimulus values of the display primaries
    displayXYZCalFormat = wattsToLumensConversionFactor * XYZcolorMatchingFunctions * displaySPDs;

    % Compute the display's XYZ -> RGB matrix
    displayPrimariesCalFormat = [...
        1 0 0; ...  % RGB primaries leading corresponding to the R channel SPD (i.e., displaySPDs(1,:)
        0 1 0; ...  % RGB primaries leading corresponding to the G channel SPD (i.e., displaySPDs(2,:)
        0 0 1 ...   % RGB primaries leading corresponding to the B channel SPD (i.e., displaySPDs(3,:)
    ];
    displayXYZtoRGB = (displayXYZCalFormat' \ displayPrimariesCalFormat')';
end

function theToneMappedLuminancesVector = toneMapLuminance(theLuminancesVector, alpha, displayPrimaryLuminances)
    % Compute the log-average luminance (image key)
    delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with zero luminance
    theKey = exp((1/numel(theLuminancesVector))*sum(log(theLuminancesVector + delta)));
    
    % Compute the scaled luminances vector
    theScaledLuminancesVector = alpha / theKey * theLuminancesVector;
    
    % Compress high luminances (tonemapping)
    peakLuminance = sum(displayPrimaryLuminances);
    theToneMappedLuminancesVector = peakLuminance * theScaledLuminancesVector ./ (1.0+theScaledLuminancesVector);
end

function [theChromaticitiesVector, theLuminancesVector, nCols,mRows] = chromaLumaChannelsFromRGBPrimaries(theRGBPrimariesImage, displayXYZtoRGB)
    % Transform the RGB image [Rows x Cols x 3] into a [3 x N] matrix for faster computations
    [rgbPrimariesImageCalFormat,nCols,mRows] = ImageToCalFormat(theRGBPrimariesImage);
    
    % Correct and report any negative RGB primary values
    rgbPrimariesImageCalFormat = correctNegativeRGBValues(rgbPrimariesImageCalFormat, 'negative before tone mapping');
    
    % Apply the RGB -> XYZ transformation
    XYZCalFormat = inv(displayXYZtoRGB) * rgbPrimariesImageCalFormat;

    % XYZ to xyY transformation (XYZ tristimulus coords to chroma/luma)
    xyYCalFormat = XYZToxyY(XYZCalFormat);
    
    % Return the chromaticities and the luminances vectors
    theChromaticitiesVector = xyYCalFormat(1:2,:);
    theLuminancesVector = xyYCalFormat(3,:);
end


function theImage = importImage(rootDir, inputImageFolder, imageName)
    filenameIn = fullfile(rootDir, inputImageFolder, imageName);
    [exrImage, channelNames] = importEXRImage(filenameIn);

    % Find indices of the R, G, and B channels
    RchannelIndex = find(ismember(channelNames, 'R')==1);
    GchannelIndex = find(ismember(channelNames, 'G')==1);
    BchannelIndex = find(ismember(channelNames, 'B')==1);
    
    % Only keep the R, G, and B channels
    theImage(:,:,1) = exrImage(:,:,RchannelIndex );
    theImage(:,:,2) = exrImage(:,:,GchannelIndex );
    theImage(:,:,3) = exrImage(:,:,BchannelIndex );
end
