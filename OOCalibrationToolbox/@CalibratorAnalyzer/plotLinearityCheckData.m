% Method to generate plots of the linearity check data.
function plotLinearityCheckData(obj, figureGroupIndex)
   
    % Basic linearity tests from two measurements
    plotBasicLinearityData(obj, figureGroupIndex);
    
    % Plot deviations in xyY of measured from nominal values
    plotDeviationData(obj, figureGroupIndex);
    
    % Plot nominal and measured spectra
    plotSpectralAditivityData(obj, figureGroupIndex);
end

function plotSpectralAditivityData(obj, figureGroupIndex)
%
    ambSpd = obj.newStyleCal.rawData.ambientMeasurements;
%
    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJ.get('S'));
    
    kValues = [1 5 9 13];
    for k = 1:length(kValues)
        kk = kValues(k);
        measuredSpd  = obj.newStyleCal.rawData.basicLinearityMeasurements1(kk,:) - ambSpd; 
        predictedSpd = (obj.newStyleCal.rawData.basicLinearityMeasurements1(kk+1,:)-ambSpd) + ...
                       (obj.newStyleCal.rawData.basicLinearityMeasurements1(kk+2,:)-ambSpd) + ...
                       (obj.newStyleCal.rawData.basicLinearityMeasurements1(kk+3,:)-ambSpd);

        figName = sprintf('Additivity check RGB =(%d %d %d)e-2', ...
            round(100*obj.newStyleCal.basicLinearitySetup.settings(1,kk)), ...
            round(100*obj.newStyleCal.basicLinearitySetup.settings(2,kk)), ...
            round(100*obj.newStyleCal.basicLinearitySetup.settings(3,kk)));

        % Init figure
        h = figure('Name', figName, 'NumberTitle', 'off', 'Visible', 'off'); 
        clf; hold on;

        subplot('Position', [0.1 0.15 0.89 0.82]);
        hold on
        
        % Plot predicted spectrum as filled line plot
        [xd, yd] = stairs(spectralAxis, predictedSpd);
        faceColor = [0.7 0.7 0.7]; edgeColor = 'none';
        obj.makeShadedPlot(xd, yd, faceColor, edgeColor);
     
        % Plot measured as a line plot on top
        stairs(spectralAxis, measuredSpd, 'Color', 'r', 'LineWidth', 2.0);
        
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
end


function plotDeviationData(obj, figureGroupIndex)

    % Get T_ensor data
    T_sensor = obj.calStructOBJ.get('T_sensor');
    
    % Compute measured and nominal xyY values
    basicxyY1  = XYZToxyY(T_sensor * obj.newStyleCal.rawData.basicLinearityMeasurements1');
    basicxyY2  = XYZToxyY(T_sensor * obj.newStyleCal.rawData.basicLinearityMeasurements2');
    nominalxyY = XYZToxyY(SettingsToSensorAcc(obj.calStructOBJ, obj.newStyleCal.basicLinearitySetup.settings));
    
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


function plotBasicLinearityData(obj, figureGroupIndex)
%
    % Get T_ensor data
    T_sensor = obj.calStructOBJ.get('T_sensor');
    
    % Compute measured and nominal xyY values
    basicxyY1  = XYZToxyY(T_sensor * obj.newStyleCal.rawData.basicLinearityMeasurements1');
    basicxyY2  = XYZToxyY(T_sensor * obj.newStyleCal.rawData.basicLinearityMeasurements2');
    nominalxyY = XYZToxyY(SettingsToSensorAcc(obj.calStructOBJ, obj.newStyleCal.basicLinearitySetup.settings));
        
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
