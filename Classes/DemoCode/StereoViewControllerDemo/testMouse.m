function testMouse

    rightScreenConfig = struct;
    rightScreenConfig.screenSizePixel(1) = 1920;
    rightScreenConfig.screenSizePixel(2) = 1200;
    rightScreenConfig.screenSizeMM(1) = 48.18*10;
    rightScreenConfig.screenSizeMM(2) = 36.13*10;
    
    rightScreenConfig 
    
    cube = imread('/Users/nicolas/Downloads/RightTestImage.tiff');
    
    stereoPair = struct;
    stereoPair.imageData.right = cube;
    stereoPair.imageSize = [48.18 36.13];
    
    imageRegion = struct;
    imageRegion.excludePerimeterPoints = [560 153; 256 295; 259 622; 551 838; 815 646; 882 324; 560 153];
    imageRegion.includePerimeterPoints = [0 84; 960 84; 960 877; 0 877; 0 84 ];
    imageRegion.parentImageWidthInPixels  = size(stereoPair.imageData.right,2);
    imageRegion.parentImageHeightInPixels = size(stereoPair.imageData.right,1);
    imageRegion.parentImageWidthInCm      = stereoPair.imageSize(1);  
    imageRegion.parentImageHeightInCm     = stereoPair.imageSize(2);
    
    
    mousePositionsToGenerate = 2000;   
    [mouseXpos, mouseYpos] = StereoViewController.generateRandomInitialMousePositionBasedOnImageRegion(imageRegion, rightScreenConfig , mousePositionsToGenerate);
    
    figure(1);
    clf;
    image([1:imageRegion.parentImageWidthInPixels], [1:imageRegion.parentImageHeightInPixels], cube(:,:,1:3));
    hold on;
    plot(mouseXpos, mouseYpos,'ko', 'MarkerFaceColor', [0.99 0.1 0.4]);
    drawnow;
    
end
