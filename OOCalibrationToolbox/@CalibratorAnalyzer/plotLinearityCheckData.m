
% Method to generate plots of the linearity check data.
function plotLinearityCheckData(obj, figureGroupIndex, gridDims)
    
    % Setting up plots
    hFig = figure('Name', 'Linearity Check Data', 'NumberTitle', 'off', ...
        'Position',[200, 500, 2200, 1200]);
    
    % Create a panel in the figure
    hPanel = uipanel('Parent', hFig, 'Position', [0.05 0.05 0.9 0.9]);
    
    % Parameters for padding
    horizontalPadding = 0.03; % Space on the left and right
    verticalPadding = 0.0125;   % Space on the top and bottom
    scaleFactor = 0.95;        % Scale down the axes size
    
    % Extract grid dimensions
    numRows = gridDims(2);
    numCols = gridDims(1);
    
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

    % Basic linearity tests from two measurements
    plotBasicLinearityData(obj, figureGroupIndex, hPanel, pos);
    
    % Plot deviations in xyY of measured from nominal values
    plotDeviationData(obj, figureGroupIndex, hPanel, pos);
    
    % Plot nominal and measured spectra
    plotSpectralAditivityData(obj, figureGroupIndex, hPanel, pos);
end

function plotSpectralAditivityData(obj, figureGroupIndex, hPanel, pos)
    
    ambSpd = obj.newStyleCalarray.rawData.ambientMeasurements;
%
    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJarray.get('S'));
    
    skip = 1+obj.calStructOBJarray.cal.nDevices;
    kValues = 1:skip:min([13 size(obj.newStyleCalarray.rawData.basicLinearityMeasurements1,1)-skip+1]);  
    
    for k = 1:length(kValues)
        kk = kValues(k);
        measuredSpd  = obj.newStyleCalarray.rawData.basicLinearityMeasurements1(kk,:) - ambSpd;
        
        % Sum over all nDevices
        predictedSpd = sum(obj.newStyleCalarray.rawData.basicLinearityMeasurements1(kk+(1:obj.calStructOBJarray.cal.nDevices),:),1);
        
        % Subtract ambient Spd
        predictedSpd = bsxfun(@minus, predictedSpd, ambSpd*obj.calStructOBJarray.cal.nDevices);
        
