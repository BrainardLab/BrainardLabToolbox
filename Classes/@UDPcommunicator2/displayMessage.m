function displayMessage(obj, hostName, action,  messageLabel, messageData, packetNo)

    if (isempty(messageData))
        fprintf('\n%s %s packet %04d with message label ''%s'' and no attached data.\n', hostName, action, packetNo, messageLabel);
    elseif (isstruct(messageData))
        fprintf('\n%s %s packet %04d with message label ''%s'' and the following struct data.\n', hostName, action, packetNo, messageLabel);
        messageData
        fprintf('\n');
    elseif (isnumeric(messageData))
        fprintf('\n%s %s packet %04d with message label ''%s'' and the following numeric data.\n', hostName, action, packetNo, messageLabel, messageData);
        fprintf('%g\n',messageData);
    elseif (ischar(messageData))
        fprintf('\n%s %s packet %04d with message label ''%s'' and the following char data.\n', hostName, action, packetNo, messageLabel, messageData);
        fprintf('%s\n',messageData);
    else
        fprintf('\n%s %s packet %04d with message label ''%s'' and the following data of type %s.\n', hostName, action, packetNo, messageLabel, class(messageData));
        messageData
        fprintf('\n');
    end
end

