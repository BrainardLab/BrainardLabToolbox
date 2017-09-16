function packet = waitForMessage(obj, msgLabel, varargin)
    
    p = inputParser;
    addRequired(p,'msgLabel');
    addOptional(p,'timeOutSecs', Inf,@isnumeric);
    parse(p,msgLabel,varargin{:});
    timeOutSecs = p.Results.timeOutSecs;
    expectedMessageLabel = p.Results.msgLabel;
    if isempty(expectedMessageLabel)
        expectedMessageLabel = '';
    end
    if (~ischar(expectedMessageLabel))
        error('%s The expected message label must be a string, or an empty array, i.e.: []\n',obj.waitForMessageSignature);
    end
    
    % initialize response struct
    packet = struct(...
        'messageLabel', '', ...            % a string
        'messageData', [], ...             % either empty or a struct
        'timedOutFlag', false ...   % a flag indicating whether we timeout - is this needed?
    );

    % Wait until we receive something or we timeout
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs);
    if (packet.timedOutFlag)
        timeOutAction('while waiting for a message to arrive');
        return;
    end
    
    % Read the leading packet label
    packet.messageLabel = matlabUDP('receive')

    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs);
    if (packet.timedOutFlag)
        timeOutAction('while waiting to receive number of bytes');
        return;
    end
    
    % Read number of bytes of ensuing data
    bytesString = matlabUDP('receive');
    bytesString
    numBytes = str2double(bytesString);
    fprintf('Will read %d char\n', numBytes);
    
    % Read all bytes
    theData = [];
    for k = 1:numBytes
        packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs);
        if (packet.timedOutFlag)
            timeOutAction(sprintf('while waiting to receive byte %d/%d', k, numBytes));
            return;
        end
        theData(k) = str2double(matlabUDP('receive'));
    end

    % Read the message label again
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs);
    if (packet.timedOutFlag)
        timeOutAction('while waiting to verify message label');
        return;
    end
    
    trailingMessageLabel = matlabUDP('receive')
    if (~strcmp(packet.messageLabel,trailingMessageLabel))
        error('\nTrailing message label (''%s'') does not match leading message label (''%'').', trailingMessageLabel, packet.messageLabel);
    end

    % Reconstruct data object
    if (numBytes > 0)
        packet.messageData = getArrayFromByteStream(uint8(theData));
    else
        packet.messageData = [];
    end

    packet.messageData
  
    % Send acknowledgment if all OK
    if (strcmp(expectedMessageLabel, packet.messageLabel))
        matlabUDP('send', obj.ACKNOWLEDGMENT);
    else
        matlabUDP('send', obj.INVALID_TRANSMISSION);
    end

%{  
        % check if the message label we received is the same as the one we are expecting, and inform the sender
        if (strcmp(response.msgLabel, expectedMessageLabel))    
            % Do not send back an TRANSMITTED_MESSAGE_MATCHES_EXPECTED message 
            % when we were expecting a TRANSMITTED_MESSAGE_MATCHES_EXPECTED and we received it
            if (strcmp(expectedMessageLabel, obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED))
                if (strcmp(obj.verbosity,'max'))
                    fprintf('%s Received expected message (''%s'')\n', obj.waitForMessageSignature,  expectedMessageLabel);
                end
            else 
                % Send back a TRANSMITTED_MESSAGE_MATCHES_EXPECTED message 
                obj.sendMessage(obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED, 'nan', 'doNotreplyToThisMessage', true);
                if (~strcmp(obj.verbosity,'min'))  && (~strcmp(obj.verbosity,'none'))
                    fprintf('%s Expected message received within %2.2f milli-seconds, acknowledging the sender.', obj.waitForMessageSignature, elapsedTime*1000);
                end 
            end
        elseif (~strcmp(expectedMessageLabel, obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED))
            % Send back message that the expected message does not match the received one
            if (~strcmp(obj.verbosity,'min'))  && (~strcmp(obj.verbosity,'none'))
                fprintf('%s: Received: ''%s'' <strong>instead of</strong> ''%s''.\n', obj.waitForMessageSignature, response.msgLabel, expectedMessageLabel);
            end
            obj.sendMessage(sprintf('Received (''%s'') message does not match expected (''%s'')', response.msgLabel, expectedMessageLabel), 'nan', 'doNotreplyToThisMessage', true);
        end
%}
end

function timeOutAction(timeoutEvent)
    fprintf(2, 'Timed out %s. Notify remote host?\n', timeoutEvent');
end

    