%         predictedSpd = (obj.newStyleCalarray.rawData.basicLinearityMeasurements1(kk+1,:)-ambSpd) + ...
%                        (obj.newStyleCalarray.rawData.basicLinearityMeasurements1(kk+2,:)-ambSpd) + ...
%                        (obj.newStyleCalarray.rawData.basicLinearityMeasurements1(kk+3,:)-ambSpd);

        if (obj.calStructOBJarray.cal.nDevices == 3)
            figName = sprintf('Additivity check RGB =(%d %d %d)e-2', ...
                round(100*obj.newStyleCalarray.basicLinearitySetup.settings(1,kk)), ...
                round(100*obj.newStyleCalarray.basicLinearitySetup.settings(2,kk)), ...
                round(100*obj.newStyleCalarray.basicLinearitySetup.settings(3,kk)));
        else
            figName = sprintf('Additivity check (multi-primary) setup %d/%d', k, length(kValues));
        end

        % Define a scale factor to reduce size
        scaleFactor = 0.82; % Adjust this value to make the figures smaller

        % Create a new axes in the specified position with reduced size
        originalPos = pos{3 + k - 1}; % Get the original position
        scaledWidth = originalPos(3) * scaleFactor; % Scale down the width
        scaledHeight = originalPos(4) * scaleFactor; % Scale down the height

        % Create the axes with scaled position
        h = axes('Parent', hPanel, 'Position', [originalPos(1), originalPos(2), scaledWidth, scaledHeight]);
        hold(h, 'on');
        
        % Plot predicted spectrum as filled line plot
        [xd, yd] = stairs(spectralAxis, predictedSpd*1000);
        faceColor = [0.5 0.5 0.5]; edgeColor = 'none';
        obj.makeShadedPlot(xd, yd, faceColor, edgeColor, h);
     
        % Plot measured as a line plot on top
        stairs(spectralAxis, measuredSpd*1000, 'Color', 'r', 'LineWidth', 1.0);
        
        set(gca, 'XLim', [380,780], 'YLim', [0 max([0.1 1.05*1000*max([max(predictedSpd) max(measuredSpd)])])]);
        box on;
        hleg = legend({' measured ', ' predicted '}, 'Location', 'NorthEast');
        set(hleg,'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 10);
        set(gca, 'Color', [1 1 1], 'XColor', 'b', 'YColor', 'b');
        set(gca, 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
        xlabel('\it wavelength (nm)', 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
        ylabel('\it power (mWatts)', 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14); 
        title(figName)

        % Finish plot
        drawnow;

    end
end


function plotDeviationData(obj, figureGroupIndex, hPanel, pos)

    % Get T_ensor data
    T_sensor = obj.calStructOBJarray.get('T_sensor');
    
    % Compute measured and nominal xyY values
    basicxyY1  = XYZToxyY(T_sensor * obj.newStyleCalarray.rawData.basicLinearityMeasurements1');
    basicxyY2  = XYZToxyY(T_sensor * obj.newStyleCalarray.rawData.basicLinearityMeasurements2');
    nominalxyY = XYZToxyY(SettingsToSensorAcc(obj.calStructOBJarray, obj.newStyleCalarray.basicLinearitySetup.settings));
    
    % compute deviations of measured from nominal xyY values
    deviationsxyY1 = basicxyY1-nominalxyY;
    deviationsxyY2 = basicxyY2-nominalxyY;

    % Define scale factor to reduce size
    scaleFactor = 0.85; % Adjust this value to make the figures smaller

    % Initialize positions for each axis
    width = (pos{2}(3) / 3) * scaleFactor; % Scale down the width
    height = pos{2}(4) * scaleFactor; % Scale down the height

    % Define spacing amount
    spacing = 0.02; % Adjust this value to increase or decrease spacing

    % Define positions for three axes with spacing
    positions = {
        [pos{2}(1), pos{2}(2), width - spacing, height],  % First axis
        [pos{2}(1) + width + spacing, pos{2}(2), width - spacing, height],  % Second axis
        [pos{2}(1) + 2 * (width + spacing), pos{2}(2), width - spacing, height]   % Third axis
        };

    % Plot data
    ax1 = axes('Parent', hPanel, 'Position', positions{1});
    hold(ax1, 'on');
    plot(nominalxyY(3,:),deviationsxyY1(1,:),'r+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    plot(nominalxyY(3,:),deviationsxyY2(1,:),'b+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-0.2 0.2]);
    hleg = legend('meas #1', 'meas #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica', 'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    xlabel('\it nominal luminance (cd/m^2)', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it delta x-chroma (meas-nominal)', 'FontName', 'Helvetica',  'FontSize', 14);  
    
    title(sprintf('Linearity Deviation: Max abs deviation %0.4f\n',max(abs([deviationsxyY1(1,:) deviationsxyY2(1,:)]))), ...
        'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 11);
        
    ax2 = axes('Parent', hPanel, 'Position', positions{2});
    hold(ax2, 'on');
    plot(nominalxyY(3,:),deviationsxyY1(2,:),'r+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    plot(nominalxyY(3,:),deviationsxyY2(2,:),'b+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-0.2 0.2]);
    hleg = legend('meas #1', 'meas #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica',  'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    xlabel('\it nominal luminance (cd/m2)', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it delta y-chroma (meas-nominal)', 'FontName', 'Helvetica',  'FontSize', 14); 
    title(sprintf('Linearity Deviation: Max abs deviation %0.4f\n',max(abs([deviationsxyY1(2,:) deviationsxyY2(2,:)]))), ...
        'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 11);

    ax3 = axes('Parent', hPanel, 'Position', positions{3});
    hold(ax3, 'on');
    plot(nominalxyY(3,:),deviationsxyY1(3,:),'r+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    plot(nominalxyY(3,:),deviationsxyY2(3,:),'b+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-10 10]);
    hleg = legend('meas #1', 'meas #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica',  'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    xlabel('\it nominal luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 14);
    ylabel('\it delta luminance (meas-nominal)', 'FontName', 'Helvetica',  'FontSize', 14); 
    title(sprintf('Linearity Deviation: Max abs deviation %0.2f\n',max(abs([deviationsxyY1(3,:) deviationsxyY2(3,:)]))), ...
        'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 11);
    

    % Finish plot
    drawnow;

end


function plotBasicLinearityData(obj, figureGroupIndex, hPanel, pos)
    
    % Get T_sensor data
    T_sensor = obj.calStructOBJarray.get('T_sensor');
    
    % Compute measured and nominal xyY values
    basicxyY1  = XYZToxyY(T_sensor * obj.newStyleCalarray.rawData.basicLinearityMeasurements1');
    basicxyY2  = XYZToxyY(T_sensor * obj.newStyleCalarray.rawData.basicLinearityMeasurements2');
    nominalxyY = XYZToxyY(SettingsToSensorAcc(obj.calStructOBJarray, obj.newStyleCalarray.basicLinearitySetup.settings));

    % Define scale factor to reduce size
    scaleFactor = 0.85; % Adjust this value to make the figures smaller

    % Initialize positions for each axis
    width = (pos{1}(3) / 3) * scaleFactor; % Scale down the width
    height = pos{1}(4) * scaleFactor; % Scale down the height

    % Define spacing amount
    spacing = 0.02; % Adjust this value to increase or decrease spacing

    % Define positions for three axes with spacing
    positions = {
        [pos{1}(1), pos{1}(2), width - spacing, height],  % First axis
        [pos{1}(1) + width + spacing, pos{1}(2), width - spacing, height],  % Second axis
        [pos{1}(1) + 2 * (width + spacing), pos{1}(2), width - spacing, height]   % Third axis
        };
    
    % Plot data
    ax1 = axes('Parent', hPanel, 'Position', positions{1});
    hold(ax1, 'on');
    plot(nominalxyY(1,:),basicxyY1(1,:),'rs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    plot(nominalxyY(1,:),basicxyY2(1,:),'bs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    plot([0.1 0.7],[0.1 0.7],'k');
    axis([0.1 0.7 0.1 0.7]);
    axis('square');
    hleg = legend('measurement #1', 'measurement #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    xlabel('\it nominal x-chroma', 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    ylabel('\it measured x-chroma', 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    title('Basic Linearity Test 1')
    

    ax2 = axes('Parent', hPanel, 'Position', positions{2});
    hold(ax2, 'on');
    plot(nominalxyY(2,:),basicxyY1(2,:),'rs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    plot(nominalxyY(2,:),basicxyY2(2,:),'bs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    plot([0.1 0.7],[0.1 0.7],'k');
    axis([0.1 0.7 0.1 0.7]);
    axis('square');
    hleg = legend('measurement #1', 'measurement #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    xlabel('\it nominal y-chroma', 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    ylabel('\it measured y-chroma', 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);    
    title('Basic Linearity Test 2')
    
    ax3 = axes('Parent', hPanel, 'Position', positions{3});
    hold(ax3, 'on');
    plot(nominalxyY(3,:),basicxyY1(3,:), 'rs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    plot(nominalxyY(3,:),basicxyY2(3,:), 'bs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    minVal = min([nominalxyY(3,:),basicxyY1(3,:)])-1;
    maxVal = max([nominalxyY(3,:),basicxyY1(3,:)])+1;
    plot([minVal maxVal],[minVal maxVal],'k');
    axis([minVal maxVal minVal maxVal]);
    axis('square');
    hleg = legend('measurement #1', 'measurement #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    xlabel('\it nominal luminance', 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    ylabel('\it measured luminance', 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);  
    title('Basic Linearity Test 3')
        
    % Finish plot
    drawnow;
            
end
