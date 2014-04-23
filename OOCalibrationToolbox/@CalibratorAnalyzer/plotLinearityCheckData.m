% Method to generate plots of the linearity check data.
function plotLinearityCheckData(obj, figureGroupIndex)
    % Get the cal
    calStruct = obj.cal;
   
    plotBasicLinearityData(obj, calStruct, figureGroupIndex);
    plotDeviationData(obj, calStruct, figureGroupIndex);
    
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

        subplot('Position', [0.05 0.05 0.94 0.94]);
        plot(obj.spectralAxis, measuredSpd,'r-');
        hold on
        plot(obj.spectralAxis, predictedSpd,'b-');
        legend('measured', 'predicted');
        set(gca, 'YLim', [0 max([max(predictedSpd) max(measuredSpd)])]);
        % Finish plot
        drawnow;

        % Add figure to the figures group
        obj.updateFiguresGroup(h, figureGroupIndex);
    end
end


function plotDeviationData(obj, calStruct, figureGroupIndex)

    basicxyY1  = XYZToxyY(obj.T_xyz * calStruct.rawData.basicLinearityMeasurements1');
    basicxyY2  = XYZToxyY(obj.T_xyz * calStruct.rawData.basicLinearityMeasurements2');
    nominalxyY = XYZToxyY(SettingsToSensorAcc(calStruct, calStruct.basicLinearitySetup.settings));
    
    deviationsxyY1 = basicxyY1-nominalxyY;
    deviationsxyY2 = basicxyY2-nominalxyY;
        
    % Init figure
    h = figure('Name', 'Linearity Deviations', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Plot data
    subplot(1,3,1); hold on
    plot(nominalxyY(3,:),deviationsxyY1(1,:),'r+');
    plot(nominalxyY(3,:),deviationsxyY2(1,:),'b+');
    xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-0.2 0.2]);
    xlabel('Nominal Y');
    ylabel('x meas-nominal');
    title(sprintf('Max abs deviation %0.4f\n',max(abs([deviationsxyY1(1,:) deviationsxyY2(1,:)]))));
        
    subplot(1,3,2); hold on
    plot(nominalxyY(3,:),deviationsxyY1(2,:),'r+');
    plot(nominalxyY(3,:),deviationsxyY2(2,:),'b+');
    xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-0.2 0.2]);
    xlabel('Nominal Y');
    ylabel('y meas-nominal');
    title(sprintf('Max abs deviation %0.4f\n',max(abs([deviationsxyY1(2,:) deviationsxyY2(2,:)]))));

    subplot(1,3,3); hold on
    plot(nominalxyY(3,:),deviationsxyY1(3,:),'r+');
    plot(nominalxyY(3,:),deviationsxyY2(3,:),'b+');
    xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-5 5]);
    xlabel('Nominal Y');
    ylabel('Y meas-nominal');
    title(sprintf('Max abs deviation %0.2f\n',max(abs([deviationsxyY1(3,:) deviationsxyY2(3,:)]))));

    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end


function plotBasicLinearityData(obj, calStruct, figureGroupIndex)
%
    basicxyY1  = XYZToxyY(obj.T_xyz * calStruct.rawData.basicLinearityMeasurements1');
    basicxyY2  = XYZToxyY(obj.T_xyz * calStruct.rawData.basicLinearityMeasurements2');
    nominalxyY = XYZToxyY(SettingsToSensorAcc(calStruct, calStruct.basicLinearitySetup.settings));
        
    % Init figure
    h = figure('Name', 'Basic Linearity Tests', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Plot data
    subplot(1,3,1); hold on
    plot(nominalxyY(1,:),basicxyY1(1,:),'r+');
    plot(nominalxyY(1,:),basicxyY2(1,:),'b+');
    plot([0.1 0.7],[0.1 0.7],'k');
    axis([0.1 0.7 0.1 0.7]);
    xlabel('Nominal x');
    ylabel('Measured x');
    axis('square');
        
    subplot(1,3,2); hold on
    plot(nominalxyY(2,:),basicxyY1(2,:),'r+');
    plot(nominalxyY(2,:),basicxyY2(2,:),'b+');
    plot([0.1 0.7],[0.1 0.7],'k');
    axis([0.1 0.7 0.1 0.7]);
    xlabel('Nominal y');
    ylabel('Measured y');
    axis('square');

    subplot(1,3,3); hold on
    plot(nominalxyY(3,:),basicxyY1(3,:),'r+');
    plot(nominalxyY(3,:),basicxyY2(3,:),'b+');
    minVal = min([nominalxyY(3,:),basicxyY1(3,:)])-1;
    maxVal = max([nominalxyY(3,:),basicxyY1(3,:)])+1;
    plot([minVal maxVal],[minVal maxVal],'k');
    axis([minVal maxVal minVal maxVal]);
    xlabel('Nominal Y (cd/m2)');
    ylabel('Measured Y (cd/m2)');
    axis('square');
        
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end
