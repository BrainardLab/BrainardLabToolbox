% Method to transform a native measurement according to user-supplied S and T matrices
function measurement = transformMeasurement(obj, applyUserS, applyUserT)
    
    if (isempty(obj.nativeMeasurement.energy))
        fprintf('There is no measurement yet !\n');
        measurement = [];
        return;
    end
    
    resampledSPD = [];
    
    % applyUserS
    if (applyUserS)
        % resample SPD according to passed userS
        resampledSPD = SplineSpd(obj.nativeS, obj.nativeMeasurement.energy', obj.userS);

        % update measurement
        measurement = struct( ...
            'spectralAxis', SToWls(obj.userS), ...
            'energy',       resampledSPD ...
            );
    end

    % applyUserS
    if (applyUserT)    
        if (~isempty(resampledSPD))
            effectiveSPD = resampledSPD;
        else
            effectiveSPD = obj.nativeMeasurement.energy';
        end
        
        % transform SPD according to passed userT
        result = obj.userT * effectiveSPD;
        measurement = result;
    end
    
end % obj = transformMeasurement(obj)