function obj = fitRawGamma(obj, nInputLevels)
% Fit the raw gamma curve measured.
%
    % Generate CalStructOBJ to handle the (new-style) cal struct
    [calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(obj.cal);
    
    % Fit the gamma
    if (nargin < 2 || isempty(nInputLevels))
        nInputLevels = calStructOBJ.get('gamma.nInputLevels');
        if (isempty(nInputLevels))
            nInputLevels = 1024;
        end 
    end
    
    CalibrateFitGamma(calStructOBJ, nInputLevels);

    % Update internal data reprentation
    obj.processedData.gammaInput  = calStructOBJ.get('gammaInput');
    obj.processedData.gammaTable  = calStructOBJ.get('gammaTable');
    obj.processedData.gammaFormat = calStructOBJ.get('gammaFormat');
    
    % Clear calStructOBJ - not needed anymore
    clear 'calStructOBJ'
end