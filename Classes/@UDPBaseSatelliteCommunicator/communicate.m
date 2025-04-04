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

function [messageReceived, status, roundTripDelayMilliSecs, attemptsNo] = communicate(obj, packetNo, communicationPacket, varargin)
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

    if (obj.isATransmissionPacket(communicationPacket.direction, obj.localHostName))
        % We are transmitting a packet
        if (beVerbose)
            fprintf('\n<strong>%s</strong> is sending packet %d via UDP channel %d and will expect ACK within %2.4f seconds.', ...
                obj.localHostName, packetNo, communicationPacket.udpChannel, communicationPacket.timeOutSecs);
        end

        attemptsNo = 1;
        [status, ackAttemptsNum] = obj.sendMessage(communicationPacket.messageLabel, communicationPacket.messageData, ...
            'timeOutSecs', communicationPacket.timeOutSecs, ...
            'maxAttemptsNum', maxAttemptsNum ...
        ); 
        
        noACK = true;
        while (attemptsNo < maxAttemptsNum) && (noACK)
            switch status
                case obj.ACKNOWLEDGMENT
                    if beVerbose
                        obj.displayMessage(sprintf('received status ''%s'' from remote host', status), communicationPacket.messageLabel, communicationPacket.messageData, packetNo);
                    end
                    noACK = false;
                case obj.NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD
                    obj.displayMessage(sprintf('received status ''%s'' from remote host (packet no: %d)', status, packetNo), communicationPacket.messageLabel, communicationPacket.messageData, packetNo, 'alert', true);
                    attemptsNo = attemptsNo + 1;
                    % Pause for 0.5 seconds before resending
                    pause(0.5)
                    % Flush the queue
                    obj.flushQueue();
                    fprintf('\n<strong>Attempting to send message ''%s'' again (attempt #%d)</strong>\n', communicationPacket.messageLabel, attemptsNo);
                    [status, ackAttemptsNum] = obj.sendMessage(communicationPacket.messageLabel, communicationPacket.messageData, ...
                            'timeOutSecs', communicationPacket.timeOutSecs, ...
                            'maxAttemptsNum', maxAttemptsNum ...
                    );
                case { obj.UNEXPECTED_MESSAGE_LABEL_RECEIVED, obj.BAD_TRANSMISSION}
                    obj.displayMessage(sprintf('received status ''%s'' from remote host (packet no: %d)', status, packetNo), communicationPacket.messageLabel, communicationPacket.messageData, packetNo, 'alert', true);
                    attemptsNo = attemptsNo + 1;
                    % Pause for 0.5 seconds before resending
                    pause(0.5)
                    % Flush the queue
                    obj.flushQueue();
                    fprintf('\n<strong>Attempting to send the  message ''%s'' again (attempt #%d)</strong>\n', communicationPacket.messageLabel, attemptsNo);
                    [status, ackAttemptsNum] = obj.sendMessage(communicationPacket.messageLabel, communicationPacket.messageData, ...
                            'timeOutSecs', communicationPacket.timeOutSecs, ...
                            'maxAttemptsNum', maxAttemptsNum ...
                    );
                otherwise
                    obj.displayMessage(sprintf('received unexpected status ''%s'' from remote host (packet no: %d)', status, packetNo), communicationPacket.messageLabel, communicationPacket.messageData, packetNo, 'alert', true);
                    attemptsNo = attemptsNo + 1;
                    % Pause for 0.5 seconds
                    pause(0.5)
                    % Flush the queue
                    obj.flushQueue();
                    % Resend package
                    fprintf('\n<strong>Attempting to send the  message ''%s'' again (attempt #%d)</strong>\n', communicationPacket.messageLabel, attemptsNo);
                    [status, ackAttemptsNum] = obj.sendMessage(communicationPacket.messageLabel, communicationPacket.messageData, ...
                            'timeOutSecs', communicationPacket.timeOutSecs, ...
                            'maxAttemptsNum', maxAttemptsNum ...
                    );
            end % switch
        end % while

        if (noACK)
            error('Communicate() bailed out: failure to receive ACK after %d attempts of transmission\n', maxAttemptsNum);
        else
            if (attemptsNo > 1)
                fprintf('\n<strong>Succesfully transmitted message on attempt %d.</strong>\n', attemptsNo);
            end
        end
        roundTripDelayMilliSecs = toc * 1000;
        attemptsNo = attemptsNo + ackAttemptsNum-1;
        
    else
        % We are receiving a packet
        if (beVerbose)
            fprintf('\n<strong>%s</strong> is waiting to receive packet %d via UDP channel %d and will timeout after %2.4f seconds.', ...
                obj.localHostName, packetNo, communicationPacket.udpChannel, communicationPacket.timeOutSecs);
        end

        attemptsNo = 1;
        if isinf(communicationPacket.timeOutSecs)
            waitSecsToReceivePacket = communicationPacket.timeOutSecs;
        else
            waitSecsToReceivePacket = obj.maxSecondsToWaitForReceivingAnExpectedMessage;
        end
        receivedPacket = obj.waitForMessage(communicationPacket.messageLabel, ...
            'pauseTimeSecsInLazyWaitForMessage', communicationPacket.pauseTimeSecsInLazyWaitForMessage, ...
            'waitSecsToReceivePacket', waitSecsToReceivePacket, ...
            'timeOutSecs', communicationPacket.timeOutSecs ...
        );

        % Compute status of operation
        status = 'to be determined';
        while (attemptsNo < maxAttemptsNum) && ~(strcmp(status, obj.GOOD_TRANSMISSION))
            
            status = obj.GOOD_TRANSMISSION;
            if (receivedPacket.timedOutFlag)
                status = obj.MESSAGE_FAILED_TO_ARRIVE_WITHIN_MAX_WAIT_PERIOD;
                obj.displayMessage(sprintf('received no message within the max wait period (attempt no. %d)', attemptsNo), communicationPacket.messageLabel, [], packetNo, 'alert', true);
            end

            if (receivedPacket.badTransmissionFlag)
                status = obj.BAD_TRANSMISSION;
                obj.displayMessage(sprintf('received message contains bad data (packet no:%d)', packetNo), receivedPacket.messageLabel, receivedPacket.messageData, packetNo, 'alert', true);
            elseif (~isempty(receivedPacket.mismatchedMessageLabel))
                status = obj.UNEXPECTED_MESSAGE_LABEL_RECEIVED;
                obj.displayMessage(sprintf('received message with wrong label (expected: ''%s'', packet no: %d)', receivedPacket.mismatchedMessageLabel, packetNo), receivedPacket.messageLabel, receivedPacket.messageData, packetNo, 'alert', true);
            end

            if (strcmp(status, obj.GOOD_TRANSMISSION))
                continue;
            end
            
            attemptsNo = attemptsNo + 1;
            fprintf('\n<strong>Waiting to receive a resubmission for message label: ''%s'' (attempt #%d, packet no: %d)</strong>\n', communicationPacket.messageLabel, attemptsNo, packetNo);
            receivedPacket = obj.waitForMessage(communicationPacket.messageLabel, ...
                'pauseTimeSecsInLazyWaitForMessage', communicationPacket.pauseTimeSecsInLazyWaitForMessage, ...
                'waitSecsToReceivePacket', waitSecsToReceivePacket, ...
                'timeOutSecs', communicationPacket.timeOutSecs ...
        );
        end % while

        if (strcmp(status, obj.GOOD_TRANSMISSION))
            if (attemptsNo>1)
                fprintf('\n<strong>Succesfully received message on attempt %d.</strong>\n', attemptsNo); 
            end
            if (beVerbose)
                obj.displayMessage('received expected message', receivedPacket.messageLabel, receivedPacket.messageData, packetNo);
            end
            messageReceived = struct();
            messageReceived.label = receivedPacket.messageLabel;
            messageReceived.data  = receivedPacket.messageData;
            roundTripDelayMilliSecs = toc * 1000;
        else
            error('Communicate() bailed out: failure to receive a valid message after %d attempts.\n', maxAttemptsNum);
        end
    end
end