% Method to generate plots of the essential data.
function plotEssentialData(obj, figureGroupIndex, gridDims)

    % Since there is only one file, the properties don't need to be cell
    % arrays
    obj.calStructOBJarray = obj.calStructOBJarray{1};
    obj.newStyleCalarray = obj.newStyleCalarray{1};
    obj.plotsExportsFolder = obj.plotsExportsFolder{1};
    
    % Get data
    P_device = obj.calStructOBJarray.get('P_device');
    
    % Spectral data
    [nWaves, nDevices] = size(P_device);
    
    % Line colors for the different primaries
    if (nDevices == 3)
        lineColors = [1 0 0; 0 1 0; 0 0 1];
    else
        lineColors = brewermap(nDevices, '*spectral');
    end

    % Setting up plots
    hFig = figure('Name', 'Essential Data', 'NumberTitle', 'off', ...
                   'Position',[200, 500, 2200, 1200]); 

    % Adjust PaperSize to match the figure's dimensions
    figPos = hFig.PaperPosition;
    hFig.PaperSize = [figPos(3) figPos(4)]; % Set PaperSize to the figure's width and height

    % Save as an editable pdf
    set(gcf, 'Renderer', 'painters');

    % Create a panel in the figure
    hPanel = uipanel('Parent', hFig, 'Position', [0.05 0.05 0.9 0.9]);

    % Parameters for padding
    horizontalPadding = 0.03; % Space on the left and right
    verticalPadding = 0.0125;   % Space on the top and bottom
    scaleFactor = 0.95;        % Scale down the axes size

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
        left = (col - 1) * (axWidth + horizontalPadding) + 2 * horizontalPadding;
        bottom = 1 - row * (axHeight + verticalPadding); % Adjust for bottom padding
        position = [left, bottom, axWidth, axHeight];
        pos{end + 1} = position;

    end

    % Gamma functions.
    plotGammaData(obj, figureGroupIndex, lineColors, hPanel, pos);

    % Chromaticity data
    plotChromaticityData(obj, figureGroupIndex, lineColors, hPanel, pos);

    % Chromaticity stability
    plotPrimaryChromaticityStabilityData(obj, figureGroupIndex, lineColors, hPanel, pos);

    if (nWaves > 3)
        % SPDs
        plotSpectralData(obj,  figureGroupIndex, lineColors, hPanel, pos);

        % Ambient SPD
         plotAmbientData(obj,  figureGroupIndex, hPanel, pos);
        if (nDevices == 3)
            % Full spectral data for all gamma input values (unscaled/scaled)
            plotFullSpectra(obj,  1, 'Red primary', figureGroupIndex, 'NorthWest', hPanel, pos);
            plotFullSpectra(obj,  2, 'Green primary', figureGroupIndex, 'NorthEast', hPanel, pos);
            plotFullSpectra(obj,  3, 'Blue primary', figureGroupIndex, 'NorthEast', hPanel, pos);
        else
            pIndices = 1:nDevices;  % Create an index vector for all devices

            plotFullSpectraMultiPrimaries(obj, pIndices, figureGroupIndex, lineColors);
        end

    end

    % Repeatability 
    % if (obj.calStructOBJarray.get('nAverage') > 1)
    %     plotRepeatibilityData(obj,  figureGroupIndex, lineColors, hPanel, pos);
    % else
    %    plotNulPlot(obj, figureGroupIndex, hPanel, pos);
    % end

end

