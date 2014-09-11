function matrixDitherOffsets = generateMatrixDitherOffsets(temporalDitheringMode, rows, cols)

    % perturbation amount to use prior to rounding
    % avoid using full range so that rounds to nearest value
    ditherOffsets = [ -0.3750   -0.1250  0.1250  0.3750];
    
    matrixDitherOffsets = zeros(4, rows, cols,3);
    
    if strcmp(temporalDitheringMode, '10BitPlusNoise')
        % 10-bit via temporal dithering, plus noise
        noiseMagnitude = 0.06;
        for subframeIndex = 1:4
            matrixDitherOffsets(subframeIndex,:,:,:) = ...
                (ditherOffsets(subframeIndex) + (rand(rows,cols,3)-0.5)/0.5*noiseMagnitude)/255;
        end
        
    elseif strcmp(temporalDitheringMode, '10BitNoNoise')
        % 10-bit via temporal dithering, no noise
        noiseMagnitude = 0.0;
        for subframeIndex = 1:4
            matrixDitherOffsets(subframeIndex,:,:,:) = ...
                (ditherOffsets(subframeIndex) + (rand(rows,cols,3)-0.5)/0.5*noiseMagnitude)/255;
        end
        
    elseif strcmp(temporalDitheringMode, '8Bit')
        % 8-bit
        for subframeIndex = 1:4
            matrixDitherOffsets(subframeIndex,:,:,:) = zeros(rows,cols,3);
        end
    else
       error('Unknown dithering mode: %s', temporalDitheringMode); 
    end
            
end
