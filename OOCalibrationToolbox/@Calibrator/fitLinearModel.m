function obj = fitLinearModel(obj)
% Fit the linear model to measured calibration data.
%
    % Generate CalStructOBJ to handle the (new-style) cal struct
    [calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(obj.cal);
    
    % Fit the linear model
    CalibrateFitLinMod(calStructOBJ);
    
    % Update internal data reprentation
    obj.rawData.gammaTable     = calStructOBJ.get('rawGammaTable');
    obj.processedData.P_device = calStructOBJ.get('P_device'); 
    obj.processedData.T_device = calStructOBJ.get('T_device');
    obj.processedData.monSVs   = calStructOBJ.get('monSVs');

    % Clear calStructOBJ - not needed anymore
    clear 'calStructOBJ'
end