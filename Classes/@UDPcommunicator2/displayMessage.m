function displayMessage(obj, hostName, action,  messageLabel, messageData, packetNo)

    if (isempty(messageData))
        fprintf('\n<strong>%s</strong> %s \n\tpacket %04d : message label = ''%s'' ; message data: none \n', hostName, action, packetNo, messageLabel);
    elseif (isstruct(messageData))
        fprintf('\n<strong>%s</strong> %s \n\tpacket %04d : message label = ''%s'' ; message data: struct\n', hostName, action, packetNo, messageLabel);
        messageData
        fprintf('\n');
    elseif (isnumeric(messageData))
        fprintf('\n<strong>%s</strong> %s \n\tpacket %04d : message label = ''%s'' ; message data: %g\n', hostName, action, packetNo, messageLabel, messageData);
    elseif (ischar(messageData))
        fprintf('\n<strong>%s</strong> %s \n\tpacket %04d : message label = ''%s'' ; message data: %s\n', hostName, action, packetNo, messageLabel, messageData);
    else
        fprintf('\n<strong>%s</strong> %s \n\tpacket %04d : message label = ''%s'' ; message data: \n', hostName, action, packetNo, messageLabel, class(messageData));
        messageData
        fprintf('\n');
    end
end

