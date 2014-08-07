% Method for executing a standard calibration protocol
function obj = calibrate(obj)
%
    if (obj.options.verbosity > 9)
        fprintf('In PsychImagingCalibrator.calibrate() method\n');
    end
    
    % Make a local copy of obj.cal so we do not keep calling it and regenerating it
    calStruct = obj.cal;
    
    % Generate the calibration rectangle
    obj.generateCalibrationRect();

    % Prompt user to leave the room
    userPrompt = 1; beepWhenDone = 2;
    obj.promptUserToLeaveTheRoom(userPrompt);
    
    % Set email notification preference
    obj.setNotificationPreferences();
    
    % Generate a new @CalibratorRawData object to store the measurements
    obj.rawData = CalibratorRawData();
    
    % Initialize random number generator
    ClockRandSeed;
 
    % Start timing
    t0 = clock;

    % Initialize states of the screen to be measured and the other screen
    obj.setDisplaysInitialState(userPrompt);
   

    % Begin by some basic linearity measurements (first pass). 
    % These may be compared to what happens when we predict the same values from the calibration itself.
    if (~isempty(calStruct.basicLinearitySetup))
        fprintf('1. Basic linearity measurements, pass 1 ... \n');
        
        % allocate storage for all basic measurements
        settingsNumToBeMeasured  = size(calStruct.basicLinearitySetup.settings,2);
        obj.rawData.basicLinearityMeasurements1 = zeros(settingsNumToBeMeasured, obj.measurementChannelsNum);
        
        % set background settings
        backgroundSettings = calStruct.describe.bgColor';
        
        % Measure the SPD for all the settings in the calStruct.basicLinearitySetup
        for settingsIndex = 1:settingsNumToBeMeasured
            settingsToTest = calStruct.basicLinearitySetup.settings(:,settingsIndex);
            [obj.rawData.basicLinearityMeasurements1(settingsIndex,:), obj.rawData.S] = ...
                obj.updateStimulusAndMeasure(backgroundSettings, settingsToTest, calStruct.describe.useBitsPP);
        end % for settingsIndex
    end  % if (~isempty(calStruct.basicLinearitySetup))
   
    
    % Follow-up with full specturm gamma curve measurements for each phosphor.
    % Compute range of input gamma values
    delta = 1.0/calStruct.describe.nMeas;    
    obj.rawData.gammaInput = linspace(delta, 1, calStruct.describe.nMeas);
    
    % measurements are arranged as [ numberOfAverages x primariesNum x gammaCurveSamples x measurementChannelsNum]
    obj.rawData.gammaCurveMeasurements = zeros( ...
                                            calStruct.describe.nAverage, ...
                                            calStruct.describe.displayPrimariesNum, ...
                                            calStruct.describe.nMeas, ...
                                            obj.measurementChannelsNum...
                                        );
                                    
    obj.rawData.gammaCurveSortIndices = zeros(calStruct.describe.nAverage, calStruct.describe.displayPrimariesNum, calStruct.describe.nMeas);
    
    
    % Do the full-gamma measurements 
    for repeatIndex = 1:calStruct.describe.nAverage
       for currentPrimaryIndex = 1: calStruct.describe.displayPrimariesNum
           fprintf('2. Testing display primary: %g (of %g) ...\n',currentPrimaryIndex,calStruct.describe.displayPrimariesNum);
           
           % set color of other (than the currentPrimaryIndex) primaries
           otherPrimaryIndices                  = setdiff(1:calStruct.describe.displayPrimariesNum, currentPrimaryIndex);
           ambientSettings                      = zeros(calStruct.describe.displayPrimariesNum,1);
           ambientSettings(otherPrimaryIndices) = calStruct.describe.fgColor(otherPrimaryIndices);
           
           % set background color
           backgroundSettings = calStruct.describe.bgColor';
           
           % set target color
           targetSettingsArray                           = zeros(calStruct.describe.displayPrimariesNum, calStruct.describe.nMeas);
           targetSettingsArray(currentPrimaryIndex,:)    = obj.rawData.gammaInput;
           targetSettingsArray(otherPrimaryIndices(1),:) = ones(size(obj.rawData.gammaInput))*calStruct.describe.fgColor(otherPrimaryIndices(1));
           targetSettingsArray(otherPrimaryIndices(2),:) = ones(size(obj.rawData.gammaInput))*calStruct.describe.fgColor(otherPrimaryIndices(2));
                
           % take first ambient reading
           fprintf('   Testing ambient #1: ...\n');
           [darkAmbient1, obj.rawData.S] = obj.updateStimulusAndMeasure(backgroundSettings, ambientSettings, calStruct.describe.useBitsPP);
                
           % measure full gamma in random order
           randomIndices = randperm(calStruct.describe.nMeas);
           obj.rawData.gammaCurveSortIndices(repeatIndex, currentPrimaryIndex,:) = randomIndices;
           
           for gammaPointIndex = 1:length(randomIndices)
               % tetermine target settings
               randomGammaPointIndex = randomIndices(gammaPointIndex);
               fprintf('   Testing gamma point: %g ...\n',randomGammaPointIndex);
               % measure the target
               targetSettings = targetSettingsArray(:,randomGammaPointIndex); 
               [obj.rawData.gammaCurveMeasurements(repeatIndex, currentPrimaryIndex, randomGammaPointIndex, :), obj.rawData.S] = ...
                   obj.updateStimulusAndMeasure(backgroundSettings, targetSettings, calStruct.describe.useBitsPP);
           end  % for gammaPointIndex
           
           % take second ambient reading
           fprintf('   Testing ambient #2: ...\n');
           [darkAmbient2, obj.rawData.S] = obj.updateStimulusAndMeasure(backgroundSettings, ambientSettings, calStruct.describe.useBitsPP);
                
           % average the two
           darkAmbient = 0.5*(darkAmbient1+darkAmbient2);
           darkAmbient = reshape(darkAmbient, [1 1 1 length(darkAmbient)]);
           
           % and subtract from the measurements
           for gammaPointIndex = 1:calStruct.describe.nMeas
                obj.rawData.gammaCurveMeasurements(repeatIndex, currentPrimaryIndex, gammaPointIndex,:) = ...
                obj.rawData.gammaCurveMeasurements(repeatIndex, currentPrimaryIndex, gammaPointIndex,:) - darkAmbient;
           end
       end % for currentPrimaryIndex
    end % for repeatIndex 



    % Repeat the basic linearity tests (second pass)
    if (~isempty(calStruct.basicLinearitySetup))
        fprintf('3. Basic linearity measurements, pass 2 ...\n');
        
        % allocate storage for all basic measurements
        settingsNumToBeMeasured = size(calStruct.basicLinearitySetup.settings,2);
        obj.rawData.basicLinearityMeasurements2 = zeros(settingsNumToBeMeasured, obj.measurementChannelsNum);
        
         % set background settings
        backgroundSettings = calStruct.describe.bgColor';
        
        % Measure the SPD for all the settings in the calStruct.basicLinearitySetup
        for settingsIndex = 1:settingsNumToBeMeasured
            settingsToTest = calStruct.basicLinearitySetup.settings(:,settingsIndex);
            [obj.rawData.basicLinearityMeasurements2(settingsIndex,:), obj.rawData.S] = ...
                obj.updateStimulusAndMeasure(backgroundSettings, settingsToTest, calStruct.describe.useBitsPP);
        end % for settingsIndex
    end  % if (~isempty(calStruct.basicLinearitySetup))
    

    
    % Continue with the dependence of test on background test.
    if (~isempty(calStruct.backgroundDependenceSetup))
        fprintf('4. Effect of background measurements ...\n');
        
        % allocate storage for all dependence measurements
        settingsNumToBeMeasured    = size(calStruct.backgroundDependenceSetup.settings,2);
        backgroundsNumToBeMeasured = size(calStruct.backgroundDependenceSetup.bgSettings,2);
        obj.rawData.backgroundDependenceMeasurements = zeros(backgroundsNumToBeMeasured, settingsNumToBeMeasured, obj.measurementChannelsNum);
        
        for bgIndex = 1:backgroundsNumToBeMeasured
            backgroundSettings = calStruct.backgroundDependenceSetup.bgSettings(:,bgIndex);
            for settingsIndex = 1:settingsNumToBeMeasured
                settingsToTest = calStruct.backgroundDependenceSetup.settings(:,settingsIndex);
                [obj.rawData.backgroundDependenceMeasurements(bgIndex, settingsIndex,:), obj.rawData.S] = ...
                    obj.updateStimulusAndMeasure(backgroundSettings, settingsToTest, calStruct.describe.useBitsPP);
            end
        end
    end


    % Conclude with the ambient measurements
    % Re-initialize states of the screens
    fprintf('5. Ambient light measurements ...\n');
    
    backgroundSettings  = calStruct.describe.bgColor';
    settingsToTest      = [0.0 0.0 0.0]';
    
    for repeatIndex = 1:calStruct.describe.nAverage
        [ambientMeasurement, obj.rawData.S]  = obj.updateStimulusAndMeasure(backgroundSettings, settingsToTest, calStruct.describe.useBitsPP);
        if (repeatIndex == 1)
            obj.rawData.ambientMeasurements = ambientMeasurement;
        else
            obj.rawData.ambientMeasurements = obj.rawData.ambientMeasurements + ambientMeasurement;
        end
    end
    
    % compute average
    obj.rawData.ambientMeasurements = obj.rawData.ambientMeasurements / calStruct.describe.nAverage;
   

    % Report time
    t1 = clock;
    fprintf('\nCalibration measurements took %g minutes\n\n', etime(t1, t0)/60);

    if (calStruct.describe.nAverage > 0)
        % Compute mean over all nAverages (this is equivalent to cal.rawdata.mon' in old code)
        obj.rawData.gammaCurveMeanMeasurements = squeeze(mean(obj.rawData.gammaCurveMeasurements,1));
        
        % Get rid of negative values.
        obj.rawData.gammaCurveMeanMeasurements(obj.rawData.gammaCurveMeanMeasurements < 0) = 0;
    end
    
    % Process data
    obj.processRawData();
    
    % Finally, export cal struct
    obj.exportCal;
    
    % Plot some basic stuff
    obj.plotBasicMeasurements();
    
    % Let user know it's done
    obj.promptUserThatCalibrationIsDone(beepWhenDone);      
end


