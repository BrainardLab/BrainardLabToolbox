% Demo usage of the PR-650 object.
%
% 3/27/2014  npc   Wrote it.
%

function OOC_testPR650dev
    clear classes

    verbosity = 1;
    % Instantiate a PR650dev object
    DB_PR650obj = PR650dev(verbosity);

    try
        % Set various PR-650 specific optional parameters
        DB_PR650obj.setOptions(...
        	'syncMode',     'ON', ...
        	'verbosity',     5 ...
                );

        % Unit Tests
        DB_PR650obj.deviceModelName
        DB_PR650obj.hostInfo

        disp('Hires userS, userT');
        % userT showcase
        SPD = DB_PR650obj.measure('userS', [380 1 401], 'userT', [zeros(1,401); ones(1,401); zeros(1,401)]);

        % Load the Judd-Vos'51 XYZ mofidied color matching functions.
        load T_xyzJuddVos;
        % Convert spectral sampling from  [380 5 81] (S_xyzJuddVos) to [380 4 101]
        T_xyz = 683*SplineCmf(S_xyzJuddVos,T_xyzJuddVos, [380 4 101]);
        disp('size of T_xyz')
        clear 'S_xyzJuddVos', 'T_xyzJuddVos';

        % Load the Stockman-Sharpe (2000) 2-degree cone fundamentals
        load T_cones_ss2;
        % Convert spectral sampling from  [390 1 441] (S_cones_ss2) to [380 4 101]
        T_cones = SplineCmf(S_cones_ss2,T_cones_ss2, [380 4 101]);
        clear 'T_cones_ss2', 'S_cones_ss2';

        disp('Native userS, userT = XYZ (judd-vos)');
        % userT showcase
        XYZ = DB_PR650obj.measure( 'userT', T_xyz)
        fprintf('xyY: %4.4f, %4.4f, %4.4f\n', XYZ(1) / sum(XYZ), XYZ(2) / sum(XYZ), XYZ(2));
        pause;
    
        % Load the standard CIE '31 color matching functions.
        load T_xyz1931;
        % Convert spectral sampling from  [380 5 81] (S_xyz1931) to [380 4 101]
        T_xyz = 683*SplineCmf(S_xyz1931,T_xyz1931, [380 4 101]);
        disp('Native userS, userT = XYZ (1931)');
        % userT showcase
        XYZ = DB_PR650obj.measure( 'userT', T_xyz);
        % or
        XYZ = DB_PR650obj.measurement;
        fprintf('xyY: %4.4f, %4.4f, %4.4f\n', XYZ(1) / sum(XYZ), XYZ(2) / sum(XYZ), XYZ(2));
        pause;


        % userS showcase
        disp('Native measurement');
        SPD = DB_PR650obj.measure();
        % display
        figure(1);
        clf;
        bar(DB_PR650obj.measurement.spectralAxis, DB_PR650obj.measurement.energy, 'EdgeColor', [0 0 0], 'FaceColor', [0.1 0.7 0.9], 'BarWidth', 1.0);
        set(gca, 'XLim', [380-5 780+5]);
        pause;


        disp('Native measurement - passing native');
        SPD = DB_PR650obj.measure('userS', 'native', 'userT', 'native');
        % display
        figure(1);
        clf;
        bar(DB_PR650obj.measurement.spectralAxis, DB_PR650obj.measurement.energy, 'EdgeColor', [0 0 0], 'FaceColor', [0.1 0.7 0.9], 'BarWidth', 1.0);
        set(gca, 'XLim', [380-5 780+5]);
        pause;

        disp('Native measurement - passing hires S')
        SPD = DB_PR650obj.measure('userS', [380 1 401]);
        % display
        figure(1);
        clf;
        bar(DB_PR650obj.measurement.spectralAxis, DB_PR650obj.measurement.energy, 'EdgeColor', [0 0 0], 'FaceColor', [0.1 0.7 0.9], 'BarWidth', 1.0);
        set(gca, 'XLim', [380-5 780+5]);
        pause;

        disp('Native measurement - passing lowres S')
        SPD = DB_PR650obj.measure('userS', [380 8 51]);
        % display
        figure(1);
        clf;
        bar(DB_PR650obj.measurement.spectralAxis, DB_PR650obj.measurement.energy, 'EdgeColor', [0 0 0], 'FaceColor', [0.1 0.7 0.9], 'BarWidth', 1.0);
        set(gca, 'XLim', [380-5 780+5]);
        pause;

        % Shutdown PR650obj object and close the associated device
        DB_PR650obj.shutDown();
        
     catch err
        % Shutdown DBLab_Radiometer object and close the associated device
        DB_PR650obj.shutDown();
        
        rethrow(err)
    end % end try/catch
    
end