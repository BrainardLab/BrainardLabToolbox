function updateFiguresGroup(obj, figHandle, figureGroupIndex)

    % Unload figureHandlesArray
    figureHandlesArray = obj.figureHandlesArray{figureGroupIndex};
    
    % Update figure handles array
    if isempty(figureHandlesArray)
        figureHandlesArray = figHandle;
    else
        figureHandlesArray = [figureHandlesArray figHandle];
    end
    
    % Add figure to the group
    obj.dockFigureToGroup(figHandle, obj.figureGroupName{figureGroupIndex});
    
    % Reload figureHandlesArray
    obj.figureHandlesArray{figureGroupIndex} = figureHandlesArray;
end
