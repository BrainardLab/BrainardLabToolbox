function updateFiguresGroup(obj, figHandle)
    % Update figure handles array
    if isempty(obj.figureHandlesArray)
        obj.figureHandlesArray = figHandle;
    else
        obj.figureHandlesArray = [obj.figureHandlesArray figHandle];
    end
    
    % Add figure to the group
    obj.dockFigureToGroup(figHandle, obj.figureGroupName);
end
