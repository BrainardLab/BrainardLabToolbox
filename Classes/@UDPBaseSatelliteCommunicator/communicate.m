% Method to perform a single communication action as determined by the
% communicationPacket. If the packet defines a read message, the received
% message is returned, otherwise we return an empty array. The status of the 
% operation and the round trip delay are also returned.
% If we are transmitting, we are expecting an acknowledgment. If this is
% not received, or if we get a bad transmission flag, we transmit again up
% to the maxAttemptsNum passed (default is 1 attempt). If we are
% receiveing, and we do not receive the expected packet within the timeOut
% period, the waitMessage() method informs the sender and we keep waiting
% to obtain a new message up to the maxAttemptsNum.

function [messageReceived, status, roundTipDelayMilliSecs] = communicate(obj, packetNo, communicationPacket, varargin)
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

    % Set default state of return arguments
    messageReceived = [];

    tic

    if (isATransmissionPacket(communicationPacket.direction, obj.localHostName))
        % We are transmitting a packet
        if (beVerbose)
            fprintf('\n<strong>%s</strong> is sending packet %d via UDP channel %d and will expect ACK within %2.1f seconds.', ...
                obj.localHostName, packetNo, communicationPacket.udpChannel, communicationPacket.timeOutSecs);
        end

        attemptNo = 1;
        status = obj.sendMessage(communicationPacket.messageLabel, communicationPacket.messageData, ...
            'timeOutSecs', communicationPacket.timeOutSecs ...
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
                    attemptNo = attemptNo + 1;
                    fprintf('\n<strong>Attempting to send the same message (attempt #%d)</strong>\n', attemptNo);
                    status = obj.sendMessage(communicationPacket.messageLabel, communicationPacket.messageData, ...
                            'timeOutSecs', communicationPacket.timeOutSecs ...
                    );
                case { obj.UNEXPECTED_MESSAGE_LABEL_RECEIVED, obj.BAD_TRANSMISSION}
                    obj.displayMessage(sprintf('received status ''%s'' from remote host', status), communicationPacket.messageLabel, communicationPacket.messageData, packetNo, 'alert', true);
                    attemptNo = attemptNo + 1;
                    fprintf('\n<strong>Attempting to send the same message (attempt #%d)</strong>\n', attemptNo);
                    status = obj.sendMessage(communicationPacket.messageLabel, communicationPacket.messageData, ...
                            'timeOutSecs', communicationPacket.timeOutSecs ...
                    );
            end % switch
        end % while

        if (noACK)
            error('Communicate() bailed out: failure to receive ACK after %d attempts of transmission\n', maxAttemptsNum);
        else
            if (attemptNo > 1)
                fprintf('\n<strong>Succesfully transmitted message on attempt %d.</strong>\n', attemptNo);
            end
        end
    else
        % We are receiving a packet
        if (beVerbose)
            fprintf('\n<strong>%s</strong> is waiting to receive packet %d via UDP channel %d and will timeout after %2.1f seconds.', ...
                obj.localHostName, packetNo, communicationPacket.udpChannel, communicationPacket.timeOutSecs);
        end

        attemptNo = 1;
        receivedPacket = obj.waitForMessage(communicationPacket.messageLabel, ...
            'timeOutSecs', communicationPacket.timeOutSecs ...
        );

        % Compute status of operation
        status = 'to be determined';
        while (attemptNo < maxAttemptsNum) && ~(strcmp(status, obj.GOOD_TRANSMISSION))
            
            status = obj.GOOD_TRANSMISSION;
            if (receivedPacket.timedOutFlag)
                status = obj.NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD;
                obj.displayMessage(sprintf('received message operation timed out'), receivedPacket.messageLabel, receivedPacket.messageData, packetNo, 'alert', true);
            end

            if (receivedPacket.badTransmissionFlag)
                status = obj.BAD_TRANSMISSION;
                obj.displayMessage(sprintf('received message contains bad data'), receivedPacket.messageLabel, receivedPacket.messageData, packetNo, 'alert', true);
            elseif (~isempty(receivedPacket.mismatchedMessageLabel))
                status = obj.UNEXPECTED_MESSAGE_LABEL_RECEIVED;
                obj.displayMessage(sprintf('received message with wrong label (expected: ''%s'')', receivedPacket.mismatchedMessageLabel), receivedPacket.messageLabel, receivedPacket.messageData, packetNo, 'alert', true);
            end

            if (strcmp(status, obj.GOOD_TRANSMISSION))
                continue;
            end
            
            attemptNo = attemptNo + 1;
            fprintf('\n<strong>Waiting to receive a resubmission (attempt #%d)</strong>\n', attemptNo);
            receivedPacket = obj.waitForMessage(communicationPacket.messageLabel, ...
                'timeOutSecs', communicationPacket.timeOutSecs ...
            );
        end % while

        if (strcmp(status, obj.GOOD_TRANSMISSION))
            if (attemptNo>1)
                fprintf('\n<strong>Succesfully received message on attempt %d.</strong>\n', attemptNo);
            end
            if (beVerbose)
                obj.displayMessage('received expected message', receivedPacket.messageLabel, receivedPacket.messageData, packetNo);
            end
            messageReceived = struct();
            messageReceived.label = receivedPacket.messageLabel;
            messageReceived.data  = receivedPacket.messageData;
        else
            error('Communicate() bailed out: failure to receive a valid message after %d attempts.\n', maxAttemptsNum);
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
