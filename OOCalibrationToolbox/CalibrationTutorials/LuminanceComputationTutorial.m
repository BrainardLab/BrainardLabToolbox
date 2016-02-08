function LuminanceComputationTutorial

    % Load calibration file
    load('ViewSonic-2_Calib.mat');
    
    % Create a calibration struct OBJ based on the latest stored calibration  
    [calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(cals{end});
    clear 'cals';
    
    % Retrieve the spectral sampling of the measured data
    spectralSampling = calStructOBJ.get('S');
    
    % Load the '31 XYZ color matching functions
    load T_xyz1931
    
    % Spline the XYZ '31 CMFs to match the spectral sampling of the measured data
    T_xyz = SplineCmf(S_xyz1931, 683*T_xyz1931, spectralSampling);
    
    % Set the calibration sensor space to the '31 XYZ color matching functions
    SetSensorColorSpace(calStructOBJ, T_xyz, spectralSampling);
    
    % Define the RGB settingsvalues for which we want to compute their luminances
    channelSettings = [...
        1 0 0; ...   % max Red   gun loading, G, B = 0
        0 1 0; ...   % max Green gun loading, R, B = 0
        0 0 1; ...   % max Blue  gun loading, R, G = 0
        0 0 0 ...    % zero RGB loading (black)
        ];
    
    % Compute XYZ values for the desiredchannel settings
    XYZ = PrimaryToSensor(calStructOBJ, SettingsToPrimary(calStructOBJ, channelSettings'));
    
    for k = 1:size(channelSettings,1)
       fprintf('Luminance for RGB = <%2.1f, %2.1f, %2.1f> : % 6.2f cd/m2\n', ...
           channelSettings(k,1), channelSettings(k,2), channelSettings(k,3), XYZ(2,k));
    end
end


