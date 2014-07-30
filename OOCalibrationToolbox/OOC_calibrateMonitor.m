% Demo usage of object-oriented-based monitor calibration.
%
% 3/27/2014  npc   Wrote it.
%

function OOC_calibrateMonitor
    
    clear classes
    clc
        
    % Instantiate a Radiometer object, here a PR650obj.
    radiometerOBJ = PR650dev();
    calibratorOBJ  = [];
    
    try
        % Set various PR-650 specific optional parameters
        radiometerOBJ.setOptions(...
        	'syncMode',     'OFF', ...
        	'verbosity',     0 ...
        );
    
        
        % Instantiate an Calibrator object, here an MGLcalibrator, with the required initializer variables.
        calibratorOBJ = MGLcalibrator(...
                            'executiveScriptName',              mfilename, ...              % name of the executive script (this file)
                            'radiometerObj',                    radiometerOBJ, ...          % name of the radiometer object
                            'screenToCalibrate',                2, ...                      % second display
                            'desiredScreenSizePixel',           [1920 1080], ...            % width and height of display to be calibrated
                            'desiredRefreshRate',               60, ...                     % refresh rate in Hz
                            'displayPrimariesNum',              3, ...                      % i.e., R,G,B guns
                            'displayDeviceType',                'monitor', ...  
                            'displayDeviceName',                'NicolasViewSonic', ...     % a name for the display, could be anything
                            'calibrationFile',                  'ViewSonicProbe', ...       % name of file on which the calibration data will be saved
                            'comment',                          'Office ViewSonic' ...      % a comment, could be anything
                            );

        calibratorOBJ.displayCalStruct();
        
        %disp('Hit enter to see the default options.');
        %pause
        %eval(sprintf('Default_options = calibratorOBJ.options'));      
        
        
        % Set various optional parameters using a CalibratorOptions class
        % To see what options are available type: doc CalibratorOptions
        % Set some of the available options to other than their default values
        calibratorOBJ.options = ...
            CalibratorOptions( ...
                'verbosity',                        2, ...
                'whoIsDoingTheCalibration',         input('Enter your name: ','s'), ...
                'emailAddressForDoneNotification',  GetWithDefault('Enter email address for done notification',  'cottaris@sas.upenn.edu'), ...
                'blankOtherScreen',                 0, ...                          % whether to blank the other display (1=yes, 0 = no), ...
                'whichBlankScreen',                 1, ...                          % screen number of the display to be blanked
                'blankSettings',                    [0.3962 0.3787 0.4039], ...     % what color to be blank with (black = [0 0 0 ]);
                'bgColor',                          [0.3962 0.3787 0.4039], ...     % color of the background 
                'fgColor',                          [0.3962 0.3787 0.4039], ...     % color of the foreground
                'meterDistance',                    0.5, ...                        % distance between radiometer and screen
                'leaveRoomTime',                    1, ...                          % seconds allowed to leave room
                'nAverage',                         3, ...                          % number of repeated measurements for averaging
                'nMeas',                            15, ...                         % samples along gamma curve
                'boxSize',                          150, ...                        % size of calibration stimulus
                'boxOffsetX',                       0, ...                          % x-offset from center of screen         
                'boxOffsetY',                       0, ...                          % y-offset from center of screen
                'primaryBasesNum',                  1, ...                          
                'gamma',                            struct( ...
                                                        'fitType',          'crtPolyLinear', ...
                                                        'contrastThresh',   0.001, ...
                                                        'fitBreakThresh',   0.02 ...
                                                    ) ...  
            );
        
        %disp('Hit enter to see the modified options.');
        %pause
        %eval(sprintf('Modified_options = calibratorOBJ.options'));
        
        
        % Calibrate !
        calibratorOBJ.calibrate();
            
        % Optionally, display the generated cal struct
        % calibratorOBJ.displayCalStruct();
        
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


