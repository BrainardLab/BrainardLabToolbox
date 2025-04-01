
function obj = plotAllData(obj)

    figureGroupNames = {'Essential Data', 'Linearity Checks', 'Background Effects', 'Luminance vs Chromaticity Data', 'Comparison Panel', 'Gamma Data Comparison'};

    numFiles = length(obj.calStructOBJarray);

    if numFiles == 1 % If there's only one file, create four panels of calibration graphs

        for figureGroupIndex = 1:4
            
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
            elseif (figureGroupIndex == 4)
                gridDims = obj.luminanceVsChromaticityGridDims;
                if (~isempty(obj.newStyleCal.rawData.backgroundDependenceMeasurements))
                   obj.plotLuminanceVsChromaticityData(figureGroupIndex, gridDims);
                end   
            end

        end

    else    % If there's more than one file, create a calibration comparison panel and a gamma comparison panel

        for figureGroupIndex = 5:6

            % Setting up to plot figures on panel
            gridDims = obj.comparisonGridDims;

            if figureGroupIndex == 5
                % Set group names for all the generated figures
                obj.figureGroupName{figureGroupIndex} = figureGroupNames{figureGroupIndex};
   
                % Plot calibration comparison data
                obj.plotCalibrationComparison(figureGroupIndex, gridDims);
            elseif figureGroupIndex == 6
                % Set group names for all the generated figures
                obj.figureGroupName{figureGroupIndex} = figureGroupNames{figureGroupIndex};
   
                % Plot gamma comparison data
                obj.plotGammaComparison(figureGroupIndex, gridDims);
            end

        end

    end
    
end
