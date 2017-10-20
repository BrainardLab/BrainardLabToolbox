% Method to load the background and target indices of the current LUT.
function loadClut(obj, bgSettings, targetSettings, useBitsPP)

        % Generate stimulus texture
        stim = ones(obj.options.boxSize,obj.options.boxSize,3);
        stim(:,:,1) = targetSettings(1);
        stim(:,:,2) = targetSettings(2);
        stim(:,:,3) = targetSettings(3);
        stimTexture = mglCreateTexture(stim*255);
        
        % Generate identity LUT
        lutSteps = obj.screenInfo.gammaTableLength;
        deltas = (0:(lutSteps-1))/(lutSteps-1);
        gammaTable.redTable(1:lutSteps)   = deltas;
        gammaTable.greenTable(1:lutSteps) = deltas;
        gammaTable.blueTable(1:lutSteps)  = deltas;

        % Clear screen with background color
        mglClearScreen(bgSettings);
        
        % Blit stimulus
        mglBltTexture(stimTexture,[obj.calibrationRect.x0, obj.calibrationRect.y0],0,0);
        
        % Set gamma LUT
        mglSetGammaTable(gammaTable.redTable, gammaTable.greenTable, gammaTable.blueTable);
        
        % Present stimulus
        mglFlush();
end
