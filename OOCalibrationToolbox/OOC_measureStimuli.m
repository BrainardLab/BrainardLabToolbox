function OOC_measureStimuli
% Measure the radiance of a number of stimuli using the PR670
%
% For more PR670 options see OOC_testPR670
%
%
    % Try to open the PR670
    DB_PR670obj = [];
    
    try 
        % Open the PR-670
        DB_PR670obj = PR670dev(...
                'verbosity',        1, ...       % 1 -> minimum verbosity
                'devicePortString', [] ...       % empty -> automatic port detection)
        );

    catch err
       if (isempty(DB_PR670obj))
            IOPort('closeall')
       else
            % Exit remote control
            fprintf(2,'\nAn exception was raised. Shutting down PR670. Please wait ...\n');
            
            % Shutdown DBLab_Radiometer object and close the associated device
            DB_PR670obj.shutDown();
        end
        
        rethrow(err)
    end
    
    % Ask user for the nStim, nRepeats and datafile name
    nStimDefault = 12;
    nRepeatsDefault = 5;
    dataFileNameDefault = 'MetropsisStim';
    
    nStimuli = GetWithDefault('nStimuli', nStimDefault);
    nRepeats = GetWithDefault('nRepeats', nRepeatsDefault);
    dataFileName = GetWithDefault('datafile name', dataFileNameDefault);
    dataFileName = [dataFileName '.mat'];
    
    % Arrange the subplot positions in a 3-rows x nCols grid
    rowsNum = 3;
    subplotPos = arrangeSuplotPositions(nStimuli, rowsNum);
  
    % Reset figure
    hFig = [];
    
    % Loop over stimuli and reps
    for iStim = 1:nStimuli
        queryString = sprintf('\nHit enter to measure stimulus %d of %d:', iStim,nStimuli);
        Speak(queryString, 'Fiona')
        for iRepeat = 1:nRepeats
            % Ask user to proceed
            queryString = sprintf('\nHit enter for repeat %d of %d):', iRepeat, nRepeats);
            Speak(queryString, 'Fiona')
            GetWithDefault(queryString, 0);
            
            % Measure the source
            DB_PR670obj.measure();
            
            % Retrieve the data
            radiance = DB_PR670obj.measurement.energy;
            wavelengths = DB_PR670obj.measurement.spectralAxis;
            
            % Save the data
            if (iStim*iRepeat == 1)
                radianceData = zeros(nStimuli, nRepeats, numel(radiance));
            end
            radianceData(iStim, iRepeat,:) = radiance;
            save(dataFileName, 'radianceData', 'wavelengths');
            
            % Plot the data
            hFig = plotSpectra(iStim, iRepeat, nRepeats, radiance, wavelengths, subplotPos, hFig);
        end
    end
    
    % Save again
    save(dataFileName, 'radianceData', 'wavelengths');
    
    % Shutdown DBLab_Radiometer object and close the associated device
    DB_PR670obj.shutDown();
   
    Speak('All done', 'Fiona')     
end

% Method to plot the data as they are collected
function hFig = plotSpectra(iStim, iRepeat, nRepeats, radiance, wavelengths, subplotPos, hFig)
    if (isempty(hFig))
        hFig = figure(1); clf;
        set(hFig, 'Position', [10 10 1300 750], 'Color', [0 0 0]);
    end
    
    % Make subplot
    rowsNum = size(subplotPos,1);
    colsNum = size(subplotPos,2);
    row = floor((iStim-1)/colsNum)+1;
    col = mod(iStim-1,colsNum)+1;
    subplot('Position', subplotPos(row,col).v);
    
    % Pick line color for repetition
    lineColors = brewermap(nRepeats, 'Spectral');
    
    % Plot the data
    plot(wavelengths, radiance*1000, '-', 'LineWidth', 1.0, 'Color', squeeze(lineColors(iRepeat,:)));
    
    % Set ticks and limits
    if (iRepeat == 1)
        hold on;
    end
    if (row == rowsNum)
        xlabel('\it wavelength (nm)');
    else
        set(gca, 'XTickLabel', {});
    end
    if (col == 1)
        ylabel('\it power (mWatts)');
    end
    set(gca, 'XTick', 300:50:800, 'XLim', [380 780], ...
        'FontSize', 12, 'XColor', [0.4 0.4 0.4], ...
        'YColor', [0.4 0.4 0.4], 'Color', [0 0 0]);
    box on; grid on;
end

% Method to arrange the subplot position
function subplotPos = arrangeSuplotPositions(nStimuli, rowsNum)
    colsNum = ceil(nStimuli/rowsNum);
    subplotPos = NicePlot.getSubPlotPosVectors(...
       'rowsNum', rowsNum, ...
       'colsNum', colsNum, ...
       'heightMargin',  0.07, ...
       'widthMargin',   0.04, ...
       'leftMargin',    0.05, ...
       'rightMargin',   0.01, ...
       'bottomMargin',  0.07, ...
       'topMargin',     0.01);
end
