function [rawGammaInput, path] = makeOldStyleRawGammaInput(obj)
    [rawGammaInput, path] = obj.retrieveFieldFromStruct('rawData', 'gammaInput');
    rawGammaInput = rawGammaInput';
end

 