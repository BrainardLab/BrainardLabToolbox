% Method to generate plots of background effects data.
function plotBackgroundEffectsData(obj, figureGroupIndex)
    
    % Plot background effects on the spectra of each target settings
    for settingIndex = 1:size(obj.newStyleCal.backgroundDependenceSetup.settings,2)
        spectra = squeeze(obj.newStyleCal.rawData.backgroundDependenceMeasurements(:,settingIndex,:));
        maxAll(settingIndex) = max(max(spectra));
    end
    
    maxAll = max(maxAll);
    
    for settingIndex = 1:size(obj.newStyleCal.backgroundDependenceSetup.settings,2)
        spectra = squeeze(obj.newStyleCal.rawData.backgroundDependenceMeasurements(:,settingIndex,:));
        plotSpectra(obj, spectra, maxAll, obj.newStyleCal.backgroundDependenceSetup.settings(:,settingIndex), figureGroupIndex);
    end
end

function plotSpectra(obj, spectra, maxAll, settings, figureGroupIndex)
    % Init figure
    h = figure('Name', sprintf('Effects of background on RGB =(%d %d %d)e-2', round(100*settings(1)), round(100*settings(2)), round(100*settings(3))), 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;

    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJ.get('S'));
    
    % Plot data
    backgroundSettingsNum = size(obj.newStyleCal.backgroundDependenceSetup.bgSettings,2);
    lineColors = zeros(backgroundSettingsNum,3);
    
    for backgroundSettingIndex = 1:backgroundSettingsNum 
        bgSettings = obj.newStyleCal.backgroundDependenceSetup.bgSettings(:, backgroundSettingIndex);
        if (sum(bgSettings) == 0)
           zeroBackgroundSPD = squeeze(spectra(backgroundSettingIndex,:));
        end
    end
    
    maxSPDdiff = zeros(1, backgroundSettingsNum);
    
    for backgroundSettingIndex = 1:backgroundSettingsNum 
        lineColors(backgroundSettingIndex,:) = (obj.newStyleCal.backgroundDependenceSetup.bgSettings(:, backgroundSettingIndex))';
        lineColors(find(lineColors > 0.75)) = 0.75;
        spdDiff = (squeeze(spectra(backgroundSettingIndex,:)) - zeroBackgroundSPD);
        maxSPDdiff(backgroundSettingIndex) = max(abs(spdDiff));
        edgeColor = squeeze(lineColors(backgroundSettingIndex,:));
        plot(spectralAxis, spdDiff*1000, '-', 'Color', edgeColor, 'LineWidth', 2.0);
        
        legendsMatrix{backgroundSettingIndex} = sprintf('bg=(%0.2f, %0.2f, %0.2f)', ...
            obj.newStyleCal.backgroundDependenceSetup.bgSettings(1,backgroundSettingIndex), ...
            obj.newStyleCal.backgroundDependenceSetup.bgSettings(2,backgroundSettingIndex), ...
            obj.newStyleCal.backgroundDependenceSetup.bgSettings(3,backgroundSettingIndex));
    end
    maxSPDdiff = max(maxSPDdiff);
    
    [hleg, objh,outh,outm] = legend(legendsMatrix, 'Location', 'NorthEast');
    set(objh,'linewidth',2);

    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 12, 'Color', 'none', 'LineWidth', 0.1);
    box on;
    axis([380,780, -maxAll/2*1000 maxAll/2*1000]);
    set(gca, 'Color', [1 1 1], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    xlabel('\it wavelength (nm)', 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    ylabel('\it SPD(lambda | bg) - SPD(lambda | bg=(0,0,0))', 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14); 
    
    % Finish plot
    drawnow;
    
    uicontrol(h,  ...
                        'Units',    'normalized',  ...
                        'Position',  [0.01 0.01 0.1 0.1], ...
                        'String',   ' Export ', ...
                        'Fontsize',  14, ...      
                        'FontWeight','normal', ...
                        'ForegroundColor',     [0.2 0.2 0.2], ...
                        'Callback',  {@obj.SaveFigure_Callback, gcf,  get(h, 'Name')} ...
                );
            
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end
