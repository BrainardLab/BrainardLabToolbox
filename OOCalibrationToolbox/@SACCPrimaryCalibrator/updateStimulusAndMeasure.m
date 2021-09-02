% Method to update the stimulus and conduct a single radiometric measurement by 
% calling the corresponding method of the attached @Radiometer object.
function [measurement, S] = updateStimulusAndMeasure(obj, bgSettings, targetSettings, useBitsPP)
%

    % [SEMIN]
    % Use a loop to modify this to print out values of all settings entries.
    if (obj.options.verbosity > 1)
        for i=1:nSubprimaries
        fprintf('        Target settings %2.0f   : %2.3f \n\n',i,targetSettings(i));
        end
    end
    
    % update background and target stimuli
    obj.updateBackgroundAndTarget(bgSettings, targetSettings, useBitsPP);

    % then measure 
    obj.radiometerObj.measure();
    
    % and finally return results
    measurement = obj.radiometerObj.measurement.energy;
    S = WlsToS(obj.radiometerObj.measurement.spectralAxis(:))
end