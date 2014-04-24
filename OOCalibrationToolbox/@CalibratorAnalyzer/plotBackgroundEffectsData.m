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
    lineColors = zeros(backgroundSettingsNum,3);
    
    for backgroundSettingIndex = 1:backgroundSettingsNum 
        
        lineColors(backgroundSettingIndex,:) = (calStruct.backgroundDependenceSetup.bgSettings(:, backgroundSettingIndex))';
        [xd, yd] = stairs(obj.spectralAxis, squeeze(spectra(backgroundSettingIndex,:)));
        faceColor = [0.9 0.9 0.9]; edgeColor = squeeze(lineColors(backgroundSettingIndex,:));
        obj.makeShadedPlot(xd, yd, faceColor, edgeColor);
        
        legendsMatrix{backgroundSettingIndex} = sprintf('bg=(%0.2f, %0.2f, %0.2f)', ...
            calStruct.backgroundDependenceSetup.bgSettings(1,backgroundSettingIndex), ...
            calStruct.backgroundDependenceSetup.bgSettings(2,backgroundSettingIndex), ...
            calStruct.backgroundDependenceSetup.bgSettings(3,backgroundSettingIndex));
    end
    
    for backgroundSettingIndex = 1:backgroundSettingsNum
        stairs(obj.spectralAxis, squeeze(spectra(backgroundSettingIndex,:)), 'Color', squeeze(lineColors(backgroundSettingIndex,:)), 'LineWidth', 2.0);
    end
    
    hleg = legend(legendsMatrix, 'Location', 'NorthEast');
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 12, 'Color', 'none', 'LineWidth', 0.1);
    box on;
    axis([380,780, 0 1.05 * max(max(spectra))]);
    set(gca, 'Color', [0.8 0.8 0.8], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Wavelength (nm)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Power', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14); 
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end
