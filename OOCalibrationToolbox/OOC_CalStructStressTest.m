function OOC_CalStructStressTest
    Test1;
end

function Test1
% 
%%  Load a calibration file.
    clc;
    clear all;
    newStyleCalFileName = 'ViewSonicProbe';
    oldStyleCalFileName = 'StereoLCDLeft';
    [cal, ~] = GetCalibrationStructure('Enter calibration filename',oldStyleCalFileName,[]);
    %cal.S_device = cal.describe.S*2;
    fprintf('Hit enter to continue ...\n');
    pause
    
%%  Instantiate a @CalStruct object for controlled & unified access to old- and new-style cal structs.
    % Minimum verbosity
    fprintf('\n------------------------------------------------------------------\n');
    fprintf('Instantiating a <strong> @CalStruct</strong>  object to manage cal.\n');
    fprintf('------------------------------------------------------------------\n');
    fprintf('Hit enter to continue ...\n');
    pause;
    calStructVerbosity = 1;
    calStruct = CalStruct(cal, 'verbosity', calStructVerbosity);
    clear 'cal'
    fprintf('\n------------------------------------------------------------------');
    fprintf('\nWorkspace contents\n');
    whos
    fprintf('------------------------------------------------------------------\n');
    
    fprintf('Hit enter to continue ...\n');
    pause
    
%%  Get a field with a typo, say, 's'
    if (true)
        fprintf('\n------------------------------------------------------------------\n');
        fprintf('<strong>Unit test1: Typo in field  name to access.</strong>\n');
        fprintf('------------------------------------------------------------------\n');
        fprintf('Hit enter to continue ...\n');
        pause;
        s = calStruct.get('s')
        fprintf('Hit enter to continue ...\n');
        pause;
    end
    
%%  Get the S
    if (true)
        fprintf('\n------------------------------------------------------------------\n');
        fprintf('<strong>Unit test2a: Accessing ''S''.</strong>\n');
        fprintf('------------------------------------------------------------------\n');
        fprintf('Hit enter to continue ...\n');
        pause;
        S = calStruct.get('S')
        fprintf('Hit enter to continue ...\n');
        pause;
    end
    
%%  Get the S_Device
    if (true)
        fprintf('\n------------------------------------------------------------------\n');
        fprintf('<strong>Unit test2b: Accessing ''S_device''.</strong>\n');
        fprintf('------------------------------------------------------------------\n');
        fprintf('Hit enter to continue ...\n');
        pause;
        s_Device = calStruct.get('S_device')
        fprintf('Hit enter to continue ...\n');
        pause;
    end

%%  Get the S_Ambient
    if (true)
        fprintf('\n------------------------------------------------------------------\n');
        fprintf('<strong>Unit test2c: Accessing ''S_ambient''.</strong>\n');
        fprintf('------------------------------------------------------------------\n');
        fprintf('Hit enter to continue ...\n');
        pause;
        s_ambient = calStruct.get('S_ambient')
        fprintf('Hit enter to continue ...\n');
        pause;
    end
    
%%  Set a new S_Device (just for testing)
    if (true)
        fprintf('\n------------------------------------------------------------------\n');
        fprintf('<strong>Unit test3: Overwriting ''S_device''.</strong>\n');
        fprintf('------------------------------------------------------------------\n');
        fprintf('Hit enter to continue ...\n');
        pause;
        sDev = [380 2 201];
        calStruct.set('S_device', sDev);
        fprintf('Hit enter to continue ...\n');
        pause;
    end
    
%%  Modify values
    if (true)
        fprintf('\n------------------------------------------------------------------\n');
        fprintf('<strong>Unit test4: Modify a field.</strong>\n');
        fprintf('------------------------------------------------------------------\n');
        fprintf('Hit enter to continue ...\n');
        pause;
        
        gammaMode = calStruct.get('gammaMode')
        iGammaTable = calStruct.get('iGammaTable');
        if isempty(iGammaTable)
            fprintf('iGammaTable is empty\n');
        else
            fprintf('iGammaTable size: %d x %d\n', size(iGammaTable,1), size(iGammaTable,2))
        end
        fprintf('Hit enter to set the new gamma mode ...\n');
        pause;
        
        newGammaMode = 1;
        cal = SetGammaMethod(calStruct.cal, newGammaMode);
        
        % Instantiate new @CalStruct object with updated cal structure
        calStruct = CalStruct(cal, 'verbosity', calStructVerbosity);
        % Clear cal, so fields are accessed only via get and set methods of calStruct.
        clear 'cal'
        gammaMode = calStruct.get('gammaMode')
        iGammaTable = calStruct.get('iGammaTable');
        if isempty(iGammaTable)
            fprintf('iGammaTable is empty\n');
        else
            fprintf('iGammaTable size: %d x %d\n', size(iGammaTable,1), size(iGammaTable,2))
        end
        
        fprintf('\n------------------------------------------------------------------');
        fprintf('\nWorkspace contents\n');
        whos
        fprintf('------------------------------------------------------------------\n');
        fprintf('Hit enter to continue ...\n');
        pause;
    end
    
    %%  Call a non-modifed PTB function that expects an old-style cal
    if (true)
        fprintf('\n------------------------------------------------------------------\n');
        fprintf('<strong>Unit test5:  Cal non-modifed PTB functions (PrimaryToSettings, SettingsToPrimary) that expect an old-style cal.</strong>\n');
        fprintf('------------------------------------------------------------------\n');
        fprintf('Hit enter to continue ...\n');
        pause;
        
        gammaInput = calStruct.get('gammaInput');
        gammaTable = calStruct.get('gammaTable');
        figure;
        clf;
        subplot(1,3,1); hold on
        plot(gammaInput,gammaTable(:,1),'r-');
        axis([0 1 0 1]); axis('square');
        xlabel('Input value');
        ylabel('Linear output');
        title('Device Gamma');

        newGammaMode = 1;
        cal = SetGammaMethod(calStruct.cal, newGammaMode);
        
        % Instantiate new @CalStruct object with updated cal structure
        calStruct = CalStruct(cal, 'verbosity', calStructVerbosity);
        % Clear cal, so fields are accessed only via get and set methods of calStruct.
        clear 'cal'
        
        linearValues = ones(3,1)*linspace(0,1,256);
        clutValues = PrimaryToSettings(calStruct.cal,linearValues);
        predValues = SettingsToPrimary(calStruct.cal,clutValues);

        subplot(1,3,2); hold on
        plot(linearValues,clutValues(1,:)','r--');
        axis([0 1 0 1]); axis('square');
        xlabel('Linear output');
        ylabel('Input value');
        title('Inverse Gamma');

        subplot(1,3,3); hold on
        plot(linearValues,predValues(1,:)','r');
        axis([0 1 0 1]); axis('square');
        xlabel('Desired value');
        ylabel('Predicted value');
        title('Gamma Correction');

    end
         
end


