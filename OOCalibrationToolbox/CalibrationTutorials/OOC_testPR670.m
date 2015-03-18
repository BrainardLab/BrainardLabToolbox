function OOC_testPR670

    % Load the Stockman-Sharpe (2000) 2-degree cone fundamentals
    load T_cones_ss2;

    % Load the melanopsin fundamental
    load 'T_melanopsin'

    % Load the standard CIE '31 color matching functions.
    load T_xyz1931;

    % Set a desired common sampling for all measurements
    desiredS = [380 1 401];

    % Convert spectral sampling of all fundamentals to the desired sampling
    T_cones      = SplineCmf(S_cones_ss2,  T_cones_ss2,  desiredS);
    T_melanopsin = SplineCmf(S_melanopsin, T_melanopsin, desiredS);
    T_xyz        = SplineCmf(S_xyz1931,    T_xyz1931,    desiredS);

    % Assemble big T_sensor matrix
    T_allSensors = [T_cones; T_melanopsin; T_xyz];
    sensorNames  = {'Lcone', 'Mcone', 'Scone', 'Melan', 'CIE31 X', 'CIE31 Y', 'CIE31 Z'};
    sensorColors = [0.9 0.5 0.7;  0.4 0.9 0.7;  0.8 0.6 0.9; ...
                    0.24 0.5 0.99; 1 0.1 0; 0.1 1.0 0; 0 0.1 1];
                
    DB_PR670obj = [];
    
    try
        DB_PR670obj = PR670dev(...
            'verbosity',        1, ...       % 1 -> minimum verbosity
            'devicePortString', [] ...       % empty -> automatic port detection)
        );
    
    
         % Get some info
        fprintf('device model name : %s\n', DB_PR670obj.deviceModelName);
        fprintf('Device serial no  : %s\n\n', DB_PR670obj.deviceSerialNum);
        
        % Test utility methods
        DB_PR670obj.setBacklightLevel(0);
        pause(0.5);
        DB_PR670obj.setBacklightLevel(100);
        pause(0.5);
        
        % List available configuration options and their valid values
        DB_PR670obj.listConfigurationOptions();
        
        
        % Print current configuration
        PR670configBefore = DB_PR670obj.currentConfiguration()
        
        pause;
        
        % Set a different set of configuration options
        DB_PR670obj.setOptions(...
            'verbosity',        1, ...
        	'syncMode',         'OFF', ...
            'cyclesToAverage',  1, ...
            'sensitivityMode',  'STANDARD', ...
            'exposureTime',     'ADAPTIVE', ...
            'apertureSize',     '1/2 DEG' ...
        );
    
        % Print current configuration
        PR670configAfter = DB_PR670obj.currentConfiguration()
        
        
        fprintf('\n\n* * Separate trigger and getMeasuredData * * \n');
        DB_PR670obj.triggerMeasure();
        result = DB_PR670obj.getMeasuredData();
        figure(100);
        plot(result);
        pause;
        
        
        fprintf('\n\n* * custom userS, userT measurement * * \n');
        % userT showcase
        sensorActivations = DB_PR670obj.measure('userS', desiredS, 'userT', T_allSensors);
        % Plot results
        figure(1);
        clf;
        hold on;
        for k = 1:numel(sensorNames)
            bar(k, sensorActivations(k), 'facecolor', sensorColors(k,:));
        end
        set(gca, 'XTick', [1:numel(sensorNames)], 'XTickLabel', sensorNames);
        box on; grid on;
        set(gca, 'FontSize', 14, 'FontName', 'Helvetica');
        xlabel('sensor type', 'FontSize', 16, 'FontWeight', 'b'); ylabel('sensor activation', 'FontSize', 16, 'FontWeight', 'b');
        drawnow
        
        % user S showcase
        fprintf('\n\n* * Native measurement * * \n');
        SPD = DB_PR670obj.measure('userS', desiredS, 'userT', 'native');
        % plot results
        figure(2);
        clf;
        bar(DB_PR670obj.measurement.spectralAxis, DB_PR670obj.measurement.energy, 'EdgeColor', [0 0 0], 'FaceColor', [0.1 0.7 0.9], 'BarWidth', 1.0);
        set(gca, 'XLim', [380-5 780+5]);
        drawnow;
        
  
        
        
        fprintf('Hit enter to continue with more tests\n');
        pause;
        
        sourceFreq = DB_PR670obj.measureSourceFrequency();
        fprintf('Source frequency (1 cycle averaging): %f Hz\n', sourceFreq);
        
        
        
        
        % Test settings of different options
        % Auto Sync
        fprintf('\n\nTest. Set SyncMode to AUTO.\n');
        DB_PR670obj.setOptions(...
            'verbosity', 2, ...
        	'syncMode',  'AUTO' ...
        );
        
        

        % No Sync
        fprintf('\n\nTest. Set SyncMode to OFF.\n');
        DB_PR670obj.setOptions(...
            'verbosity', 2, ...
        	'syncMode',  'OFF' ...
        );

        
        
        fprintf('\n\nTest. Set SyncMode to 150 Hz.\n');
        % 90 Hz Sync
        DB_PR670obj.setOptions(...
            'verbosity', 2, ...
        	'syncMode',  150 ...
        );

        
        
        fprintf('\n\nTest. Set cyclesToAverage to 23.\n');
        DB_PR670obj.setOptions(...
            'verbosity', 2, ...
        	'cyclesToAverage',  23 ...
        );
        
    
    
        fprintf('\n\nTest. Set cyclesToAverage to 86.\n');
        DB_PR670obj.setOptions(...
            'verbosity', 2, ...
        	'cyclesToAverage',  86 ...
        );
        

        fprintf('\n\nTest. Set sensitivity mode to STANDARD with ADAPTIVE exposure time.\n');
        DB_PR670obj.setOptions(...
        	'sensitivityMode',  'STANDARD', ...
            'exposureTime', 'ADAPTIVE'...
        );
        
        
        fprintf('\n\nTest. Set sensitivity mode to STANDARD with 5,000 milliseconds exposure time.\n');
        DB_PR670obj.setOptions(...
        	'sensitivityMode',  'STANDARD', ...
            'exposureTime', 5*1000 ...
        );

        
    
        fprintf('\n\nTest. Set sensitivity mode to EXTENDED with 20,0000 milliseconds exposure time.\n');
        DB_PR670obj.setOptions(...
        	'sensitivityMode',  'EXTENDED', ...
             'exposureTime', 20*1000 ...
        );
    
    
        fprintf('\n\nTest. Aperture set to 1 deg.\n');
        DB_PR670obj.setOptions(...
        	'apertureSize',  '1 DEG' ...
        );

        
        
        fprintf('\n\nTest. Aperture set to 1/2 deg.\n');
        DB_PR670obj.setOptions(...
        	'apertureSize',  '1/2 DEG' ...
        );

        
        
        fprintf('\n\nTest. Aperture set to 1/4 deg.\n');
        DB_PR670obj.setOptions(...
        	'apertureSize',  '1/4 DEG' ...
        );

        
        
        fprintf('\n\nTest. Aperture set to 1/8 deg.\n');
        DB_PR670obj.setOptions(...
        	'apertureSize',  '1/8 DEG' ...
        );


    
    catch err
       if (isempty(DB_PR670obj))
            IOPort('closeall')
       else
            % Exit remote control
            fprintf(2,'\nAn exception was raised. Shutting down PR670. Please wait ...\n');
            
            % Shutdown DBLab_Radiometer object and close the associated device
            DB_PR670obj.shutDown();
        end
        
        rethrow(err)
    end
    
    % Shutdown DBLab_Radiometer object and close the associated device
    DB_PR670obj.shutDown();
    
end
