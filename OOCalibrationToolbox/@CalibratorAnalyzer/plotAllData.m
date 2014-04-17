function obj = plotAllData(obj)

    % Set a group name for all the generated figures
    obj.figureGroupName = 'Calibration Results';
    
    % Remove the group from the desktop
    obj.desktopHandle.removeGroup(obj.figureGroupName);
    
    % Add the group to the desktop
    obj.desktopHandle.addGroup(obj.figureGroupName);
   
    
    % Empty the figures handle array
    obj.figureHandlesArray = [];
    
    % Generate plots of the essential data
    obj.plotEssentialData();
       
    
    % Undock 'Calibration Results' group
    obj.desktopHandle.setGroupDocked(obj.figureGroupName, 0);
   
    % Arrange figures in a 2x3 grid
    obj.desktopHandle.setDocumentArrangement(obj.figureGroupName, 2, java.awt.Dimension(2,3));
   
    % Finally, make all figures visible
    for k = 1:length(obj.figureHandlesArray)
        figHandle = obj.figureHandlesArray(k);
        set(figHandle,'Visible', 'on'); 
    end
    
end
