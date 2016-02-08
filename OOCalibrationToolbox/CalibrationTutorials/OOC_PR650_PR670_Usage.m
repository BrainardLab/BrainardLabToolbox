function OOC_PR650_PR670_Usage

    try
        
        % init spectroRadiometerOBJ to empty
        spectroRadiometerOBJ = [];
        
        PR650 = false;
        if (PR650)
            S = [380 4 101];
            
            % Instantiate a PR650 object
            spectroRadiometerOBJ  = PR650dev(...
                'verbosity',        1, ...       % 1 -> minimum verbosity
                'devicePortString', [] ...       % empty -> automatic port detection)
            );

            spectroRadiometerOBJ.setOptions('syncMode', 'OFF');
            
        else
            S = [380 2 201];
            
            % Instantiate a PR670 object
            spectroRadiometerOBJ  = PR670dev(...
                'verbosity',        1, ...       % 1 -> minimum verbosity
                'devicePortString', [] ...       % empty -> automatic port detection)
            );
           
            spectroRadiometerOBJ.setOptions(...
            'verbosity',        1, ...
        	'syncMode',         'OFF', ...
            'cyclesToAverage',  1, ...
            'sensitivityMode',  'EXTENDED', ...
            'exposureTime',     20000, ...            % 20,000 msec exposure
            'apertureSize',     '1/2 DEG' ...
        );
    
        end
        
        fprintf('Hit enter to take a measurement\n');
        pause
        radMeas = spectroRadiometerOBJ.measure('userS', S);
        spectroRadiometerOBJ.measurementQuality
        figure(1); plot(SToWls(S), radMeas, 'r-');
        
        fprintf('Hit enter to shutdown radiometer.\n');
        spectroRadiometerOBJ.shutDown();
        
    catch e
        % cleanup related to the spectroRadiometerOBJ
        if (exist('spectroRadiometerOBJ', 'var'))
            if (isempty(spectroRadiometerOBJ))
                fprintf(2,'\nClosing all IO ports due to encountered error.\n');
                IOPort('closeall');
            else
                % Shutdown spectroRadiometerOBJ object and close the associated device
                fprintf(2,'\nShutting down spectroRadiometerOBJ due to encountered error. \n');
                spectroRadiometerOBJ.shutDown();
            end
        end
       
        rethrow(e)
    end

end

