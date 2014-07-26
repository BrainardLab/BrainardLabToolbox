function obj = exportCal(obj)

    fprintf('Exporting new-style cal format to %s.mat\n', obj.calibrationFile);
    SaveCalFile(obj.cal, obj.calibrationFile);
    
    % Flash window showing that the calibration was finished and where the
    % calibration file was saved
    calibrationMessage = sprintf('Calibration data saved in %s', which(sprintf('%s.mat', obj.calibrationFile)));
    
    
    f = figure;
    set(f, 'NumberTitle', 'off', ...
           'Position', [200 500 1000 80], ...
           'Menubar', 'none', ...
           'Toolbar', 'none', ...
           'Name', 'Calibration Status: Finished');
       
    drawnow;
    
    % Make window not resizable
    jFrame  = get(handle(gcf), 'JavaFrame');
    jWindow = jFrame.fHG1Client.getWindow;
    jWindow.setResizable(0)
    
    % Dsiable the red button
    set(gcf, 'CloseRequestFcn', '');
    
    % Only way to close this window is by clicking on the button
    uicontrol('Position',[20 20 960 40], ...
              'String', calibrationMessage,...
              'FontSize', 14, ...
              'Callback', @close);

    uiwait(gcf);
    
    function close(src, evnt)
         delete(gcf);
    end

end
