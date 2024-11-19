% Method to generate and plot graphs of the essential data.
function plotCalibrationComparison(obj, figureGroupIndex, gridDims)
    
    numFiles = length(obj.calStructOBJarray);

    % Preallocate cell arrays 
    nWaves = zeros(numFiles, 1);
    nDevices = zeros(numFiles, 1);
    lineColors = cell(numFiles, 1);

    for ii = 1:numFiles

        % Get data
        P_device = obj.calStructOBJarray{ii}.get('P_device');

        % First spectral data
        [nWaves(ii), nDevices(ii)] = size(P_device);

        % Line colors for the different primaries
        if (nDevices(ii) == 3)
            lineColors{ii} = [1 0 0; 0 1 0; 0 0 1];
        else
            lineColors{ii} = brewermap(nDevices(ii), '*spectral');
        end

    end

    % Setting up plots
    hFig = figure('Name', 'Comparison Panel', 'NumberTitle', 'off', ...
        'Position', [200, 500, 2200, 1200]);

    % Adjust PaperSize to match the figure's dimensions
    figPos = hFig.PaperPosition;
    hFig.PaperSize = [figPos(3) figPos(4)]; % Set PaperSize to the figure's width and height

    % Save as an editable pdf
    set(gcf, 'Renderer', 'painters');

    % Create a panel in the figure
    hPanel = uipanel('Parent', hFig, 'Position', [0.05 0.05 0.9 0.9]);

    % Parameters for padding
    horizontalPadding = 0.025; % Space on the left and right
    verticalPadding = 0.065;   % Space on the top and bottom
    scaleFactor = 0.9;        % Scale down the axes size

    % Extract grid dimensions
    numRows = gridDims(1);
    numCols = gridDims(2);

    % Calculate available width and height for axes
    availableWidth = 1 - horizontalPadding * (numCols + 1);
    availableHeight = 1 - verticalPadding * (numRows + 1);

    % Calculate width and height of each axis
    axWidth = (availableWidth * scaleFactor) / numCols;
    axHeight = (availableHeight * scaleFactor) / numRows;
    pos = [];

    % Calculate position for each subplot within the panel
    for i = 1:numRows * numCols
        row = ceil(i / numCols);  % Determine row index
        col = mod(i - 1, numCols) + 1;  % Determine column index

        % Calculate position [left, bottom, width, height]
        left = (col - 1) * (axWidth + horizontalPadding) + 3 * horizontalPadding;
        bottom = 1 - row * (axHeight + verticalPadding); % Adjust for bottom padding
        position = [left, bottom, axWidth, axHeight];
        pos{end + 1} = position;

    end

    if (nDevices(ii) > 3)
        % Centering pos{2}
        left = horizontalPadding + (availableWidth / 2) - (axWidth / 2) + 0.01;  % Centering calculation
        pos{2} = [left, 1 - axHeight - verticalPadding, axWidth, axHeight];  % Centered position
    end

    if (all(nWaves > 3))
        % SPDs
        plotSpectralData(obj,  figureGroupIndex, lineColors, hPanel, pos);

        % Ambient SPD
        plotAmbientData(obj,  figureGroupIndex, hPanel, pos);
    end

    % Chromaticity data
    plotChromaticityData(obj, figureGroupIndex, lineColors, hPanel, pos);

    % Gamma functions.
    plotGammaData(obj, figureGroupIndex, lineColors, hPanel, pos);

end

