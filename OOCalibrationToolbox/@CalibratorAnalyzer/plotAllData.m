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
            if (~isempty(obj.newStyleCal.rawData.basicLinearityMeasurements1))
                obj.plotLinearityCheckData(figureGroupIndex);
            end
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
           %set(figHandles(k),'Position', [20+(figureGroupIndex-1)*20, 20 + (figureGroupIndex-1)*50 1900 1200]);
           % set(figHandles(k),'MenuBar','none');    % Hide standard menu bar menus.
           % set(figHandles(k),'ToolBar','none');    % Hide standard menu bar menus.
        end
    
        % Arrange figures in a grid with dimensions gridDims
        obj.desktopHandle.setDocumentArrangement(obj.figureGroupName{figureGroupIndex}, 2, java.awt.Dimension(gridDims(1), gridDims(2)));

        
        % Set the size of the figure group
        %desktopHandle = obj.desktopHandle;
        %figureGroupNames{figureGroupIndex}
        %groupContainer = desktopHandle.getGroupContainer('Essential Data') % figureGroupNames{figureGroupIndex})
        %container = groupContainer.getTopLevelAncestor;
        %container.setSize(1900, 1200);
        %container.setLocation(20+(figureGroupIndex-1)*20, 20 + (figureGroupIndex-1)*50);
        
        
        % Arrange figures in a grid with dimensions gridDims
        %obj.desktopHandle.setDocumentArrangement(obj.figureGroupName{figureGroupIndex}, 2, java.awt.Dimension(gridDims(1), gridDims(2)));
        %obj.desktopHandle.setDocumentArrangement(obj.figureGroupName{figureGroupIndex}, 2, java.awt.Dimension(1,1));
  
    end
    
end
