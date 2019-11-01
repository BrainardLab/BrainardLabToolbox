function toneMapHighDynamicRangeImage
% Tonemap multi-channel EXR images
% 
% Syntax:
%   toneMapHighDynamicRangeImage();
%
% Description:
%    Imports and visualizes raw EXR images. Tonemaps the luminance
%    channel using a global Reinhardt tone mapping method
%    and visualizes the tone-mapped image.
%
% Tonemapping reference:
%    "Photographic Tone Reproduction for Digital Images", by Reinhardt,
%    Stark, Shirley and Ferwerda
%
% History:
% 11/1/2019   Nicolas P. Cottaris   Wrote it
%

    % Set the root directory
    [rootDir, ~] = fileparts(which(mfilename));
    addpath(genpath(rootDir));
    
    % Select the high dynamic range image to import
    imageName = 'Rec709.exr'; % 'WideColorGamut.exr' % 'Balls.exr'; % 'Rec709.exr'; % 'Balls.exr';
    inputImageFolder = 'inputEXRImages';
    theRGBSettingsImage = importImage(rootDir, inputImageFolder, imageName);
    
    % One watt of light at 555 nm has luminous flux of 683 lumens.
    wattsToLumensConversionFactor = 683;
    
    % The tonemapping factor (try different values to see the effect)
    alpha = 0.07;
    
    % Assume theRGBSettingsImage is corrected for a display gamma of 2.0, i.e. 
    % that it is raised to the power of 1/gamma, so undo this to get
    % theRGBPrimariesImage (linear RGB).
    gamma = 2;
    theRGBPrimariesImage = theRGBSettingsImage .^ gamma;
    
    % Load the display on which to present the high dynamic range image
    load('resources/display.mat', 'display');
  
    % Compute display's gun luminances and the XYZ->RGB matrix
    [displayPrimaryLuminances, displayXYZtoRGB] = displayParams(display.spd, display.wave, wattsToLumensConversionFactor);
    
    % Compute the chroma and luminance components
    [theChromaticitiesVector, theLuminancesVector, nCols,mRows] = chromaLumaChannelsFromRGBPrimaries(theRGBPrimariesImage, displayXYZtoRGB, wattsToLumensConversionFactor);
    maxInputLuminance = max(theLuminancesVector)
    
    % Tone map theLuminancesVector
    theToneMappedLuminancesVector = toneMapLuminance(theLuminancesVector, alpha, displayPrimaryLuminances, maxInputLuminance);
    maxToneMappedLuminance = max(theToneMappedLuminancesVector)
    
    % Compute the primary values from the tonemapped luminances, and chroma channels
    theRGBPrimariesToneMappedImage = RGBPrimariesFromChromaLumaChannels(theChromaticitiesVector, theToneMappedLuminancesVector, displayXYZtoRGB, nCols,mRows, wattsToLumensConversionFactor);

    % Compute the RGB settings of the tonemapped image by applying the inverse gamma
    theRGBSettingsToneMappedImage = theRGBPrimariesToneMappedImage .^ (1/gamma);
    
    % Display original and tone mapped image
    figure(1); clf;
    subplot(3,3,1);
    imshow(theRGBSettingsImage, [0 1])
    title('no tone map');
    
    subplot(3,3,4);
    imshow(theRGBSettingsToneMappedImage, [0 1]);
    title(sprintf('tone mapped, alpha = %2.3f', alpha));
    
    subplot(3,3,[2 3 5 6]);
    lumRange = [0 max([max(theLuminancesVector) max(theToneMappedLuminancesVector)])];
    
    yyaxis left
    lumBins = linspace(lumRange(1), lumRange(2), 50);
    if (lumRange(2) < 1)
        lumTicks = 0.1;
    elseif (lumRange(2) < 5)
        lumTicks = 0.25;
    elseif (lumRange(2) < 10)
        lumTicks = 1;
    elseif (lumRange(2) < 50)
        lumTicks = 5;
    elseif (lumRange(2) < 100)
        lumTicks = 10;
    elseif (lumRange(2) < 500)
        lumTicks = 50;
    else
        lumTicks = 100;
    end
    h1 = histogram(theLuminancesVector, lumBins); hold on;
    h2 = histogram(theToneMappedLuminancesVector, lumBins);
    h1.FaceColor = [0.0 0 0];
    h2.FaceColor = [0.9 0.2 0.1];
    set(gca, 'XLim', lumRange,  'XTick', 0:lumTicks:lumRange(2), 'YLim', [0.9 10000], 'YTick', [1 10 100 1000 10000], 'YTickLabel', {'1', '10', '100', '1000', '10000'},'YScale', 'log', 'YColor', 'k');
    ylabel('pixels num');
    
    yyaxis right
    plot(theLuminancesVector,theToneMappedLuminancesVector, 'k.');
    
    set(gca, 'XLim', lumRange, 'YLim', lumRange, 'XTick', 0:lumTicks:lumRange(2), 'YTick', 0:lumTicks:lumRange(2), 'YColor', 'r');
    grid on
    xlabel('input image luminances (cd/m2)');
    ylabel('tonemapped image luminances (cd/m2)');
    
    subplot(3,3,7)
    rIn  = theRGBPrimariesImage(:,:,1);
    rOut = theRGBPrimariesToneMappedImage(:,:,1);
    rRange = [0 max([max(rIn(:)) max(rOut(:))])];
    plot(rIn(:), rOut(:), 'r.');
    set(gca, 'XLim', rRange, 'YLim', rRange);
    axis 'square';
    xlabel('R no tone map'); ylabel('R tone mapped');
    
    subplot(3,3,8)
    rIn  = theRGBPrimariesImage(:,:,2);
    rOut = theRGBPrimariesToneMappedImage(:,:,2);
    rRange = [0 max([max(rIn(:)) max(rOut(:))])];
    plot(rIn(:), rOut(:), 'g.');
    set(gca, 'XLim', rRange, 'YLim', rRange);
    axis 'square';
    xlabel('G no tone map'); ylabel('G tone mapped');
    
    subplot(3,3,9)
    rIn  = theRGBPrimariesImage(:,:,3);
    rOut = theRGBPrimariesToneMappedImage(:,:,3);
    rRange = [0 max([max(rIn(:)) max(rOut(:))])];
    plot(rIn(:), rOut(:), 'b.');
    set(gca, 'XLim', rRange, 'YLim', rRange);
    axis 'square';
    xlabel('B no tone map'); ylabel('B tone mapped');
    
