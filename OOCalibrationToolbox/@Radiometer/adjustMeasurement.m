% transform a native measurement according to params passed
function measurement = adjustMeasurement(obj, userOptions)

    applyUserS = false;
    applyUserT = false;

    % Configure an inputParser to examine whether the options passed to us are valid
    parser = inputParser;
    parser.addParamValue('userS', []);
    parser.addParamValue('userT', []);
    % Execute the parser


    parser.parse(userOptions{:});
    % Create a standard Matlab structure from the parser results.
    parserResults = parser.Results;
    pNames = fieldnames(parserResults);
    for k = 1:length(pNames)
        obj.(pNames{k}) = parserResults.(pNames{k});
    end

    if (strcmp(obj.userS, 'native') || isempty(obj.userS))
        obj.userS = obj.nativeS;
    else
       applyUserS = true; 
    end

    if (strcmp(obj.userT, 'native') || isempty(obj.userT))
        obj.userT = obj.nativeT;
    else
       applyUserT = true;
    end

    if (applyUserS || applyUserT)
        if (obj.verbosity > 5)
            fprintf('>>> Measurement transformation was requested <<<\n');
        end
        measurement = transformMeasurement(obj, applyUserS, applyUserT);
    else
        if (obj.verbosity > 5)
            fprintf('>>> Native measurement was requested <<<\n');
        end
        measurement = obj.nativeMeasurement;
    end
end



% Method to transform a native measurement according to user-supplied S and T matrices
function theTransformedMeasurement = transformMeasurement(obj, applyUserS, applyUserT)
    
    if (isempty(obj.nativeMeasurement.energy))
        fprintf('There is no measurement yet !\n');
        theTransformedMeasurement = [];
        return;
    end
    
    resampledSPD = [];
    
    % applyUserS
    if (applyUserS)
        % resample SPD according to passed userS
        resampledSPD = SplineSpd(obj.nativeS, obj.nativeMeasurement.energy', obj.userS);

        % update measurement
        theTransformedMeasurement = struct( ...
            'spectralAxis', SToWls(obj.userS), ...
            'energy',       resampledSPD ...
            );
    end

    % applyUserT
    if (applyUserT)    
        if (~isempty(resampledSPD))
            effectiveSPD = resampledSPD;
        else
            effectiveSPD = obj.nativeMeasurement.energy';
        end
        
        % transform SPD according to passed userT
        result = obj.userT * effectiveSPD;
        theTransformedMeasurement = result;
    end
    
end % obj = transformMeasurement(obj)

