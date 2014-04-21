% Method to generate plots of the linearity check data.
function plotLinearityCheckData(obj, figureGroupIndex)
    % Get the cal
    calStruct = obj.cal;
   
    plotBasicLinearityData(obj, calStruct, figureGroupIndex);
end

function plotBasicLinearityData(obj, calStruct, figureGroupIndex)
    
    % Load CIE '31 color matching functions
    load T_xyz1931
    T_xyz = SplineCmf(S_xyz1931, 683*T_xyz1931, obj.rawData.S);
    
    basicxyY1  = XYZToxyY(T_xyz*calStruct.rawData.basicLinearityMeasurements1');
    basicxyY2  = XYZToxyY(T_xyz*calStruct.rawData.basicLinearityMeasurements2');
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
