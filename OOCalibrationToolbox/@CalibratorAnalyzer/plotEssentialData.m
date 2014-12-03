% Method to generate plots of the essential data.
function plotEssentialData(obj, figureGroupIndex)
    
    % Gamma functions.
    plotGammaData(obj, figureGroupIndex);

    % Get data
    P_device = obj.calStructOBJ.get('P_device');
    
    % Spectral data
    if (size(P_device, 1) > 3)
        % SPDs
        plotSpectralData(obj,  figureGroupIndex);
        % Ambient SPD
        plotAmbientData(obj,  figureGroupIndex);
        % Full spectral data for all gamma input values (unscaled/scaled)
        plotFullSpectra(obj,  1, 'Red primary', figureGroupIndex, 'NorthWest');
        plotFullSpectra(obj,  2, 'Green primary', figureGroupIndex, 'NorthEast');
        plotFullSpectra(obj,  3, 'Blue primary', figureGroupIndex, 'NorthEast');
    end
    
    % Chromaticity data
    plotChromaticityData(obj, figureGroupIndex);
    
    % Chromaticity stability
    plotPrimaryChromaticityStabilityData(obj, figureGroupIndex);
    
    % Repeatability 
    if (obj.calStructOBJ.get('nAverage') > 0)
        plotRepeatibilityData(obj,  figureGroupIndex);
    else
        plotNulPlot(obj, figureGroupIndex);
    end
    
end

