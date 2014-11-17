% Method to update cal struct with ambient stuff
function obj = addAmbientData(obj)
    obj.processedData.P_ambient = obj.rawData.ambientMeasurements';
    obj.processedData.T_ambient = WlsToT(obj.rawData.S);
end
