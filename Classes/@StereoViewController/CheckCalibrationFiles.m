function calibrationIsOK = CheckCalibrationFiles(obj)
%
    calibrationIsOK = true;
    
    calWarningDays = 14;
	calErrorDays   = 1000;
    if (obj.stringentCalibrationChecks)
        calErrorDays = 28; 
    end
    
    % Check calibration age, screen resolution, and refresh rate
    for leftright = 1:2
        
        % First the spectral calibration files
        cal = LoadCalFile(obj.stereoDisplayConfiguration.spectralFileNames{leftright});
        
        % calibration age
        calAge = GetCalibrationAge(cal);
        if (calAge < calWarningDays)
            fprintf('Calibration was last done %d days ago \n',calAge);
        elseif (calAge < calErrorDays)
            messageToDisplay = sprintf('WARNING: Spectral calibration for %s LCD is %d days old, recalibrate soon!\n', obj.stereoDisplayConfiguration.displayPosition{leftright}, calAge);
            disp(messageToDisplay);
            if (obj.useModalWindowForMessages)
               CodeDevHelper.DisplayModalMessageBox(messageToDisplay, 'Warning');
            end
        else
            messageToDisplay = sprintf('Spectral calibration for %s LCD is %d days old, recalibrate now!\n',obj.stereoDisplayConfiguration.displayPosition{leftright}, calAge);
            disp(messageToDisplay);
            if (obj.useModalWindowForMessages)
               CodeDevHelper.DisplayModalMessageBox(messageToDisplay, 'ERROR');
            end
            calibrationIsOK = false;
            return;
        end
        
        if (obj.stringentCalibrationChecks) 
            % screen resolution
            if (cal.describe.screenSizePixel ~= obj.stereoDisplayConfiguration.screenData{leftright}.screenSizePixel)
                messageToDisplay = sprintf('Error: Calibrated screen resolution for %s LCD is different than current resolution.', obj.stereoDisplayConfiguration.displayPosition{leftright});
                disp(messageToDisplay);
                if (obj.useModalWindowForMessages)
                    CodeDevHelper.DisplayModalMessageBox(messageToDisplay, 'ERROR');
                end
                calibrationIsOK = false;
                return;
            end

            % refresh rate
            if cal.describe.hz ~= obj.stereoDisplayConfiguration.screenData{leftright}.refreshRate
                messageToDisplay = sprintf('Error: Calibrated refresh rate for %s LCD is different than current refresh rate.', obj.stereoDisplayConfiguration.displayPosition{leftright});
                disp(messageToDisplay);
                if (obj.useModalWindowForMessages)
                    CodeDevHelper.DisplayModalMessageBox(messageToDisplay, 'ERROR');
                end
                calibrationIsOK = false;
                return;
            end
        end
        
        % Now the warp calibration files
        cal = LoadCalFile(obj.stereoDisplayConfiguration.warpFileNames{leftright});
        % calibration age
        calAge = GetCalibrationAge(cal);
        if (calAge < calWarningDays)
            fprintf('Calibration was last done %d days ago \n',calAge);
        elseif (calAge < calErrorDays)
            messageToDisplay = sprintf('WARNING: Warp calibration for %s LCD is %d days old, recalibrate soon!\n', obj.stereoDisplayConfiguration.displayPosition{leftright}, calAge);
            disp(messageToDisplay);
            if (obj.useModalWindowForMessages)
                CodeDevHelper.DisplayModalMessageBox(messageToDisplay, 'Warning');
            end
        else
            messageToDisplay = sprintf('Warp calibration for %s LCD is %d days old, recalibrate now!\n', obj.stereoDisplayConfiguration.displayPosition{leftright}, calAge);
            disp(messageToDisplay);
            if (obj.useModalWindowForMessages)
                CodeDevHelper.DisplayModalMessageBox(messageToDisplay, 'ERROR');
            end
            calibrationIsOK = false;
            return;
        end
        
    end
    
end