function plotRepeatibilityData(obj, figureGroupIndex)

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
    for trialIndex = 1:nAverages
        plot(gammaInput, squeeze(primary_xyY(trialIndex, 1, lumIndex, :)), 'r.-');
        plot(gammaInput, squeeze(primary_xyY(trialIndex, 2, lumIndex, :)), 'g.-');
        plot(gammaInput, squeeze(primary_xyY(trialIndex, 3, lumIndex, :)), 'b.-');
    end
    axis([0 1 0 maxLum]);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Settings value', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Luminance in cd/m2', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);    
    
    % x-chromaticity of RGB primaries as a function of gamma input value
    subplot(1,3,2); hold on
    for trialIndex = 1:nAverages
        plot(gammaInput, squeeze(primary_xyY(trialIndex, 1, xChromaIndex, :)), 'r.-');
        plot(gammaInput, squeeze(primary_xyY(trialIndex, 2, xChromaIndex, :)), 'g.-');
        plot(gammaInput, squeeze(primary_xyY(trialIndex, 3, xChromaIndex, :)), 'b.-');
    end
    axis([0 1 0 1]);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Settings value', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('x-chromaticity', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);  
    
    % y-chromaticity of RGB primaries as a function of gamma input value
    subplot(1,3,3); hold on
    for trialIndex = 1:nAverages
        plot(gammaInput, squeeze(primary_xyY(trialIndex, 1, yChromaIndex, :)), 'r.-');
        plot(gammaInput, squeeze(primary_xyY(trialIndex, 2, yChromaIndex, :)), 'g.-');
        plot(gammaInput, squeeze(primary_xyY(trialIndex, 3, yChromaIndex, :)), 'b.-');
    end
    axis([0 1 0 1]);
    box on;
    xlabel('Settings value', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('y-chromaticity', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);  
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
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

function plotPrimaryChromaticityStabilityData(obj, figureGroupIndex)
    % Init figure
    h = figure('Name', 'RGB Primaries Chromaticity Stability', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Get number of calibrated primaries
    primariesNum = obj.calStructOBJ.get('nDevices');
    
    % Get T_ensor data
    T_sensor = obj.calStructOBJ.get('T_sensor');
    
    primaryNames = {'red', 'green', 'blue'};
    
    for primaryIndex = 1:primariesNum
        % Put measurements into columns of a matrix from raw data in calibration file.
        fullSpectra = squeeze(obj.newStyleCal.rawData.gammaCurveMeanMeasurements(primaryIndex, :,:));

        % Compute phosphor chromaticities
        xyYMon = XYZToxyY(T_sensor*fullSpectra');
    
        % Plot data
        subplot('Position', [0.08 + (primaryIndex-1)*0.32 0.08 0.26 0.9]);
        T_sensor  = obj.calStructOBJ.get('T_sensor');

        % Compute the spectral locus
        xyYLocus = XYZToxyY(T_sensor);
        plot(xyYLocus(1,:)',xyYLocus(2,:)','k');
        hold on;
        
        plot(xyYMon(1,:), xyYMon(2,:), 'k-');
        
        for k = 1:size(fullSpectra,1)
            if (primaryIndex == 1)
                faceColor = [1.0 1.0 1.0] - (k/size(fullSpectra,1)*[0.2 1.0 1.0]);  
            elseif (primaryIndex == 2)
                faceColor = [1.0 1.0 1.0] - (k/size(fullSpectra,1)*[1.0 0.1 1.0]);
            elseif (primaryIndex == 3)
                faceColor = [1.0 1.0 1.0] - (k/size(fullSpectra,1)*[1.0 1.0 0.1]);
            end
            edgeColor = faceColor;
            plot(xyYMon(1,k), xyYMon(2,k), 's', 'MarkerFaceColor', faceColor, 'MarkerEdgeColor', edgeColor, 'MarkerSize', 8);
        end
    
        %xmean = mean(squeeze(xyYMon(1,:)));
        %ymean = mean(squeeze(xyYMon(2,:)));
        
        axis([0 1 0 1]);
        axis('square');
        
        xlabel('x chromaticity', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
        if (primaryIndex == 1)
            ylabel('y chromaticity', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
        else
            ylabel('');
        end
        set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
        set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
        title(sprintf('%s primary',primaryNames{primaryIndex}));
        box on;
    end

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

function plotChromaticityData(obj, figureGroupIndex)
    % Get data
    P_device  = obj.calStructOBJ.get('P_device');
    P_ambient = obj.calStructOBJ.get('P_ambient');
    T_sensor  = obj.calStructOBJ.get('T_sensor');
   
    % Spectral data
    if (size(P_device, 1) > 3)
        xyYMon = XYZToxyY(T_sensor * P_device);
        xyYAmb = XYZToxyY(T_sensor * P_ambient);
    else
        xyYMon = XYZToxyY(P_device);
        xyYAmb = XYZToxyY(P_ambient);
    end
    % Compute the spectral locus
    xyYLocus = XYZToxyY(T_sensor);
    
    % Init figure
    h = figure('Name', 'RGB primaries chromaticities', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Plot data
    plot(xyYMon(1,1)',  xyYMon(2,1)',  'ro',  'MarkerFaceColor', [1.0 0.5 0.5], 'MarkerSize', 10);
    plot(xyYMon(1,2)',  xyYMon(2,2)',  'go',  'MarkerFaceColor', [0.5 1.0 0.5], 'MarkerSize', 10);
    plot(xyYMon(1,3)',  xyYMon(2,3)',  'bo',  'MarkerFaceColor', [0.5 0.5 1.0], 'MarkerSize', 10);
    plot(xyYAmb(1,1)',  xyYAmb(2,1)',  'ks',  'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 10);
    plot(xyYLocus(1,:)',xyYLocus(2,:)','k');
    
    legendsMatrix= {'Red', 'Green', 'Blue', 'Ambient'};
    hleg = legend(legendsMatrix, 'Location', 'EastOutside');
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 12);
    
    axis([0 1 0 1]); axis('square');
    xlabel('x chromaticity', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('y chromaticity', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    box 'on'
    
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
        y = squeeze(fullSpectra(k,:));
        obj.makeShadedPlot(x,y, faceColor, edgeColor);
        legendsMatrix{k} = sprintf('%0.2f', rawGammaInput(size(fullSpectra,1)-k+1));
    end
    hleg = legend(legendsMatrix, 'Location', legendPosition);
    set(hleg,'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 10);
    
    %plot(obj.spectralAxis, fullSpectra);
    xlabel('Wavelength (nm)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Power', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    axis([380,780,-Inf,Inf]);
    box on;
    
    % scaled spectra
    subplot('Position', [0.60 0.14 0.37 0.85]);
    for k = size(scaledSpectra,1):-1:1
        y = squeeze(scaledSpectra(k,:));
        if (primaryIndex == 1)
            faceColor = [1.0 0.7 0.7];  
        elseif (primaryIndex == 2)
            faceColor = [0.7 1.0 0.7]; 
        elseif (primaryIndex == 3)
            faceColor = [0.7 0.7 1.0]; 
        end
        
        edgeColor = 'k';
        obj.makeShadedPlot(x,y, faceColor, edgeColor);
    end
    %plot(obj.spectralAxis, scaledSpectra);
    xlabel('Wavelength (nm)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Normalized Power', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    axis([380,780,-Inf,Inf]);
    box on;
    
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
    y = squeeze(P_ambient(:,1));
    faceColor = [0.9 0.9 0.9]; edgeColor = [0.3 0.3 0.3];
    obj.makeShadedPlot(x,y, faceColor, edgeColor);
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Wavelength (nm)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Power', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    %title('Ambient spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380,780, 0,Inf]);
    box on;
    
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

function plotSpectralData(obj, figureGroupIndex)
    % Init figure
    h = figure('Name', 'Primary SPDs', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    
    % Compute spectral axis
    spectralAxis = SToWls(obj.calStructOBJ.get('S'));
    
    % Get data
    P_device = obj.calStructOBJ.get('P_device');
    
    % Get number of calibrated primaries
    primariesNum = obj.calStructOBJ.get('nDevices');
    if (primariesNum > 3)
        subplot(1,2,1); hold on;
    end

    % Plot data
    x = spectralAxis;
    y = squeeze(P_device(:,1));
    faceColor = [1.0 0.7 0.7]; edgeColor = 'r';
    obj.makeShadedPlot(x,y, faceColor, edgeColor);
    
    y = squeeze(P_device(:,2));
    faceColor = [0.7 1.0 0.7]; edgeColor = 'g';
    obj.makeShadedPlot(x,y, faceColor, edgeColor);
    
    y = squeeze(P_device(:,3));
    faceColor = [0.7 0.7 1.0]; edgeColor = 'b';
    obj.makeShadedPlot(x,y, faceColor, edgeColor);

    y = squeeze(P_device(:,1));
    plot(x,y, 'r-');
    
    y = squeeze(P_device(:,2));
    plot(x,y, 'g-');
    
    y = squeeze(P_device(:,3));
    plot(x,y, 'b-');
    
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Wavelength (nm)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Power', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    
    %title('Primary spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380,780,-Inf,Inf]);

    if (primariesNum > 3)
        subplot(1,2,2); hold on;
        plot(spectralAxis, P_device(:,4), 'r');
        plot(spectralAxis, P_device(:,5), 'g');
        plot(spectralAxis, P_device(:,6), 'b');
        xlabel('Wavelength (nm)', 'Fontweight', 'bold');
        ylabel('Power', 'Fontweight', 'bold');
        %title('Phosphor correction', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
        axis([380,780,-Inf,Inf]);
    end
    box on;
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    
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

function plotGammaData(obj, figureGroupIndex)
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
    if (primariesNum > 3)
        subplot(1,2,1); hold on;
    end
    
    % Plot fitted data
    plot(gammaInput, gammaTable(:,1),'r-');
    plot(gammaInput, gammaTable(:,2),'g-');
    plot(gammaInput, gammaTable(:,3),'b-');
    
    if (primariesNum > 3)
        subplot(1,2,2); hold on;
        % Plot fitted data
        plot(gammaInput, gammaTable(:,4),'r-');
        plot(gammaInput, gammaTable(:,5),'g-');
        plot(gammaInput, gammaTable(:,6),'b-');
    end
    
    % Plot measured data
    if (size(rawGammaInput,1) == 1)
        plot(rawGammaInput, rawGammaTable(:,1), ...
            'rs', 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerEdgeColor', [1 0 0]);
        plot(rawGammaInput, rawGammaTable(:,2), ...
            'gs', 'MarkerFaceColor', [0.8 1.0 0.8], 'MarkerEdgeColor', [0 1 0]);
        plot(rawGammaInput, rawGammaTable(:,3), ...
            'bs', 'MarkerFaceColor', [1.0 1.0 0.8], 'MarkerEdgeColor', [0 0 1]);
    else
        plot(rawGammaInput(1,:), rawGammaTable(:,1), ...
            'rs', 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerEdgeColor', [1 0 0]);
        plot(rawGammaInput(2,:), rawGammaTable(:,2), ...
            'gs', 'MarkerFaceColor', [0.8 1.0 0.8], 'MarkerEdgeColor', [0 1 0]);
        plot(rawGammaInput(3,:), rawGammaTable(:,3), ...
            'bs', 'MarkerFaceColor', [1.0 1.0 0.8], 'MarkerEdgeColor', [0 0 1]);
    end
    
    xlabel('Settings value', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Normalized output', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    %title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([0 1 0 1.2]);

    if (primariesNum > 3)
        subplot(1,2,2); hold on;
        % Plot measured data
        if (size(rawGammaInput,1) == 1)
            plot(rawGammaInput, rawGammaTable(:,4), ...
                'rs', 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerEdgeColor', [1 0 0]);
            plot(rawGammaInput, rawGammaTable(:,5), ...
                'gs', 'MarkerFaceColor', [0.8 1.0 0.8], 'MarkerEdgeColor', [0 1 0]);
            plot(rawGammaInput, rawGammaTable(:,6), ...
                'bs', 'MarkerFaceColor', [1.0 1.0 0.8], 'MarkerEdgeColor', [0 0 1]);
        else
            plot(rawGammaInput(1,:), rawGammaTable(:,4), ...
                'rs', 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerEdgeColor', [1 0 0]);
            plot(rawGammaInput(2,:), rawGammaTable(:,5), ...
                'gs', 'MarkerFaceColor', [0.8 1.0 0.8], 'MarkerEdgeColor', [0 1 0]);
            plot(rawGammaInput(3,:), rawGammaTable(:,6), ...
                'bs', 'MarkerFaceColor', [1.0 1.0 0.8], 'MarkerEdgeColor', [0 0 1]);
        end
    
        xlabel('Input value', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
        ylabel('Normalized output', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
        %title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
        axis([0 1 0 1.2]);
    end
    
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    box on;
    
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

