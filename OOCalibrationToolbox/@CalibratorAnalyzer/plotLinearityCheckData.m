% Method to generate plots of the linearity check data.
function plotLinearityCheckData(obj, figureGroupIndex)
    % Get the cal
    calStruct = obj.cal;
   
    % Basic linearity tests from two measurements
    plotBasicLinearityData(obj, calStruct, figureGroupIndex);
    
    % Plot deviations in xyY of measured from nominal values
    plotDeviationData(obj, calStruct, figureGroupIndex);
    
    % Plot nominal and measured spectra
    plotSpectralAditivityData(obj, calStruct, figureGroupIndex);
end

function plotSpectralAditivityData(obj, calStruct, figureGroupIndex)
%
    ambSpd = calStruct.rawData.ambientMeasurements;
%
    kValues = [1 5 9 13];
    for k = 1:length(kValues)
        kk = kValues(k);
        measuredSpd  = calStruct.rawData.basicLinearityMeasurements1(kk,:) - ambSpd; 
        predictedSpd = (calStruct.rawData.basicLinearityMeasurements1(kk+1,:)-ambSpd) + ...
                       (calStruct.rawData.basicLinearityMeasurements1(kk+2,:)-ambSpd) + ...
                       (calStruct.rawData.basicLinearityMeasurements1(kk+3,:)-ambSpd);

        figName = sprintf('Additivity check (%0.2f,%0.2f, %0.2f)', ...
            calStruct.basicLinearitySetup.settings(1,kk), ...
            calStruct.basicLinearitySetup.settings(2,kk), ...
            calStruct.basicLinearitySetup.settings(3,kk));

        % Init figure
        h = figure('Name', figName, 'NumberTitle', 'off', 'Visible', 'off'); 
        clf; hold on;

        subplot('Position', [0.1 0.15 0.89 0.82]);
        hold on
        
        % Plot predicted spectrum as filled line plot
        [xd, yd] = stairs(obj.spectralAxis, predictedSpd);
        faceColor = [0.7 0.7 0.7]; edgeColor = 'none';
        obj.makeShadedPlot(xd, yd, faceColor, edgeColor);
     
        % Plot measured as a line plot on top
        stairs(obj.spectralAxis, measuredSpd, 'Color', 'r', 'LineWidth', 2.0);
        
        set(gca, 'XLim', [380,780], 'YLim', [0 1.05*max([max(predictedSpd) max(measuredSpd)])]);
        box on;
        hleg = legend({' measured ', ' predicted '}, 'Location', 'NorthEast');
        set(hleg,'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 10);
        set(gca, 'Color', [1 1 1], 'XColor', 'b', 'YColor', 'b');
        set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
        xlabel('Wavelength (nm)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
        ylabel('Power', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14); 
      
        % Finish plot
        drawnow;

        % Add figure to the figures group
        obj.updateFiguresGroup(h, figureGroupIndex);
    end
end


function plotDeviationData(obj, calStruct, figureGroupIndex)
    % Compute measured and nominal xyY values
    basicxyY1  = XYZToxyY(obj.T_xyz * calStruct.rawData.basicLinearityMeasurements1');
    basicxyY2  = XYZToxyY(obj.T_xyz * calStruct.rawData.basicLinearityMeasurements2');
    nominalxyY = XYZToxyY(SettingsToSensorAcc(calStruct, calStruct.basicLinearitySetup.settings));
    
    % compute deviations of measured from nominal xyY values
    deviationsxyY1 = basicxyY1-nominalxyY;
    deviationsxyY2 = basicxyY2-nominalxyY;
        
    % Init figure
    h = figure('Name', 'Linearity Deviations', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Plot data
    subplot(1,3,1); hold on
    plot(nominalxyY(3,:),deviationsxyY1(1,:),'r+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    plot(nominalxyY(3,:),deviationsxyY2(1,:),'b+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-0.2 0.2]);
    hleg = legend('meas #1', 'meas #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Nominal Y-luminance (cd/m2)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Delta x-chroma (meas-nominal)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);  
    
    title(sprintf('Max abs deviation %0.4f\n',max(abs([deviationsxyY1(1,:) deviationsxyY2(1,:)]))), ...
        'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 10);
        
    subplot(1,3,2); hold on
    plot(nominalxyY(3,:),deviationsxyY1(2,:),'r+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    plot(nominalxyY(3,:),deviationsxyY2(2,:),'b+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-0.2 0.2]);
    hleg = legend('meas #1', 'meas #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Nominal Y-luminance (cd/m2)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Delta y-chroma (meas-nominal)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14); 
    title(sprintf('Max abs deviation %0.4f\n',max(abs([deviationsxyY1(2,:) deviationsxyY2(2,:)]))), ...
        'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 10);

    subplot(1,3,3); hold on
    plot(nominalxyY(3,:),deviationsxyY1(3,:),'r+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    plot(nominalxyY(3,:),deviationsxyY2(3,:),'b+', 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-5 5]);
    hleg = legend('meas #1', 'meas #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Nominal Y-luminance (cd/m2)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Delta Y-lum (meas-nominal)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14); 
    title(sprintf('Max abs deviation %0.2f\n',max(abs([deviationsxyY1(3,:) deviationsxyY2(3,:)]))), ...
        'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 10);
    

    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end


function plotBasicLinearityData(obj, calStruct, figureGroupIndex)
%
    % Compute measured and nominal xyY values
    basicxyY1  = XYZToxyY(obj.T_xyz * calStruct.rawData.basicLinearityMeasurements1');
    basicxyY2  = XYZToxyY(obj.T_xyz * calStruct.rawData.basicLinearityMeasurements2');
    nominalxyY = XYZToxyY(SettingsToSensorAcc(calStruct, calStruct.basicLinearitySetup.settings));
        
    % Init figure
    h = figure('Name', 'Basic Linearity Tests', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Plot data
    subplot(1,3,1);  hold on    
    plot(nominalxyY(1,:),basicxyY1(1,:),'rs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    plot(nominalxyY(1,:),basicxyY2(1,:),'bs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    plot([0.1 0.7],[0.1 0.7],'k');
    axis([0.1 0.7 0.1 0.7]);
    axis('square');
    hleg = legend('measurement #1', 'measurement #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Nominal x-chroma', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Measured x-chroma', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);    
    

    subplot(1,3,2); hold on
    plot(nominalxyY(2,:),basicxyY1(2,:),'rs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    plot(nominalxyY(2,:),basicxyY2(2,:),'bs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    plot([0.1 0.7],[0.1 0.7],'k');
    axis([0.1 0.7 0.1 0.7]);
    axis('square');
    hleg = legend('measurement #1', 'measurement #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Nominal y-chroma', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Measured y-chroma', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14); 
    
    
    subplot(1,3,3); hold on
    plot(nominalxyY(3,:),basicxyY1(3,:), 'rs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    plot(nominalxyY(3,:),basicxyY2(3,:), 'bs', 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 6);
    minVal = min([nominalxyY(3,:),basicxyY1(3,:)])-1;
    maxVal = max([nominalxyY(3,:),basicxyY1(3,:)])+1;
    plot([minVal maxVal],[minVal maxVal],'k');
    axis([minVal maxVal minVal maxVal]);
    axis('square');
    hleg = legend('measurement #1', 'measurement #2', 'Location', 'SouthEast');
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 10);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Nominal Y-luminance', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Measured Y-luminance', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);  
        
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end
