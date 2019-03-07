function analyzeLuminanceModulation256Hz

    % The data filenames
    fileNames = {'mtrp_flicker.mat', 'mtrp_flickernull.mat'};
    
    % Set to true to scale individual luminance plot to their own range
    % or set it to false for no scaling.
    scaleLuminancePlots = true;
    
    % Import and visualize the data
    for iFile = 1:numel(fileNames)
        [luminance256HzData, X8HzData, Y8HzData, Z8HzData, time256Hz, time8Hz] = importData(fileNames{iFile});
        plotData(time256Hz, time8Hz, luminance256HzData, X8HzData, Y8HzData, Z8HzData, scaleLuminancePlots, fileNames{iFile});
    end
end

function [luminance256HzData, xChroma8HzData, yChroma8HzData, zChroma8HzData, time256Hz, time8Hz] = importData(fileName)
    [rootDir,~] = fileparts(which(mfilename));
    load(fullfile(rootDir, 'measurements', fileName), ...
        'luminance256HzData', 'xChroma8HzData', 'yChroma8HzData', 'zChroma8HzData');
    time256Hz = (1:size(luminance256HzData,2))/256.0 * 1000.0;
    time8Hz = (1:size(xChroma8HzData,2))/8*1000.0;
end


function plotData(time256Hz, time8Hz, luminance256HzData, X8HzData, Y8HzData, Z8HzData, scaleLuminancePlots, fileName)
    maxLuminance = max(luminance256HzData(:));
    hFig = figure(1); clf;
    set(hFig, 'Position', [10 10 2400 1300]);
    
    nStim = size(luminance256HzData,1);
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
       'rowsNum', nStim, ...
       'colsNum', 2, ...
       'heightMargin',  0.01, ...
       'widthMargin',    0.05, ...
       'leftMargin',     0.02, ...
       'rightMargin',    0.01, ...
       'bottomMargin',   0.04, ...
       'topMargin',      0.00);
    
   
    for iStim = 1:nStim
        subplot('Position', subplotPosVectors(iStim,1).v);
        plot(time256Hz, luminance256HzData(iStim,:), 'k.-');
        hold on;
        %plot(time8Hz, Y8HzData(iStim,:), 'rs-');
        set(gca, 'XTick', 0:500:time256Hz(end), 'XLim', [0 time256Hz(end)], 'YLim', [0 maxLuminance], 'YTick', 0:20:maxLuminance, 'FontSize', 14);
        if (scaleLuminancePlots)
            set(gca, 'YLim', [min(squeeze(luminance256HzData(iStim,:))) max(squeeze(luminance256HzData(iStim,:)))]);
        end
        
        if (iStim == nStim)
            xlabel('time (msec)');
            ylabel('luminance (cd/m2)');
        else
            set(gca, 'XTickLabel', {});
        end
        grid on; box on
        
        subplot('Position', subplotPosVectors(iStim,2).v);
        xChroma8Hz = X8HzData./(X8HzData+Y8HzData+Z8HzData);
        yChroma8Hz = Y8HzData./(X8HzData+Y8HzData+Z8HzData);
    
        plot(time8Hz, xChroma8Hz(iStim,:), 'rs-'); hold on;
        plot(time8Hz, yChroma8Hz(iStim,:), 'bs-');
        set(gca, 'XTick', 0:500:time256Hz(end), 'XLim', [0 time256Hz(end)], 'YLim', [min([min(xChroma8Hz) min(yChroma8Hz)]) max([max(xChroma8Hz) max(yChroma8Hz)])], ...
            'YTick', 0:0.1:1, 'FontSize', 14);
        
        if (iStim == nStim)
            xlabel('time (msec)');
            ylabel('x/y-chroma');
        else
            set(gca, 'XTickLabel', {});
        end
        
        grid on; box on
    
        drawnow;
    end
    
    NicePlot.exportFigToPDF(sprintf('%s.pdf', fileName), hFig, 300);
end


