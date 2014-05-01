% Method to generate the mon data in the old-style way.
function [mon, path] = makeOldStyleMon(obj)
    primariesNum        = size(obj.inputCal.rawData.gammaCurveMeasurements,2); 
    gammaSamples        = size(obj.inputCal.rawData.gammaCurveMeasurements,3); 
    spectralSamples     = size(obj.inputCal.rawData.gammaCurveMeasurements,4);
    
    for primaryIndex = 1:primariesNum
    for gammaPointIndex = 1:gammaSamples
        firstSample = (gammaPointIndex-1)*spectralSamples + 1;
        lastSample  = gammaPointIndex*spectralSamples;
        mon(firstSample:lastSample, primaryIndex) = ...
            reshape(squeeze(obj.inputCal.rawData.gammaCurveMeanMeasurements(primaryIndex,gammaPointIndex,:)), ...
            [spectralSamples 1]);
    end
    end
    
    path = 'cal.rawData.mon';
end