function plotRepeatibilityData(obj, figureGroupIndex, lineColors, hPanel, pos)

    h = axes('Parent', hPanel, 'Position', pos{9});
    ax = h;
    hold on

    % Clear the current axes to prepare for new plot
    cla; % Clear the axes for new plot

    nAverages    = obj.calStructOBJarray.get('nAverage');
    primariesNum = obj.calStructOBJarray.get('nDevices');
    nMeasures    = obj.calStructOBJarray.get('nMeas');
    T_sensor     = obj.calStructOBJarray.get('T_sensor');
    gammaInput   = obj.newStyleCalarray.rawData.gammaInput;
    
    % Convert the set of measurments to xyY
    primary_xyY = zeros(nAverages, primariesNum, 3, nMeasures);
    for trialIndex = 1:nAverages
        for primaryIndex = 1:primariesNum
            primary_xyY(trialIndex, primaryIndex, :, :) = ...
                XYZToxyY(T_sensor  * (squeeze(obj.newStyleCalarray.rawData.gammaCurveMeasurements(trialIndex, primaryIndex, :, :)))');
        end
    end
    xChromaIndex   = 1;
    yChromaIndex   = 2;
    lumIndex = 3;
    maxChromaX = max(max(max(squeeze(primary_xyY(:, :, xChromaIndex, :)))));
    maxChromaY = max(max(max(squeeze(primary_xyY(:, :, yChromaIndex, :)))));
    maxLum     = max(max(max(squeeze(primary_xyY(:, :, lumIndex, :)))));
    
    % Luminance of RGB primaries as a function of gamma input value
    subplot(1,3,1); hold on
    lumIndex = 3;
    markerSize = 10;
%     for trialIndex = 1:nAverages
%         for primaryIndex = 1:primariesNum
%             plot(gammaInput, squeeze(primary_xyY(trialIndex, primaryIndex, lumIndex, :)), '.-', ...
%                 'MarkerSize', markerSize, 'MarkerFaceColor', lineColors(primaryIndex,:), 'Color', lineColors(primaryIndex,:));
%         end
%     end

    for primaryIndex = 1:primariesNum
        x = gammaInput;
        errorbar(x, mean(squeeze(primary_xyY(:, primaryIndex, lumIndex, :)),1), ...
                    std(squeeze(primary_xyY(:, primaryIndex, lumIndex, :)),0,1), ...
                'ko', 'MarkerSize', 8, 'MarkerFaceColor', lineColors(primaryIndex,:), 'MarkerEdgeColor', 0.5*lineColors(primaryIndex,:), 'LineWidth', 1.0);

    end
    
    axis([0 1 0 max([0.1 maxLum])]);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    xlabel('\it settings value', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it luminance (cd/m^2)', 'FontName', 'Helvetica',  'FontSize', 14);    
    
    % x-chromaticity of RGB primaries as a function of gamma input value
    subplot(1,3,2); hold on
%     for trialIndex = 1:nAverages
%         for primaryIndex = 1:primariesNum
%             plot(gammaInput, squeeze(primary_xyY(trialIndex, primaryIndex, xChromaIndex, :)), '.-', ...
%                 'MarkerSize', markerSize, 'MarkerFaceColor', lineColors(primaryIndex,:), 'Color', lineColors(primaryIndex,:));
%         end
%     end
    
    for primaryIndex = 1:primariesNum
        x = gammaInput;
        errorbar(x, mean(squeeze(primary_xyY(:, primaryIndex, xChromaIndex, :)),1), ...
                    std(squeeze(primary_xyY(:, primaryIndex, xChromaIndex, :)),0,1), ...
                'ko', 'MarkerSize', 8, 'MarkerFaceColor', lineColors(primaryIndex,:), 'MarkerEdgeColor', 0.5*lineColors(primaryIndex,:), 'LineWidth', 1.0);
    end
    
    axis([0 1 0 1]);
    box on;
    set(gca, 'Color', [1.0 1.0 1], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    xlabel('\it settings value', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it x-chromaticity', 'FontName', 'Helvetica',  'FontSize', 14);  
    
    % y-chromaticity of RGB primaries as a function of gamma input value
    subplot(1,3,3); hold on
%     for trialIndex = 1:nAverages
%         for primaryIndex = 1:primariesNum
%             plot(gammaInput, squeeze(primary_xyY(trialIndex, primaryIndex, yChromaIndex, :)), '.-', ...
%                 'MarkerSize', markerSize, 'MarkerFaceColor', lineColors(primaryIndex,:), 'Color', lineColors(primaryIndex,:));
%         end
%     end
    
    for primaryIndex = 1:primariesNum
        x = gammaInput;
        errorbar(x, mean(squeeze(primary_xyY(:, primaryIndex, yChromaIndex, :)),1), ...
                    std(squeeze(primary_xyY(:, primaryIndex, yChromaIndex, :)),0,1), ...
                'ko', 'MarkerSize', 8, 'MarkerFaceColor', lineColors(primaryIndex,:), 'MarkerEdgeColor', 0.5*lineColors(primaryIndex,:), 'LineWidth', 1.0);
    end
    
    axis([0 1 0 1]);
    box on;
    xlabel('\it settings value', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it y-chromaticity', 'FontName', 'Helvetica',  'FontSize', 14);  
    set(gca, 'Color', [1.0 1.0 1], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    % Finish plot
    drawnow;
            
end

function makeShadedPlot(x,y, faceColor, edgeColor, ax)
    px = reshape(x, [1 numel(x)]);
    py = reshape(y, [1 numel(y)]);
    px = [px(1) px px(end)];
    py = [1*eps py 2*eps];
    pz = -10*eps*ones(size(py)); 
    patch(ax,px,py,pz,'FaceColor',faceColor,'EdgeColor',edgeColor, 'FaceAlpha', 0.5);
end

function plotNulPlot(obj, figureGroupIndex, hPanel, pos)
    % Init axes
    h = axes('Parent', hPanel, 'Position', pos{3});
    ax = h;
    hold on
    axis off
  
    % Finish plot
    drawnow;

end

function plotPrimaryChromaticityStabilityData(obj, figureGroupIndex, lineColors, hPanel, pos)

    % Get number of calibrated primaries
    primariesNum = obj.calStructOBJarray.get('nDevices');

    if (primariesNum > 3)
        % Init axes
        index = 5;
        scaleFactor = 0.95; % Adjust this value to change the size of the plot
        newWidth = pos{index}(3) * scaleFactor;
        newHeight = pos{index}(4) * scaleFactor;
        newPosition = [pos{index}(1) - 0.01, pos{index}(2) - 0.05, newWidth, newHeight]; % Maintain the same position, but change size
    else
        % Init axes
        index = 1;
        scaleFactor = 0.9; 

        % Compute the size
        newWidth = pos{index}(3) * scaleFactor;
        newHeight = pos{index}(4) * scaleFactor;

        % Adjust position 
        offsetX = ((newWidth - pos{index}(3)) / 2) - 0.07;  % Half the added width
        offsetY = 0.02;
        newPosition = [pos{index}(1) - offsetX, pos{index}(2) - offsetY, newWidth, newHeight]; % Shifted to the right
    end

    h = axes('Parent', hPanel, 'Position', newPosition);
    ax = h;
    hold on
    
    % Get number of calibrated primaries
    primariesNum = obj.calStructOBJarray.get('nDevices');
    
    % Get T_ensor data
    T_sensor = obj.calStructOBJarray.get('T_sensor');
     
    legends = {};
    hpLegends = [];
    for primaryIndex = 1:primariesNum
        legends{numel(legends)+1} = sprintf('p%d', primaryIndex);
        
        % Put measurements into columns of a matrix from raw data in calibration file.
        fullSpectra = squeeze(obj.newStyleCalarray.rawData.gammaCurveMeanMeasurements(primaryIndex, :,:));

        % Compute phosphor chromaticities
        xyYMon = XYZToxyY(T_sensor*fullSpectra');
    
        % Plot data
        %subplot('Position', [0.08 + (primaryIndex-1)*0.32 0.08 0.26 0.9]);
        T_sensor  = obj.calStructOBJarray.get('T_sensor');

        % Compute the spectral locus
        xyYLocus = XYZToxyY(T_sensor);
        plot(xyYLocus(1,:)',xyYLocus(2,:)','k');
        
        plot(xyYMon(1,:), xyYMon(2,:), 'k-', 'LineWidth', 2.0);
        
        for k = size(fullSpectra,1):-1:1
            markerSize = (6 + 10*k/(size(fullSpectra,1)))^2;
            if (k == size(fullSpectra,1))
                hp = plot(xyYMon(1,k), xyYMon(2,k),  'o', 'MarkerFaceColor', lineColors(primaryIndex,:), ...
                'MarkerEdgeColor', [0 0 0], 'MarkerSize', sqrt(markerSize));
                hpLegends(numel(hpLegends)+1) = hp;
            else
                scatter(xyYMon(1,k), xyYMon(2,k), markerSize, 'o', 'MarkerFaceColor', lineColors(primaryIndex,:), ...
                    'MarkerEdgeColor', [0 0 0], 'MarkerFaceAlpha', 0.5);
            end
        end
 
        axis([0 0.75 0 0.85]);
        axis('square');
        
        xlabel('\it x chromaticity', 'FontName', 'Helvetica',  'FontSize', 18);
        if (primaryIndex == 1)
            ylabel('\it y chromaticity', 'FontName', 'Helvetica',  'FontSize', 18);
        else
           ylabel('');
        end
        set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
        % title(sprintf('%s primary',primaryNames{primaryIndex}));
        box on;
    end
    
    hleg = legend(hpLegends, legends, 'Location', 'SouthOutside', 'NumColumns',3);
    set(hleg,'FontName', 'Helvetica',  'FontSize', 12);
    title('Primary Chromaticity Stability');

    % Finish plot
    drawnow;
            
end

function plotChromaticityData(obj, figureGroupIndex, lineColors, hPanel, pos)
    % Get data
    P_device  = obj.calStructOBJarray.get('P_device');
    P_ambient = obj.calStructOBJarray.get('P_ambient');
    T_sensor  = obj.calStructOBJarray.get('T_sensor');
   

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

    if (primariesNum > 3)
        index = 4;
        % Init axes
        scaleFactor = 0.95; % Adjust this value to change the size of the plot
        newWidth = pos{index}(3) * scaleFactor;
        newHeight = pos{index}(4) * scaleFactor;
        newPosition = [pos{index}(1) - 0.007, pos{index}(2) - 0.05, newWidth, newHeight]; % Maintain the same position, but change size
    else
        % Init axes
        index = 1;
        scaleFactor = 0.9; 

        % Compute the size
        newWidth = pos{index}(3) * scaleFactor;
        newHeight = pos{index}(4) * scaleFactor;

        % Adjust position 
        offsetX = 0.07;
        offsetY = 0.02;

        newPosition = [pos{index}(1) - offsetX, pos{index}(2) - offsetY, newWidth, newHeight];
    end

    h = axes('Parent', hPanel, 'Position', newPosition);
    ax = h;
    hold on

    % Plot data
    legends = {};
    for primaryIndex = 1:primariesNum
        plot(xyYMon(1,primaryIndex)',  xyYMon(2,primaryIndex)',  'ko',  'MarkerFaceColor', lineColors(primaryIndex,:), 'MarkerSize', 10);
        legends{numel(legends)+1} = sprintf('p%d', primaryIndex);
    end
    legends{numel(legends)+1} = 'ambient';
    
    plot(xyYAmb(1,1)',  xyYAmb(2,1)',  'ks',  'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 10);
    plot(xyYLocus(1,:)',xyYLocus(2,:)','k');
    
    hleg = legend(legends, 'Location', 'SouthOutside', 'NumColumns',4);
    set(hleg,'FontName', 'Helvetica',  'FontSize', 12);
    
    axis([0 0.75 0 0.85]); axis('square');
    xlabel('\it x chromaticity', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it y chromaticity', 'FontName', 'Helvetica',  'FontSize', 14);
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    title('Primary Chromaticities');
    box 'on'
    
    % Finish plot
    drawnow;

end

function plotFullSpectraMultiPrimaries(obj, pIndices, figureGroupIndex, lineColors)
  
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

    % Setting up plots
    % Making another figure for the SPD stability plots, since there are
    % more than three
    hFig2 = figure('Name', 'Essential Data: SPD Stability', 'NumberTitle', 'off', ...
                   'Position',[200, 500, 2200, 1200]); 

    % Create a panel in the figure
    hPanel2 = uipanel('Parent', hFig2, 'Position', [0.05 0.05 0.9 0.9]);

    % Parameters for padding
    horizontalPadding = 0.03; % Space on the left and right
    verticalPadding = 0.0125;   % Space on the top and bottom
    scaleFactor = 0.95;        % Scale down the axes size

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
        left = (col - 1) * (axWidth + horizontalPadding) + 2 * horizontalPadding;
        bottom = 1 - row * (axHeight + verticalPadding); % Adjust for bottom padding
        position = [left, bottom, axWidth, axHeight];
        pos{end + 1} = position;

    end
    
    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJarray.get('S'));

    rawGammaInput = obj.calStructOBJarray.get('rawGammaInput');
    
    % Put measurements into columns of a matrix from raw data in calibration file.
    gammaCurveMeanMeasurements = obj.newStyleCalarray.rawData.gammaCurveMeanMeasurements;

    numColors = numel(pIndices);

    index = 0;
    pk = 0;
    for r = 1:rows
        for c = 1:cols
            pk = pk + 1;
            if (pk <= numel(pIndices))
                primaryIndex = pIndices(pk);
                fullSpectra   = 1000*squeeze(gammaCurveMeanMeasurements(primaryIndex, :,:));
                scaledSpectra = 0*fullSpectra;
                maxSpectra = fullSpectra(end,:);
                for gammaPoint = 1:obj.calStructOBJ.get('nMeas')
                    scaledSpectra(gammaPoint,:) = (fullSpectra(gammaPoint,:)' * (fullSpectra(gammaPoint,:)' \ maxSpectra'))';
                end

                index = index + 1;
                scaleFactor = 0.8;
                % Setting the axes for each primary
                ax = axes('Parent', hPanel2, 'Position',  [pos{index}(1), pos{index}(2) + 0.01, pos{index}(3)/2 * scaleFactor, pos{index}(4)* scaleFactor]);
                hold(ax, 'on');

                % Plot the full spectra
                for k = size(fullSpectra, 1):-1:1
                    % Get the base color from the lineColors array
                    baseColor = lineColors(mod(primaryIndex - 1, numColors) + 1, :); % Ensure within bounds

                    % Compute the face color transitioning to white
                    fadeFactor = (size(fullSpectra, 1) - k) / (size(fullSpectra, 1) - 1); % Fade factor from 0 to 1
                    faceColor = baseColor * (1 - fadeFactor) + [1, 1, 1] * fadeFactor; % Interpolate towards white

                    edgeColor = 'none'; % Set edgeColor as needed

                    y = squeeze(fullSpectra(k, :)) * 1000;
                    obj.makeShadedPlot(spectralAxis, y, faceColor, edgeColor, ax);
                    legendsMatrix{k} = sprintf('%0.2f', rawGammaInput(size(fullSpectra, 1) - k + 1));
                end

                % Set title and axis properties
                hleg = legend(legendsMatrix, 'Location', 'northeast');
                set(hleg,'FontName', 'Helvetica','FontSize', 10);
                set(ax, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b', 'FontName', 'Helvetica', 'FontSize', 14);
                xlabel(ax, '\it wavelength (nm)', 'FontName', 'Helvetica', 'FontSize', 14);
                ylabel(ax, '\it power (mWatts)', 'FontName', 'Helvetica', 'FontSize', 14);
                axis(ax, [380, 780, -Inf, Inf]);
                box(ax, 'on');

                % Set specific titles for each primary
                t = title(ax, sprintf('Primary %d SPD Stability', primaryIndex));
                t.Position(1) = t.Position(1) + 15; % Move horizontally (right)

                ax2 = axes('Parent', hPanel2, 'Position', [pos{index}(1) + pos{index}(3)/2 + 0.01, pos{index}(2) + 0.01, pos{index}(3)/2 * scaleFactor, pos{index}(4) * scaleFactor]);

                % Plot the scaled spectra with specified colors
                for k = size(scaledSpectra, 1):-1:1
                    y = squeeze(scaledSpectra(k, :));
                    hold(ax2, 'on');
                    plot(ax2, spectralAxis, y, 'k-');
                end

                % Set title and axis properties
                set(ax2, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b', 'FontName', 'Helvetica', 'FontSize', 14);
                xlabel(ax2, '\it wavelength (nm)', 'FontName', 'Helvetica', 'FontSize', 14);
                ylabel(ax2, '\it power (mWatts)', 'FontName', 'Helvetica', 'FontSize', 14);
                axis(ax2, [380, 780, -Inf, Inf]);
                box(ax2, 'on');

            end
        end
    end

            % Finish plot
            drawnow;
end


function plotFullSpectra(obj, primaryIndex, primaryName, figureGroupIndex, legendPosition, hPanel, pos)

    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJarray.get('S'));
    
    rawGammaInput = obj.calStructOBJarray.get('rawGammaInput');
    
    % Put measurements into columns of a matrix from raw data in calibration file.
    gammaCurveMeanMeasurements = obj.newStyleCalarray.rawData.gammaCurveMeanMeasurements;
    fullSpectra   = squeeze(gammaCurveMeanMeasurements(primaryIndex, :,:));
    scaledSpectra = 0*fullSpectra;
    
    %maxSpectra    = repmat(max(fullSpectra,[],2), [1 size(fullSpectra,2)]);
    %scaledSpectra = fullSpectra./maxSpectra;    
    maxSpectra = fullSpectra(end,:); 
    for gammaPoint = 1:obj.calStructOBJarray.get('nMeas')
        scaledSpectra(gammaPoint,:) = (fullSpectra(gammaPoint,:)' * (fullSpectra(gammaPoint,:)' \ maxSpectra'))';
    end
    
    % measured spectra
    subplot();
    x = spectralAxis;

    scaleFactor = 0.8; % Adjust this factor to change size of figure

    % Setting the axes for each primary
    if (primaryIndex == 1)
        ax1 = axes('Parent', hPanel, 'Position',  [pos{4}(1), pos{4}(2) + 0.01, pos{4}(3)/2 * scaleFactor, pos{4}(4)* scaleFactor]);
    elseif (primaryIndex == 2)
        ax1 = axes('Parent', hPanel, 'Position', [pos{5}(1), pos{5}(2) + 0.01, pos{5}(3)/2 * scaleFactor, pos{5}(4) * scaleFactor]);
    elseif (primaryIndex == 3)
        ax1 = axes('Parent', hPanel, 'Position', [pos{6}(1), pos{6}(2) + 0.01, pos{6}(3)/2 * scaleFactor, pos{6}(4) * scaleFactor]);
    end

    for k = size(fullSpectra,1):-1:1
        if (primaryIndex == 1)
            faceColor = [1.0 1.0 1.0] - (k/size(fullSpectra,1)*[0.2 1.0 1.0]);  
            if (mod(k,3) == 0) 
                edgeColor = 'none'; %[0.0 0.0 0.0]; 
            else
                edgeColor = 'none'; 
            end     
        elseif (primaryIndex == 2)
            faceColor = [1.0 1.0 1.0] - (k/size(fullSpectra,1)*[1.0 0.1 1.0]);  
            if (mod(k,3) == 0) 
                edgeColor = 'none'; %[0.0 0.0 0.0]; 
            else
                edgeColor = 'none'; 
            end         
        elseif (primaryIndex == 3)
            faceColor = [1.0 1.0 1.0] - (k/size(fullSpectra,1)*[1.0 1.0 0.1]);  
            if (mod(k,3) == 0) 
                edgeColor = 'none'; %[0.0 0.0 0.0]; 
            else
                edgeColor = 'none';
            end         
        end
        y = squeeze(fullSpectra(k,:))*1000;
        obj.makeShadedPlot(x, y, faceColor, edgeColor, ax1);
        legendsMatrix{k} = sprintf('%0.2f', rawGammaInput(size(fullSpectra,1)-k+1));
    end

    spectraSize = size(fullSpectra, 1);

    if spectraSize <= 11
        hleg = legend(legendsMatrix, 'Location', 'northeast');
        set(hleg,'FontName', 'Helvetica','FontSize', 10);
    else % Reduce the size of the legend if there are too many entries
        % Make a copy of legends matrix
        legendEntries = legendsMatrix;

        % Set all entries to empty except for the first, middle, and last
        midIdx = round(spectraSize / 2);  % Find the middle index
        legendEntries(1:end) = {''};  % Set all entries to empty
        legendEntries{1} = legendsMatrix{1};  % Keep the first entry
        legendEntries{midIdx} = legendsMatrix{midIdx};  % Keep the middle entry
        legendEntries{end} = legendsMatrix{end};  % Keep the last entry

        hleg = legend(legendEntries, 'Location', 'northeast');
        set(hleg,'FontName', 'Helvetica','FontSize', 10);
    end
    
    %plot(obj.spectralAxis, fullSpectra);
    xlabel('\it wavelength (nm)', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it power (mWatts)', 'FontName', 'Helvetica',  'FontSize', 14);
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    axis([380,780,-Inf,Inf]);
    if (primaryIndex == 1)
        title('Red Primary SPD Stability')
    elseif (primaryIndex == 2)
        title('Green Primary SPD Stability')
    elseif (primaryIndex == 3)
        title('Blue Primary SPD Stability')
    end
    box on;
    
    % scaled spectra
    subplot();
    hold on;

    % Setting the axes for each primary
    if (primaryIndex == 1)
        ax1 = axes('Parent', hPanel, 'Position', [pos{4}(1) + pos{4}(3)/2 + 0.01, pos{4}(2) + 0.01, pos{4}(3)/2 * scaleFactor, pos{4}(4) * scaleFactor]);
    elseif (primaryIndex == 2)
        ax2 = axes('Parent', hPanel, 'Position', [pos{5}(1) + pos{5}(3)/2 + 0.01, pos{5}(2) + 0.01, pos{5}(3)/2 * scaleFactor, pos{5}(4) * scaleFactor]);
    elseif (primaryIndex == 3)
        ax3 = axes('Parent', hPanel, 'Position', [pos{6}(1) + pos{6}(3)/2 + 0.01, pos{6}(2) + 0.01, pos{6}(3)/2 * scaleFactor, pos{6}(4) * scaleFactor]);
    end

    for k = size(scaledSpectra,1):-1:1
        y = squeeze(scaledSpectra(k,:));
        if (primaryIndex == 1)
            faceColor = [1.0 0.7 0.7];  
            ax = ax1;
        elseif (primaryIndex == 2)
            faceColor = [0.7 1.0 0.7]; 
            ax = ax2;
        elseif (primaryIndex == 3)
            faceColor = [0.7 0.7 1.0]; 
            ax = ax3;
        end
        hold(ax, 'on');
        plot(ax, x,y, 'k-');
        % edgeColor = 'k';
        % obj.makeShadedPlot(x,y, faceColor, edgeColor);
        % plot(x,y, 'k-');
    end
    %plot(obj.spectralAxis, scaledSpectra);
    xlabel('\it wavelength (nm)', 'FontName', 'Helvetica', 'FontSize', 14);
    ylabel('\it normalized power', 'FontName', 'Helvetica',  'FontSize', 14);
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
   
    axis([380,780,-Inf,Inf]);
    box on;
    
    % Finish plot
    drawnow;
end


function plotAmbientData(obj,  figureGroupIndex, hPanel, pos)
    % Get number of calibrated primaries
    primariesNum = obj.calStructOBJarray.get('nDevices');

    if primariesNum > 3
        scaleFactor = 0.9; 
    else
        scaleFactor = 0.85; 
    end
    
    % Adjust the position using the scale factor
    scaledPosition = [pos{3}(1), pos{3}(2), pos{3}(3) * scaleFactor, pos{3}(4) * scaleFactor];
    
    % Init axes with the scaled position
    h = axes('Parent', hPanel, 'Position', scaledPosition);
    ax = h;
    hold on;
    
    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJarray.get('S'));
    
    % Get data
    P_ambient = obj.calStructOBJarray.get('P_ambient');
    
    % Plot data
    x = spectralAxis;
    y = squeeze(P_ambient(:,1))*1000;
    faceColor = [0.9 0.9 0.9]; edgeColor = [0.3 0.3 0.3];
    obj.makeShadedPlot(x,y, faceColor, edgeColor, ax);
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    xlabel('\it wavelength (nm)', 'FontName', 'Helvetica', 'FontSize', 14);
    ylabel('\it power (mWatts)', 'FontName', 'Helvetica',  'FontSize', 14);
    %title('Ambient spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380,780, 0,Inf]);
    set(gca, 'YLim', [0 max([max(y) 1000*eps])]);
    title('Ambient SPD');
    box on;
    
    % Finish plot
    drawnow;
            
end

function plotSpectralData(obj, figureGroupIndex, lineColors, hPanel, pos)
    % Get number of calibrated primaries
    primariesNum = obj.calStructOBJarray.get('nDevices');

    if primariesNum > 3
        scaleFactor = 0.9; 
    else
        scaleFactor = 0.85; 
    end
    
    % Adjust the position using the scale factor
    scaledPosition = [pos{2}(1), pos{2}(2), pos{2}(3) * scaleFactor, pos{2}(4) * scaleFactor];
    
    % Init axes with the scaled position
    h = axes('Parent', hPanel, 'Position', scaledPosition);
    ax = h;
    hold on;
    
    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJarray.get('S'));
    
    % Get data 
    P_device = obj.calStructOBJarray.get('P_device');

    % Plot data
    x = spectralAxis;
    for primaryIndex = 1:primariesNum
        y = squeeze(P_device(:,primaryIndex))*1000;
        faceColor = lineColors(primaryIndex,:); 
        edgeColor = faceColor*0.5;
        obj.makeShadedPlot(x, y, faceColor, edgeColor, ax);
    end
    
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    xlabel('\it wavelength (nm)', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it power (mWatts)', 'FontName', 'Helvetica', 'FontSize', 14);
    
    %title('Primary spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380,780,-Inf,Inf]);

    box on;
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    title('Primary SPDs');
    
    % Finish plot
    drawnow;

end

function plotGammaData(obj, figureGroupIndex, lineColors, hPanel, pos)
    % Get number of calibrated primaries
    primariesNum = obj.calStructOBJarray.get('nDevices');

    if primariesNum > 3
        scaleFactor = 0.9; 
    else
        scaleFactor = 0.85; 
    end
    
    if primariesNum == 3
        % Get data
        rawGammaInput   = obj.newStyleCalarray.rawData.gammaInput; % Use this if you want to plot measured data
        rawGammaTable   = obj.newStyleCalarray.rawData.gammaTable;  % Use this if you want to plot measured data
        gammaInput      = obj.newStyleCalarray.processedData.gammaInput;
        gammaTable      = obj.newStyleCalarray.processedData.gammaTable;

        % Get number of calibrated primaries
        primariesNum = size(gammaTable,2);
        legendColumns = 1;
 
        for primaryIndex = 1:primariesNum
            
            % Setting axes
            if primaryIndex == 1
                index  = 7;
                % Adjust the position using the scale factor
                scaledPosition = [pos{index}(1) + 0.035, pos{index}(2), pos{index}(3) * scaleFactor, pos{index}(4) * scaleFactor];

                % Init axes with the scaled position
                h = axes('Parent', hPanel, 'Position', scaledPosition);
                ax = h;
                hold on;
                title('Gamma Function p1')
            elseif primaryIndex == 2
                index  = 8;
                % Adjust the position using the scale factor
                scaledPosition = [pos{index}(1) + 0.035, pos{index}(2), pos{index}(3) * scaleFactor, pos{index}(4) * scaleFactor];

                % Init axes with the scaled position
                h = axes('Parent', hPanel, 'Position', scaledPosition);
                ax = h;
                hold on;
                title('Gamma Function p2')
            elseif primaryIndex == 3
                index  = 9;
                % Adjust the position using the scale factor
                scaledPosition = [pos{index}(1) + 0.035, pos{index}(2), pos{index}(3) * scaleFactor, pos{index}(4) * scaleFactor];

                % Init axes with the scaled position
                h = axes('Parent', hPanel, 'Position', scaledPosition);
                ax = h;
                hold on;
                title('Gamma Function p3')
            end

            % Plot fitted (normalized) data
            legends = {};
            handles = [];

            markersize = 5;

            % Adjust gammaInput and gammaTable to only include every 67th point
            indices = 1:67:numel(gammaInput); % Select every 67th index
            gammaInputSubset = gammaInput(indices);
            gammaTableSubset = gammaTable(indices, primaryIndex);

            legends{numel(legends)+1} = sprintf('p%d', primaryIndex);
            theColor = lineColors(primaryIndex,:);
            hP = plot(gammaInputSubset, gammaTableSubset, ...
                'MarkerFaceColor', theColor, 'Color', theColor, 'MarkerSize', markersize, ...
                'Marker', 's', 'LineStyle', 'none'); 
            handles(numel(handles)+1) = hP;

            % Adding the identity line
            minValue = min([gammaInput(:); gammaTable(:)]); % Minimum value for axis limits
            maxValue = max([gammaInput(:); gammaTable(:)]); % Maximum value for axis limits
            hP2 = plot([minValue, maxValue], [minValue, maxValue], '-k', 'LineWidth', 3);
            legends{numel(legends)+1} = 'Identity Line';
            handles(numel(handles)+1) = hP2;

            xlabel('\it settings value', 'FontName', 'Helvetica');
            ylabel('\it normalized output', 'FontName', 'Helvetica');
            %title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
            axis([-0.05 1.05 -0.05 1.05]);
            axis 'square'
            box on
            set(gca,  'XColor', 'b', 'YColor', 'b', 'FontSize', 14);
            legend(handles, legends, 'Location','EastOutside','NumColumns',legendColumns);
        end

    else
        % Adjust the position using the scale factor
        scaledPosition = [pos{1}(1), pos{1}(2), pos{1}(3) * scaleFactor, pos{1}(4) * scaleFactor];

        % Init axes with the scaled position
        h = axes('Parent', hPanel, 'Position', scaledPosition);
        ax = h;
        hold on;

        % Get data
        rawGammaInput   = obj.newStyleCalarray.rawData.gammaInput;
        rawGammaTable   = obj.newStyleCalarray.rawData.gammaTable;
        gammaInput      = obj.newStyleCalarray.processedData.gammaInput;
        gammaTable      = obj.newStyleCalarray.processedData.gammaTable;

        % Get number of calibrated primaries
        primariesNum = size(gammaTable,2);
        legendColumns = 3;
  
        markersize = 5;
        % Plot fitted data
        legends = {};
        handles = [];
        for primaryIndex = 1:primariesNum
            legends{numel(legends)+1} = sprintf('p%d', primaryIndex);
            theColor = lineColors(primaryIndex,:);
            hP = plot(gammaInput, gammaTable(:,primaryIndex),'r-', 'LineWidth', 1.5, ...
                'MarkerFaceColor', theColor, 'Color', theColor, 'MarkerSize', markersize);
            handles(numel(handles)+1) = hP;
        end

        % Plot measured data
        if (size(rawGammaInput,1) == 1)
            for primaryIndex = 1:primariesNum
                theColor = lineColors(primaryIndex,:);
                plot(rawGammaInput, rawGammaTable(:,primaryIndex),'s', ...
                    'MarkerFaceColor', theColor, 'MarkerEdgeColor', theColor*0.5);
            end
        else
            for primaryIndex = 1:primariesNum
                theColor = lineColors(primaryIndex,:);
                plot(rawGammaInput(primaryIndex,:), rawGammaTable(:,primaryIndex),'s', ...
                    'MarkerFaceColor', theColor, 'MarkerEdgeColor', theColor*0.5);
            end
        end

        xlabel('\it settings value', 'FontName', 'Helvetica');
        ylabel('\it normalized output', 'FontName', 'Helvetica');
        %title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
        axis([-0.05 1.05 -0.05 1.05]);
        axis 'square'
        box on
        set(gca,  'XColor', 'b', 'YColor', 'b', 'FontSize', 14);
        title('Gamma Functions');
        legend(handles, legends, 'Location','SouthEast','NumColumns',legendColumns);

    end
    
    % Finish plot
    drawnow;

end

