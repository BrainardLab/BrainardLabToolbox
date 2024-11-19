function plotGammaComparison(obj, figureGroupIndex, gridDims)

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

if all(nDevices == 3) && numFiles == 3 % Only create this plot if there are 3 cals with 3 primaries

    % Setting up plots
    hFig = figure('Name', 'Gamma Data Comparison', 'NumberTitle', 'off', ...
        'Position', [200, 500, 2200, 1200]);

    % Adjust PaperSize to match the figure's dimensions
    figPos = hFig.PaperPosition;
    hFig.PaperSize = [figPos(3) figPos(4)]; % Set PaperSize to the figure's width and height

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

    % Gamma functions.
    plotGammaData(obj, figureGroupIndex, lineColors, hPanel, pos);

end

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

legendColumns = 1;
numSubplots = primariesNum(i);
% 1 = red, 2 = green, 3 = blue

% Define spacing
spacing = 0.01; % Space between subplots
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
        0 1 0;     % Green
        0.5 0 0.5; % Purple
        1 0.75 0.8 % Pink
        ];

    % Different shape options
    shapes = {'o', 's', 'd', '^', 'v', '<', '>', 'p', '*'};

    hold on;

    primaryColumn = {};

    for j = 1:numFiles % Getting gamma table for each file and color

        primaryColumn{j} = gammaTable{j}(:,primaryIndex);

    end

    diff12 = primaryColumn{1} - primaryColumn{2};
    diff13 = primaryColumn{1} - primaryColumn{3};
    diff23 = primaryColumn{2} - primaryColumn{3};

    diffs = {diff12, diff13, diff23};

    % Different shape options
    % shapes = {'o', 's', 'd', '^', 'v', '<', '>', 'p', '*'};

    hold on

    % Loop through each pairwise difference to plot as a line
    for j = 1:length(diffs)

        % shape = shapes{mod(j-1, length(shapes)) + 1}; 
        theColor = colors(j,:); % Cycle through colors

        plot(gammaInput{j}, diffs{j},'s', ...
            'Marker', '+', 'Color', theColor, ...
            'LineWidth', 1.5); 

        % x axis is settings value
        % y axis is delta in normalized output

        if j == 1
            legends{numel(legends)+1} = 'Ref Cal - Cal 2';
        elseif j == 2
            legends{numel(legends)+1} = 'Ref Cal - Cal 3';
        elseif j == 3
            legends{numel(legends)+1} = 'Cal 2 - Cal 3';
        end

    end

    hold off

    xlabel('\it settings value', 'FontSize', 7);

    if i == 1
        ylabel('\it delta normalized output', 'FontName', 'Helvetica');
    end

    titleText = sprintf('Gamma Comparison p%d', i); % Customize your title text
    text(0.5, 1.05, titleText, 'Units', 'normalized', 'HorizontalAlignment', 'center', 'FontSize', 16, 'FontWeight', 'bold');
    %  axis([-0.05 1.05 -0.05 1.05]);
    axis 'square'
    box on
    ylim([-0.5, 0.5]);
    yticks(-0.5:0.25:0.5);
    set(gca,  'XColor', 'b', 'YColor', 'b', 'FontSize', 14);

    % Create the legend
    legend(legends, 'Location', 'northwest', 'NumColumns', legendColumns);

end

drawnow;

end
