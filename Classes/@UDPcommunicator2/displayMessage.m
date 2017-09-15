function displayMessage(obj, message)

    if (isempty(message.data))
        fprintf('\nReceived message ''%s'' with no attached data.\n', message.label);
    elseif (isstruct(message.data))
        fprintf('\nReceived message ''%s'' with the following struct data.\n', message.label);
        message.data
        fprintf('\n');
    elseif (isnumeric(message.data))
        fprintf('\nReceived message ''%s'' with the following numeric data.\n', message.label, message.data);
        fprintf('%g\n',message.data);
    elseif (ischar(message.data))
        fprintf('\nReceived message ''%s'' with the following char data.\n', message.label, message.data);
        fprintf('%s\n',message.data);
    else
        fprintf('\nReceived message ''%s'' with the data of type %s.\n', message.label, class(message.data));
        message.data
        fprintf('\n');
    end
end

