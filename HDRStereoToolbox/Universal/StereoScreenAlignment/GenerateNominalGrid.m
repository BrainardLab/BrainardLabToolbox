function [Xnominal,Ynominal] = GenerateNominalGrid(nodeSpacingInPixels, screenWidth, screenHeight)
    % Generate calibration grid
    xNodesNum = screenWidth/nodeSpacingInPixels + 1;
    yNodesNum = screenHeight/nodeSpacingInPixels + 1;
        
    xNodeSeparation = round(screenWidth/(xNodesNum-1));
    yNodeSeparation = round(screenHeight/(yNodesNum-1));
    
    % compute x,y sampling
    xGridCoords = (0:xNodeSeparation:screenWidth);
    yGridCoords = (0:yNodeSeparation:screenHeight);
        
    % compute the calibration meshgrid
    [Xnominal,Ynominal] = meshgrid(xGridCoords, yGridCoords);
end