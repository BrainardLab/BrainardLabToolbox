function obj = plotAllData(obj)

    figureGroupNames = {'Essential Data', 'Linearity Checks', 'Background Effects', 'Comparison Panel'};

    numFiles = length(obj.calStructOBJarray);

    if numFiles == 1 % If there's only one file, create three panels of calibration graphs

        for figureGroupIndex = 1:3
            
            % Set a group name for all the generated figures
            obj.figureGroupName{figureGroupIndex} = figureGroupNames{figureGroupIndex};

            % Generate plots of the essential data
            if (figureGroupIndex == 1)
                gridDims = obj.essentialDataGridDims;
                obj.plotEssentialData(figureGroupIndex, gridDims);         
            elseif (figureGroupIndex == 2)
                gridDims = obj.linearityChecksGridDims;
                if (~isempty(obj.newStyleCal.rawData.basicLinearityMeasurements1))
                    obj.plotLinearityCheckData(figureGroupIndex, gridDims);
                end
            elseif (figureGroupIndex == 3)
                gridDims = obj.backgroundEffectsGridDims;
                if (~isempty(obj.newStyleCal.rawData.backgroundDependenceMeasurements))
                   obj.plotBackgroundEffectsData(figureGroupIndex, gridDims);
               end                
            end

        end

    else    % If there's more than one file, create only one calibration comparison panel

        figureGroupIndex = 4;

        % Set a group name for all the generated figures
        obj.figureGroupName{figureGroupIndex} = figureGroupNames{figureGroupIndex};

        % Setting up to plot figures on panel
        gridDims = obj.comparisonGridDims;
        
        % Plot calibration comparison data
        obj.plotCalibrationComparison(figureGroupIndex, gridDims);

    end
    
end
