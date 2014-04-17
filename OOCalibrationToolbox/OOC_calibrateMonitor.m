% Demo usage of object-oriented-based monitor calibration.
%
% 3/27/2014  npc   Wrote it.
%

function OOC_calibrateMonitor
    
    clear classes
    clc
    
    % add all subdirectories
    % addpath(genpath(pwd));
    
    screenToCalibrate = 1;
    whichBlankScreen  = 2;
    screenPixelDims   = [2560 1440];

    screenToCalibrate = 2;
    whichBlankScreen  = 1;
    screenPixelDims   = [1920 1080];
        
        
    % Instantiate a Radiometer object, here a PR650obj.
    DBLab_Radiometer = PR650dev();
    DBLab_Calibrator = [];
    
    try
        % Set various PR-650 specific optional parameters
        DBLab_Radiometer.setOptions(...
        	'syncMode',     'OFF', ...
        	'verbosity',     5 ...
        );
    
        
        % Instantiate an Calibrator object, here an MGLcalibrator, with the required initializer variables.
        DBLab_Calibrator = MGLcalibrator(...
                            'executiveScriptName',              mfilename, ...             % name of the executive script (this file)
                            'radiometerObj',                    DBLab_Radiometer, ...
                            'screenToCalibrate',                screenToCalibrate, ...     % the screen ID on which stimulus are presented (0,1,...)
                            'desiredScreenSizePixel',           screenPixelDims, ...
                            'desiredRefreshRate',               60, ...
                            'displayPrimariesNum',              3, ...
                            'displayDeviceType',                'monitor', ...  
                            'displayDeviceName',                'NicolasViewSonic', ...
                            'calibrationFile',                  'ViewSonicProbe', ...       % name of file on which the cal struct is to be saved
                            'comment',                          'Nicolas Office ViewSonic (via new method)' ...
                            );

        DBLab_Calibrator.displayCalStruct();
        disp('Hit enter to see the default options.');
        pause
        eval(sprintf('Default_options = DBLab_Calibrator.options'));      
        
        
        % Set various optional parameters using a CalibratorOptions class
        % To see what options are available type: doc CalibratorOptions
        % Set some of the available options to other than their default values
        DBLab_Calibrator.options = ...
            CalibratorOptions( ...
                'verbosity',                        2, ...
                'whoIsDoingTheCalibration',         input('Enter your name: ','s'), ...
                'emailAddressForDoneNotification',  GetWithDefault('Enter email address for done notification',  'cottaris@sas.upenn.edu'), ...
                'blankOtherScreen',                 0, ...
                'whichBlankScreen',                 whichBlankScreen, ...
                'blankSettings',                    [0.4, 0.4, 0.4], ...
                'bgColor',                          [0.7451, 0.7451, 0.7451], ...
                'fgColor',                          [0.0 0.0 0.0], ...
                'meterDistance',                    0.75, ...
                'leaveRoomTime',                    1, ...
                'nAverage',                         1, ...         % number of repeated measurements for averaging
                'nMeas',                            15, ...        % samples along gamma curve
                'boxSize',                          150, ...
                'boxOffsetX',                       0, ...              
                'boxOffsetY',                       0, ...
                'primaryBasesNum',                  1, ...
                'gamma',                            struct( ...
                                                        'fitType',          'crtPolyLinear', ...
                                                        'contrastThresh',   1.0000e-03, ...
                                                        'fitBreakThresh',   0.02 ...
                                                    ) ...  
            );
        disp('Hit enter to see the modified options.');
        pause
        eval(sprintf('Modified_options = DBLab_Calibrator.options'));
        
        
        % Calibrate !
        DBLab_Calibrator.calibrate();
            
        % Optionally, display the generated cal struct
        % DBLab_Calibrator.displayCalStruct();
        
        % Optionally, export cal struct in old format, for backwards compatibility with old programs.
        DBLab_Calibrator.exportOldFormatCal();
        
        disp('All done with the calibration ...');

        % Shutdown DBLab_Calibrator
        DBLab_Calibrator.shutDown();
        
        % Shutdown DBLab_Radiometer object
        DBLab_Radiometer.shutDown();
    
    catch err
        % Shutdown DBLab_Radiometer object
        DBLab_Radiometer.shutDown();
        
        if (~isempty(DBLab_Calibrator))
            % Shutdown DBLab_Calibrator
            DBLab_Calibrator.shutDown();
        end
        
        rethrow(err)
    end % end try/catch
end


