function OOC_testPR670

    DB_PR670obj = [];
    
    try
        DB_PR670obj = PR670dev('verbosity', 2);
        
         % Get some info
        fprintf('device model name: %s\n', DB_PR670obj.deviceModelName);
        fprintf('Device serial no is : %s.\n', DB_PR670obj.deviceSerialNum)
        DB_PR670obj.hostInfo
        
        
        % Test utility methods
        DB_PR670obj.setBacklightLevel(0);
        pause(0.5);
        DB_PR670obj.setBacklightLevel(100);
        pause(0.5);
        
        DB_PR670obj.setOptions(...
            'verbosity',        2, ...
        	'syncMode',         'OFF', ...
            'cyclesToAverage',  1, ...
            'sensitivityMode',  'STANDARD', ...
            'apertureSize',     '1 DEG' ...
        );
            

        sourceFreq = DB_PR670obj.measureSourceFrequency();
        fprintf('Source frequency (1 cycle averaging): %f Hz\n', sourceFreq);
        
        fprintf('\n\n* * Native measurement * * \n');
        for k = 1:10
            fprintf('Measurement %d\n', k);
            SPD = DB_PR670obj.measure();
            % display
            figure(1);
            clf;
            bar(DB_PR670obj.measurement.spectralAxis, DB_PR670obj.measurement.energy, 'EdgeColor', [0 0 0], 'FaceColor', [0.1 0.7 0.9], 'BarWidth', 1.0);
            set(gca, 'XLim', [380-5 780+5]);
            drawnow;
        end
        
        disp('Hit enter to continue with more tests\n');
        pause;
        
    
        % Test settings of different options
        % Auto Sync
        fprintf('Test. Set SyncMode to AUTO.\n');
        DB_PR670obj.setOptions(...
            'verbosity',  2, ...
        	'syncMode',  'AUTO' ...
        );

        % No Sync
        fprintf('Test. Set SyncMode to OFF.\n');
        DB_PR670obj.setOptions(...
             'verbosity',  2, ...
        	'syncMode',  'OFF' ...
        );
        
        fprintf('Test. Set SyncMode to 150 Hz.\n');
        % 90 Hz Sync
        DB_PR670obj.setOptions(...
             'verbosity',  2, ...
        	'syncMode',  150 ...
        );

        fprintf('Test. Set cyclesToAverage to 23.\n');
        DB_PR670obj.setOptions(...
            'verbosity',  2, ...
        	'cyclesToAverage',  23 ...
        );
    
        fprintf('Test. Set cyclesToAverage to 86.\n');
        DB_PR670obj.setOptions(...
            'verbosity',  2, ...
        	'cyclesToAverage',  86 ...
        );
    

        fprintf('Test. Set sensitivity mode to STANDARD.\n');
        DB_PR670obj.setOptions(...
            'verbosity',  2, ...
        	'sensitivityMode',  'STANDARD' ...
        );
    
        fprintf('Test. Set sensitivity mode to EXTENDED.\n');
        DB_PR670obj.setOptions(...
            'verbosity',  2, ...
        	'sensitivityMode',  'EXTENDED' ...
        );
    
        fprintf('Test. Aperture set to 1 deg.\n');
        DB_PR670obj.setOptions(...
            'verbosity',  2, ...
        	'apertureSize',  '1 DEG' ...
        );
    
        fprintf('Test. Aperture set to 1/2 deg.\n');
        DB_PR670obj.setOptions(...
            'verbosity',  2, ...
        	'apertureSize',  '1/2 DEG' ...
        );
    
        fprintf('Test. Aperture set to 1/4 deg.\n');
        DB_PR670obj.setOptions(...
            'verbosity',  2, ...
        	'apertureSize',  '1/4 DEG' ...
        );
    
        fprintf('Test. Aperture set to 1/8 deg.\n');
        DB_PR670obj.setOptions(...
            'verbosity',  2, ...
        	'apertureSize',  '1/8 DEG' ...
        );

    
    catch err
       if (isempty(DB_PR670obj))
            IOPort('closeall')
        else
            % Shutdown DBLab_Radiometer object and close the associated device
            DB_PR670obj.shutDown();
        end
        
        rethrow(err)
    end
    
    % Shutdown DBLab_Radiometer object and close the associated device
    DB_PR670obj.shutDown();
    
end
