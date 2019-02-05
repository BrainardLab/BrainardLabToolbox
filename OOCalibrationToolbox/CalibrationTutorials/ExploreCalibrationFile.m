% Expores the contents of a calibration file produced by OOC_calibateMonitor
%
% 02/05/2019  npc   Wrote it.
%
% Also see: LinearizationTutorial.m
%

function ExploreCalibrationFile

    % Load calibration file
    load('/Users/nicolas/Downloads/MetropsisScreen.mat')
    
    % Select the last calibration
    theCal = cals{end};
    
    % Visualize the primary SPDs and the gamma tables
    visualizeBasicData(theCal);
    
    % Visualize results from the primary additivity tests
    visualizePrimaryAdditivityData(theCal);
    
    % Visualize results from the spatial independence tests
    visualizeSpatialIndependenceData(theCal);
end

function visualizeBasicData(theCal)
    % Generate a calStructOBJ from the cal struct
    calStructOBJ = ObjectToHandleCalOrCalStruct(theCal);
    
    DescribeMonCal(calStructOBJ);
    
    % Retrieve the spectral sampling vector
    S = calStructOBJ.get('S');
    spectralSamplesNum = S(3);
    
    % Retrieve the number of gamma curve samples
    gammaCurveSamplesNum = calStructOBJ.get('nMeas');
    
    % Retrieve the number of primaries
    nDevices = calStructOBJ.get('nDevices');
    
    % Retrieve the processed spectra of the display's primaries.
    % These are computed by fitting a linear model to the spectra of the 
    % primaries measured at 'gammaCurveSamplesNum' levels of the gamma table
    P_device = calStructOBJ.get('P_device');
    
    % Retrieve the raw spectra of the display's primaries
    monitorSPDs = calStructOBJ.get('monSpd');

    % Assemble the full measurement spectra matrix
    rawSpectralmeasurements = zeros(nDevices, spectralSamplesNum, gammaCurveSamplesNum);
    for devIndex = 1:nDevices
        rawSpectralmeasurements(devIndex,:,:) = reshape(monitorSPDs{devIndex}, spectralSamplesNum, gammaCurveSamplesNum);
    end
    
    % Retrieve the gamma tables (raw and interpolated)
    rawGammaInput = calStructOBJ.get('rawGammaInput');
    rawGammaTable = calStructOBJ.get('rawGammaTable');
    gammaInput    = calStructOBJ.get('gammaInput');
    gammaTable    = calStructOBJ.get('gammaTable');

    % Plot the raw spectra
    PlotRawAndModelSpectra(S, rawSpectralmeasurements, P_device);
    
    % Plot the gamma tables
    PlotGammaTables(rawGammaInput, rawGammaTable, gammaInput, gammaTable);
end

% Visualize how modulations of the background affects the radiance emitted
% by the target
function visualizeSpatialIndependenceData(theCal)
    
    % Steup subplot position vectors
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      1, ...
        'colsNum',      6, ...
        'widthMargin',  0.05, ...
        'leftMargin',   0.07, ...
        'bottomMargin', 0.15, ...
        'topMargin',    0.1);
    
    hFig = figure();
    set(hFig, 'Position', [100 100 2200 300]);
    
    wavelengthAxis = SToWls(theCal.rawData.S);
    backgroundSettingsNum = size(theCal.backgroundDependenceSetup.bgSettings,2);
    targetSettingsNum = size(theCal.backgroundDependenceSetup.settings,2);
    zeroBackgroundIndex = find(sum(theCal.backgroundDependenceSetup.bgSettings,1) == 0);
    
    diffRangeMilliWatts = [-1 1];
    for targetIndex = 1:targetSettingsNum
        RGBsettings = theCal.backgroundDependenceSetup.settings(:,targetIndex);
        SPDs = squeeze(theCal.rawData.backgroundDependenceMeasurements(:,targetIndex,:));
        zeroBackgroundSPD = squeeze(SPDs(zeroBackgroundIndex,:));
        residualSPDs = bsxfun(@minus, SPDs, zeroBackgroundSPD);
        
        subplot('Position', subplotPosVectors(1,targetIndex).v);
        plot(wavelengthAxis, residualSPDs*1000, 'k-');
        % set plot limits
        set(gca, 'XLim', [wavelengthAxis(1)-5 wavelengthAxis(end)+5], 'YLim', diffRangeMilliWatts);
        legend('predicted', 'measured');
        % set plot labels
        xlabel('wavelength (nm)');
        ylabel('residual power (mWatts)');
        title(sprintf('target RGB = %2.2f,%2.2f,%2.2f', RGBsettings(1), RGBsettings(2), RGBsettings(3)));
    end % targetIndex
