function display3Rects(obj, stim1, stim2, stim3, stim1Rect, stim2Rect, stim3Rect, ditherOffsets1, ditherOffsets2, ditherOffsets3)

    if (obj.displayTemporalDither ~= 4)
       error('This function is to be used only for 4-frame temporal dithering mode'); 
    end
    
    try
        if (~isempty(obj.texturePointers))
            fprintf('\nClosing existing textures (%d).\n', numel(texturePointers));
            Screen('Close', obj.texturePointers);
            obj.texturePointers = [];
        end
        optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
        
        for subframe = 1:4
            stim1RGBstimMatrix = stim1 + squeeze(ditherOffsets1(subframe,:,:,:));
            stim1RGBstimMatrix(find(stim1RGBstimMatrix<0)) = 0;
            stim1RGBstimMatrix(find(stim1RGBstimMatrix>1)) = 1;
            stim1TexturePtr(subframe) = Screen('MakeTexture', obj.masterWindowPtr, stim1RGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);

            stim2RGBstimMatrix = stim2 + squeeze(ditherOffsets2(subframe,:,:,:));
            stim2RGBstimMatrix(find(stim2RGBstimMatrix<0)) = 0;
            stim2RGBstimMatrix(find(stim2RGBstimMatrix>1)) = 1;
            stim2TexturePtr(subframe) = Screen('MakeTexture', obj.masterWindowPtr, stim2RGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);

            stim3RGBstimMatrix = stim3 + squeeze(ditherOffsets3(subframe,:,:,:));
            stim3RGBstimMatrix(find(stim3RGBstimMatrix<0)) = 0;
            stim3RGBstimMatrix(find(stim3RGBstimMatrix>1)) = 1;
            stim3TexturePtr(subframe) = Screen('MakeTexture', obj.masterWindowPtr, stim3RGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision); 
        end

        % update the list of existing texture pointers so that they
        % can be cleared before next draw
        obj.texturePointers = [obj.texturePointers stim1TexturePtr stim2TexturePtr stim3TexturePtr];          

        %draw imagery to each sub-screen
        sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
                                    
        Screen('SelectStereoDrawBuffer', obj.masterWindowPtr, 0);  
        Screen('DrawTexture', obj.masterWindowPtr, stim1TexturePtr(1), sourceRect, stim1Rect, rotationAngle, filterMode, globalAlpha);     % stim1
        Screen('DrawTexture', obj.masterWindowPtr, stim2TexturePtr(1), sourceRect, stim2Rect, rotationAngle, filterMode, globalAlpha);     % stim2
        Screen('DrawTexture', obj.masterWindowPtr, stim3TexturePtr(1), sourceRect, stim3Rect, rotationAngle, filterMode, globalAlpha);     % stim2

        
        Screen('SelectStereoDrawBuffer', obj.masterWindowPtr, 1);
        Screen('DrawTexture', obj.masterWindowPtr, stim1TexturePtr(2), sourceRect, stim1Rect, rotationAngle, filterMode, globalAlpha);     % stim1
        Screen('DrawTexture', obj.masterWindowPtr, stim2TexturePtr(2), sourceRect, stim2Rect, rotationAngle, filterMode, globalAlpha);     % stim2            
        Screen('DrawTexture', obj.masterWindowPtr, stim3TexturePtr(2), sourceRect, stim3Rect, rotationAngle, filterMode, globalAlpha);     % stim2            

        
        Screen('SelectStereoDrawBuffer', obj.slaveWindowPtr, 0);
        Screen('DrawTexture', obj.slaveWindowPtr, stim1TexturePtr(3), sourceRect, stim1Rect, rotationAngle, filterMode, globalAlpha);      % stim1
        Screen('DrawTexture', obj.slaveWindowPtr, stim2TexturePtr(3), sourceRect, stim2Rect, rotationAngle, filterMode, globalAlpha);      % stim2
        Screen('DrawTexture', obj.slaveWindowPtr, stim3TexturePtr(3), sourceRect, stim3Rect, rotationAngle, filterMode, globalAlpha);      % stim2

        Screen('SelectStereoDrawBuffer', obj.slaveWindowPtr, 1);
        Screen('DrawTexture', obj.slaveWindowPtr, stim1TexturePtr(4), sourceRect, stim1Rect, rotationAngle, filterMode, globalAlpha);      % stim1
        Screen('DrawTexture', obj.slaveWindowPtr, stim2TexturePtr(4), sourceRect, stim2Rect, rotationAngle, filterMode, globalAlpha);      % stim2
        Screen('DrawTexture', obj.slaveWindowPtr, stim3TexturePtr(4), sourceRect, stim3Rect, rotationAngle, filterMode, globalAlpha);      % stim2

        fprintf('Flipping screens\n');
        % Flip all 4 buffers
        Screen('Flip', obj.slaveWindowPtr,  [], [], 1);
        Screen('Flip', obj.masterWindowPtr, [], [], 1);                       
              
    catch err
        sca;
        rethrow(err);
    end
    
end