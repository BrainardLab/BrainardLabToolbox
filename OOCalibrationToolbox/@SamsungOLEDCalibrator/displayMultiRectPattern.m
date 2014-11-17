function displayMultiRectPattern(obj)

    if (obj.displayTemporalDither ~= 4)
       error('This function is to be used only for 4-frame temporal dithering mode'); 
    end
    
    try
        if (~isempty(obj.texturePointers))
            fprintf('\nClosing existing textures (%d).\n', numel(obj.texturePointers(:)));
            % Close all existing texture pointers
            Screen('Close', obj.texturePointers(:));
            obj.texturePointers = [];
        end
        optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
        
        
        for patternIndex = 1:numel(obj.stimDataMatrices)
            ditheringMatrix = obj.ditheringMatrices{patternIndex};
            stimMatrix      = obj.stimDataMatrices{patternIndex};
            for subframe = 1:4
                subframeStimMatrix = stimMatrix + squeeze(ditheringMatrix(subframe,:,:,:));
                subframeStimMatrix(find(subframeStimMatrix<0)) = 0;
                subframeStimMatrix(find(subframeStimMatrix>1)) = 1;
                obj.texturePointers(patternIndex, subframe) = ...
                	Screen('MakeTexture', obj.masterWindowPtr, subframeStimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);
            end
        end
        
        %draw imagery to each sub-screen
        sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
                  
        subframe = 1;
        Screen('SelectStereoDrawBuffer', obj.masterWindowPtr, 0);  
        for patternIndex = 1:numel(obj.stimDataMatrices)
            Screen('DrawTexture', obj.masterWindowPtr, obj.texturePointers(patternIndex,subframe), sourceRect, ...
                obj.stimDestinationRects{patternIndex}, rotationAngle, filterMode, globalAlpha); 
        end
        
        subframe = 2;
        Screen('SelectStereoDrawBuffer', obj.masterWindowPtr, 1);
        for patternIndex = 1:numel(obj.stimDataMatrices)
            Screen('DrawTexture', obj.masterWindowPtr, obj.texturePointers(patternIndex,subframe), sourceRect, ...
                obj.stimDestinationRects{patternIndex}, rotationAngle, filterMode, globalAlpha); 
        end
        
        subframe = 3;
        Screen('SelectStereoDrawBuffer', obj.slaveWindowPtr, 0);
        for patternIndex = 1:numel(obj.stimDataMatrices)
            Screen('DrawTexture', obj.slaveWindowPtr, obj.texturePointers(patternIndex,subframe), sourceRect, ...
                obj.stimDestinationRects{patternIndex}, rotationAngle, filterMode, globalAlpha); 
        end
        
        subframe = 4;
        Screen('SelectStereoDrawBuffer', obj.slaveWindowPtr, 1);
        for patternIndex = 1:numel(obj.stimDataMatrices)
            Screen('DrawTexture', obj.slaveWindowPtr, obj.texturePointers(patternIndex,subframe), sourceRect, ...
                obj.stimDestinationRects{patternIndex}, rotationAngle, filterMode, globalAlpha); 
        end
        
        fprintf('Flipping screens\n');
        % Flip all 4 buffers
        Screen('Flip', obj.slaveWindowPtr,  [], [], 1);
        Screen('Flip', obj.masterWindowPtr, [], [], 1);                       
              
    catch err
        sca;
        rethrow(err);
    end
    
end