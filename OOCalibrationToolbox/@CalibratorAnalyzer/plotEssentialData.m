% Method to generate plots of the essential data.
function plotEssentialData(obj, figureGroupIndex)
    
    % Get data
    P_device = obj.calStructOBJ.get('P_device');
    
    % Spectral data
    [nWaves, nDevices] = size(P_device);
    
    % Line colors for the different primaries
    if (nDevices == 3)
        lineColors = [1 0 0; 0 1 0; 0 0 1];
    else
        lineColors = brewermap(nDevices, '*spectral');
    end
    
    % Gamma functions.
    plotGammaData(obj, figureGroupIndex, lineColors);

    if (nWaves > 3)
        % SPDs
        plotSpectralData(obj,  figureGroupIndex, lineColors);
       
        % Ambient SPD
        plotAmbientData(obj,  figureGroupIndex);
        if (nDevices == 3)
            % Full spectral data for all gamma input values (unscaled/scaled)
            plotFullSpectra(obj,  1, 'Red primary', figureGroupIndex, 'NorthWest');
            plotFullSpectra(obj,  2, 'Green primary', figureGroupIndex, 'NorthEast');
            plotFullSpectra(obj,  3, 'Blue primary', figureGroupIndex, 'NorthEast');
        else
            pDisplayed = round(nDevices/3);
            pIndices = 1:pDisplayed;
            plotFullSpectraMultiPrimaries(obj, pIndices, figureGroupIndex, lineColors(pIndices,:));
            
            pIndices = pDisplayed+(1:pDisplayed);
            plotFullSpectraMultiPrimaries(obj, pIndices, figureGroupIndex, lineColors(pIndices,:));
            
            pIndices = (2*pDisplayed+1):nDevices;
            plotFullSpectraMultiPrimaries(obj, pIndices, figureGroupIndex, lineColors(pIndices,:));
        end
        
    end
    
    
    % Chromaticity data
    plotChromaticityData(obj, figureGroupIndex, lineColors);
    
     
    % Chromaticity stability
    plotPrimaryChromaticityStabilityData(obj, figureGroupIndex, lineColors);
    
 
    % Repeatability 
    if (obj.calStructOBJ.get('nAverage') > 1)
        plotRepeatibilityData(obj,  figureGroupIndex, lineColors);
    else
       plotNulPlot(obj, figureGroupIndex);
    end

end

