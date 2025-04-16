% Method to generate plots of background effects data.
function plotLuminanceVsChromaticityData(obj, figureGroupIndex, gridDims)

  % Setting up plots
    hFig = figure('Name', 'Luminance vs Chromaticity Data', 'NumberTitle', 'off', ...
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

    % Set lineColors
    lineColors = [1 0 0; 0 1 0; 0 0 1];

    % Get number of calibrated primaries
    primariesNum = obj.calStructOBJarray.get('nDevices');

    % Get number of calibrated primaries
    primariesNum = obj.calStructOBJarray.get('nDevices');
    
    % Get T_sensor data
    T_sensor = obj.calStructOBJarray.get('T_sensor');

    for subplot = 1:2

        h = axes('Parent', hPanel, 'Position', pos{subplot}); 
        ax = h;
        hold(ax, 'on');

        hpLegends = [];
        legends = {};

        for primaryIndex = 1:primariesNum

            % Put measurements into columns of a matrix from raw data in calibration file.
            fullSpectra = squeeze(obj.newStyleCalarray.rawData.gammaCurveMeanMeasurements(primaryIndex, :,:));

            % Compute phosphor chromaticities
            xyYMon = XYZToxyY(T_sensor*fullSpectra');

            % Get T_sensor data
            T_sensor  = obj.calStructOBJarray.get('T_sensor');

            % plot(xyYMon(1,:), xyYMon(2,:), 'k-', 'LineWidth', 2.0);

            if subplot == 1   % First plot - luminance vs x chromaticity

                markerSize = 8;
                hp = plot(xyYMon(3,:), xyYMon(1,:),  'o', 'MarkerFaceColor', lineColors(primaryIndex,:), ...
                    'MarkerEdgeColor', [0 0 0], 'MarkerSize', markerSize);
                hpLegends(end + 1) = hp;

                axis('square');
                xlabel('\it Luminance', 'FontName', 'Helvetica',  'FontSize', 18);
                ylabel('\it x chromaticity', 'FontName', 'Helvetica',  'FontSize', 18);
                set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
                set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
                box on;

                legends{end + 1} = sprintf('p%d', primaryIndex);

            else     % Second plot - luminance vs y chromaticity

                markerSize = 8;
                hp = plot(xyYMon(3,:), xyYMon(2,:),  'o', 'MarkerFaceColor', lineColors(primaryIndex,:), ...
                    'MarkerEdgeColor', [0 0 0], 'MarkerSize', markerSize);
                hpLegends(numel(hpLegends)+1) = hp;

                axis('square');
                xlabel('\it Luminance', 'FontName', 'Helvetica',  'FontSize', 18);
                ylabel('\it y chromaticity', 'FontName', 'Helvetica',  'FontSize', 18);
                set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
                set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
                box on;

                legends{end + 1} = sprintf('p%d', primaryIndex);

            end

        end

        hleg = legend(hpLegends, legends, 'Location', 'Northeast', 'NumColumns', 3);
        set(hleg, 'FontName', 'Helvetica', 'FontSize', 12);

        if subplot == 1
            title('Luminance vs x chromaticity');
        else
            title('Luminance vs y chromaticity');
        end

        % Finish plot
        drawnow;

    end

    % Define the file name and full path for saving
    jpgFilename = fullfile(obj.plotsExportsFolder, 'Luminance_vs_Chromaticity_Data.jpg');

    % Save the whole figure as a JPG image
    exportgraphics(hFig, jpgFilename, 'Resolution', 150);

end

