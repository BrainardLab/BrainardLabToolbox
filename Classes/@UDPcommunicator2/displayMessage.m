function displayMessage(obj, messageLabel, messageData)

    if (isempty(messageData))
        fprintf('\nReceived message ''%s'' with no attached data.\n', messageLabel);
    elseif (isstruct(messageData))
        fprintf('\nReceived message ''%s'' with the following struct data.\n', messageLabel);
        messageData
        fprintf('\n');
    elseif (isnumeric(messageData))
        fprintf('\nReceived message ''%s'' with the following numeric data.\n', messageLabel, messageData);
        fprintf('%g\n',messageData);
    elseif (ischar(messageData))
        fprintf('\nReceived message ''%s'' with the following char data.\n', messageLabel, messageData);
        fprintf('%s\n',messageData);
    else
        fprintf('\nReceived message ''%s'' with the data of type %s.\n', messageLabel, class(messageData));
        messageData
        fprintf('\n');
    end
end

