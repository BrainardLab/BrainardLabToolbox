function displayMessage(obj, action,  messageLabel, messageData, packetNo, varargin)
    p = inputParser;
    p.addOptional('alert', false, @islogical);
    parse(p, varargin{:});
    alert = p.Results.alert;
    hostName = obj.localHostName;
    
    if (isempty(messageData))
        fprintf(alert+1, '\n<strong>%s</strong> %s \n\tpacket %04d : message label = ''%s'' ; message data: none \n', hostName, action, packetNo, messageLabel);
    elseif (isstruct(messageData))
        fprintf(alert+1, '\n<strong>%s</strong> %s \n\tpacket %04d : message label = ''%s'' ; message data: struct\n', hostName, action, packetNo, messageLabel);
        messageData
        fprintf('\n');
    elseif (isnumeric(messageData))
        fprintf(alert+1, '\n<strong>%s</strong> %s \n\tpacket %04d : message label = ''%s'' ; message data: %g\n', hostName, action, packetNo, messageLabel, messageData);
    elseif (ischar(messageData))
        fprintf(alert+1, '\n<strong>%s</strong> %s \n\tpacket %04d : message label = ''%s'' ; message data: %s\n', hostName, action, packetNo, messageLabel, messageData);
    else
        fprintf(alert+1, '\n<strong>%s</strong> %s \n\tpacket %04d : message label = ''%s'' ; message data: \n', hostName, action, packetNo, messageLabel, class(messageData));
        messageData
        fprintf('\n');
    end
end

