% Method to generate plots of the essential data.
function plotEssentialData(obj, figureGroupIndex)

    % Get the cal
    calStruct = obj.cal;
    
    % Gamma functions.
    plotGammaData(obj, calStruct, figureGroupIndex);

    % Spectral data
    if (obj.measurementChannelsNum > 3)
        % SPDs
        plotSpectralData(obj, calStruct, figureGroupIndex);
        % Ambient SPD
        plotAmbientData(obj, calStruct, figureGroupIndex);
        % Full spectral data for all gamma input values (unscaled/scaled)
        plotFullSpectra(obj, calStruct, 1, 'Red primary', figureGroupIndex, 'NorthWest');
        plotFullSpectra(obj, calStruct, 2, 'Green primary', figureGroupIndex, 'NorthEast');
        plotFullSpectra(obj, calStruct, 3, 'Blue primary', figureGroupIndex, 'NorthEast');
    end
    
    % Chromaticity data
    plotChromaticityData(obj, calStruct, figureGroupIndex);
    
    % Chromaticity stability
    plotPrimaryChromaticityStabilityData(obj, calStruct, figureGroupIndex);
    
    % Repeatability 
    if (calStruct.describe.nAverage > 1)
        plotRepeatibilityData(obj, calStruct, figureGroupIndex);
    else
        plotNulPlot(obj, calStruct, figureGroupIndex)
    end
    
end

