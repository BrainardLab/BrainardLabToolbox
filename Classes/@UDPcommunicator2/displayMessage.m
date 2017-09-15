function displayMessage(obj, action,  messageLabel, messageData, packetNo)

    if (isempty(messageData))
        fprintf('\n%s packet %04d with message label ''%s'' and no attached data.\n', action, packetNo, messageLabel);
    elseif (isstruct(messageData))
        fprintf('\n%s packet %04d with message label ''%s'' and the following struct data.\n', action, packetNo, messageLabel);
        messageData
        fprintf('\n');
    elseif (isnumeric(messageData))
        fprintf('\n%s packet %04d with message label ''%s'' and the following numeric data.\n', action, packetNo, messageLabel, messageData);
        fprintf('%g\n',messageData);
    elseif (ischar(messageData))
        fprintf('\n%s packet %04d with message label ''%s'' and the following char data.\n', action, packetNo, messageLabel, messageData);
        fprintf('%s\n',messageData);
    else
        fprintf('\n%s packet %04d with message label ''%s'' and the following data of type %s.\n', action, packetNo, messageLabel, class(messageData));
        messageData
        fprintf('\n');
    end
end