function plotRepeatibilityData(obj, figureGroupIndex, lineColors)

    nAverages    = obj.calStructOBJ.get('nAverage');
    primariesNum = obj.calStructOBJ.get('nDevices');
    nMeasures    = obj.calStructOBJ.get('nMeas');
    T_sensor     = obj.calStructOBJ.get('T_sensor');
    gammaInput   = obj.newStyleCal.rawData.gammaInput;
    
    % Convert the set of measurments to xyY
    primary_xyY = zeros(nAverages, primariesNum, 3, nMeasures);
    for trialIndex = 1:nAverages
        for primaryIndex = 1:primariesNum
            primary_xyY(trialIndex, primaryIndex, :, :) = ...
                XYZToxyY(T_sensor  * (squeeze(obj.newStyleCal.rawData.gammaCurveMeasurements(trialIndex, primaryIndex, :, :)))');
        end
    end
    xChromaIndex   = 1;
    yChromaIndex   = 2;
    lumIndex = 3;
    maxChromaX = max(max(max(squeeze(primary_xyY(:, :, xChromaIndex, :)))));
    maxChromaY = max(max(max(squeeze(primary_xyY(:, :, yChromaIndex, :)))));
    maxLum     = max(max(max(squeeze(primary_xyY(:, :, lumIndex, :)))));
    
    % Init figure
    h = figure('Name', 'Measurement Repeatability', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Luminance of RGB primaries as a function of gamma input value
    subplot(1,3,1); hold on
    lumIndex = 3;
    markerSize = 10;
    for trialIndex = 1:nAverages
        for primaryIndex = 1:primariesNum
            plot(gammaInput, squeeze(primary_xyY(trialIndex, primaryIndex, lumIndex, :)), 'ko-', ...
                'MarkerSize', markerSize, 'MarkerFaceColor', lineColors(primaryIndex,:));
        end
    end
    axis([0 1 0 max([0.1 maxLum])]);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    xlabel('\it settings value', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it luminance (cd/m^2)', 'FontName', 'Helvetica',  'FontSize', 14);    
    
    % x-chromaticity of RGB primaries as a function of gamma input value
    subplot(1,3,2); hold on
    for trialIndex = 1:nAverages
        for primaryIndex = 1:primariesNum
            plot(gammaInput, squeeze(primary_xyY(trialIndex, primaryIndex, xChromaIndex, :)), 'ko-', ...
                'MarkerSize', markerSize, 'MarkerFaceColor', lineColors(primaryIndex,:));
        end
    end
    axis([0 1 0 1]);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    xlabel('\it settings value', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it x-chromaticity', 'FontName', 'Helvetica',  'FontSize', 14);  
    
    % y-chromaticity of RGB primaries as a function of gamma input value
    subplot(1,3,3); hold on
    for trialIndex = 1:nAverages
        for primaryIndex = 1:primariesNum
            plot(gammaInput, squeeze(primary_xyY(trialIndex, primaryIndex, yChromaIndex, :)), ...
                'ko-', 'MarkerSize', markerSize, 'MarkerFaceColor', lineColors(primaryIndex,:));
        end
    end
    axis([0 1 0 1]);
    box on;
    xlabel('\it settings value', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it y-chromaticity', 'FontName', 'Helvetica',  'FontSize', 14);  
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'normal', 'FontSize', 14);
    % Finish plot
    drawnow;
    
    uicontrol(h,  ...
                        'Units',    'normalized',  ...
                        'Position',  [0.01 0.01 0.1 0.1], ...
                        'String',   ' Export ', ...
                        'Fontsize',  14, ...      
                        'FontWeight','Bold', ...
                        'ForegroundColor',     [0.2 0.2 0.2], ...
                        'Callback',  {@obj.SaveFigure_Callback, gcf, get(h, 'Name')} ...
                );
            
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end


function plotNulPlot(obj, figureGroupIndex)
    % Init figure
    h = figure('Name', '(null)', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; 
    axis off
  
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

function plotPrimaryChromaticityStabilityData(obj, figureGroupIndex, lineColors)
    % Init figure
    h = figure('Name', 'Primary Chromaticity Stability', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Get number of calibrated primaries
    primariesNum = obj.calStructOBJ.get('nDevices');
    
    % Get T_ensor data
    T_sensor = obj.calStructOBJ.get('T_sensor');
     
    for primaryIndex = 1:primariesNum
        % Put measurements into columns of a matrix from raw data in calibration file.
        fullSpectra = squeeze(obj.newStyleCal.rawData.gammaCurveMeanMeasurements(primaryIndex, :,:));

        % Compute phosphor chromaticities
        xyYMon = XYZToxyY(T_sensor*fullSpectra');
    
        % Plot data
        %subplot('Position', [0.08 + (primaryIndex-1)*0.32 0.08 0.26 0.9]);
        T_sensor  = obj.calStructOBJ.get('T_sensor');

        % Compute the spectral locus
        xyYLocus = XYZToxyY(T_sensor);
        plot(xyYLocus(1,:)',xyYLocus(2,:)','k');
        
        plot(xyYMon(1,:), xyYMon(2,:), 'k-', 'LineWidth', 2.0);
         
        for k = 1:size(fullSpectra,1)
            plot(xyYMon(1,k), xyYMon(2,k), 's', 'MarkerFaceColor', lineColors(primaryIndex,:), 'MarkerEdgeColor', [0 0 0], 'MarkerSize', 4);
        end
    
        %xmean = mean(squeeze(xyYMon(1,:)));
        %ymean = mean(squeeze(xyYMon(2,:)));
        
        axis([0 0.75 0 0.85]);
        axis('square');
        
        xlabel('\it x chromaticity', 'FontName', 'Helvetica',  'FontSize', 18);
        %if (primaryIndex == 1)
            ylabel('\it y chromaticity', 'FontName', 'Helvetica',  'FontSize', 18);
        %else
        %    ylabel('');
        %end
        set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
        %title(sprintf('%s primary',primaryNames{primaryIndex}));
        box on;
    end

    % Finish plot
    drawnow;
    
    uicontrol(h,  ...
                        'Units',    'normalized',  ...
                        'Position',  [0.01 0.01 0.1 0.1], ...
                        'String',   ' Export ', ...
                        'Fontsize',  14, ...      
                        'FontWeight','normal', ...
                        'ForegroundColor',     [0.2 0.2 0.2], ...
                        'Callback',  {@obj.SaveFigure_Callback, gcf,  get(h, 'Name')} ...
                );
            
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end

function plotChromaticityData(obj, figureGroupIndex, lineColors)
    % Get data
    P_device  = obj.calStructOBJ.get('P_device');
    P_ambient = obj.calStructOBJ.get('P_ambient');
    T_sensor  = obj.calStructOBJ.get('T_sensor');
   

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
    
    % Init figure
    h = figure('Name', 'Primary chromaticities', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Plot data
    legends = {};
    for primaryIndex = 1:primariesNum
        plot(xyYMon(1,primaryIndex)',  xyYMon(2,primaryIndex)',  'ko',  'MarkerFaceColor', lineColors(primaryIndex,:), 'MarkerSize', 10);
        legends{numel(legends)+1} = sprintf('p%d', primaryIndex);
    end
    legends{numel(legends)+1} = 'ambient';
    
    plot(xyYAmb(1,1)',  xyYAmb(2,1)',  'ks',  'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 10);
    plot(xyYLocus(1,:)',xyYLocus(2,:)','k');
    
    hleg = legend(legends, 'Location', 'EastOutside', 'NumColumns',3);
    set(hleg,'FontName', 'Helvetica',  'FontSize', 12);
    
    axis([0 0.75 0 0.85]); axis('square');
    xlabel('\it x chromaticity', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it y chromaticity', 'FontName', 'Helvetica',  'FontSize', 14);
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    box 'on'
    
    % Finish plot
    drawnow;
    
    uicontrol(h,  ...
                        'Units',    'normalized',  ...
                        'Position',  [0.01 0.01 0.1 0.1], ...
                        'String',   ' Export ', ...
                        'Fontsize',  14, ...      
                        'FontWeight','normal', ...
                        'ForegroundColor',     [0.2 0.2 0.2], ...
                        'Callback',  {@obj.SaveFigure_Callback, gcf,  get(h, 'Name')} ...
                );
            
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
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
    
    % Init figure
    h = figure('Name', sprintf('SPD stability (p%d-p%d)', pIndices(1), pIndices(end)), 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum', rows, ...
        'colsNum', cols, ...
        'heightMargin', 0.13, ...
        'widthMargin', 0.06, ...
        'leftMargin', 0.06, ...
        'rightMargin', 0.001, ...
        'bottomMargin', 0.09, ...
        'topMargin', 0.05);
    
    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJ.get('S'));
    
    % Put measurements into columns of a matrix from raw data in calibration file.
    gammaCurveMeanMeasurements = obj.newStyleCal.rawData.gammaCurveMeanMeasurements;
    
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

                subplot('Position', subplotPosVectors(r,c).v);
                hold on;
                x = spectralAxis;
                
                for k = size(scaledSpectra,1):-1:1
                    y = squeeze(scaledSpectra(k,:));
                    plot(x,y, 'k-', 'LineWidth', 1.0);
                end
                
                for k = size(scaledSpectra,1):-1:1
                    y = squeeze(scaledSpectra(k,:));
                    plot(x,y, '-', 'Color', lineColors(pk,:), 'LineWidth', 0.75);
                end
                
  
                title(sprintf('p%d', primaryIndex));
                
                set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
                set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
                axis([380,780,-Inf,Inf]);
                box on;
            end
        end
    end
    
    
    
    
    
    % Finish plot
    drawnow;
    
    uicontrol(h,  ...
                        'Units',    'normalized',  ...
                        'Position',  [0.01 0.01 0.1 0.1], ...
                        'String',   ' Export ', ...
                        'Fontsize',  14, ...      
                        'FontWeight','normal', ...
                        'ForegroundColor',     [0.2 0.2 0.2], ...
                        'Callback',  {@obj.SaveFigure_Callback, gcf,  get(h, 'Name')} ...
                );
            
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
    
    

end


function plotFullSpectra(obj, primaryIndex, primaryName, figureGroupIndex, legendPosition)

    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJ.get('S'));
    
    rawGammaInput = obj.calStructOBJ.get('rawGammaInput');
    
    % Put measurements into columns of a matrix from raw data in calibration file.
    gammaCurveMeanMeasurements = obj.newStyleCal.rawData.gammaCurveMeanMeasurements;
    fullSpectra   = squeeze(gammaCurveMeanMeasurements(primaryIndex, :,:));
    scaledSpectra = 0*fullSpectra;
    
    %maxSpectra    = repmat(max(fullSpectra,[],2), [1 size(fullSpectra,2)]);
    %scaledSpectra = fullSpectra./maxSpectra;    
    maxSpectra = fullSpectra(end,:); 
    for gammaPoint = 1:obj.calStructOBJ.get('nMeas')
        scaledSpectra(gammaPoint,:) = (fullSpectra(gammaPoint,:)' * (fullSpectra(gammaPoint,:)' \ maxSpectra'))';
    end
    
    % Init figure
    h = figure('Name', sprintf('%s SPD stability', primaryName), 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % measured spectra
    subplot('Position', [0.10 0.14 0.37 0.85]);
    x = spectralAxis;
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
        obj.makeShadedPlot(x,y, faceColor, edgeColor);
        legendsMatrix{k} = sprintf('%0.2f', rawGammaInput(size(fullSpectra,1)-k+1));
    end
    hleg = legend(legendsMatrix, 'Location', legendPosition);
    set(hleg,'FontName', 'Helvetica','FontSize', 10);
    
    %plot(obj.spectralAxis, fullSpectra);
    xlabel('\it wavelength (nm)', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it power (mWatts)', 'FontName', 'Helvetica',  'FontSize', 14);
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    axis([380,780,-Inf,Inf]);
    box on;
    
    % scaled spectra
    subplot('Position', [0.60 0.14 0.37 0.85]);
    hold on;
    for k = size(scaledSpectra,1):-1:1
        y = squeeze(scaledSpectra(k,:));
        if (primaryIndex == 1)
            faceColor = [1.0 0.7 0.7];  
        elseif (primaryIndex == 2)
            faceColor = [0.7 1.0 0.7]; 
        elseif (primaryIndex == 3)
            faceColor = [0.7 0.7 1.0]; 
        end
        
        % edgeColor = 'k';
        % obj.makeShadedPlot(x,y, faceColor, edgeColor);
        plot(x,y, 'k-');
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
    
    uicontrol(h,  ...
                        'Units',    'normalized',  ...
                        'Position',  [0.01 0.01 0.1 0.1], ...
                        'String',   ' Export ', ...
                        'Fontsize',  14, ...      
                        'FontWeight','normal', ...
                        'ForegroundColor',     [0.2 0.2 0.2], ...
                        'Callback',  {@obj.SaveFigure_Callback, gcf,  get(h, 'Name')} ...
                );
            
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end


function plotAmbientData(obj,  figureGroupIndex)
    % Init figure
    h = figure('Name', 'Ambient SPD', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJ.get('S'));
    
    % Get data
    P_ambient = obj.calStructOBJ.get('P_ambient');
    
    % Plot data
    x = spectralAxis;
    y = squeeze(P_ambient(:,1))*1000;
    faceColor = [0.9 0.9 0.9]; edgeColor = [0.3 0.3 0.3];
    obj.makeShadedPlot(x,y, faceColor, edgeColor);
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    xlabel('\it wavelength (nm)', 'FontName', 'Helvetica', 'FontSize', 14);
    ylabel('\it power (mWatts)', 'FontName', 'Helvetica',  'FontSize', 14);
    %title('Ambient spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380,780, 0,Inf]);
    set(gca, 'YLim', [0 max([max(y) 1000*eps])]);
    box on;
    
    % Finish plot
    drawnow;
    
    uicontrol(h,  ...
                        'Units',    'normalized',  ...
                        'Position',  [0.01 0.01 0.1 0.1], ...
                        'String',   ' Export ', ...
                        'Fontsize',  14, ...      
                        'FontWeight','normal', ...
                        'ForegroundColor',     [0.2 0.2 0.2], ...
                        'Callback',  {@obj.SaveFigure_Callback, gcf,  get(h, 'Name')} ...
                );
            
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end

function plotSpectralData(obj, figureGroupIndex, lineColors)
    % Init figure
    h = figure('Name', 'Primary SPDs', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJ.get('S'));
    
    % Get data
    P_device = obj.calStructOBJ.get('P_device');
    
    % Get number of calibrated primaries
    primariesNum = obj.calStructOBJ.get('nDevices');

    % Plot data
    x = spectralAxis;
    for primaryIndex = 1:primariesNum
        y = squeeze(P_device(:,primaryIndex))*1000;
        faceColor = lineColors(primaryIndex,:); 
        edgeColor = faceColor*0.5;
        obj.makeShadedPlot(x,y, faceColor, edgeColor);
    end
    
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    xlabel('\it wavelength (nm)', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it power (mWatts)', 'FontName', 'Helvetica', 'FontSize', 14);
    
    %title('Primary spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380,780,-Inf,Inf]);

    box on;
    set(gca, 'FontName', 'Helvetica',  'FontSize', 14);
    
    % Finish plot
    drawnow;
    
    % Add export button
    uicontrol(h,  ...
                        'Units',    'normalized',  ...
                        'Position',  [0.01 0.01 0.1 0.1], ...
                        'String',   ' Export ', ...
                        'Fontsize',  14, ...      
                        'FontWeight','normal', ...
                        'ForegroundColor',     [0.2 0.2 0.2], ...
                        'Callback',  {@obj.SaveFigure_Callback, gcf,  get(h, 'Name')} ...
                );
            
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);  
end

function plotGammaData(obj, figureGroupIndex, lineColors)
    % Init figure
    h = figure('Name', 'Gamma functions', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Get data
    rawGammaInput   = obj.newStyleCal.rawData.gammaInput;
    rawGammaTable   = obj.newStyleCal.rawData.gammaTable;
    gammaInput      = obj.newStyleCal.processedData.gammaInput;
    gammaTable      = obj.newStyleCal.processedData.gammaTable;
    
    % Get number of calibrated primaries
    primariesNum = size(gammaTable,2);
    
    if (primariesNum == 3)
        legendColumns = 1;
    else
        legendColumns = 3;
    end
    
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
    
    xlabel('\it settings value', 'FontName', 'Helvetica',  'FontSize', 14);
    ylabel('\it normalized output', 'FontName', 'Helvetica', 'FontSize', 14);
    %title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([-0.05 1.05 -0.05 1.05]);
    axis 'square'
    box on
    set(gca,  'XColor', 'b', 'YColor', 'b');
    legend(handles, legends, 'Location','EastOutside','NumColumns',legendColumns, 'FontSize', 12);
    
    % Finish plot
    drawnow;
    
    % Add export button
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

