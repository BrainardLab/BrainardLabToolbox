function testEXR

    % Collection of EXR images to test
    testImagesShort = {...
       'Gamut' ...                      % CIE chromaticity diagram
       'MitsubaCylinder_31channels' ... % 31-band blender image
        };
    
    testImagesLong = {...
       'StillLife' ...                  % very high dynanic range
       'Gamut' ...                      % CIE chromaticity diagram
       'Balls_RGB' ...                  % specular reflectances
       'Flower_RGB' ...                 % a flower image
       'MitsubaSphere_31channels' ...   % 31-band sphere
       'MitsubaCylinder_31channels' ... % 31-band blender image
       'LightField' ...                 % 31-band light-field image
        };
    
    testImages = testImagesShort;
    % Determine the root directory
    [rootDir, ~] = fileparts(which(mfilename));
    
    % Go !
    for imIndex = 1:numel(testImages)
        testImage = testImages{imIndex};
        testEXRImportExport(testImage, imIndex, rootDir);
    end
end

function testEXRImportExport(testImage, imIndex, exrImageRootDir)

    % Set image folders
    inputImageFolder = 'inputEXRImages';
    outputImageFolder = 'outputEXRImages';
    
    % Select tone mapping gain to apply to each image during visualization
    switch (testImage)
        case 'StillLife'
            imageName = 'StillLife.exr';
            toneMapGain = 40;
        case 'Balls_RGB'
            imageName = 'Balls.exr';
            toneMapGain = 5;
        case 'Flower_RGB'
            imageName = 'Rec709.exr';
            toneMapGain = 2;
        case 'Gamut'
            imageName = 'WideColorGamut.exr';
            toneMapGain = 2;
        case 'MitsubaSphere_31channels'
            imageName = 'TestSphereMitsuba.exr';
            toneMapGain = 2;
        case 'MitsubaCylinder_31channels'
            imageName = 'Demo1-001.exr';
            toneMapGain = 1;
        case 'LightField'
            imageName = 'LightFieldSphere-001.exr';
            toneMapGain = 1;
    end
    
    % Set input and output filenames
    filenameIn = fullfile(exrImageRootDir, inputImageFolder, imageName);
    filenameOut = strrep(fullfile(exrImageRootDir, outputImageFolder, imageName),'.exr', '_output.exr');
    
    % Generate output image folder if it does not exist
    [outputImageFolder, ~] = fileparts(filenameOut);
    if (~isdir(outputImageFolder))
        mkdir(outputImageFolder);
    end
    
    % Import the EXR image
    [inputEXRimage, inputEXRchannelNames] = importEXRImage(filenameIn);

    % Display the EXR image
    figNum = imIndex;
    displayEXRimage(figNum, sprintf('%s-input',filenameIn), inputEXRimage, inputEXRchannelNames, toneMapGain, []);
    
    % Alter the EXR image (up/down flipping of the central pixels)
    [outputEXRimage, scrambledROI] = scrambleEXRImage(inputEXRimage);
    
    % Typecast the altered EXR image
    if (~isa(outputEXRimage, 'double'))
        warning('This image is not a double, automatic cast to double for saving it as EXR.');
        outputEXRImage = double(outputEXRimage);
    end
            
    % Set the channel names for the output EXR image
    outputEXRchannelNames = cell(1, numel(inputEXRchannelNames));
    for chIndex = 1:numel(inputEXRchannelNames)
        outputEXRchannelNames{chIndex} = sprintf('%s', inputEXRchannelNames{chIndex});
    end

    % Export the EXR image
    exportEXRImage(filenameOut, outputEXRimage, outputEXRchannelNames);
    fprintf('Scrambled EXR image saved in %s\n', filenameOut);
    
    % Import and display the saved image
    [outputEXRimage, outputEXRchannelNames] = importEXRImage(filenameOut);
    figNum = imIndex+1000;
    displayEXRimage(figNum, sprintf('%s-scrambled',filenameIn), outputEXRimage, outputEXRchannelNames, toneMapGain, scrambledROI);
    
    % Compare input and output EXRimages
    figNum = imIndex+2000;
    compareEXRimages(figNum, sprintf('%s-diff',filenameIn), inputEXRimage,outputEXRimage, inputEXRchannelNames, scrambledROI);
end

function [outputEXRImage, scrambledROI] = scrambleEXRImage(inputEXRimage)
    outputEXRImage = inputEXRimage;
    mRows = size(outputEXRImage,1);
    nCols = size(outputEXRImage,2);
    mn = min([mRows nCols]);
    mm = floor(mRows/2) + [-floor(mn/3):floor(mn/3)];
    mm2 = mm(end:-1:1);
    nn = floor(nCols/2) + [-floor(mn/3):floor(mn/3)];
    for chIndex = 1:size(outputEXRImage,3)
        outputEXRImage(mm,nn,chIndex) = outputEXRImage(mm2,nn,chIndex);
    end
    scrambledROI.x = [min(nn) max(nn) max(nn) min(nn) min(nn)];
    scrambledROI.y = [min(mm) min(mm) max(mm) max(mm) min(mm)];
