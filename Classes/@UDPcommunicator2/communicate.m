function [messageReceived, status] = communicate(obj, hostName, packetNo, communicationPacket, varargin)
    % Set default state of return arguments
    messageReceived = [];
    
    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('beVerbose', false, @islogical);
    p.addParameter('displayPackets', false, @islogical);
    p.parse(varargin{:});
    beVerbose = p.Results.beVerbose;
    displayPackets = p.Results.displayPackets;
    
    if (displayPackets)
        communicationPacket
    end
    
    if (isATransmissionPacket(communicationPacket.direction, hostName))
        if (beVerbose)
            fprintf('\n<strong>%s</strong> is sending packet %d and will expect ACK within %2.1f seconds with action: ''%s''.', ...
                hostName, packetNo, communicationPacket.timeOutSecs, communicationPacket.timeOutAction);
        end
        status = obj.sendMessage(...
            communicationPacket.messageLabel, communicationPacket.messageData, ...
            'timeOutSecs', communicationPacket.timeOutSecs, ...
            'timeOutAction', communicationPacket.timeOutAction ...
        );
        if (beVerbose)
            obj.displayMessage(hostName, sprintf('received status ''%s'' from remote host for', status), communicationPacket.messageLabel, communicationPacket.messageData, packetNo);
        end
    else
        if (beVerbose)
            fprintf('\n<strong>%s</strong> is waiting to receive packet %d and will timeout after %2.1f seconds with action: ''%s'' and bad transmission action: ''%s''.', ...
                hostName, packetNo, communicationPacket.timeOutSecs, communicationPacket.timeOutAction, communicationPacket.badTransmissionAction);
        end
        receivedPacket = obj.waitForMessage(communicationPacket.messageLabel, ...
            'timeOutSecs', communicationPacket.timeOutSecs, ...
            'timeOutAction', communicationPacket.timeOutAction, ...
            'badTransmissionAction', communicationPacket.badTransmissionAction ...
        );

        % Check if the received message was an ABORT message
        if strcmp(receivedPacket.messageLabel, obj.ABORT_MESSAGE.label)
            status = obj.ABORT_MESSAGE.label;
            return;
        end
        
        % Update status of operation
        status = obj.GOOD_TRANSMISSION;
        if (receivedPacket.timedOutFlag)
            status = obj.NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD;
        end
        if (receivedPacket.badTransmissionFlag)
            status = obj.BAD_TRANSMISSION;
        end
        if (~isempty(receivedPacket.mismatchedMessageLabel))
            obj.displayMessage(hostName, sprintf('received incorrect message while expecting ''%s''', receivedPacket.mismatchedMessageLabel), receivedPacket.messageLabel, receivedPacket.messageData, packetNo);
        end
        if (strcmp(status, obj.GOOD_TRANSMISSION))
            if (beVerbose)
                obj.displayMessage(hostName, 'successfully received', receivedPacket.messageLabel, receivedPacket.messageData, packetNo);          
            end
            messageReceived = struct();
            messageReceived.label = receivedPacket.messageLabel;
            messageReceived.data  = receivedPacket.messageData;
        end
    end
end

function transmitAction = isATransmissionPacket(direction, hostName)
    transmitAction = false;
    p = strfind(hostName, '.');
    hostName = hostName(1:p(1)-1);
    hostEntry = strfind(direction, hostName);
    rightwardArrowEntry = strfind(direction, '->');
    leftwardArrowEntry = strfind(direction, '<-');
    if (~isempty(rightwardArrowEntry))
        if (hostEntry < rightwardArrowEntry)
            transmitAction = true;
        end
    else
        if (isempty(leftwardArrowEntry))
            error('direction field does not contain correct direction information: ''%s''.\n', direction);
        end
        if (hostEntry > leftwardArrowEntry)
            transmitAction = true;
        end
    end
end