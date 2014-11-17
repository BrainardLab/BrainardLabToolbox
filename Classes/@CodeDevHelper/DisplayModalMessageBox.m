function DisplayModalMessageBox(message, windowTitle)
% Method to show a pop-up window with a message, a title, and an OK button.
%
% Program execution stops until the OK button is pressed.
% This method is useful for alerting the user that something
% requires his/her attention, for example when a calibration file that is too old.
%
% @b Usage: 
% @code
% CodeDevHelper.DisplayModalMessageBox(''Calibration file is out of date'', ''Attention !'')
% @endcode
%
% Parameters:
%  message: -- Message to be displayed (in single quotes)
%  windowTitle:  -- Title for the window (in single quotes)
%
% History:
% @code
% 3/17/2013   npc   Wrote it
% @endcode
%
    fontName = 'System';
    fontSize = 12;
    msgHandle = msgbox(message, windowTitle, 'warn', 'modal');
    set(msgHandle, 'Visible', 'off' );
    
    % get handles to the UIControls ([OK] PushButton) and Text
    buttonHandle = findobj( msgHandle, 'Type', 'UIControl' );
    textHandle   = findobj( msgHandle, 'Type', 'Text' );

    % change the font and fontsize
    extent0 = get(textHandle, 'Extent' ); % text extent in old font
    set(buttonHandle, 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'Bold' );
    set(textHandle, 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'Bold' );
    extent1 = get(textHandle, 'Extent' ); % text extent in new font

    % resize the msgbox object to accommodate new FontName and FontSize
    delta = extent1 - extent0;          % change in extent
    pos = get(msgHandle, 'Position' );  % msgbox current position
    pos = pos + 1.05*delta;             % change size of msgbox
    pos = ceil(pos);
    
    set(msgHandle,  'Position', pos);   % set new position
    set(buttonHandle, 'Position', [pos(3)-150 pos(4)-80 100 30]);
    set(msgHandle, 'Visible', 'on' );
    waitfor(msgHandle);
    
end