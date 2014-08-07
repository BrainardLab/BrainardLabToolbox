function updateBackgroundAndTarget(obj, bgSettings, targetSettings, useBitsPP)

    if (useBitsPP)
        error('The PsychImaging calibrator does not support bits++ yet');
    end
    
    try
        if (~isempty(obj.texturePointers))
            %fprintf('\nClosing existing textures (%d).\n', numel(obj.texturePointers));
            Screen('Close', obj.texturePointers);
            obj.texturePointers = [];
        end

        
        optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
        
        % Generate background texture
        backgroundRGBstimMatrix = zeros(obj.screenRect(4), obj.screenRect(3), 3);
        for k = 1:3
            backgroundRGBstimMatrix(:,:,k) = bgSettings(k);
        end
        backgroundTexturePtr = Screen('MakeTexture', obj.masterWindowPtr, backgroundRGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);
        % update the list of existing texture pointers
        obj.texturePointers = [obj.texturePointers backgroundTexturePtr];
        
        
        % Generate target texture
        targetRGBstimMatrix = zeros(obj.calibrationRect.size(2) ,obj.calibrationRect.size(1),3);
        for k = 1:3
            targetRGBstimMatrix(:,:,k) = targetSettings(k);
        end
        targetTexturePtr = Screen('MakeTexture', obj.masterWindowPtr, targetRGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);
        
        % update the list of existing texture pointers
        obj.texturePointers = [obj.texturePointers targetTexturePtr ];

        % Draw Background texture
        sourceRect = []; destRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
        Screen('DrawTexture', obj.masterWindowPtr, backgroundTexturePtr, sourceRect, destRect, rotationAngle, filterMode, globalAlpha);       % background
        
        % Draw Target texture
        targetDestRect = CenterRectOnPointd(...
            [0 0 obj.calibrationRect.size(1) obj.calibrationRect.size(2)], ...
            obj.calibrationRect.x0, obj.calibrationRect.y0...
            );
        Screen('DrawTexture', obj.masterWindowPtr, targetTexturePtr, sourceRect, targetDestRect, rotationAngle, filterMode, globalAlpha);     % foreground

        % Flip master display
        Screen('Flip', obj.masterWindowPtr);  
    
    catch err
        sca;
        rethrow(err);
    end
    
end
