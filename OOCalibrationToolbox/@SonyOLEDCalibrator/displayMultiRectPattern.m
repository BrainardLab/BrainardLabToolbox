function displayMultiRectPattern(obj)

    try
        if (~isempty(obj.texturePointers))
            fprintf('\nClosing existing textures (%d).\n', numel(obj.texturePointers(:)));
            % Close all existing texture pointers
            Screen('Close', obj.texturePointers(:));
            obj.texturePointers = [];
        end
        optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
        
        for patternIndex = 1:numel(obj.stimDataMatrices)
            stimMatrix      = obj.stimDataMatrices{patternIndex};
            obj.texturePointers(patternIndex) = Screen('MakeTexture', ...
                obj.masterWindowPtr, stimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);
        end % paternIndex
         
        % draw to screen 
        sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
                  
        subframe = 1;
        Screen('SelectStereoDrawBuffer', obj.masterWindowPtr, 0);  
        for patternIndex = 1:numel(obj.stimDataMatrices)
            Screen('DrawTexture', obj.masterWindowPtr, obj.texturePointers(patternIndex), sourceRect, ...
                obj.stimDestinationRects{patternIndex}, rotationAngle, filterMode, globalAlpha); 
        end
        
        % Flip screen to show the stimulus
        Screen('Flip', obj.masterWindowPtr, [], [], 1);    
        
    catch err
        sca;
        rethrow(err);
    end
    
end