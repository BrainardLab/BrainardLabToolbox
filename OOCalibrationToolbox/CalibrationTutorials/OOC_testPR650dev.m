% Demo usage of the PR-650 object.
%
% 3/27/2014  npc   Wrote it.
% 3/11/2015  npc   Minor updates.

function OOC_testPR650dev

    DB_PR650obj = [];
    
    try
        DB_PR650obj = PR650dev(...
        'verbosity',        1, ...       % 1 -> minimum verbosity
        'devicePortString', [] ...       % empty -> automatic port detection
        );

        % Set various PR-650 specific optional parameters
        DB_PR650obj.setOptions(...
        	'syncMode',     'ON', ...
        	'verbosity',     5 ...
                );

        % Info
        DB_PR650obj.deviceModelName
        DB_PR650obj.hostInfo

        
        % Load the Stockman-Sharpe (2000) 2-degree cone fundamentals
        load T_cones_ss2;
        
        % Load the melanopsin fundamental
        load 'T_melanopsin'
        
        % Load the standard CIE '31 color matching functions.
        load T_xyz1931;
        
        % Set a desired commong sampling for all measurements
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
        
        % userT showcase
        sensorActivations = DB_PR650obj.measure('userS', desiredS, 'userT', T_allSensors);
        
        % Plot results
        figure(2);
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
        
        % userS showcase
        disp('Native measurement');
        SPD = DB_PR650obj.measure();
        % display
        figure(1);
        clf;
        bar(DB_PR650obj.measurement.spectralAxis, DB_PR650obj.measurement.energy, 'EdgeColor', [0 0 0], 'FaceColor', [0.1 0.7 0.9], 'BarWidth', 1.0);
        set(gca, 'XLim', [380-5 780+5]);
      
        disp('Native measurement - passing native');
        SPD = DB_PR650obj.measure('userS', 'native', 'userT', 'native');
        % display
        figure(1);
        clf;
        bar(DB_PR650obj.measurement.spectralAxis, DB_PR650obj.measurement.energy, 'EdgeColor', [0 0 0], 'FaceColor', [0.1 0.7 0.9], 'BarWidth', 1.0);
        set(gca, 'XLim', [380-5 780+5]);
        
        disp('Native measurement - passing hires S')
        SPD = DB_PR650obj.measure('userS', [380 1 401]);
        % display
        figure(1);
        clf;
        bar(DB_PR650obj.measurement.spectralAxis, DB_PR650obj.measurement.energy, 'EdgeColor', [0 0 0], 'FaceColor', [0.1 0.7 0.9], 'BarWidth', 1.0);
        set(gca, 'XLim', [380-5 780+5]);
       
        disp('Native measurement - passing lowres S')
        SPD = DB_PR650obj.measure('userS', [380 8 51]);
        % display
        figure(1);
        clf;
        bar(DB_PR650obj.measurement.spectralAxis, DB_PR650obj.measurement.energy, 'EdgeColor', [0 0 0], 'FaceColor', [0.1 0.7 0.9], 'BarWidth', 1.0);
        set(gca, 'XLim', [380-5 780+5]);
       
        % Shutdown PR650obj object and close the associated device
        DB_PR650obj.shutDown();
        
     catch err
        
        if (isempty(DB_PR650obj))
            IOPort('closeall')
        else
            % Shutdown DBLab_Radiometer object and close the associated device
            DB_PR650obj.shutDown();
        end
        
        rethrow(err)
    end % end try/catch
    
end