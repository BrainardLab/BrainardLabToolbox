% Method to generate plots of the essential data.
function plotEssentialData(obj, figureGroupIndex)

    % Get the cal
    calStruct = obj.cal;
    
    % 1. Gamma functions.
    plotGammaData(obj, calStruct, figureGroupIndex);

    % 2. Spectral data
    if (obj.measurementChannelsNum > 3)
        % 2a. SPDs
        plotSpectralData(obj, calStruct, figureGroupIndex);
        % 2b. Ambient
        plotAmbientData(obj, calStruct, figureGroupIndex);
        % 2c. Full spectral data for all gamma input values (unscaled/scaled)
        plotFullSpectra(obj, calStruct, 1, 'Red phosphor', figureGroupIndex);
        plotFullSpectra(obj, calStruct, 2, 'Green phosphor', figureGroupIndex);
        plotFullSpectra(obj, calStruct, 3, 'Blue phosphor', figureGroupIndex);
    end
    
    % 3a. Chromaticity data
    plotChromaticityData(obj, calStruct, figureGroupIndex);
    
    % 3b. Chromaticity stability
    plotPhosphorChromaticityStability(obj, calStruct, figureGroupIndex);   
end


function plotPhosphorChromaticityStability(obj, calStruct, figureGroupIndex)

    % Load CIE '31 color matching functions
    load T_xyz1931
    T_xyz = SplineCmf(S_xyz1931, 683*T_xyz1931, obj.rawData.S);
    
    % Init figure
    h = figure('Name', 'Phosphor Chromaticity', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    for primaryIndex = 1:calStruct.describe.displayPrimariesNum
        % Put measurements into columns of a matrix from raw data in calibration file.
        fullSpectra = squeeze(calStruct.rawData.gammaCurveMeanMeasurements(primaryIndex, :,:));

        % Compute phosphor chromaticities
        xyYMon = XYZToxyY(T_xyz*fullSpectra');
    
        % Plot data
        nDontPlotLowPower = 4;
        plot(xyYMon(1,1:end)',xyYMon(2,1:end)','k+');
        plot(xyYMon(1,nDontPlotLowPower+1:end)',xyYMon(2,nDontPlotLowPower+1:end)','r+');
    end
    
    axis([0 1 0 1]); axis('square');
    xlabel('x chromaticity');
    ylabel('y chromaticity');
    title(sprintf('Lower %d luminances in black',nDontPlotLowPower));
    box on;
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end

function plotChromaticityData(obj, calStruct, figureGroupIndex)
    % Load CIE '31 color matching functions
    load T_xyz1931
    T_xyz = SplineCmf(S_xyz1931, 683*T_xyz1931, obj.rawData.S);
    
    % Compute xyLum of the three primaries
    if (obj.measurementChannelsNum > 3)
        xyYMon = XYZToxyY(T_xyz * calStruct.processedData.P_device);
        xyYAmb = XYZToxyY(T_xyz * calStruct.processedData.P_ambient);
    else
        xyYMon = XYZToxyY(calStruct.processedData.P_device);
        xyYAmb = XYZToxyY(calStruct.processedData.P_ambient);
    end
    % Compute the spectral locus
    xyYLocus = XYZToxyY(T_xyz);
    
    % Init figure
    h = figure('Name', 'RGB channel chromaticities', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Plot data
    plot(xyYMon(1,1)',  xyYMon(2,1)',  'ro','MarkerSize',8,'MarkerFaceColor', [1.0 0.8 0.8]);
    plot(xyYMon(1,2)',  xyYMon(2,2)',  'go','MarkerSize',8,'MarkerFaceColor', [0.8 1.0 0.8]);
    plot(xyYMon(1,3)',  xyYMon(2,3)',  'bo','MarkerSize',8,'MarkerFaceColor', [0.8 0.8 1.0]);
    plot(xyYAmb(1,1)',  xyYAmb(2,1)',  'ks','MarkerSize',8,'MarkerFaceColor', [0.8 0.8 0.8]);
    plot(xyYLocus(1,:)',xyYLocus(2,:)','k');
    
    axis([0 1 0 1]); axis('square');
    xlabel('x chromaticity');
    ylabel('y chromaticity');
    box 'on'
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end


function plotFullSpectra(obj, calStruct, primaryIndex, primaryName, figureGroupIndex)
    % Put measurements into columns of a matrix from raw data in calibration file.
    fullSpectra   = squeeze(calStruct.rawData.gammaCurveMeanMeasurements(primaryIndex, :,:));
    scaledSpectra = 0*fullSpectra;
    
    %maxSpectra    = repmat(max(fullSpectra,[],2), [1 size(fullSpectra,2)]);
    %scaledSpectra = fullSpectra./maxSpectra;    
    maxSpectra = fullSpectra(end,:); 
    for gammaPoint = 1:calStruct.describe.nMeas
        scaledSpectra(gammaPoint,:) = (fullSpectra(gammaPoint,:)' * (fullSpectra(gammaPoint,:)' \ maxSpectra'))';
    end
    
    % Compute spectral axis
    S = calStruct.rawData.S;
    spectralAxis = SToWls(S);
    
    % Init figure
    h = figure('Name', sprintf('%s spectra', primaryName), 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % measured spectra
    subplot(1,2,1);
    plot(spectralAxis, fullSpectra);
    xlabel('Wavelength (nm)', 'Fontweight', 'bold');
    ylabel('Power', 'Fontweight', 'bold');
    axis([380,780,-Inf,Inf]);
    
    % scaled spectra
    subplot(1,2,2);
    plot(spectralAxis, scaledSpectra);
    xlabel('Wavelength (nm)', 'Fontweight', 'bold');
    ylabel('Normalized Power', 'Fontweight', 'bold');
    axis([380,780,-Inf,Inf]);
    box on;
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end


function plotAmbientData(obj, calStruct, figureGroupIndex)
    % Compute spectral axis
    S = calStruct.rawData.S;
    spectralAxis = SToWls(S);
    
    % Init figure
    h = figure('Name', 'Ambient SPD', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Plot data
    plot(spectralAxis, calStruct.processedData.P_ambient(:,1),'k');
    xlabel('Wavelength (nm)', 'Fontweight', 'bold');
    ylabel('Power', 'Fontweight', 'bold');
    title('Ambient spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380,780,-Inf,Inf]);
    box on;
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex);
end

function plotSpectralData(obj, calStruct, figureGroupIndex)

    % Compute spectral axis
    S = calStruct.rawData.S;
    spectralAxis = SToWls(S);
    
    % Init figure
    h = figure('Name', 'Primary SPDs', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Get number of calibrated primaries
    primariesNum = size(obj.rawData.gammaTable,2);
    if (primariesNum > 3)
        subplot(1,2,1); hold on;
    end

    % Plot data
    plot(spectralAxis, calStruct.processedData.P_device(:,1), 'r');
    plot(spectralAxis, calStruct.processedData.P_device(:,2), 'g');
    plot(spectralAxis, calStruct.processedData.P_device(:,3), 'b');
    xlabel('Wavelength (nm)', 'Fontweight', 'bold');
    ylabel('Power', 'Fontweight', 'bold');
    title('Phosphor spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380,780,-Inf,Inf]);

    if (primariesNum > 3)
        subplot(1,2,2); hold on;
        plot(spectralAxis, calStruct.processedData.P_device(:,4), 'r');
        plot(spectralAxis, calStruct.processedData.P_device(:,5), 'g');
        plot(spectralAxis, calStruct.processedData.P_device(:,6), 'b');
        xlabel('Wavelength (nm)', 'Fontweight', 'bold');
        ylabel('Power', 'Fontweight', 'bold');
        title('Phosphor correction', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
        axis([380,780,-Inf,Inf]);
    end
    box on;
    
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
    
    xlabel('Input value', 'Fontweight', 'bold');
    ylabel('Normalized output', 'Fontweight', 'bold');
    title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
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
    
        xlabel('Input value', 'Fontweight', 'bold');
        ylabel('Normalized output', 'Fontweight', 'bold');
        title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
        axis([0 1 0 1.2]);
    end
     
    box on;
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h, figureGroupIndex); 
end