function plotChromaticityData(obj, figureGroupIndex, lineColors, hPanel, pos)

    h = axes('Parent', hPanel, 'Position', pos{4});
    ax = h;
    
    % Clear the current axes to prepare for new plot
    cla;
    hold on;

    numFiles = length(obj.calStructOBJarray);   

    legends = {};

    for ii = 1:numFiles

        P_device  = obj.calStructOBJarray{ii}.get('P_device');
        P_ambient = obj.calStructOBJarray{ii}.get('P_ambient');
        T_sensor  = obj.calStructOBJarray{ii}.get('T_sensor');

        % Spectral data
        [nWaves, primariesNum] = size(P_device);

        if (nWaves > 3)
            xyYMon = XYZToxyY(T_sensor * P_device);
            xyYAmb = XYZToxyY(T_sensor * P_ambient);
        else
        xyYMon = XYZToxyY(P_device);
        xyYAmb = XYZToxyY(P_ambient);
        end

        % Compute the spectral locus
        xyYLocus = XYZToxyY(T_sensor);

        % Define the starting marker size and the decrement
        startingSize = 16;
        markerDecrement = 2;

        % Different shape options
        shapes = {'o', 's', 'd', '^', 'v', '<', '>', 'p', '*'};

        % Plot data
        for primaryIndex = 1:primariesNum
            % Calculate the marker size for the current index
            markerSize = startingSize - (ii - 1) * markerDecrement;

            % Make sure the marker size does not go below a minimum size, e.g., 2
            if markerSize < 2
                markerSize = 2;
            end

            shape = shapes{mod(ii-1, length(shapes)) + 1}; % Cycle through shapes
 
            % To make the shape outlines easier to see:    
            % Use modulo to cycle through lineColors 
            originalColor = lineColors{1}(mod(primaryIndex-1, size(lineColors{1}, 1)) + 1, :);

            % Create a lighter version by blending with white
            lighterColor = originalColor + (1 - originalColor) * 0.25;

            % Ensure values are clamped between 0 and 1
            lighterColor = min(max(lighterColor, 0), 1);

            if ii == 1 
                plot(xyYMon(1,primaryIndex)',  xyYMon(2,primaryIndex)', 'Marker', 'o', 'MarkerFaceColor', lighterColor, 'MarkerSize', markerSize, ...
                    'MarkerEdgeColor', 'none', 'LineStyle', 'none');
                legends{numel(legends)+1} = sprintf('Ref Cal p%d', primaryIndex);
            elseif primaryIndex == 1
                plot(xyYMon(1,primaryIndex)',  xyYMon(2,primaryIndex)', 'Marker', shape, 'MarkerFaceColor', lighterColor, 'MarkerSize', markerSize, ...
                    'MarkerEdgeColor', 'k', 'LineWidth', 1.5, 'LineStyle', 'none');
                legends{numel(legends)+1} = '';
                legends{numel(legends)+1} = sprintf('p%d Cal %d', primaryIndex, ii);
            else
                plot(xyYMon(1,primaryIndex)',  xyYMon(2,primaryIndex)', 'Marker', shape, 'MarkerFaceColor', lighterColor, 'MarkerSize', markerSize, ...
                    'MarkerEdgeColor', 'k', 'LineWidth', 1.5, 'LineStyle', 'none');
                legends{numel(legends)+1} = sprintf('p%d Cal %d', primaryIndex, ii);
             
            end

        end

        if ii == 1
            % Use a separate plot for the ambient entry
            plot(xyYAmb(1, 1)', xyYAmb(2, 1)', 'ks', ...
                'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', markerSize, ...
                'Marker', shape,  'MarkerEdgeColor', 'none');
            legends{numel(legends)+1} = 'ambient Ref Cal';
        else
            plot(xyYAmb(1, 1)', xyYAmb(2, 1)', 'ks', ...
                'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', markerSize, ...
                'Marker', shape,  'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
            legends{numel(legends)+1} = sprintf('ambient Cal %d', ii);
        end

        plot(xyYLocus(1,:)',xyYLocus(2,:)','k');

    end

    hold off

    hleg = legend(legends, 'Location', 'northeastoutside', 'NumColumns',3);
    set(hleg,'FontName', 'Helvetica',  'FontSize', 12);

    axis([0 0.75 0 0.85]); axis('square');
    xlabel('\it x chromaticity', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it y chromaticity', 'FontName', 'Helvetica',  'FontSize', 14);
    title('Primary Chromaticities');
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    box 'on'

    % Finish plot
    drawnow;

end


function plotAmbientData(obj, figureGroupIndex, hPanel, pos)

    h = axes('Parent', hPanel, 'Position', pos{3});
    ax = h;

    % Clear the current axes to prepare for new plot
    cla;
    hold on;

    numFiles = length(obj.calStructOBJarray);

    % Preallocate cell arrays 
    spectralAxis = cell(numFiles, 1);
    P_ambient = cell(numFiles, 1);

    % Different line style options
    lineStyles = {'--', ':', '-.', '-'};

    legends = {};
    xMax = -Inf;  % Initialize variable to track maximum y-value
    yMax = -Inf;  % Initialize variable to track maximum y-value

    hold on
    
    for i = 1:numFiles

        % Compute spectral axis
        spectralAxis{i} = SToWls(obj.calStructOBJarray{i}.get('S'));

        % Get data
        P_ambient{i} = obj.calStructOBJarray{i}.get('P_ambient');
           
        if i == 1
            legends{numel(legends)+1} = 'Ref Cal';
            lineWidth = 3; % Make the first line bold
            lineStyle = '-';
        else
            legends{numel(legends)+1} = sprintf('Cal %d', i);
            lineWidth = 1.5; % Normal line width for others
            lineStyle = lineStyles{mod(i-2, length(lineStyles)) + 1}; % Cycle through line styles
        end

        % Plot all calibration data
        x = spectralAxis{i};
        y = squeeze(P_ambient{i}(:,1))*1000;
        % Update the maximum x-value and y-value
        xMax = max(xMax, max(x));
        yMax = max(yMax, max(y));
        plot(x, y, 'LineStyle', lineStyle, 'Color', [0.5, 0.5, 0.5], 'LineWidth', lineWidth);

    end

    hold off

    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    xlabel('\it wavelength (nm)', 'FontName', 'Helvetica', 'FontSize', 14);
    ylabel('\it power (mWatts)', 'FontName', 'Helvetica',  'FontSize', 14);
    %title('Ambient spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    title('Ambient SPDs');
    legend(legends, 'Location', 'northeast', 'NumColumns', 2);
    % set(gca, 'YLim', [0 max([max(y) 1000*eps])]);
    box on;

    % Set the x-axis and y-axis limits
    xMaxAdjusted = xMax * 1.01; % Increase max x-value by 1%, just for a little extra space
    yMaxAdjusted = yMax * 1.1; % Increase max y-value by 10%
    axis([380, xMaxAdjusted, 0, yMaxAdjusted]); % Adjusted y-axis limit
    
    % Finish plot
    drawnow;

end

function plotSpectralData(obj, figureGroupIndex, lineColors, hPanel, pos)

    h = axes('Parent', hPanel, 'Position', pos{2});
    ax = h;

    % Clear the current axes to prepare for new plot
    cla; 
    hold on;

    numFiles = length(obj.calStructOBJarray);

    % Preallocate cell arrays 
    spectralAxis = cell(numFiles, 1);
    P_device = cell(numFiles, 1);
    primariesNum = cell(numFiles, 1);

    legends = {};
    yMax = -Inf;  % Initialize variable to track maximum y-value

    primaryMax = {};
    lineHandles = [];

    hold on
    
    for i = 1:numFiles

        % Compute spectral axis
        spectralAxis{i} = SToWls(obj.calStructOBJarray{i}.get('S'));

        % Get data
        P_device{i} = obj.calStructOBJarray{i}.get('P_device');

         % Get number of calibrated primaries
        primariesNum{i} = obj.calStructOBJarray{i}.get('nDevices');

        x = spectralAxis{i};

        if primariesNum{i} == 3

            for primaryIndex = 1:primariesNum{i}
                y = squeeze(P_device{i}(:,primaryIndex))*1000;

                % Update the maximum y-value
                yMax = max(yMax, max(y));

                % Define colors for the different reference cal lines
                colors = [
                    1 0 0;   % Red
                    0 1 0;   % Green
                    0 0 1    % Blue
                    ];

                % Different line style options
                lineStyles = {'--', ':', '-.', '-'};

                % Plot fitted data (line)
                if i == 1
                    legends{numel(legends)+1} = sprintf('p%d Ref Cal', primaryIndex);
                    lineWidth = 3; % Make the first line bold
                    lineStyle = '-';
                else
                    legends{numel(legends)+1} = sprintf('p%d Cal %d', primaryIndex, i);
                    lineWidth = 1.5; % Normal line width for others
                    lineStyle = lineStyles{mod(i-2, length(lineStyles)) + 1}; % Cycle through line styles
                end

                % Use mod to cycle through colors
                theColor = colors(mod(primaryIndex-1, size(colors, 1)) + 1, :); % Solid color

                h1 = plot(x, y, 'LineStyle', lineStyle, 'Color', theColor, 'LineWidth', lineWidth, 'DisplayName', sprintf('Primary %d', primaryIndex));

                lineHandles = [lineHandles; h1];

                % Finding the max of each primary for each calibration
                MaxValue = max(y);
                primaryMax{end + 1} = MaxValue;
            end
        
        else

            for primaryIndex = 1:primariesNum{i}

                y = squeeze(P_device{i}(:,primaryIndex))*1000;

                % Update the maximum y-value
                yMax = max(yMax, max(y));

                % Make a color map of colors
                colors = brewermap(primariesNum{i}, '*spectral');

                % Different line style options
                lineStyles = {'--', ':', '-.', '-'};

                % Plot fitted data (line)
                if i == 1
                    legends{numel(legends)+1} = sprintf('p%d Ref Cal', primaryIndex);
                    lineWidth = 3; % Make the first line bold
                    lineStyle = '-';
                else
                    legends{numel(legends)+1} = sprintf('p%d Cal %d', primaryIndex, i);
                    lineWidth = 1.5; % Normal line width for others
                    lineStyle = lineStyles{mod(i-2, length(lineStyles)) + 1}; % Cycle through line styles
                end

                % Use mod to cycle through colors
                theColor = colors(mod(primaryIndex-1, size(colors, 1)) + 1, :); % Solid color

                h1 = plot(x, y, 'LineStyle', lineStyle, 'Color', theColor, 'LineWidth', lineWidth, 'DisplayName', sprintf('Primary %d', primaryIndex));

                lineHandles = [lineHandles; h1];

                % Finding the max of each primary for each calibration
                MaxValue = max(y);
                primaryMax{end + 1} = MaxValue;

            end

        end

    end

    % Finding and averaging scale factors
    
    numPrimaries = primariesNum{1}; % Setting the number of primaries based on the ref cal
    numGroups = floor(length(primaryMax) / numPrimaries); % Total number of groups
    % where each group corresponds to one calibration

    % Creating a cell array that will contain lists, each of which will
    % contain the ratios for the i-th primary
    allRatios = {};
    for i = 1:numPrimaries
        primaryRatios = [];
        allRatios{i} = primaryRatios;
    end

    for group = 1:numGroups - 1 % Looping through the groups (each group = data from one calibration file)

        index = [];

        for i = 1:numPrimaries  

            % Finding the index of each primary in the current calibration file    
            index(end + 1) = group * numPrimaries + i;    

            % Dividing the value of that primary by the value 
            % of the corresponding primary in the reference calibration
            allRatios{i}(end + 1) = primaryMax{i} / primaryMax{index(i)};

        end    
           
        % Code for the case where there are 3 primaries
        % p1_ratios = [];
        % p2_ratios = [];
        % p3_ratios = [];

        % firstIndex = group * numPrimaries + 1;   % First entry in the group (4th, 7th, ...)
        % secondIndex = group * numPrimaries + 2;  % Second entry in the group (5th, 8th, ...)
        % thirdIndex = group * numPrimaries + 3;   % Third entry in the group (6th, 9th, ...)
        % 
        % p1_ratios(end + 1) = primaryMax{1} / primaryMax{firstIndex};
        % p2_ratios(end + 1) = primaryMax{2} / primaryMax{secondIndex};
        % p3_ratios(end + 1) = primaryMax{3} / primaryMax{thirdIndex};

        % scaleFactor{end + 1} = mean([p1_ratios(i), p2_ratios(i), p3_ratios(i)]);

        % y1 = squeeze(P_device{i + 1}(:,1))*1000;
        % y2 = squeeze(P_device{i + 1}(:,2))*1000;
        % y3 = squeeze(P_device{i + 1}(:,3))*1000;

        % y1Adj = y1 * scaleFactor{i};
        % y2Adj = y2 * scaleFactor{i};
        % y3Adj = y3 * scaleFactor{i};

    end

    scaleFactor = {};

    for i = 1:numFiles - 1
    % Note that when i = 1, we're actually plotting the scale factor for
    % the second calibration (since the first is the reference)

    elementsToAverage = [];
    y = [];
    yAdj = [];

        for j = 1:numPrimaries

            % Collecting elements of allRatios
            % These are the ratios for each primary for the current cal
            elementsToAverage(end + 1) = allRatios{j}(i);

        end

        % Finding the scale factor for the current calibration
        scaleFactor{i} = mean(elementsToAverage);
       
        % Applying the scale factor to each primary
        for j = 1:numPrimaries

            % Finding the y values for each primary 
            newY = squeeze(P_device{i + 1}(:,j))*1000;
            y = [y; newY];

            % Adjust y values based on the current scale factor
            for k = 1:length(newY)  % Loop through the newY elements
                newYAdj = newY(k) * scaleFactor{i};  % Adjust based on scale factor
                yAdj(k, j) = newYAdj;  % Append the adjusted value
            end
       
            % Different line style options
            lineStyles = {'--', ':', '-.', '-'};

            lineStyle = lineStyles{mod(i-1, length(lineStyles)) + 1}; % Cycle through line styles

            if j == 1
                h = plot(x, yAdj(:, j), 'LineStyle', lineStyle, 'Color', 'k', 'LineWidth', lineWidth);
                lineHandles = [lineHandles; h];
                legends{numel(legends)+1} = sprintf('Cal %d SC', i + 1);
            else
                plot(x, yAdj(:, j), 'LineStyle', lineStyle, 'Color', 'k', 'LineWidth', lineWidth);
            end

        end
     
    end

    hold off

    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    xlabel('\it wavelength (nm)', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it power (mWatts)', 'FontName', 'Helvetica', 'FontSize', 14);
    title('Primary SPDs');
    if numPrimaries > 3
        legend(lineHandles, legends, 'Location', 'northeastoutside', 'NumColumns', 2);
    else
        legend(lineHandles, legends, 'Location', 'northeast', 'NumColumns', 2);
    end

    % Set the y-axis limits
    yMaxAdjusted = yMax * 1.1; % Increase max y-value by 10%
    axis([380, 780, -Inf, yMaxAdjusted]); % Adjusted y-axis limit

    box on;
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    
    % Finish plot
    drawnow;
    
end

function plotGammaData(obj, figureGroupIndex, lineColors, hPanel, pos)

    numFiles = length(obj.calStructOBJarray);

    % Preallocate arrays
    rawGammaInput = cell(numFiles, 1);
    rawGammaTable = cell(numFiles, 1);
    gammaInput = cell(numFiles, 1);
    gammaTable = cell(numFiles, 1);
    primariesNum = zeros(numFiles, 1);
    
    % Get data 
    for i = 1:numFiles

        rawGammaInput{i} = obj.newStyleCalarray{i}.rawData.gammaInput;
        rawGammaTable{i} = obj.newStyleCalarray{i}.rawData.gammaTable;
        gammaInput{i} = obj.newStyleCalarray{i}.processedData.gammaInput;
        gammaTable{i} = obj.newStyleCalarray{i}.processedData.gammaTable;

        % Get number of calibrated primaries from all calibrations
        primariesNum(i) = size(gammaTable{i} ,2);

    end

    if all(primariesNum == 3) % The case that every entry is 3
        legendColumns = 1;
        numSubplots = primariesNum(i);
        % 1 = red, 2 = green, 3 = blue

        % Define spacing
        spacing = 0.005; % Space between subplots
        scaleFactor = 0.67; % Scale factor to reduce the size of each subplot
        % totalWidth = (scaleFactor * (1 - (numSubplots - 1) * spacing)) / numSubplots; % Adjusted total width
        totalWidth = scaleFactor / numSubplots - 0.08;
        verticalOffset = 0.07; % Move up
        horizontalOffset = -0.02; % Move left

        for i = 1:numSubplots

            % Create an axes in the specified position for the subplot
            leftPosition = pos{1}(1) + (i - 1) * (totalWidth + spacing); % Adjusted spacing
            bottomPosition = pos{1}(2) + verticalOffset; % Adjust vertical position
            % Create each axes in the specified position
            h = axes('Parent', hPanel, 'Position', [leftPosition + horizontalOffset, bottomPosition, totalWidth, pos{1}(4) * scaleFactor]);
            axes(h);

            % nexttile(tl)

            legends = {};

            markersize = 5;

            primaryIndex = i;

            % Define colors for the different reference cal lines
            colors = [
                1 0 0;   % Red
                0 1 0;   % Green
                0 0 1    % Blue
                ];

            % Different shape options
            shapes = {'o', 's', 'd', '^', 'v', '<', '>', 'p', '*'};

            hold on;

            for j = 1:numFiles % Plotting each calibration on the current subplot

                % Adjust gammaInput and gammaTable to only include every 67th point
                indices = 1:67:numel(gammaInput); % Select every 67th index
                gammaInputSubset = gammaInput{j}(indices);
                gammaTableSubset = gammaTable{j}(indices, primaryIndex);
                % Get these to make sense ^^^

                % Plot fitted data
                if j == 1
                    legends{numel(legends)+1} = sprintf('p%d Ref Cal', primaryIndex);
                    lineWidth = 3; % Make the first line bold
                    lineStyle = '-';
                    % Use mod to cycle through colors
                    theColor = colors(mod(primaryIndex-1, size(colors, 1)) + 1, :); % Solid color
                    plot(gammaInput{j}, gammaTable{j}(:,primaryIndex),'LineStyle', lineStyle, 'LineWidth', lineWidth, ...
                        'MarkerFaceColor', theColor, 'Color', theColor, 'MarkerSize', markersize);
                else
                    shape = shapes{mod(j-1, length(shapes)) + 1}; % Cycle through shapes
                    % Use mod to cycle through colors
                    theColor = colors(mod(primaryIndex-1, size(colors, 1)) + 1, :); % Solid color

                    plot(gammaInputSubset, gammaTableSubset, shape, ...
                        'MarkerFaceColor', theColor, 'MarkerEdgeColor', theColor*0.5, ...
                        'LineStyle', 'none');
                    legends{numel(legends)+1} = sprintf('p%d Cal %d', primaryIndex, j);

                end
 
            end

            hold off

            if i == 1
                ylabel('\it normalized output', 'FontName', 'Helvetica');
            end

            titleText = sprintf('Gamma Function p%d', i); % Customize your title text
            text(0.5, 1.05, titleText, 'Units', 'normalized', 'HorizontalAlignment', 'center', 'FontSize', 16, 'FontWeight', 'bold');
            xlabel('\it settings value', 'FontName', 'Helvetica');
            % ylabel('\it normalized output', 'FontName', 'Helvetica');
            %title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
            axis([-0.05 1.05 -0.05 1.05]);
            axis 'square'
            box on
            set(gca,  'XColor', 'b', 'YColor', 'b', 'FontSize', 14);

            % Create the legend
            lgd = legend(legends, 'Location', 'northwest', 'NumColumns', legendColumns);

            % Adjust the legend position to be below the x-axis
            legendPosition = get(lgd, 'Position'); % Get the current legend position
            legendPosition(2) = legendPosition(2) - 0.1; % Adjust this value as needed
            % Set the new position of the legend
            set(lgd, 'Position', legendPosition);

        end

    else
        % Setting up plots
        % Making another figure for the gamma plots, since there are
        % more than three

        % Assuming the files have the same number of primaries
        numPrimaries = primariesNum(2);

        pIndices = 1:numPrimaries;

        switch(numel(pIndices))
            case 1
                rows = 1; cols = 1;
            case 2
                rows = 1; cols = 2;
            case 3
                rows = 1; cols = 3;
            case 4
                rows = 2; cols = 2;
            case {5,6}
                rows = 2; cols = 3;
            case {7,8,9}
                rows = 3; cols = 3;
            case {10,11,12}
                rows = 3; cols = 4;
            case {13,14,15,16}
                rows = 4; cols = 4;
            otherwise
                rows = 4; cols = 5;
        end

        legendColumns = 1;

        hFig2 = figure('Name', 'Comparison Panel: Gamma Functions', 'NumberTitle', 'off', ...
            'Position',[200, 500, 2200, 1200]);

        % Create a panel in the figure
        hPanel2 = uipanel('Parent', hFig2, 'Position', [0.05 0.05 0.9 0.9]);

        % Parameters for padding
        horizontalPadding = 0.03; % Space on the left and right
        verticalPadding = 0.0125;   % Space on the top and bottom
        scaleFactor = 0.8;        % Scale down the axes size

        % Get grid dimensions
        numRows = rows;
        numCols = cols;

        % Calculate available width and height for axes
        availableWidth = 1 - horizontalPadding * (numCols + 1);
        availableHeight = 1 - verticalPadding * (numRows + 1);

        % Calculate width and height of each axis
        axWidth = (availableWidth * scaleFactor) / numCols;
        axHeight = (availableHeight * scaleFactor) / numRows;
        pos = [];

        % Calculate position for each subplot within the panel
        for i = 1:numRows * numCols
            row = ceil(i / numCols);  % Determine row index
            col = mod(i - 1, numCols) + 1;  % Determine column index

            % Calculate position [left, bottom, width, height]
            left = (col - 1) * (availableWidth / numCols) + horizontalPadding + 0.05; % Center based on available width
            bottom = 1 - row * (availableHeight / numRows) + verticalPadding; % Adjust for bottom padding

            % Center the axes by adjusting the left position
            left = left + (availableWidth / numCols - axWidth) / 2;

            position = [left, bottom, axWidth, axHeight];
            pos{end + 1} = position;
        end

        for i = 1:numPrimaries

            h = axes('Parent', hPanel2, 'Position', pos{i});
            axes(h);

            % Different shape options
            shapes = {'o', 's', 'd', '^', 'v', '<', '>', 'p', '*'};

            legends = {};

            markersize = 5;

            primaryIndex = i;

            hold on;

            for j = 1:numFiles % Plotting each calibration on the current subplot

                % Plot fitted data (line)
                if j == 1
                    legends{numel(legends)+1} = sprintf('p%d Ref Cal', primaryIndex);
                    lineWidth = 3; % Make the first line bold
                    lineStyle = '-';
                    % Use mod to cycle through colors
                    colors = brewermap(numPrimaries, '*spectral');
                    theColor = colors(mod(primaryIndex-1, size(colors, 1)) + 1, :); % Choice of color                
                    plot(gammaInput{j}, gammaTable{j}(:,primaryIndex),'LineStyle', lineStyle, 'LineWidth', lineWidth, ...
                        'MarkerFaceColor', theColor,'Color', theColor, 'MarkerSize', markersize);
                else
                    % Plot measured data (points)
                    % Check if each entry in rawGammaInput has 1 column
                    isSingleColumn = cellfun(@(x) size(x, 1) == 1, rawGammaInput);
                    shape = shapes{mod(j-1, length(shapes)) + 1}; % Cycle through shapes
                    % Use mod to cycle through colors
                    colors = brewermap(numPrimaries, '*spectral');
                    theColor = colors(mod(primaryIndex-1, size(colors, 1)) + 1, :); % Choice of color

                    if all(isSingleColumn)
                        plot(rawGammaInput{j}, rawGammaTable{j}(:,primaryIndex), shape, ...
                            'MarkerFaceColor', theColor, 'MarkerEdgeColor', theColor*0.5);
                        legends{numel(legends)+1} = sprintf('p%d Cal %d', primaryIndex, j);
                    else
                        plot(rawGammaInput{j}(primaryIndex,:), rawGammaTable{j}(:,primaryIndex), shape, ...
                            'MarkerFaceColor', theColor, 'MarkerEdgeColor', theColor*0.5);
                        legends{numel(legends)+1} = sprintf('p%d Cal %d', primaryIndex, j);
                    end
                end

            end

            hold off
           
            title(sprintf('Gamma Function p%d', i), 'FontSize', 13, 'FontWeight', 'bold');
            xlabel('\it settings value', 'FontName', 'Helvetica');
            ylabel('\it normalized output', 'FontName', 'Helvetica');
            axis([-0.05 1.05 -0.05 1.05]);
            axis 'square'
            box on
            set(gca,  'XColor', 'b', 'YColor', 'b', 'FontSize', 14);

            % Create the legend
            lgd = legend(legends, 'Location', 'northeastoutside', 'NumColumns', legendColumns);

        end

    end

    drawnow;

end