end

function compareEXRimages(figNum, figureName, inputEXRImage,outputEXRImage, inputEXRchannelNames, scrambledROI)
    
    % find pixel indices with scrambled data
    x = 1:size(inputEXRImage,2);
    y = 1:size(inputEXRImage,1);
    [X,Y] = meshgrid(x,y);
    X = X(:); Y = Y(:);
    indices = find((X>=min(scrambledROI.x) & X<=max(scrambledROI.x)) & ...
                  (Y>=min(scrambledROI.y) & Y<=max(scrambledROI.y)));
    
    hFig = figure(figNum); clf;
    set(hFig, 'Color', [0.1 0.1 0.1], 'Name', figureName, ...
        'Position', [10+30*rand(1,1), 10+50*rand(1,1), 1500, 900]);
    channelsNum = size(inputEXRImage,3);
    for k = 1: channelsNum 
        if (channelsNum > 30)
            subplot(5,7,k);
        elseif (channelsNum > 20)
            subplot(4,6,k);
        elseif (channelsNum > 6)
            subplot(3,5,k);
        else 
            subplot(2,3,k);
        end
        
        inputImageChannelSlice = squeeze(inputEXRImage(:,:,k));
        outputImageChannelSlice = squeeze(outputEXRImage(:,:,k));
        
        % Do not include pixels within the scrambled version
        inputImageChannelSlice(indices) = nan;
        outputImageChannelSlice(indices) = nan;
        
        diffImage = inputImageChannelSlice-outputImageChannelSlice;
        range = max([0.01 max(abs(diffImage(:)))]) * [-1 1];
        imagesc(diffImage, range); 
        if (~isempty(scrambledROI))
            hold on;
            plot(scrambledROI.x, scrambledROI.y, 'r-');
            hold off;
        end
        hT = title(sprintf('diff (%s)', inputEXRchannelNames{k}));
        hT.Color = [0.8 1.0 1.0];
        
        axis 'image';
        set(gca, 'XTick', [], 'YTick', [], 'FontSize', 14);
        colormap(gray);
        hb = colorbar();
        hb.Color = [0 1 1];
    end
        
end

function displayEXRimage(figNum, figureName, inputEXRimage, inputEXRchannelNames, toneMapGain, scrambledROI)
    
    % Tonemap
    img = toneMap(inputEXRimage, toneMapGain);
    
    % Display
    hFig = figure(figNum); clf;
    set(hFig, 'Color', [0.1 0.1 0.1], 'Name', figureName, ...
        'Position', [10+30*rand(1,1), 10+50*rand(1,1), 1500, 900]);
    channelsNum = size(img,3);
    for k = 1: channelsNum 
        if (channelsNum > 30)
            subplot(5,7,k);
        elseif (channelsNum > 20)
            subplot(4,6,k);
        elseif (channelsNum > 6)
            subplot(3,5,k);
        else 
            subplot(2,3,k);
        end
        
        imgChannelSlice = squeeze(img(:,:,k));
        imagesc(imgChannelSlice, [0 1]); 
        if (~isempty(scrambledROI))
            hold on;
            plot(scrambledROI.x, scrambledROI.y, 'r-');
            hold off;
        end
        
        hT = title(sprintf('%s', inputEXRchannelNames{k}));
        hT.Color = [0.8 1.0 1.0];
        
        axis 'image';
        set(gca, 'XTick', [], 'YTick', [], 'FontSize', 14);
        colormap(gray);
        
        if (channelsNum == 3)
            subplot(2,3, channelsNum+1);
            imshow(img(:,:,3:-1:1));
            axis 'image';
            set(gca, 'XTick', [], 'YTick', [], 'FontSize', 14);
            hT = title('RGB image');
            hT.Color = [0.8 1.0 1.0];
        end
        
        if (channelsNum == 4)
            subplot(2,3, channelsNum+1);
            imshow(img(:,:,4:-1:2));
            axis 'image';
            set(gca, 'XTick', [], 'YTick', [], 'FontSize', 14);
            hT = title('RGB image');
            hT.Color = [0.8 1.0 1.0];
        end
        
    end
end

function img = toneMap(img, gain)
    img(img<0) = 0;
    img = img / max(img(:));
    img = gain * img .^ 0.5;
    img(img>1) = 1;
end

