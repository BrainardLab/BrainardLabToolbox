% Executive script for object-oriented-based monitor calibration.
%
% 3/27/2014  npc   Wrote it.
% 8/05/2014  npc   Added option to conduct PsychImaging - based calibration

function OOC_calibrateMonitor
    
    clear classes
    clc
    
    
    % Instantiate a Radiometer object, here a PR650obj.
    radiometerOBJ = PR650dev(...
        'verbosity',        10, ...      % 1 -> minimum verbosity
        'devicePortString', [] ...      % empty -> automatic port detection
        );
    
    calibratorOBJ  = [];
    
    % List of available @Calibrator objects
    calibratorTypes = {'MGL-based', 'PsychImaging-based (8-bit)'};
    calibratorsNum  = numel(calibratorTypes);
    
    % Ask the user to select a calibrator type
    fprintf('\n\n Available calibrator types:\n');
    for k = 1:calibratorsNum
        fprintf('\t[%3d]. %s\n', k, calibratorTypes{k});
    end
    defaultCalibratorIndex = 1;
    calibratorIndex = input(sprintf('\tSelect a calibrator type (1-%d) [%d]: ', calibratorsNum, defaultCalibratorIndex));
    if isempty(calibratorIndex) || (calibratorIndex < 1) || (calibratorIndex > calibratorsNum)
        calibratorIndex = defaultCalibratorIndex;
    end
    fprintf('\n\t-------------------------\n');
    selectedCalibratorType = calibratorTypes{calibratorIndex};
    fprintf('Will employ an %s calibrator object [%d].\n', selectedCalibratorType, calibratorIndex);
    
    
    % Specify the @Calibrator's initialization params. 
    % Users should tailor these according to their display specs. 
    % These can be set once only, when the @Calibrator object is
    % instantiated.
    calibratorInitParams = { ...
        'executiveScriptName',      mfilename, ...              % name of the executive script (this file)
        'radiometerObj',            radiometerOBJ, ...          % name of the radiometer object
        'screenToCalibrate',        1, ...                      % second display
        'desiredScreenSizePixel',   [1920 1080], ...            % width and height of display to be calibrated
        'desiredRefreshRate',       [], ...                     % refresh rate in Hz. If empty, no check is done
        'displayPrimariesNum',      3, ...                      % i.e., R,G,B guns
        'displayDeviceType',        'monitor', ...  
        'displayDeviceName',        'SamsungOLED', ...     % a name for the display, could be anything
        'calibrationFile',          'SamsungOLED_MirrorScreen', ...       % name of file on which the calibration data will be saved
        'comment',                  'In 8-bit, Mirrored screen mode' ...      % a comment, could be anything
        };
    
    
    % Specify the @Calibrator's optional params using a CalibratorOptions class
    % To see what options are available type: doc CalibratorOptions
    % Users should tailor these according to their experimental needs.
    calibratorOptions = CalibratorOptions( ...
        'verbosity',                        2, ...
        'whoIsDoingTheCalibration',         input('Enter your name: ','s'), ...
        'emailAddressForDoneNotification',  GetWithDefault('Enter email address for done notification',  'cottaris@sas.upenn.edu'), ...
        'blankOtherScreen',                 0, ...                          % whether to blank the other display (1=yes, 0 = no), ...
        'whichBlankScreen',                 1, ...                          % screen number of the display to be blanked
        'blankSettings',                    [0.25 0.25 0.25], ...           % color of the whichBlankScreen 
        'bgColor',                          [0.3962 0.3787 0.4039], ...     % color of the background  
        'fgColor',                          [0.3962 0.3787 0.4039], ...     % color of the foreground
        'meterDistance',                    0.5, ...                        % distance between radiometer and screen
        'leaveRoomTime',                    1, ...                          % seconds allowed to leave room
        'nAverage',                         15, ...                          % number of repeated measurements for averaging
        'nMeas',                            13, ...                          % samples along gamma curve
        'boxSize',                          150, ...                        % size of calibration stimulus
        'boxOffsetX',                       0, ...                          % x-offset from center of screen (neg: leftwards, pos:rightwards)         
        'boxOffsetY',                       0, ...                          % y-offset from center of screen (neg: upwards, pos: downwards)
        'primaryBasesNum',                  1, ...                          
        'gamma',                            struct( ...
                                                'fitType',          'crtPolyLinear', ...
                                                'contrastThresh',   0.001, ...
                                                'fitBreakThresh',   0.02 ...
                                            ) ...  
        );
    
    
    beVerbose = false;
    
    try
        % Set various PR-650 specific optional parameters
        radiometerOBJ.setOptions(...
        	'syncMode',     'OFF', ...
        	'verbosity',     0 ...
        );
    
        % Instantiate an Calibrator object with the required configration variables.
        if strcmp(selectedCalibratorType, 'MGL-based')
            calibratorOBJ = MGLcalibrator(calibratorInitParams);
            
        elseif strcmp(selectedCalibratorType, 'PsychImaging-based (8-bit)')
            calibratorOBJ = PsychImagingCalibrator(calibratorInitParams);
        end

        % Set the optional parameters
        calibratorOBJ.options = calibratorOptions;
        
        if (beVerbose)
            % Optionally, display the cal struct before measurement
            calibratorOBJ.displayCalStruct();
        end
        
        % Calibrate !
        calibratorOBJ.calibrate();
            
        if (beVerbose)
            % Optionally, display the updated cal struct after the measurement
            calibratorOBJ.displayCalStruct();
        end
        
        % Optionally, export cal struct in old format, for backwards compatibility with old programs.
        % calibratorOBJ.exportOldFormatCal();
        
        disp('All done with the calibration ...');

        % Shutdown DBLab_Calibrator
        calibratorOBJ.shutDown();
        
        % Shutdown DBLab_Radiometer object
        calibratorOBJ.shutDown();
    
    catch err
        % Shutdown DBLab_Radiometer object  
        if (~isempty(calibratorOBJ))
            % Shutdown calibratorOBJ
            calibratorOBJ.shutDown();
        end
        
        rethrow(err)
    end % end try/catch
end


