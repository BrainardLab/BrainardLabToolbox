% Method to update the stimulus and conduct a single radiometric measurement by 
% calling the corresponding method of the attached @Radiometer object.
function [measurement, S] = updateStimulusAndMeasure(obj, bgSettings, targetSettings, useBitsPP)

    if (obj.options.verbosity > 1)
        for i=1:obj.nSubprimaries
        fprintf('        Target settings %2.0f   : %2.3f \n\n',i,round((obj.nInputLevels-1)*targetSettings(i)));
        end
    end
    
    % update background and target stimuli
    obj.updateBackgroundAndTarget(bgSettings, targetSettings, useBitsPP);
    
    % Make a delay before the measurement for warming-up the device
    timeToDelay = obj.options.calibratorTypeSpecificParamsStruct.LEDWarmupDurationSeconds;
    fprintf('        Timer will count %2.1f seconds for warming up \n\n',timeToDelay);
    timerForWarmingup = timer('TimerFcn','stat=false','StartDelay',timeToDelay); % Timer setting
    start(timerForWarmingup); % Start the timer
    for t = 1:timeToDelay
         disp('.'); % Just displaying the dot to see if the timer is working
         pause(1); % Pause for 1 second (so, a dot is showing per each every second)
    end
    delete(timerForWarmingup); % End the timer
    disp('        Close the Timer and the measurement will begin');
    
    % then measure 
    obj.radiometerObj.measure();
    
    % and finally return results
    measurement = obj.radiometerObj.measurement.energy;
    S = WlsToS(obj.radiometerObj.measurement.spectralAxis(:))
end