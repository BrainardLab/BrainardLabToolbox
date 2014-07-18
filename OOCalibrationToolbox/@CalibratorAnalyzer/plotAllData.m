function obj = plotAllData(obj)

    figureGroupNames = {'Essential Data', 'Linearity Checks', 'Background Effects'};
    
    for figureGroupIndex = 1:3
            
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
            gridDims = obj.essentialDataGridDims;
            obj.plotEssentialData(figureGroupIndex);
        elseif (figureGroupIndex == 2)
            gridDims = obj.linearityChecksGridDims;
            obj.plotLinearityCheckData(figureGroupIndex);
        elseif (figureGroupIndex == 3)
            gridDims = obj.backgroundEffectsGridDims;
            obj.plotBackgroundEffectsData(figureGroupIndex);
        end
        
        % Undock group
        obj.desktopHandle.setGroupDocked(obj.figureGroupName{figureGroupIndex}, 0);
         
        % Make all figures visible
        figHandles = obj.figureHandlesArray{figureGroupIndex};
        for k = 1:length(figHandles)
            set(figHandles(k),'Visible', 'on'); 
            set(figHandles(k),'MenuBar','none');    % Hide standard menu bar menus.
            set(figHandles(k),'ToolBar','none');    % Hide standard menu bar menus.
        end
    
        % Set the size of the figure group
        container = obj.desktopHandle.getGroupContainer(figureGroupNames{figureGroupIndex}).getTopLevelAncestor;
        container.setSize(1900, 1200);
        container.setLocation(20+(figureGroupIndex-1)*20, 20 + (figureGroupIndex-1)*50);
        
        % Arrange figures in a grid with dimensions gridDims
        obj.desktopHandle.setDocumentArrangement(obj.figureGroupName{figureGroupIndex}, 2, java.awt.Dimension(gridDims(1), gridDims(2)));

        % Arrange figures in a grid with dimensions gridDims
        %obj.desktopHandle.setDocumentArrangement(obj.figureGroupName{figureGroupIndex}, 2, java.awt.Dimension(gridDims(1), gridDims(2)));
        %obj.desktopHandle.setDocumentArrangement(obj.figureGroupName{figureGroupIndex}, 2, java.awt.Dimension(1,1));
  
    end
    
end
