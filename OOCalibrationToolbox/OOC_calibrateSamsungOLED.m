function OOC_calibrateSamsungOLED


    clear classes
    clc
    
    % Close all open ports
    IOPort('CloseAll')
    
    leftRadiometerOBJ   = [];
    rightRadiometerOBJ  = [];
    calibratorOBJ       = [];
    
    try
        % Instantiate the left Radiometer object, here a PR650obj.
        leftRadiometerOBJ = PR650dev(...
            'verbosity',        1, ...                           % 1 -> minimum verbosity
            'devicePortString', '/dev/cu.USA19QW3d1P1.1' ...      % empty -> automatic port detection
            );

        fprintf('\nLeft Radiometer: %s with serial no:%s\n', leftRadiometerOBJ.deviceModelName, leftRadiometerOBJ.deviceSerialNum);

        % Set various PR-650 specific optional parameters
        leftRadiometerOBJ.setOptions(...
            'syncMode',     'OFF', ...
            'verbosity',     1 ...
        );


        % Instantiate the right Radiometer object, here a PR650obj.
        rightRadiometerOBJ = PR650dev(...
            'verbosity',        1, ...                          % 1 -> minimum verbosity
            'devicePortString',  '/dev/cu.USA19H1a2P1.1' ...   % empty -> automatic port detection
            );
        fprintf('\nRight Radiometer: %s with serial no:%s\n', rightRadiometerOBJ.deviceModelName, rightRadiometerOBJ.deviceSerialNum);

        % Set various PR-650 specific optional parameters
        rightRadiometerOBJ.setOptions(...
            'syncMode',     'OFF', ...
            'verbosity',     1 ...
        );

    
        calibratorOBJ = SamsungOLEDCalibrator(...
            'executiveScriptName',   mfilename, ...                         % name of the executive script (this file)
            'leftRadiometerOBJ',     leftRadiometerOBJ, ...
            'rightRadiometerOBJ',    rightRadiometerOBJ, ...
            'calibrationFile',       'SamsungOLED_240Hz_10bit', ...         % name of file on which the calibration data will be saved
            'displayTemporalDither', 4, ...                                 % 240 Hz: 4 frame interlace for 10 - bit resolution
            'comment',               'test' ...
            );
        
        % Show target rects, so that we can center the radiometers
        leftTargetSize      = 100;
        rightTargetSize     = 100;
        leftTargetPos       = [1920/2-300 1080/2];
        rightTargetPos      = [1920/2+300 1080/2]; 
        
        calibratorOBJ.displayTargetRects(leftTargetSize, rightTargetSize, leftTargetPos, rightTargetPos);
        
        Speak('Pausing');
        pause(1.0);
        sca;
        
    catch err
        
        sca;
        rethrow(err);
    end
    
end
