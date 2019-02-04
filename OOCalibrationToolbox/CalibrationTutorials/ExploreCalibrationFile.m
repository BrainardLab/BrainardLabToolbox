function ExploreCalibrationFile
    global figNum
    
    load('/Users/nicolas/Downloads/MetropsisScreen.mat')
    
    %% Generate a calStructOBJ from the cal struct
    calStructOBJ = ObjectToHandleCalOrCalStruct(cals{end});
    DescribeMonCal(calStructOBJ);
    
    % Print all fields
    % calStructOBJ.printMappedFieldNames
    
    analyzeEssentialData(calStructOBJ);
    analyzeLinearityData(calStructOBJ);
    
end

function analyzeEssentialData(calStructOBJ)
    %% Retrieve the spectral sampling vector
    S = calStructOBJ.get('S');
    spectralSamplesNum = S(3);
    
    %% Retrieve the number of gamma curve samples
    gammaCurveSamplesNum = calStructOBJ.get('nMeas');
    
    %% Retrieve the number of primaries
    nDevices = calStructOBJ.get('nDevices');
    
    %% Retrieve the processed spectra of the display's primaries.
    % These are computed by fitting a linear model to the spectra of the 
    % primaries measured at 'gammaCurveSamplesNum' levels of the gamma table
    P_device = calStructOBJ.get('P_device');
    
    %% Retrieve the raw spectra of the display's primaries
    monitorSPDs = calStructOBJ.get('monSpd');

    %% Assemble the full measurement spectra matrix
    rawSpectralmeasurements = zeros(nDevices, spectralSamplesNum, gammaCurveSamplesNum);
    for devIndex = 1:nDevices
        rawSpectralmeasurements(devIndex,:,:) = reshape(monitorSPDs{devIndex}, spectralSamplesNum, gammaCurveSamplesNum);
    end
    
    %% Retrieve the ambient spectrum
    P_ambient = calStructOBJ.get('P_ambient');
    
    %% Retrieve the gamma tables (raw and interpolated)
    rawGammaInput = calStructOBJ.get('rawGammaInput');
    rawGammaTable = calStructOBJ.get('rawGammaTable');
    gammaInput    = calStructOBJ.get('gammaInput');
    gammaTable    = calStructOBJ.get('gammaTable');

    %% Plot the raw spectra
    PlotRawAndModelSpectra(S, rawSpectralmeasurements, P_device);
    
    %% Plot the gamma tables
    PlotGammaTables(rawGammaInput, rawGammaTable, gammaInput, gammaTable);
end


function PlotRawAndModelSpectra(S, rawSpectralmeasurements, P_device)
    global figNum
    if (isempty(figNum)); figNum = 0; end
    figNum = figNum + 1;
    
    wavelengthAxis = SToWls(S);
    
    % Steup subplot position vectors
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      1, ...
        'colsNum',      size(rawSpectralmeasurements,1), ...
        'widthMargin',  0.05, ...
        'leftMargin',   0.07, ...
        'bottomMargin', 0.15, ...
        'topMargin',    0.1);
    
    % Specify titles
    titles = {'red (raw)', 'green (raw)', 'blue (raw)'};
    
     % Specify line colors, here for 3 primaries
    lineColors = [...
        1.0 0.0 0.0;
        0.0 1.0 0.0;
        0.0 0.0 1.0 ];
    
    hFig = figure(figNum);
    set(hFig, 'Position', [100 100 1000 275]);
    
    maxAll = max([max(rawSpectralmeasurements(:)) max(P_device(:))]);
    
    % Plot the spectra
    for primaryIndex = 1:size(rawSpectralmeasurements,1)
        % generate subplot
        subplot('Position', subplotPosVectors(1,primaryIndex).v);
        plot(wavelengthAxis, squeeze(rawSpectralmeasurements(primaryIndex,:,:)), 'k-');
        hold on;
        plot(wavelengthAxis, P_device(:,primaryIndex), ...
            '.-', 'Color', lineColors(primaryIndex,:), 'MarkerSize', 16);
        hold off;
        % set plot limits
        set(gca, 'XLim', [wavelengthAxis(1)-5 wavelengthAxis(end)+5], 'YLim', [0 maxAll]);
        
        % set plot labels
        xlabel('wavelength (nm)');  title(titles{primaryIndex});
        if (primaryIndex == 1)
            ylabel('power');
        end
    end
    
    % Set fonts for all axes, legends, and titles
    NicePlot.setFontSizes(hFig, 'FontSize', 12);
end

function PlotGammaTables(rawGammaInput, rawGammaTable, gammaInput, gammaTable)
    global figNum
    figNum = figNum + 1;
    
    % Steup subplot position vectors
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      1, ...
        'colsNum',      size(rawGammaTable,2), ...
        'widthMargin',  0.05, ...
        'leftMargin',   0.07, ...
        'bottomMargin', 0.15, ...
        'topMargin',    0.1);
    
    % Specify line colors, here for 3 primaries
    lineColors = [...
        1.0 0.0 0.0;
        0.0 1.0 0.0;
        0.0 0.0 1.0 ];
    
    markerFaceColors = [...
        1.0 0.8 0.8;
        0.8 1.0 0.8;
        0.8 0.8 1.0 ];
    
    % Specify titles
    titles = {'red primary', 'green primary', 'blue primary'};
    
    % Specify no legends
    legends = {'interpolated gamma', 'raw gamma (measured)'};
    
    hFig = figure(figNum);
    set(hFig, 'Position', [100 100 1000 275]);
    
    for primaryIndex = 1:size(rawGammaTable,2)
        % generate subplot
        subplot('Position', subplotPosVectors(1,primaryIndex).v);
        
        % raw data: squares, interpolated data (1024 values): lines
        plot(gammaInput, gammaTable(:,primaryIndex), ...
            '.-', 'Color', lineColors(primaryIndex,:), 'LineWidth', 2.0);
        hold on;
        plot(rawGammaInput, rawGammaTable(:,primaryIndex), ...
            'ks',  'MarkerSize', 10, ...
            'MarkerEdgeColor', lineColors(primaryIndex,:), 'MarkerFaceColor', markerFaceColors(primaryIndex,:));
        hold off;
        
        % add legends
        legend(legends, 'Location','NorthWest');
        
        box on; grid on;
        
        % set plot limits
        set(gca, 'XLim', [rawGammaInput(1)-0.05 rawGammaInput(end)+0.05], 'YLim', [0 max(rawGammaTable(:))]);
        
        % set plot labels
        xlabel('''settings'' (gamma in)');  title(titles{primaryIndex});
        if (primaryIndex == 1)
            ylabel('''primary'' (gamma out)');
        end
    end
    
    % Set fonts for all axes, legends, and titles
    NicePlot.setFontSizes(hFig, 'FontSize', 12);
end

