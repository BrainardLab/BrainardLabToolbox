% function dockFigureToGroup(obj, figureHandle, groupName)
%     jFrame = getJFrame(ancestor(figureHandle,'figure'));
%     set(jFrame,'GroupName',groupName);
%     set(figureHandle,'WindowStyle','docked');  
%     drawnow;
% end
% 
% function jframe = getJFrame(hFigHandle)
%   % Ensure that hFig is a figure handle...
%   hFig = ancestor(hFigHandle,'figure');
%   hhFig = handle(hFig);
% 
%   jframe = [];
%   maxTries = 10;
%   while maxTries > 0
%       try
%           % Get the figure's underlying Java frame
%           jframe = get(handle(hhFig),'JavaFrame');
%           if ~isempty(jframe)
%               break;
%           else
%               maxTries = maxTries - 1;
%               drawnow; pause(0.1);
%           end
%       catch
%           maxTries = maxTries - 1;
%           drawnow; pause(0.1);
%       end
%   end
%   if isempty(jframe)
%       error(['Cannot retrieve the java frame for handle ' num2str(hFigHandle)]);
%   end
% 
% end

function dockFigureToGroup(figureHandle, groupName)
    % Ensure the figureHandle is a valid figure
    if ~ishandle(figureHandle) || ~strcmp(get(figureHandle, 'Type'), 'figure')
        error('The provided handle is not a valid figure handle.');
    end
    
    % Set the figure to docked mode
    set(figureHandle, 'WindowStyle', 'docked');
    
    % If groupName is provided, handle grouping (no direct API for grouping)
    if nargin > 1 && ~isempty(groupName)
        % MATLAB does not have a public API for grouping figures
        % You may need to manage figure handles manually or use alternative methods
        warning('Direct figure grouping functionality is not available in the public API.');
    end
    
    drawnow;
end