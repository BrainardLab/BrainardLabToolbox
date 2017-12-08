function [messageReceived, status, roundTipDelayMilliSecs] = communicate(obj, packetNo, communicationPacket, varargin)
    % Set default state of return arguments
    messageReceived = [];
    
    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('beVerbose', false, @islogical);
    p.addParameter('displayPackets', false, @islogical);
    p.addParameter('maxAttemptsNum',1, @isnumeric);
    p.parse(varargin{:});
    beVerbose = p.Results.beVerbose;
    displayPackets = p.Results.displayPackets;
    maxAttemptsNum = p.Results.maxAttemptsNum;
    
    if (displayPackets)
        communicationPacket
    end
    
    % Set the current updHandle
    obj.udpHandle = communicationPacket.udpChannel;

    tic
    
    if (isATransmissionPacket(communicationPacket.direction, obj.localHostName))
        if (beVerbose)
            fprintf('\n<strong>%s</strong> is sending packet %d via UDP channel %d and will expect ACK within %2.1f seconds with action: ''%s''.', ...
                obj.localHostName, packetNo, communicationPacket.udpChannel, communicationPacket.timeOutSecs, communicationPacket.timeOutAction);
        end
        
        attemptNo = 0;
        status = obj.sendMessage(communicationPacket.messageLabel, communicationPacket.messageData, ...
            'timeOutSecs', communicationPacket.timeOutSecs, ...
            'timeOutAction', communicationPacket.timeOutAction ...
        );
         
        noACK = true;
        while (attemptNo < maxAttemptsNum) && (noACK)
            switch status
                case obj.ACKNOWLEDGMENT 
                    if beVerbose
                        obj.displayMessage(sprintf('received status ''%s'' from remote host', status), communicationPacket.messageLabel, communicationPacket.messageData, packetNo);
                    end
                    noACK = false;
                case obj.NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD
                    obj.displayMessage(sprintf('received status ''%s'' from remote host', status), communicationPacket.messageLabel, communicationPacket.messageData, packetNo, 'alert', true);
                    error('Communicate() bailing out: Time out waiting for acknowledgment.\n');
                case { obj.UNEXPECTED_MESSAGE_LABEL_RECEIVED, obj.BAD_TRANSMISSION}
                    obj.displayMessage(sprintf('received status ''%s'' from remote host', status), communicationPacket.messageLabel, communicationPacket.messageData, packetNo, 'alert', true);
                    attemptNo = attemptNo + 1;
                    fprintf('<strong>\nAttempting to send the same message (trial #%d)\n</strong>', attemptNo);
                    status = obj.sendMessage(communicationPacket.messageLabel, communicationPacket.messageData, ...
                            'timeOutSecs', communicationPacket.timeOutSecs, ...
                            'timeOutAction', communicationPacket.timeOutAction ...
                    );
            end % switch
        end % while
        
        if (noACK)
            error('Communicate() bailing out: failed to receive ACK after %d attempts of transmission\n', maxAttemptsNum);
        end
    else
        if (beVerbose)
            fprintf('\n<strong>%s</strong> is waiting to receive packet %d via UDP channel %d and will timeout after %2.1f seconds with action: ''%s'' and bad transmission action: ''%s''.', ...
                obj.localHostName, packetNo, communicationPacket.udpChannel, communicationPacket.timeOutSecs, communicationPacket.timeOutAction, communicationPacket.badTransmissionAction);
        end
        
        attemptNo = 0;
        
        receivedPacket = obj.waitForMessage(communicationPacket.messageLabel, ...
            'timeOutSecs', communicationPacket.timeOutSecs, ...
            'timeOutAction', communicationPacket.timeOutAction, ...
            'badTransmissionAction', communicationPacket.badTransmissionAction ...
        );

        
        % Compute status of operation
        status = 'to be determined';
        while (attemptNo < maxAttemptsNum) && ~(strcmp(status, obj.GOOD_TRANSMISSION))   
            status = obj.GOOD_TRANSMISSION;
            if (receivedPacket.timedOutFlag)
                status = obj.NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD;
                obj.displayMessage(sprintf('received message operation timed out'), receivedPacket.messageLabel, receivedPacket.messageData, packetNo, 'alert', true);
                error('Communicate() bailing out: Time out waiting for a message to be received.\n');
            end
            if (receivedPacket.badTransmissionFlag)
                status = obj.BAD_TRANSMISSION;
                obj.displayMessage(sprintf('received message contains bad data'), receivedPacket.messageLabel, receivedPacket.messageData, packetNo, 'alert', true);
                attemptNo = attemptNo + 1;
                fprintf('<strong>\nWaiting to receive a resubmission (trial #%d)\n</strong>', attemptNo);
                receivedPacket = obj.waitForMessage(communicationPacket.messageLabel, ...
                    'timeOutSecs', communicationPacket.timeOutSecs, ...
                    'timeOutAction', communicationPacket.timeOutAction, ...
                    'badTransmissionAction', communicationPacket.badTransmissionAction ...
                );
            elseif (~isempty(receivedPacket.mismatchedMessageLabel))
                status = obj.UNEXPECTED_MESSAGE_LABEL_RECEIVED;
                obj.displayMessage(sprintf('received message with wrong label (expected: ''%s'')', receivedPacket.mismatchedMessageLabel), receivedPacket.messageLabel, receivedPacket.messageData, packetNo, 'alert', true);
                attemptNo = attemptNo + 1;
                fprintf('<strong>\nWaiting to receive a resubmission (trial #%d)\n</strong>', attemptNo);
                receivedPacket = obj.waitForMessage(communicationPacket.messageLabel, ...
                    'timeOutSecs', communicationPacket.timeOutSecs, ...
                    'timeOutAction', communicationPacket.timeOutAction, ...
                    'badTransmissionAction', communicationPacket.badTransmissionAction ...
                );
            end
        end % while
        
        if (strcmp(status, obj.GOOD_TRANSMISSION))
            if (beVerbose)
                obj.displayMessage('received expected message', receivedPacket.messageLabel, receivedPacket.messageData, packetNo);          
            end
            messageReceived = struct();
            messageReceived.label = receivedPacket.messageLabel;
            messageReceived.data  = receivedPacket.messageData;
        else
            error('Communicate() bailing out: failed to receive a valid message after %d attempts.\n', maxAttemptsNum);
        end
    end
    
    roundTipDelayMilliSecs = toc * 1000;
end

function transmitAction = isATransmissionPacket(direction, hostName)
    transmitAction = false;
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