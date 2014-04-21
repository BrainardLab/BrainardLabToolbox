function obj = plotAllData(obj, essentialDataGridDims, linearityChecksGridDims)

    figureGroupNames = {'Essential Data', 'Linearity Checks'};
    
    for figureGroupIndex = 1:2
        
        if (figureGroupIndex == 1)
            gridDims = essentialDataGridDims;
        else
            gridDims = linearityChecksGridDims;
        end
            
        % Set a group name for all the generated figures
        obj.figureGroupName{figureGroupIndex} = figureGroupNames{figureGroupIndex};

        % Remove the group from the desktop
        obj.desktopHandle.removeGroup(obj.figureGroupName{figureGroupIndex});

        % Add the group to the desktop
        obj.desktopHandle.addGroup(obj.figureGroupName{figureGroupIndex});

        % Empty the figures handle array
        obj.figureHandlesArray{figureGroupIndex} = [];

        % Generate plots of the essential data
        if (figureGroupIndex == 1)
            obj.plotEssentialData(figureGroupIndex);
        else
            obj.plotLinearityCheckData(figureGroupIndex);
        end
        
        % Undock group
        obj.desktopHandle.setGroupDocked(obj.figureGroupName{figureGroupIndex}, 0);

        % Arrange figures in a grid with dimensions gridDims
        obj.desktopHandle.setDocumentArrangement(obj.figureGroupName{figureGroupIndex}, 2, java.awt.Dimension(gridDims(1), gridDims(2)));

        % Finally, make all figures visible
        figHandles = obj.figureHandlesArray{figureGroupIndex};
        for k = 1:length(figHandles)
            set(figHandles(k),'Visible', 'on'); 
        end
    
    end
    
end
