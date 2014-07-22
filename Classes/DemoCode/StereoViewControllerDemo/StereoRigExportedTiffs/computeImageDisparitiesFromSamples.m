function computeImageDisparitiesFromSamples

%     leftImFileName  = fullfile('StereoRigExportedTiffs', 'NCT1C45-L.tif');
%     rightImFileName = fullfile('StereoRigExportedTiffs', 'NCT1C45-R.tif');
%     
%    
%     
  %  leftImFileName  = fullfile('StereoRigExportedTiffs', 'TestCBT1C12Big-L.tif');
  %  rightImFileName = fullfile('StereoRigExportedTiffs', 'TestCBT1C12Big-R.tif');
   
    leftImFileName  = fullfile('StereoRigExportedTiffs', 'TestCBT1C12-L.tif');
    rightImFileName = fullfile('StereoRigExportedTiffs', 'TestCBT1C12-R.tif');
%     
%     leftImFileName  = fullfile('StereoRigExportedTiffs', 'AchromForcedChoiceScene-L.tif');
%     rightImFileName = fullfile('StereoRigExportedTiffs', 'AchromForcedChoiceScene-R.tif');
%     

    stereoPairNames = {leftImFileName, leftImFileName};
    
    leftImage = imread(leftImFileName);
    rightImage = imread(rightImFileName);
    
    
    virtualSceneWidthInCm      = 51.7988;
    virtualSceneHeightInCm     = 32.3618;
    Zmax  = 76.4;  
        
    imageWidth = size(leftImage,2);
    imageHeight = size(leftImage,1);
    
    xaxis = ([1:imageWidth]-imageWidth/2)/(imageWidth/2)*virtualSceneWidthInCm;
    yaxis = ([1:imageHeight]-imageHeight/2)/(imageHeight/2)*virtualSceneHeightInCm;
    
    figure(1);
    clf;
    subplot(2,2,1);
    imagesc(xaxis, yaxis, leftImage);
    hold on
    
    axis 'equal'
    axis 'tight'
    
    
    subplot(2,2,3);
    imagesc(xaxis, yaxis, rightImage);
    hold on
    
    axis 'equal'
    axis 'tight'
    
   
    
    
    inputPoints = input('number of points: ');
    subplot(2,2,1);
    [xLeftScreen, yLeftScreen] = ginput(inputPoints)
    xLeftScreen = xLeftScreen - XSHIFT;
    
    subplot(2,2,3);
    [xRightScreen, yRightScreen] = ginput(inputPoints)
    xRightScreen = xRightScreen + XSHIFT;
    
    Zmax = 76.4;
    
    for k = 1: inputPoints
        
        [xLeftScreen(k) xRightScreen(k)]
        
        [Xi(k), Yi(k), Zi(k)] = ...
            StereoViewController.screenCoordsToVirtualXYZposition( xLeftScreen(k), ...
            yLeftScreen(k), xRightScreen(k), yRightScreen(k), Zmax, 6.4);
        
        subplot(2,2,1);
        hold on
        
    
        if k == 1
            color = [1 0 0];
        elseif (k == 2)
            color = [0 1 0];
        elseif (k == 3)
            color = [0 0 1];
        elseif (k == 4)
            color = [1 0 1];
        elseif (k == 5)
            color = [0 0.5 1];
        elseif (k == 6)
            color = [1 0.6 0];
        elseif (k == 7)
            color = [0.5 0.5 0.5];
        end
        
        plot(xLeftScreen(k)+ XSHIFT, yLeftScreen(k), 'ko', 'MarkerFaceColor', color, 'MarkerSize', 10);
        
        
        subplot(2,2,3);
        hold on
        if k == 1
            color = [1 0 0];
        elseif (k == 2)
            color = [0 1 0];
        elseif (k == 3)
            color = [0 0 1];
        elseif (k == 4)
            color = [1 0 1];
        elseif (k == 5)
            color = [0 0.5 1];
        elseif (k == 6)
            color = [1 0.6 0];
        elseif (k == 7)
            color = [0.5 0.5 0.5];
        end
        
        plot(xRightScreen(k)- XSHIFT, yRightScreen(k), 'ko', 'MarkerFaceColor', color, 'MarkerSize', 10);
        
        
    end
    
    
    subplot(2,2,1)
    xlabel('screen x-axis (cm)');
    ylabel('screen y-axis (cm)');
    title ('left screen');
    
    subplot(2,2,3)
    xlabel('screen x-axis (cm)');
    ylabel('screen y-axis (cm)');
    title ('right screen');
    
    subplot(2,2, [2 4])
    hold on;
    
    plot([-30 30], Zmax*[1 1], 'k-', 'LineWidth', 5, 'Color', [0.5 0.5 0.5]);
    plot(-3.2, 0, 'ko', 'MarkerFaceColor', [0 0 0], 'MarkerSize', 16);
    plot(3.2, 0, 'ko', 'MarkerFaceColor', [0 0 0], 'MarkerSize', 16);
    
    for k = 1:inputPoints
        if k == 1
            color = [1 0 0];
        elseif (k == 2)
            color = [0 1 0];
        elseif (k == 3)
            color = [0 0 1];
        elseif (k == 4)
            color = [1 0 1];
        elseif (k == 5)
            color = [0 0.5 1];
        elseif (k == 6)
            color = [1 0.6 0];
        elseif (k == 7)
            color = [0.5 0.5 0.5];
        end
        plot(Xi(k), Zi(k), 'ko', 'MarkerFaceColor', color, 'MarkerSize', 10);
        plot(xLeftScreen(k), Zmax, 'ks', 'MarkerFaceColor', color, 'MarkerSize', 10);
        plot(xRightScreen(k), Zmax, 'ks', 'MarkerFaceColor', color, 'MarkerSize', 10);
        plot([-3.2 xLeftScreen(k)], [0 Zmax], 'k-', 'Color', color, 'MarkerSize', 10); 
        plot([3.2 xRightScreen(k)], [0 Zmax], 'k-', 'Color', color, 'MarkerSize', 10); 
    end
    set(gca, 'Xlim', [-30 30], 'YLim', [0 100]);
    xlabel('real world x-axis (cm)');
    ylabel('real world z-axis (cm)');
    set(gca, 'Color', [0.9 0.9 0.9]);
    title('top view');
    box on
    
end