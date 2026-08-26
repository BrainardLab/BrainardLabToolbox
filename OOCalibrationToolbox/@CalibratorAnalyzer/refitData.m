function obj = refitData(obj)

    refit = false; % Change this to true if you want the option to refit data 

    numFiles = length(obj.calStructOBJarray);

    if refit == true

        for i = 1:numFiles

            % Refit accordingly
            fprintf('Processing file %d of %d...\n', i, numFiles);
            refitCurrent = GetWithDefault('Refit data [0 -> no,1 -> yes]?',0);

            if (refitCurrent)

                % Optionally, let the user specify a new type of gamma fit
                newFitType = ...
                    GetWithDefault('Enter gamma fit type (see ''help CalibrateFitGamma'')', obj.calStructOBJarray{i}.get('gamma.fitType'));

                obj.calStructOBJarray{i}.set('gamma.fitType', newFitType);

                % Optionally, let the user specify a different number of primary bases
                newBasesNum = ...
                    GetWithDefault('\nEnter number of primary bases', obj.calStructOBJarray{i}.get('nPrimaryBases'));
                obj.calStructOBJarray{i}.set('nPrimaryBases', newBasesNum);


                % Fitting a linear model to the raw data
                fprintf('Computing linear model.\n');
                % Fit the linear model
                CalibrateFitLinMod(obj.calStructOBJarray{i});

                % Update internal data reprentation
                %obj.rawData.gammaTable     = obj.calStructOBJ{1}.get('rawGammaTable');
                %obj.processedData.P_device = obj.calStructOBJ{1}.get('P_device');
                %obj.processedData.T_device = obj.calStructOBJ{1}.get('T_device');
                %obj.processedData.monSVs   = obj.calStructOBJ{1}.get('monSVs');

                % Fit the gamma
                nInputLevels = obj.calStructOBJarray{i}.get('gamma.nInputLevels');
                if (isempty(nInputLevels))
                    nInputLevels = 1024;
                end

                CalibrateFitGamma(obj.calStructOBJarray{i}, nInputLevels);
                % Update internal data reprentation
                %obj.processedData.gammaInput  = obj.calStructOBJ{1}.get('gammaInput');
                %obj.processedData.gammaTable  = pbj.calStructOBJ{1}.get('gammaTable');
                %obj.processedData.gammaFormat = pbj.calStructOBJ{1}.get('gammaFormat');


                % Process the ambient data
                %obj.processedData.P_ambient = obj.rawData.ambientMeasurements';
                %obj.processedData.T_ambient = WlsToT(obj.rawData.S);

            end

        end

    else

        disp('Refitting is off. See source code ("refitData.m") to change this setting.')

    end
    
    for i = 1:numFiles
        % Load CIE '31 color matching functions
        load T_xyz1931
        T_xyz = SplineCmf(S_xyz1931, 683*T_xyz1931, obj.calStructOBJarray{i}.get('S'));

        % Set the sensor space to the '31 XYZ color matching functions
        SetSensorColorSpace(obj.calStructOBJarray{i}, T_xyz, obj.calStructOBJarray{i}.get('S'));
    end

end
