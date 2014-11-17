% Method to transform a native measurement according to user-supplied S and T matrices
function measurement = transformMeasurement(obj, applyUserS, applyUserT)
    if (isempty(obj.nativeMeasurement.energy))
        fprintf('There is no measurement yet !\n');
        measurement = [];
    else
        % resample SPD according to passed userS
        resampledSPD = [];
        if (applyUserS)
            resampledSPD = SplineSpd(obj.nativeS, obj.nativeMeasurement.energy', obj.userS);

            % update measurement
            measurement = struct( ...
                'spectralAxis', linspace(obj.userS(1),obj.userS(1)+(obj.userS(3)-1)*obj.userS(2),obj.userS(3)), ...
                'energy',       resampledSPD ...
                );
        end

        % transform SPD according to passed userT
        if (applyUserT)
            if (~isempty(resampledSPD))
                effectiveSPD = resampledSPD;
            else
                effectiveSPD = obj.nativeMeasurement.energy';
            end
            result = obj.userT * effectiveSPD;
            measurement = result;
        end
    end
end % obj = transformMeasurement(obj)