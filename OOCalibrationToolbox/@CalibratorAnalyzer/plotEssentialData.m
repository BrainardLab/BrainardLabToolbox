% Method to generate a plot of the essential data.
% R,G,B channel gammas -> Fig. 1
% R,G,B channels SPDs -> Fig. 2
% Ambient SPD -> Fig. 3
% Chromaticity plot ->Fig. 4
%
function plotEssentialData(obj)

    % Get the cal
    calStruct = obj.cal;
    
    % 1. Gamma functions.
    plotGammaData(obj, calStruct);

    % 2. Spectral data
    if (obj.measurementChannelsNum > 3)
        % 2a. SPDs
        plotSpectralData(obj, calStruct);
        % 2b. Ambient
        plotAmbientData(obj, calStruct);
    end
    
    % 3. Chromaticity data
    plotChromaticityData(obj, calStruct);


end

function plotChromaticityData(obj, calStruct)

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
    h = figure('Name', 'Chromaticity Plot', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    plot(xyYMon(1,1)',  xyYMon(2,1)','ro','MarkerSize',8,'MarkerFaceColor','r');
    plot(xyYMon(1,2)',  xyYMon(2,2)','go','MarkerSize',8,'MarkerFaceColor','g');
    plot(xyYMon(1,3)',  xyYMon(2,3)','bo','MarkerSize',8,'MarkerFaceColor','b');
    plot(xyYLocus(1,:)',xyYLocus(2,:)','k');
    
    axis([0 1 0 1]); axis('square');
    xlabel('x chromaticity');
    ylabel('y chromaticity');
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h);
end


function plotAmbientData(obj, calStruct)
    % Init figure
    h = figure('Name', 'Ambient SPD', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Compute spectral axis
    S = calStruct.rawData.S;
    spectralAxis = SToWls(S);
    plot(spectralAxis, calStruct.processedData.P_ambient(:,1),'k');

    xlabel('Wavelength (nm)', 'Fontweight', 'bold');
    ylabel('Power', 'Fontweight', 'bold');
    title('Ambient spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380,780,-Inf,Inf]);
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h);
end

function plotSpectralData(obj, calStruct)
    % Init figure
    h = figure('Name', 'Primary SPDs', 'NumberTitle', 'off', 'Visible', 'off'); 
    clf; hold on;
    
    % Get number of calibrated primaries
    primariesNum = size(obj.rawData.gammaTable,2);
    if (primariesNum > 3)
        subplot(1,2,1); hold on;
    end
    
    % Compute spectral axis
    S = calStruct.rawData.S;
    spectralAxis = SToWls(S);
    
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
    
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h);  
end

function plotGammaData(obj, calStruct)
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
     
    % Finish plot
    drawnow;
    
    % Add figure to the figures group
    obj.updateFiguresGroup(h); 
end



