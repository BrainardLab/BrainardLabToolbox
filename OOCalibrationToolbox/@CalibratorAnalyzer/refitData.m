function obj = refitData(obj)

    % Refit accordingly
    refit = GetWithDefault('Refit data [0 -> no,1 -> yes]',0);
    if (refit)
        % Optionally, let the user specify a new type of gamma fit
        newFitType = ...
            GetWithDefault('Enter gamma fit type (see ''help CalibrateFitGamma'')', obj.calStructOBJ.get('gamma.fitType'));
        
        obj.calStructOBJ.set('gamma.fitType', newFitType);
        
        % Optionally, let the user specify a different number of primary bases
        newBasesNum = ...
            GetWithDefault('\nEnter number of primary bases', obj.calStructOBJ.get('nPrimaryBases'));
        obj.calStructOBJ.set('nPrimaryBases', newBasesNum);
        
       
        
        % Fitting a linear model to the raw data
        fprintf('Computing linear model.\n');
        % Fit the linear model
        CalibrateFitLinMod(obj.calStructOBJ);

        % Update internal data reprentation
        %obj.rawData.gammaTable     = obj.calStructOBJ.get('rawGammaTable');
        %obj.processedData.P_device = obj.calStructOBJ.get('P_device'); 
        %obj.processedData.T_device = obj.calStructOBJ.get('T_device');
        %obj.processedData.monSVs   = obj.calStructOBJ.get('monSVs');
    
        % Fit the gamma
        nInputLevels = obj.calStructOBJ.get('gamma.nInputLevels');
        if (isempty(nInputLevels))
            nInputLevels = 1024;
        end

        CalibrateFitGamma(obj.calStructOBJ, nInputLevels);
        % Update internal data reprentation
        %obj.processedData.gammaInput  = obj.calStructOBJ.get('gammaInput');
        %obj.processedData.gammaTable  = pbj.calStructOBJ.get('gammaTable');
        %obj.processedData.gammaFormat = pbj.calStructOBJ.get('gammaFormat');
    
        
        % Process the ambient data
        %obj.processedData.P_ambient = obj.rawData.ambientMeasurements';
        %obj.processedData.T_ambient = WlsToT(obj.rawData.S);
    
    end
    
    % Load CIE '31 color matching functions
    load T_xyz1931
    T_xyz = SplineCmf(S_xyz1931, 683*T_xyz1931, obj.calStructOBJ.get('S'));
    
    % Set the sensor space to the '31 XYZ color matching functions
    SetSensorColorSpace(obj.calStructOBJ, T_xyz, obj.calStructOBJ.get('S'));
end
