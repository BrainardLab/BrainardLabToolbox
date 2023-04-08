function makeCollage(collageFormat, collageRecipe)
% This function composites multiple TIFF images into a single PNG file.
%
% Description:
%    Allows compositing of TIFF images into a single PNG file.
%
%    Can also do PDF with a little code tweaking, but that seems to crash
%    for large pixels sizes.
%
%    Because this routine rasterizes the TIFF images, it doesn't preserve
%    vector art and isn't useful for production, but it does save some time
%    brining together exploratory data analyses.
%
% Inputs:
%   collageFormat: a structure containing the following fields:
%     - pixelsTall: the height of the output PNG in pixels
%     - pixelsWide: the width of the output PNG in pixels
%     - backgroundRGB: the RGB values of the background color in the range [0, 1]
%     - pdfFileName: the filename of the output PNG file
%
%   collageRecipe: a cell array where each element is a structure containing the following fields:
%     - imageDir: the directory containing the input image file
%     - imageFileName: the name of the input image file
%     - destinationWidthPixels: the width of the scaled image in the collage
%     - destinationXYposPixels: the X and Y coordinates of the center of the scaled image in the collage
%     - alpha: the transparency of the image, a value in the range [0, 1]

    % Background
    collageImage = bsxfun(@plus, zeros(collageFormat.pixelsTall, collageFormat.pixelsWide, 3, 'single'), reshape(collageFormat.backgroundRGB,[1 1 3]));

    for iPart = 1:numel(collageRecipe)
        d = collageRecipe{iPart};
        imageFile = fullfile(d.imageDir, d.imageFileName);
        [theRGBData, alphaChannel] = importGraphic(imageFile);

        sourceRows = size(theRGBData,1);
        sourceCols = size(theRGBData,2);
        aspectRatio = sourceRows/sourceCols;

        xDest = 1:d.destinationWidthPixels;
        yDest = 1:round(d.destinationWidthPixels*aspectRatio);
        destinationRows = numel(yDest);
        destinationCols = numel(xDest);
        
        xx = d.destinationXYposPixels(1) - round(mean(xDest)) + xDest;
        yy = d.destinationXYposPixels(2) - round(mean(yDest)) + yDest;

        idx = find((xx>=1)&(xx<=collageFormat.pixelsWide));
        xx = xx(idx);
        xxx = 1:destinationCols;
        xxx = xxx(idx);

        idx = find((yy>=1)&(yy<=collageFormat.pixelsTall));
        yy = yy(idx);
        yyy = 1:destinationRows;
        yyy = yyy(idx);

        destinationData = imresize(theRGBData, [destinationRows destinationCols]);

        if (~isempty(alphaChannel))
            alphaChannel = imresize(alphaChannel, [destinationRows destinationCols]);
            for iChannel = 1:3
                destinationData(yyy,xxx,iChannel) = destinationData(yyy,xxx,iChannel).* alphaChannel(yyy,xxx) + ...
                    collageImage(yy,xx,iChannel) .* (1-alphaChannel(yyy,xxx));

                collageImage(yy,xx,iChannel) = (1-d.alpha)*collageImage(yy,xx,iChannel) + ...
                      d.alpha * single(destinationData(yyy,xxx,iChannel));
            end
        else
            collageImage(yy,xx,:) = (1-d.alpha)*collageImage(yy,xx,:) + ...
                d.alpha * single(destinationData(yyy,xxx,:));
        end
    end

    % Export to PNG
    fprintf('\nExporting to PNG. Please wait ....');
    hFig = figure(100);
    set(hFig, 'Position', [10 10 round(size(collageImage,2)) round(size(collageImage,1))]);
    ax = subplot('Position', [0 0 1 1]);
    imagesc(ax,collageImage)
    axis(ax, 'image');
    set(ax, 'XTick', [], 'YTick',[]);
    drawnow;
    NicePlot.exportFigToPNG(collageFormat.pdfFileName, hFig, 300);
    fprintf('Done !\n');
end


function [theRGBData, alphaChannel] = importGraphic(imageFile)
    % Import the graphic
    imageData = importdata(imageFile);
    theRGBData = single(imageData(:,:,1:3))/255.0;
    
    alphaChannel = [];
    if (size(imageData,3) == 4)
       alphaChannel = single(imageData(:,:,4))/255.0;
    end
end
