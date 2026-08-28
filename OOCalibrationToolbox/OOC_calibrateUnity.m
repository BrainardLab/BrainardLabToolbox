function OOC_calibrateUnity
    % OOC_CALIBRATEUNITY Run monitor calibration from the conductor computer.
    %
    % This executive script has a specialized purpose and requires a
    % dual-computer calibration setup. It runs on the conductor computer,
    % which sends calibration commands to a separate display computer. The
    % display computer receives those commands and presents the requested
    % stimuli in Unity.
    %
    % Display-computer resources:
    %   Unity code:
    %     https://github.com/fh862/ellipsoids_public/tree/main/unity
    %   Unity game object:
    %     https://osf.io/k27js/files/osfstorage
    %
    % The two computers communicate through a text file stored on a shared
    % network disk that must be accessible to both computers. The conductor
    % writes commands and status messages to the file, and the display
    % computer reads the file to determine which stimulus to present.
    %
    % Code structure:
    %   1. Initialize MATLAB and add the toolbox's PsychCal overrides.
    %   2. Create the dated shared directory and communication text file.
    %   3. Select and configure the radiometer.
    %   4. Define the calibrator initialization parameters and options.
    %   5. Construct UnityImagingCalibrator, run the calibration, and shut
    %      down the calibrator and radiometer, including error cleanup.
    %
    % 7/16/2024  fh   Wrote it.
    
    % Reset MATLAB session state.
    clear all
    close all
    clc
    
    % Set paths relative to the BrainardLabToolbox root.
    toolboxRootDir = fileparts(fileparts(mfilename('fullpath')));
    overrideDir = fullfile(toolboxRootDir, 'Overrides', 'PTB-3', 'PsychCal');
    addpath(overrideDir, '-begin');
    % Use this command to verify that the toolbox override precedes Psychtoolbox.
    % which CalibrateFitLinMod -all
    
    % Build today's shared communication directory and file.
    todayDate = datestr(datetime('today'),'mmddyyyy'); % Get today's date in 'mmddyyyy' format

    % IMPORTANT: This is the shared network-disk location used by the two
    % calibration computers. MATLAB and Unity communicate through the text
    % file created in this directory, so this path must remain accessible
    % from both computers.
    path_str = '/Users/melanopsin/Aguirre-Brainard Lab Dropbox/Team Documents/ELPS_materials_temp/Calibration/';
    path_str_full = fullfile(path_str, todayDate); % Create the full path by appending today's date to the base path
    
    % Define the text file name using today's date
    fileName = sprintf('MATLAB_Unity_calibration_log_%s.txt', todayDate); 
    
    % Check if the folder already exists
    isFolderInPath = exist(path_str_full, 'dir');
    if ~isFolderInPath
        % If the folder does not exist, create it
        mkdir(path_str_full);
        % Create a new file inside the newly created folder
        filePath = fullfile(path_str_full, fileName);
        % Open (create) the file in 'w' (write) mode
        fileID = fopen(filePath, 'w');
        % Immediately close the file without writing anything
        fclose(fileID); 
    else
        % If the folder exists, check if the file already exists
        isFileInPath = exist(fullfile(path_str_full, fileName),'file');
        if isFileInPath
            % If the file exists, get the current timestamp
            timestamp = datestr(now, 'yyyymmdd_HHMMSS'); 
            % Rename the original file by appending the timestamp to the name string
            % Split the file name into parts: name and extension
            [~, name, ext] = fileparts(fileName); 
            % Create a new name with the timestamp appended
            oldFileName = fullfile(path_str_full, [name '_' timestamp ext]); 
            % Rename the file
            movefile(fullfile(path_str_full, fileName), oldFileName); 
        end
        % Create a new file (with the original name) in the folder
        filePath = fullfile(path_str_full, fileName);
        % Open (create) the file in 'w' (write) mode
        fileID = fopen(filePath, 'w'); 
        % Immediately close the file without writing anything
        fclose(fileID); 
    end
    
    % Select and instantiate the radiometer.
    whichRadiometer = GetWithDefault('Select radiometer: either PR670 or CR250',  'PR670');
    
    switch (whichRadiometer)
        case 'PR670'
            % Instantiate a PR-670 radiometer.
            radiometerOBJ = PR670dev(...
                'verbosity',        1, ...          % 1 -> minimum verbosity
                'devicePortString', '/dev/tty.usbmodem14401' ...      % explicit PR-670 port; use [] for automatic detection
                );
        case 'CR250'
            radiometerOBJ = CR250dev(...
                    'verbosity',        1, ...        % 1 -> minimum verbosity
                    'devicePortString', [] ...       % [] enables automatic port detection
                    );
    
        otherwise
            error('Must select either CR250 or PR670')
    end
    
    calibratorOBJ  = [];
       
    % Specify the @Calibrator's initialization params. 
    % Users should tailor these according to their display specs. 
    % These can be set once only, when the @Calibrator object is
    % instantiated.
    calFile_name = strcat('DELL_',todayDate);
    calibratorInitParams = { ...
        'executiveScriptName',      mfilename, ...              % name of the executive script (this file)
        'radiometerObj',            radiometerOBJ, ...          % configured radiometer object
        'screenToCalibrate',        1, ...                      % main screen (Calibrator screen ID 1)
        'desiredScreenSizePixel',   [1440 900], ...             % expected display width and height (pixels)
        'desiredRefreshRate',       [], ...                     % expected refresh rate (Hz); [] disables the check
        'displayPrimariesNum',      3, ...                      % RGB display primaries
        'displayDeviceType',        'monitor', ...  
        'displayDeviceName',        'DELL', ...                 % a name for the display, could be anything
        'calibrationFile',          calFile_name, ...           % name of file on which the calibration data will be saved
        'comment',                  'DELL U2723QE test on the bottom right blob. Gamma correction not applied. Using CR250.' ...      % a comment, could be anything
        };
    
    
    % Specify the @Calibrator's optional params using a CalibratorOptions class
    % To see what options are available type: doc CalibratorOptions
    % Users should tailor these according to their experimental needs.
    linearityColor = [1, 0.95, 0.9, 0.75, 0.5, 0.25, 0.2, 0.15]; % zero is intentionally excluded
    fgColor = [0.3962 0.3787 0.4039]; %Nicolas' choice
    % Build the 3-by-N linearity settings matrix from neutral and
    % single-primary levels, plus per-channel additivity checks around
    % fgColor for the composite targets [0.95, 0.9, 0.75].
    customLinearityMatrix = GenerateCustomLinearitySettings(linearityColor, fgColor, [0.95, 0.9, 0.75]);
    calibratorOptions = CalibratorOptions( ...
        'verbosity',                        2, ...
        'whoIsDoingTheCalibration',         input('Enter your name: ','s'), ...
        'emailAddressForDoneNotification',  GetWithDefault('Enter email address for done notification',  'fh862@sas.upenn.edu'), ...
        'blankOtherScreen',                 0, ...                          % whether to blank the other display (1=yes, 0 = no), ...
        'whichBlankScreen',                 nan, ...                        % screen ID to blank; NaN when unused
        'blankSettings',                    [0.25 0.25 0.25], ...           % RGB setting for whichBlankScreen
        'bgColor',                          [0.5 0.5 0.5], ...             % RGB background setting
        'fgColor',                          fgColor, ...                    % color of the foreground
        'meterDistance',                    1.3, ...                        % distance between radiometer and screen
        'leaveRoomTime',                    10, ...                         % seconds allowed to leave room
        'nAverage',                         1, ...                          % number of repeated measurements for averaging
        'nMeas',                            61, ...                         % samples along gamma curve
        'boxSize',                          150, ...                        % calibration stimulus size (pixels)
        'boxOffsetX',                       0, ...                          % horizontal offset in pixels (negative is left)
        'boxOffsetY',                       0, ...                          % vertical offset in pixels (negative is up)
        'primaryBasesNum',                  1, ...                          % basis vectors in the linear calibration model
        'customLinearitySetup',             struct('settings',customLinearityMatrix),...       % custom settings for the linearity test
        'gamma',                            struct( ...
                                                'fitType',          'crtPolyLinear', ...
                                                'contrastThresh',   0.001, ...
                                                'fitBreakThresh',   0.02, ...
                                                'nInputLevels',     4096 ...
                                            ) ...  
        );
    
    beVerbose = true;
    
    try
        switch (whichRadiometer)
            case 'PR670'
                % Set various PR-670 specific optional parameters
                radiometerOBJ.setOptions(...
    	            'syncMode',     'OFF', ...
    	            'verbosity',     1 ...
                );
            case 'CR250'
                % Configure the CR-250 sync options.
                syncMode = 'NTSC';
                manualSyncFrequency = 60;
    
                % Apply the selected sync mode and frequency.
                radiometerOBJ.setOptions(...
                    'syncMode',  syncMode, ...                % choose from 'None', 'Manual', 'NTSC', 'PAL', 'CINEMA'
                    'manualSyncFrequency',manualSyncFrequency ...
                    );
    
                % Optional extended CR-250 configuration (currently disabled).
                if (1==2)
                    radiometerOBJ.setOptions(...
                        'syncMode',  syncMode, ...                % choose from 'None', 'Manual', 'NTSC', 'PAL', 'CINEMA'
                        'manualSyncFrequency',manualSyncFrequency, ...
                        'speedMode', 'Normal', ...                % choose from 'Slow','Normal','Fast', '2x Fast'
                        'exposureMode', 'Auto' ...                % choose between 'Auto' and 'Fixed'
                        );
                end
    
        end
    
        % Instantiate UnityImagingCalibrator with the required configuration.
        calibratorOBJ = UnityImagingCalibrator(calibratorInitParams);
        calibratorOBJ.dropbox_filePath = filePath;
    
        % Set the optional parameters
        calibratorOBJ.options = calibratorOptions;
        
        if (beVerbose)
            % Optionally, display the cal struct before measurement
            calibratorOBJ.displayCalStruct();
        end
        
        % Run the calibration.
        calibratorOBJ.calibrate();
            
        if (beVerbose)
            % Optionally, display the updated cal struct after the measurement
            calibratorOBJ.displayCalStruct();
        end
        
        % Optionally, export cal struct in old format, for backwards compatibility with old programs.
        % calibratorOBJ.exportOldFormatCal();
        
        disp('All done with the calibration ...');
    
        % Notify Unity that calibration is done.
        calibratorOBJ.shutDown();
        
        % Shut down the radiometer.
        radiometerOBJ.shutDown();
    
    catch err
        % If radiometer initialization succeeded, attempt to notify Unity
        % before rethrowing the original error.
        if (~isempty(radiometerOBJ))
            calibratorOBJ.shutDown();
        end
        
        rethrow(err)
    end % end try/catch
end
