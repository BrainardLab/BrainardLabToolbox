function displayMessage(obj, messageLabel, messageData)

    if (isempty(message.data))
        fprintf('\nReceived message ''%s'' with no attached data.\n', messageLabel);
    elseif (isstruct(message.data))
        fprintf('\nReceived message ''%s'' with the following struct data.\n', messageLabel);
        message.data
        fprintf('\n');
    elseif (isnumeric(message.data))
        fprintf('\nReceived message ''%s'' with the following numeric data.\n', messageLabel, message.data);
        fprintf('%g\n',message.data);
    elseif (ischar(message.data))
        fprintf('\nReceived message ''%s'' with the following char data.\n', messageLabel, message.data);
        fprintf('%s\n',message.data);
    else
        fprintf('\nReceived message ''%s'' with the data of type %s.\n', messageLabel, class(message.data));
        message.data
        fprintf('\n');
    end
end