end


function theRGBPrimariesImage = RGBPrimariesFromChromaLumaChannels(theChromaticitiesVector, theLuminancesVector, displayXYZtoRGB, nCols,mRows, wattsToLumensConversionFactor)
    % Form the xyY (chroma/luma) matrix
    xyY = cat(1, theChromaticitiesVector, theLuminancesVector/wattsToLumensConversionFactor);
    
    % xyY to XYZ transformation (chroma/luma to XYZ tristimulus coords)
    XYZCalFormat = xyYToXYZ(xyY);
    
    % Apply the XYZ -> RGB transformation
    rgbPrimariesImageCalFormat = displayXYZtoRGB * XYZCalFormat;
    
    % Clip at 1.
    rgbPrimariesImageCalFormat(rgbPrimariesImageCalFormat>1) = 1;

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


function [displayLuminances, displayXYZtoRGB] = displayParams(displaySPDs, displayWavelengthAxis, wattsToLumensConversionFactor)
    % Load the '31 XYZ color matching functions
    load('T_xyz1931.mat', 'S_xyz1931', 'T_xyz1931');
    
    % Spline the XYZ '31 CMFs to match the displayWavelengthAxis
    XYZcolorMatchingFunctions = SplineCmf(S_xyz1931, T_xyz1931, WlsToS(displayWavelengthAxis));

    % Compute the max luminances of the display
    displayLuminances = wattsToLumensConversionFactor * XYZcolorMatchingFunctions(2,:) * displaySPDs;
    
    % Compute the XYZ tristimulus values of the display primaries
    displayXYZCalFormat = XYZcolorMatchingFunctions * displaySPDs;

    % Compute the display's XYZ -> RGB matrix
    displayPrimariesCalFormat = [...
        1 0 0; ...  % RGB primaries leading corresponding to the R channel SPD (i.e., displaySPDs(1,:)
        0 1 0; ...  % RGB primaries leading corresponding to the G channel SPD (i.e., displaySPDs(2,:)
        0 0 1 ...   % RGB primaries leading corresponding to the B channel SPD (i.e., displaySPDs(3,:)
    ];
    displayXYZtoRGB = (displayXYZCalFormat' \ displayPrimariesCalFormat')';
end

function theToneMappedLuminancesVector = toneMapLuminance(theLuminancesVector, alpha, displayPrimaryLuminances, maxInputLuminance)
    % Compute the log-average luminance (image key)
    delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with zero luminance
    theKey = exp((1/numel(theLuminancesVector))*sum(log(theLuminancesVector + delta)));
    
    % Compute the scaled luminances vector
    theScaledLuminancesVector = alpha / theKey * theLuminancesVector;
    
    % Compress high luminances (tonemapping)
    peakLuminance = maxInputLuminance; % sum(displayPrimaryLuminances);
    theToneMappedLuminancesVector = peakLuminance * theScaledLuminancesVector ./ (1.0+theScaledLuminancesVector);
end

function [theChromaticitiesVector, theLuminancesVector, nCols,mRows] = chromaLumaChannelsFromRGBPrimaries(theRGBPrimariesImage, displayXYZtoRGB, wattsToLumensConversionFactor)
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
    theLuminancesVector = xyYCalFormat(3,:)*wattsToLumensConversionFactor;
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
    
    theImage = theImage/max(theImage(:));
end
