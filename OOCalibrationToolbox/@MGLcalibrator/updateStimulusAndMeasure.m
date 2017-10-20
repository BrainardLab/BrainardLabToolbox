% Method to update the stimulus and conduct a single radiometric measurement by 
% calling the corresponding method of the attached @Radiometer object.
function [measurement, S] = updateStimulusAndMeasure(obj, bgSettings, targetSettings, useBitsPP)
%
    if (obj.options.verbosity > 1)
        fprintf('        Background settings: %2.3f %2.3f %2.3f\n', bgSettings(1), bgSettings(2), bgSettings(3));
        fprintf('        Target settings    : %2.3f %2.3f %2.3f\n\n', targetSettings(1), targetSettings(2), targetSettings(3));
    end
    
    % update clut
    obj.loadClut(bgSettings, targetSettings, useBitsPP);

    % then measure 
    obj.radiometerObj.measure();
    
    % and finally return results
    measurement = obj.radiometerObj.measurement.energy;
    S           = WlsToS((obj.radiometerObj.measurement.spectralAxis)');
end