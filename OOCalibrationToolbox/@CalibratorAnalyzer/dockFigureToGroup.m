function dockFigureToGroup(obj, figureHandle, groupName)
    jFrame = getJFrame(ancestor(figureHandle,'figure'));
    set(jFrame,'GroupName',groupName);
    set(figureHandle,'WindowStyle','docked');  
    drawnow;
end

function jframe = getJFrame(hFigHandle)
  % Ensure that hFig is a figure handle...
  hFig = ancestor(hFigHandle,'figure');
  hhFig = handle(hFig);

  jframe = [];
  maxTries = 10;
  while maxTries > 0
      try
          % Get the figure's underlying Java frame
          jframe = get(handle(hhFig),'JavaFrame');
          if ~isempty(jframe)
              break;
          else
              maxTries = maxTries - 1;
              drawnow; pause(0.1);
          end
      catch
          maxTries = maxTries - 1;
          drawnow; pause(0.1);
      end
  end
  if isempty(jframe)
      error(['Cannot retrieve the java frame for handle ' num2str(hFigHandle)]);
  end

end
