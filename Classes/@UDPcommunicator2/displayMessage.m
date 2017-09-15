function displayMessage(obj, messageLabel, messageData, packetNo)

    if (isempty(messageData))
        fprintf('\nReceived packet %04d with message label ''%s'' and no attached data.\n', packetNo, messageLabel);
    elseif (isstruct(messageData))
        fprintf('\nReceived packet %04d with message label ''%s'' and the following struct data.\n', packetNo, messageLabel);
        messageData
        fprintf('\n');
    elseif (isnumeric(messageData))
        fprintf('\nReceived packet %04d with message label ''%s'' and the following numeric data.\n', packetNo, messageLabel, messageData);
        fprintf('%g\n',messageData);
    elseif (ischar(messageData))
        fprintf('\nReceived packet %04d with message label ''%s'' and the following char data.\n', packetNo, messageLabel, messageData);
        fprintf('%s\n',messageData);
    else
        fprintf('\nReceived packet %04d with message label ''%s'' and the following data of type %s.\n', packetNo, messageLabel, class(messageData));
        messageData
        fprintf('\n');
    end
end

