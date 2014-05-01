% Method to generate the monIndex data in the old-style way.
function [monIndex, path] = makeOldStyleMonIndex(obj)
    trialsNum           = size(obj.inputCal.rawData.gammaCurveMeasurements,1);
    primariesNum        = size(obj.inputCal.rawData.gammaCurveMeasurements,2); 
    gammaSamples        = size(obj.inputCal.rawData.gammaCurveMeasurements,3); 
    spectralSamples     = size(obj.inputCal.rawData.gammaCurveMeasurements,4);

    for trialIndex = 1:trialsNum 
        for primaryIndex = 1:primariesNum   
            tmp = zeros(spectralSamples*gammaSamples,1);
            for gammaPointIndex = 1:gammaSamples
                firstSample = (gammaPointIndex-1)*spectralSamples + 1;
                lastSample  = gammaPointIndex*spectralSamples;
                tmp(firstSample:lastSample) = ...
                    reshape(obj.inputCal.rawData.gammaCurveMeasurements(trialIndex, primaryIndex, gammaPointIndex, :), ...
                    [1 spectralSamples]);
            end
            monIndex{trialIndex, primaryIndex} = reshape(obj.inputCal.rawData.gammaCurveSortIndices(trialIndex, primaryIndex,:), [gammaSamples 1]);  
        end
    end
    
    path = 'cal.rawData.monIndex';
    
end       