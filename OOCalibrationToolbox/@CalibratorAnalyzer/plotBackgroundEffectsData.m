% Method to generate plots of background effects data.
function plotBackgroundEffectsData(obj, figureGroupIndex)

    % Get the cal
    calStruct = obj.cal;
    
    % Plot background effects on the spectra of each target settings
    for settingIndex = 1:size(calStruct.backgroundDependenceSetup.settings,2)
        spectra = squeeze(calStruct.rawData.backgroundDependenceMeasurements(:,settingIndex,:));
        plotSpectra(obj, calStruct, spectra, calStruct.backgroundDependenceSetup.settings(:,settingIndex), figureGroupIndex);
    end
end

function plotSpectra(obj, calStruct, spectra, settings, figureGroupIndex)
    % Init figure
    h = figure('Name', sprintf('Effects of background on (%0.2f %0.2f %0.2f)', settings(1), settings(2), settings(3)), 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;

    % Plot data
    backgroundSettingsNum = size(calStruct.backgroundDependenceSetup.bgSettings,2);
    lineColors = hsv(backgroundSettingsNum);
    for backgroundSettingIndex = 1:size(calStruct.backgroundDependenceSetup.bgSettings,2)
        plot(obj.spectralAxis, squeeze(spectra(backgroundSettingIndex,:)), '-', 'LineWidth', 2.0, 'Color', squeeze(lineColors(backgroundSettingIndex,:)));
    end
    
	% Generate legends
    for k = 1:backgroundSettingsNum
        legendsMatrix{k} = sprintf('bg=(%0.2f, %0.2f, %0.2f)', ...
            calStruct.backgroundDependenceSetup.bgSettings(1,k), ...
            calStruct.backgroundDependenceSetup.bgSettings(2,k), ...
            calStruct.backgroundDependenceSetup.bgSettings(3,k));
    end
    legend(legendsMatrix);
    xlabel('Wavelength (nm)', 'Fontweight', 'bold');
    ylabel('Power', 'Fontweight', 'bold');
    axis([380,780,-Inf,Inf]);
    box on;
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end