function plotRepeatibilityData(obj, calStruct, figureGroupIndex)
    % Convert the set of measurments to xyY
    primary_xyY = zeros(calStruct.describe.nAverage, calStruct.describe.displayPrimariesNum, 3, calStruct.describe.nMeas);
    for trialIndex = 1:calStruct.describe.nAverage
        for primaryIndex = 1:calStruct.describe.displayPrimariesNum
            primary_xyY(trialIndex, primaryIndex, :, :) = ...
                XYZToxyY(obj.T_xyz  * (squeeze(calStruct.rawData.gammaCurveMeasurements(trialIndex, primaryIndex, :, :)))');
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
    for trialIndex = 1:calStruct.describe.nAverage
        plot(calStruct.rawData.gammaInput, squeeze(primary_xyY(trialIndex, 1, lumIndex, :)), 'r.-');
        plot(calStruct.rawData.gammaInput, squeeze(primary_xyY(trialIndex, 2, lumIndex, :)), 'g.-');
        plot(calStruct.rawData.gammaInput, squeeze(primary_xyY(trialIndex, 3, lumIndex, :)), 'b.-');
    end
    axis([0 1 0 maxLum]);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Settings value', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Luminance in cd/m2', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);    
    
    % x-chromaticity of RGB primaries as a function of gamma input value
    subplot(1,3,2); hold on
    for trialIndex = 1:calStruct.describe.nAverage
        plot(calStruct.rawData.gammaInput, squeeze(primary_xyY(trialIndex, 1, xChromaIndex, :)), 'r.-');
        plot(calStruct.rawData.gammaInput, squeeze(primary_xyY(trialIndex, 2, xChromaIndex, :)), 'g.-');
        plot(calStruct.rawData.gammaInput, squeeze(primary_xyY(trialIndex, 3, xChromaIndex, :)), 'b.-');
    end
    axis([0 1 0 1]);
    box on;
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Settings value', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('x-chromaticity', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);  
    
    % y-chromaticity of RGB primaries as a function of gamma input value
    subplot(1,3,3); hold on
    for trialIndex = 1:calStruct.describe.nAverage
        plot(calStruct.rawData.gammaInput, squeeze(primary_xyY(trialIndex, 1, yChromaIndex, :)), 'r.-');
        plot(calStruct.rawData.gammaInput, squeeze(primary_xyY(trialIndex, 2, yChromaIndex, :)), 'g.-');
        plot(calStruct.rawData.gammaInput, squeeze(primary_xyY(trialIndex, 3, yChromaIndex, :)), 'b.-');
    end
    axis([0 1 0 1]);
    box on;
    xlabel('Settings value', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('y-chromaticity', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);  
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end


function plotNulPlot(obj, calStruct, figureGroupIndex)
    % Init figure
    h = figure('Name', '(null)', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; 
    axis off
  
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end

function plotPrimaryChromaticityStabilityData(obj, calStruct, figureGroupIndex)
    % Init figure
    h = figure('Name', 'RGB Primaries Chromaticity Stability', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    for primaryIndex = 1:calStruct.describe.displayPrimariesNum
        % Put measurements into columns of a matrix from raw data in calibration file.
        fullSpectra = squeeze(calStruct.rawData.gammaCurveMeanMeasurements(primaryIndex, :,:));

        % Compute phosphor chromaticities
        xyYMon = XYZToxyY(obj.T_xyz*fullSpectra');
    
        % Plot data
        subplot('Position', [0.08 + (primaryIndex-1)*0.32 0.08 0.26 0.9]);
        plot(xyYMon(1,:), xyYMon(2,:), 'k-');
        hold on;
        for k = size(fullSpectra,1):-1:1
            if (primaryIndex == 1)
                faceColor = [1.0 1.0 1.0] - (k/size(fullSpectra,1)*[0.2 1.0 1.0]);  
            elseif (primaryIndex == 2)
                faceColor = [1.0 1.0 1.0] - (k/size(fullSpectra,1)*[1.0 0.1 1.0]);
            elseif (primaryIndex == 3)
                faceColor = [1.0 1.0 1.0] - (k/size(fullSpectra,1)*[1.0 1.0 0.1]);
            end
            edgeColor = 'k';
            plot(xyYMon(1,k), xyYMon(2,k), 's', 'MarkerFaceColor', faceColor, 'MarkerEdgeColor', edgeColor, 'MarkerSize', 6);
        end
    
    
        xmean = mean(squeeze(xyYMon(1,:)));
        ymean = mean(squeeze(xyYMon(2,:)));
        range = 0.05;
        axis([xmean-range/2.0 xmean+range/2.0 ymean-range/2.0 ymean+range/2.0]); 
        axis('square');
        
        xlabel('x chromaticity', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
        if (primaryIndex == 1)
            ylabel('y chromaticity', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
        else
            ylabel('');
        end
        set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
        set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
        %title(sprintf('Lower %d luminances in black',nDontPlotLowPower));
    box on;
    end
    
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end

function plotChromaticityData(obj, calStruct, figureGroupIndex)

    % Compute xyLum of the three primaries
    if (obj.measurementChannelsNum > 3)
        xyYMon = XYZToxyY(obj.T_xyz * calStruct.processedData.P_device);
        xyYAmb = XYZToxyY(obj.T_xyz * calStruct.processedData.P_ambient);
    else
        xyYMon = XYZToxyY(calStruct.processedData.P_device);
        xyYAmb = XYZToxyY(calStruct.processedData.P_ambient);
    end
    % Compute the spectral locus
    xyYLocus = XYZToxyY(obj.T_xyz);
    
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
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end


function plotFullSpectra(obj, calStruct, primaryIndex, primaryName, figureGroupIndex, legendPosition)
    % Put measurements into columns of a matrix from raw data in calibration file.
    fullSpectra   = squeeze(calStruct.rawData.gammaCurveMeanMeasurements(primaryIndex, :,:));
    scaledSpectra = 0*fullSpectra;
    
    %maxSpectra    = repmat(max(fullSpectra,[],2), [1 size(fullSpectra,2)]);
    %scaledSpectra = fullSpectra./maxSpectra;    
    maxSpectra = fullSpectra(end,:); 
    for gammaPoint = 1:calStruct.describe.nMeas
        scaledSpectra(gammaPoint,:) = (fullSpectra(gammaPoint,:)' * (fullSpectra(gammaPoint,:)' \ maxSpectra'))';
    end
    
    % Init figure
    h = figure('Name', sprintf('%s SPD stability', primaryName), 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % measured spectra
    subplot('Position', [0.10 0.14 0.37 0.85]);
    x = obj.spectralAxis;
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
        legendsMatrix{k} = sprintf('%0.2f', calStruct.rawData.gammaInput(size(fullSpectra,1)-k+1));
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
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end


function plotAmbientData(obj, calStruct, figureGroupIndex)
    % Init figure
    h = figure('Name', 'Ambient SPD', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Plot data
    x = obj.spectralAxis;
    y = squeeze(calStruct.processedData.P_ambient(:,1));
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
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end

function plotSpectralData(obj, calStruct, figureGroupIndex)
    % Init figure
    h = figure('Name', 'Primary SPDs', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Get number of calibrated primaries
    primariesNum = size(obj.rawData.gammaTable,2);
    if (primariesNum > 3)
        subplot(1,2,1); hold on;
    end

    % Plot data
    x = obj.spectralAxis;
    y = squeeze(calStruct.processedData.P_device(:,1));
    faceColor = [1.0 0.7 0.7]; edgeColor = 'r';
    obj.makeShadedPlot(x,y, faceColor, edgeColor);
    
    y = squeeze(calStruct.processedData.P_device(:,2));
    faceColor = [0.7 1.0 0.7]; edgeColor = 'g';
    obj.makeShadedPlot(x,y, faceColor, edgeColor);
    
    y = squeeze(calStruct.processedData.P_device(:,3));
    faceColor = [0.7 0.7 1.0]; edgeColor = 'b';
    obj.makeShadedPlot(x,y, faceColor, edgeColor);

    y = squeeze(calStruct.processedData.P_device(:,1));
    plot(x,y, 'r-');
    
    y = squeeze(calStruct.processedData.P_device(:,2));
    plot(x,y, 'g-');
    
    y = squeeze(calStruct.processedData.P_device(:,3));
    plot(x,y, 'b-');
    
    set(gca, 'Color', [1.0 1.0 1.0], 'XColor', 'b', 'YColor', 'b');
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    xlabel('Wavelength (nm)', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Power', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    
    %title('Primary spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380,780,-Inf,Inf]);

    if (primariesNum > 3)
        subplot(1,2,2); hold on;
        plot(obj.spectralAxis, calStruct.processedData.P_device(:,4), 'r');
        plot(obj.spectralAxis, calStruct.processedData.P_device(:,5), 'g');
        plot(obj.spectralAxis, calStruct.processedData.P_device(:,6), 'b');
        xlabel('Wavelength (nm)', 'Fontweight', 'bold');
        ylabel('Power', 'Fontweight', 'bold');
        %title('Phosphor correction', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
        axis([380,780,-Inf,Inf]);
    end
    box on;
    set(gca, 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);  
end

function plotGammaData(obj, calStruct, figureGroupIndex)
    % Init figure
    h = figure('Name', 'Gamma functions', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Get number of calibrated primaries
    primariesNum = size(obj.rawData.gammaTable,2);
    if (primariesNum > 3)
        subplot(1,2,1); hold on;
    end
    
    % Plot fitted data
    plot(calStruct.processedData.gammaInput, calStruct.processedData.gammaTable(:,1),'r-');
    plot(calStruct.processedData.gammaInput, calStruct.processedData.gammaTable(:,2),'g-');
    plot(calStruct.processedData.gammaInput, calStruct.processedData.gammaTable(:,3),'b-');
    
    if (primariesNum > 3)
        subplot(1,2,2); hold on;
        % Plot fitted data
        plot(calStruct.processedData.gammaInput, calStruct.processedData.gammaTable(:,4),'r-');
        plot(calStruct.processedData.gammaInput, calStruct.processedData.gammaTable(:,5),'g-');
        plot(calStruct.processedData.gammaInput, calStruct.processedData.gammaTable(:,6),'b-');
    
    end
    
    % Plot measured data
    if (size(calStruct.rawData.gammaInput,1) == 1)
        plot(calStruct.rawData.gammaInput, calStruct.rawData.gammaTable(:,1), ...
            'rs', 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerEdgeColor', [1 0 0]);
        plot(calStruct.rawData.gammaInput, calStruct.rawData.gammaTable(:,2), ...
            'gs', 'MarkerFaceColor', [0.8 1.0 0.8], 'MarkerEdgeColor', [0 1 0]);
        plot(calStruct.rawData.gammaInput, calStruct.rawData.gammaTable(:,3), ...
            'bs', 'MarkerFaceColor', [1.0 1.0 0.8], 'MarkerEdgeColor', [0 0 1]);
    else
        plot(calStruct.rawData.gammaInput(1,:), calStruct.rawData.gammaTable(:,1), ...
            'rs', 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerEdgeColor', [1 0 0]);
        plot(calStruct.rawData.gammaInput(2,:), calStruct.rawData.gammaTable(:,2), ...
            'gs', 'MarkerFaceColor', [0.8 1.0 0.8], 'MarkerEdgeColor', [0 1 0]);
        plot(calStruct.rawData.gammaInput(3,:), calStruct.rawData.gammaTable(:,3), ...
            'bs', 'MarkerFaceColor', [1.0 1.0 0.8], 'MarkerEdgeColor', [0 0 1]);
    end
    
    xlabel('Settingsvalue', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    ylabel('Normalized output', 'FontName', 'Helvetica', 'Fontweight', 'bold', 'FontSize', 14);
    %title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([0 1 0 1.2]);

    if (primariesNum > 3)
        subplot(1,2,2); hold on;
        % Plot measured data
        if (size(calStruct.rawData.gammaInput,1) == 1)
            plot(calStruct.rawData.gammaInput, calStruct.rawData.gammaTable(:,4), ...
                'rs', 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerEdgeColor', [1 0 0]);
            plot(calStruct.rawData.gammaInput, calStruct.rawData.gammaTable(:,5), ...
                'gs', 'MarkerFaceColor', [0.8 1.0 0.8], 'MarkerEdgeColor', [0 1 0]);
            plot(calStruct.rawData.gammaInput, calStruct.rawData.gammaTable(:,6), ...
                'bs', 'MarkerFaceColor', [1.0 1.0 0.8], 'MarkerEdgeColor', [0 0 1]);
        else
            plot(calStruct.rawData.gammaInput(1,:), calStruct.rawData.gammaTable(:,4), ...
                'rs', 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerEdgeColor', [1 0 0]);
            plot(calStruct.rawData.gammaInput(2,:), calStruct.rawData.gammaTable(:,5), ...
                'gs', 'MarkerFaceColor', [0.8 1.0 0.8], 'MarkerEdgeColor', [0 1 0]);
            plot(calStruct.rawData.gammaInput(3,:), calStruct.rawData.gammaTable(:,6), ...
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
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex); 
end



