% Method to generate the background-dependence specta in the old-style way.
function [spectra, path] = makeBgMeasSpectra(obj)
    spectralSamples       = size(obj.inputCal.rawData.gammaCurveMeasurements,4);
    backgroundSettingsNum = size(obj.inputCal.backgroundDependenceSetup.bgSettings,2);
    targetSettingsNum     = size(obj.inputCal.backgroundDependenceSetup.settings,2);

    for backgroundSettingsIndex = 1:backgroundSettingsNum
        tmp = zeros(spectralSamples,targetSettingsNum); 
        for targetSettingsIndex = 1: targetSettingsNum
            tmp(:, targetSettingsIndex) = ...
            reshape(squeeze(obj.inputCal.rawData.backgroundDependenceMeasurements(backgroundSettingsIndex, targetSettingsIndex, :)), ...
            [spectralSamples  1] );
        end
        spectra{backgroundSettingsIndex} = tmp;
    end 
    
    path = 'cal.rawData.spectra';
end