end

% Visualize measured and predicted spectra for different combinations of
% primaries.
function visualizePrimaryAdditivityData(theCal) 

    % Steup subplot position vectors
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      2, ...
        'colsNum',      4, ...
        'heightMargin', 0.1, ...
        'widthMargin',  0.05, ...
        'leftMargin',   0.07, ...
        'bottomMargin', 0.15, ...
        'topMargin',    0.1);
    
    hFig = figure();
    set(hFig, 'Position', [100 100 1300 600]);
    
    
    ambientSPD = mean(theCal.rawData.ambientMeasurements,1);
    wavelengthAxis = SToWls(theCal.rawData.S);

    maxAll = 1.1*max([max(theCal.rawData.basicLinearityMeasurements1(:)) ...
                      max(theCal.rawData.basicLinearityMeasurements2(:))]);
    
    diffRangeMilliWatts = [-1 1];
    for linMeasIndex = 1:4:13
        RGBsettings = theCal.basicLinearitySetup.settings(:,linMeasIndex);
        measuredSpd  = theCal.rawData.basicLinearityMeasurements2(linMeasIndex,:) - ambientSPD;
        predictedSpd = (theCal.rawData.basicLinearityMeasurements2(linMeasIndex+1,:)-ambientSPD) + ...
                       (theCal.rawData.basicLinearityMeasurements2(linMeasIndex+2,:)-ambientSPD) + ...
                       (theCal.rawData.basicLinearityMeasurements2(linMeasIndex+3,:)-ambientSPD);
        subplot('Position', subplotPosVectors(1,round((linMeasIndex-1)/4)+1).v)
        plot(wavelengthAxis, predictedSpd*1000, 'k-'); hold on;
        plot(wavelengthAxis, measuredSpd*1000, 'r-');
        % set plot limits
        set(gca, 'XLim', [wavelengthAxis(1)-5 wavelengthAxis(end)+5], 'YLim', [0 1000*maxAll]);
        legend('predicted', 'measured');
        % set plot labels
        xlabel('wavelength (nm)');
        ylabel('power (mWatts)');
        title(sprintf('RGB = %2.2f,%2.2f,%2.2f', RGBsettings(1), RGBsettings(2), RGBsettings(3)));
        
        subplot('Position', subplotPosVectors(2,round((linMeasIndex-1)/4)+1).v)
        plot(wavelengthAxis, (predictedSpd-measuredSpd)*1000, 'k-');
        % set plot limits
        set(gca, 'XLim', [wavelengthAxis(1)-5 wavelengthAxis(end)+5], 'YLim', diffRangeMilliWatts);
        legend('predicted', 'measured');
        % set plot labels
        xlabel('wavelength (nm)');
        ylabel('residual power (mWatts)');
    end                
end

% Plot the full stack of primary SPDs (taken at different points along the 
% gamma curve and the linear model of primaries based on an SVD of the full
% stack)
function PlotRawAndModelSpectra(S, rawSpectralmeasurements, P_device)
    
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
    
    hFig = figure();
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

end

% Plot the gamma curves
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
        set(gca, 'XLim', [0 1], 'YLim', [0 1]);
        axis 'square'
        % set plot labels
        xlabel('''settings'' (gamma in)');  title(titles{primaryIndex});
        if (primaryIndex == 1)
            ylabel('''primary'' (gamma out)');
        end
    end
end

