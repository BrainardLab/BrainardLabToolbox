% Method to generate plots of background effects data.
function plotBackgroundEffectsData(obj, figureGroupIndex, gridDims)

  % Setting up plots
    hFig = figure('Name', 'Background Effects Data', 'NumberTitle', 'off', ...
                    'Position',[200, 500, 2200, 1200]);  

    % Adjust PaperSize to match the figure's dimensions
    figPos = hFig.PaperPosition;
    hFig.PaperSize = [figPos(3) figPos(4)]; % Set PaperSize to the figure's width and height
    
    % Create a panel in the figure
    hPanel = uipanel('Parent', hFig, 'Position', [0.05 0.05 0.9 0.9]);
    
    % Parameters for padding
    horizontalPadding = 0.04; % Space on the left and right
    verticalPadding = 0.07;   % Space on the top and bottom
    scaleFactor = 0.95;       % Scale down the axes size
    
    % Extract grid dimensions
    numRows = gridDims(2);
    numCols = gridDims(1);
    
    % Calculate available width and height for axes
    availableWidth = 1 - horizontalPadding * (numCols + 1);
    availableHeight = 1 - verticalPadding * (numRows + 1);

    % Calculate width and height of each axis
    axWidth = (availableWidth * scaleFactor) / numCols;
    axHeight = (availableHeight * scaleFactor) / numRows;

    % Initialize positions
    pos = cell(1, numRows * numCols);

    % Calculate position for each subplot within the panel
    for i = 1:numRows * numCols
        row = ceil(i / numCols);  % Determine row index
        col = mod(i - 1, numCols) + 1;  % Determine column index

        % Calculate position [left, bottom, width, height]
        left = (col - 1) * (axWidth + horizontalPadding) + horizontalPadding + 0.03;
        bottom = 1 - row * (axHeight + verticalPadding) - verticalPadding + 0.04; % Adjust for bottom padding
        position = [left, bottom, axWidth, axHeight];
        pos{i} = position; % Store position in cell array
    end

    % Plot background effects on the spectra of each target settings
    for settingIndex = 1:size(obj.newStyleCalarray.backgroundDependenceSetup.settings, 2)
        spectra = squeeze(obj.newStyleCalarray.rawData.backgroundDependenceMeasurements(:, settingIndex, :));
        maxAll(settingIndex) = max(max(spectra));
    end
    
    maxAll = max([0.01 max(maxAll)]);
    
    % Plotting logic for 9 plots maximum
    for settingIndex = 1:min([9 size(obj.newStyleCalarray.backgroundDependenceSetup.settings, 2)])
        spectra = squeeze(obj.newStyleCalarray.rawData.backgroundDependenceMeasurements(:, settingIndex, :));
        % Update the call to plotSpectra to use the correct position
        current_pos = pos{settingIndex};
        plotSpectra(obj, hPanel, current_pos, spectra, maxAll, obj.newStyleCal.backgroundDependenceSetup.settings(:,settingIndex), figureGroupIndex);
    end

end

function plotSpectra(obj, hPanel, current_pos, spectra, maxAll, settings, figureGroupIndex, settingsIndex, settingsIndicesNum)

    h_axes = axes('Parent', hPanel, 'Position', current_pos);

    % Hold on for plotting
    hold on;

    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJarray.get('S'));

    % Plot data
    backgroundSettingsNum = size(obj.newStyleCalarray.backgroundDependenceSetup.bgSettings,2);
    lineColors = zeros(backgroundSettingsNum,3);

    for backgroundSettingIndex = 1:backgroundSettingsNum
        bgSettings = obj.newStyleCalarray.backgroundDependenceSetup.bgSettings(:, backgroundSettingIndex);
        if (sum(bgSettings) == 0)
            zeroBackgroundSPD = squeeze(spectra(backgroundSettingIndex,:));
        end
    end

    maxSPDdiff = zeros(1, backgroundSettingsNum);

    for backgroundSettingIndex = 1:backgroundSettingsNum
        lineColors(backgroundSettingIndex,:) = (obj.newStyleCalarray.backgroundDependenceSetup.bgSettings(:, backgroundSettingIndex))';
        lineColors(find(lineColors > 0.75)) = 0.75;
        spdDiff = (squeeze(spectra(backgroundSettingIndex,:)) - zeroBackgroundSPD);
        maxSPDdiff(backgroundSettingIndex) = max(abs(spdDiff));
        edgeColor = squeeze(lineColors(backgroundSettingIndex,:));

        plot(h_axes, spectralAxis, spdDiff*1000, '-', 'Color', edgeColor, 'LineWidth', 2.0);
        if (numel(settings) == 3)
            title(sprintf('Effects of background on RGB =(%d %d %d)e-2', round(100*settings(1)), round(100*settings(2)), round(100*settings(3))), 'Visible', 'on');
        else
            title(sprintf('Effects of background on target %d/%d', settingsIndex, settingsIndicesNum),'Visible', 'on');
        end

        if (size(obj.newStyleCalarray.backgroundDependenceSetup.bgSettings,1) == 3)
            legendsMatrix{backgroundSettingIndex} = sprintf('bg=(%0.2f, %0.2f, %0.2f)', ...
                obj.newStyleCalarray.backgroundDependenceSetup.bgSettings(1,backgroundSettingIndex), ...
                obj.newStyleCalarray.backgroundDependenceSetup.bgSettings(2,backgroundSettingIndex), ...
                obj.newStyleCalarray.backgroundDependenceSetup.bgSettings(3,backgroundSettingIndex));
        else
            legendsMatrix{backgroundSettingIndex} = sprintf('background setting %d/%d (multiprimary)', backgroundSettingIndex, backgroundSettingsNum);
        end

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

end
