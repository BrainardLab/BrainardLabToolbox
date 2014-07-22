% Method to generate plots of background effects data.
function plotBackgroundEffectsData(obj, figureGroupIndex)
    
    % Plot background effects on the spectra of each target settings
    for settingIndex = 1:size(obj.newStyleCal.backgroundDependenceSetup.settings,2)
        spectra = squeeze(obj.newStyleCal.rawData.backgroundDependenceMeasurements(:,settingIndex,:));
        plotSpectra(obj, spectra, obj.newStyleCal.backgroundDependenceSetup.settings(:,settingIndex), figureGroupIndex);
    end
end

function plotSpectra(obj, spectra, settings, figureGroupIndex)
    % Init figure
    h = figure('Name', sprintf('Effects of background on RGB =(%d %d %d)e-2', round(100*settings(1)), round(100*settings(2)), round(100*settings(3))), 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;

    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJ.get('S'));
    
    % Plot data
    backgroundSettingsNum = size(obj.newStyleCal.backgroundDependenceSetup.bgSettings,2);
    lineColors = zeros(backgroundSettingsNum,3);
    
    for backgroundSettingIndex = 1:backgroundSettingsNum 
        
        lineColors(backgroundSettingIndex,:) = (obj.newStyleCal.backgroundDependenceSetup.bgSettings(:, backgroundSettingIndex))';
        [xd, yd] = stairs(spectralAxis, squeeze(spectra(backgroundSettingIndex,:)));
        faceColor = [0.9 0.9 0.9]; edgeColor = squeeze(lineColors(backgroundSettingIndex,:));
        obj.makeShadedPlot(xd, yd, faceColor, edgeColor);
        
        legendsMatrix{backgroundSettingIndex} = sprintf('bg=(%0.2f, %0.2f, %0.2f)', ...
            obj.newStyleCal.backgroundDependenceSetup.bgSettings(1,backgroundSettingIndex), ...
            obj.newStyleCal.backgroundDependenceSetup.bgSettings(2,backgroundSettingIndex), ...
            obj.newStyleCal.backgroundDependenceSetup.bgSettings(3,backgroundSettingIndex));
    end
    
    for backgroundSettingIndex = 1:backgroundSettingsNum
        stairs(spectralAxis, squeeze(spectra(backgroundSettingIndex,:)), 'Color', squeeze(lineColors(backgroundSettingIndex,:)), 'LineWidth', 2.0);
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
    
    uicontrol(h,  ...
                        'Units',    'normalized',  ...
                        'Position',  [0.01 0.01 0.1 0.1], ...
                        'String',   ' Export ', ...
                        'Fontsize',  14, ...      
                        'FontWeight','Bold', ...
                        'ForegroundColor',     [0.2 0.2 0.2], ...
                        'Callback',  {@obj.SaveFigure_Callback, gcf,  get(h, 'Name')} ...
                );
            
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end
