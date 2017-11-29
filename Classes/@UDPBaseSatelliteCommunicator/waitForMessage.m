function packet = waitForMessage(obj, msgLabel, varargin)
    
    p = inputParser;
    p.addRequired('msgLabel');
    p.addOptional('timeOutSecs', Inf,@isnumeric);
    p.addOptional('pauseTimeSecs', 0, @isnumeric);
    p.addOptional('timeOutAction', obj.NOTIFY_CALLER, @(x)((ischar(x)) && ismember(x, {obj.NOTIFY_CALLER, obj.THROW_ERROR}))); 
    p.addOptional('badTransmissionAction', obj.NOTIFY_CALLER, @(x)((ischar(x)) && ismember(x, {obj.NOTIFY_CALLER, obj.THROW_ERROR}))); 
    parse(p,msgLabel,varargin{:});
    
    pauseTimeSecs = p.Results.pauseTimeSecs;
    timeOutSecs = p.Results.timeOutSecs;
    expectedMessageLabel = p.Results.msgLabel;
    timeOutAction = p.Results.timeOutAction;
    badTransmissionAction = p.Results.badTransmissionAction;
    udpHandle = obj.udpHandle;
        
    if isempty(expectedMessageLabel)
        expectedMessageLabel = '';
    end
    
    if (~ischar(expectedMessageLabel))
        error('%s The expected message label must be a string, or an empty array, i.e.: []\n',obj.waitForMessageSignature);
    end
    
    % initialize response struct
    packet = struct(...
        'messageLabel', '', ...                 % a string
        'messageData', [], ...                  % either empty or a struct
        'timedOutFlag', false, ...              % a flag indicating whether we timeout - is this needed?
        'badTransmissionFlag', false, ...       % a flag indicating whether we encountered bad transmiddion data
        'mismatchedMessageLabel', '' ...        % mistmatched label
    );

    % Wait until we receive something or we timeout
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseTimeSecs);
    if (packet.timedOutFlag)
        obj.executeTimeOut(sprintf('while waiting for message ''%s'' to arrive', expectedMessageLabel), timeOutAction);
        return;
    end
    
    % Read the leading packet label
    packet.messageLabel = matlabNUDP('receive', udpHandle);
    
    % We may have a second transmission of the message label
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseTimeSecs);
    bytesNumOrMessageLabel = matlabNUDP('receive', udpHandle);
    
    receivedMessageLabelDuringBothAttempts = false;
    if (strcmp(bytesNumOrMessageLabel, expectedMessageLabel))
        if (strcmp(packet.messageLabel, expectedMessageLabel))
            receivedMessageLabelDuringBothAttempts = true;
        else
            error('Synchronization error in waitForMessage: ''%s'' vs. ''%s''.\n', packet.messageLabel, bytesNumOrMessageLabel);
        end
    else
        fprintf(2,'MessageLabel during first transmission was lost !!\n');
        fprintf(2,'Possible data transmission problem\n');
        
        numBytes = str2double(bytesNumOrMessageLabel);
        fprintf(2,'Is transmitted number of bytes equal to %d ?\n', numBytes);
    end
    
    if (receivedMessageLabelDuringBothAttempts)
        packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseTimeSecs);
        if (packet.timedOutFlag)
            obj.executeTimeOut(sprintf('while waiting to receive number of bytes for message ''%s''', expectedMessageLabel), timeOutAction);
            return;
        end

        % Read number of bytes of ensuing data
        bytesString = matlabNUDP('receive', udpHandle);
        numBytes = str2double(bytesString);
    end
    
    % Read all bytes
    pauseSecs = 0;
    theData = zeros(1,numBytes);
    fprintf('\n-------------------IN------------------\n');
    for k = 1:numBytes
        packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseSecs);
        if (packet.timedOutFlag)
            obj.executeTimeOut(sprintf('while waiting to receive byte %d/%d of message ''%s''', k, numBytes, expectedMessageLabel), timeOutAction);
            return;
        end
        datum = matlabNUDP('receive', udpHandle);
        fprintf('SERIAL[%3d/%3d]: %s\n', k, numBytes, datum);
        theData(k) = str2double(datum);
    end
    fprintf('\n----------------------------------------\n');
    
    % Read the message label again
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseSecs);
    if (packet.timedOutFlag)
        obj.executeTimeOut(sprintf('while waiting to verify the label of message ''%s''', expectedMessageLabel), timeOutAction);
        return;
    end
    
    trailingMessageLabel = matlabNUDP('receive', udpHandle);
    if (~strcmp(packet.messageLabel,trailingMessageLabel))
        fprintf('Trailing message label mismatch: expected ''%s'', received: ''%s''.\n', expectedMessageLabel, trailingMessageLabel);
        if (strcmp(badTransmissionAction, obj.THROW_ERROR))
            % ask remote host to abort
            obj.sendMessage(obj.ABORT_MESSAGE.label, obj.ABORT_MESSAGE.value);
            error('Trailing message label (''%s'') does not match leading message label (''%'').\nAsked remote host to abort.', trailingMessageLabel, packet.messageLabel)
        else
            packet.badTransmissionFlag = true;
            return;
        end
    end

    % Reconstruct data object
    if (numBytes > 0)
        packet.messageData = getArrayFromByteStream(uint8(theData));
    else
        packet.messageData = [];
    end
  
    % Send acknowledgment if all OK
    if (strcmp(expectedMessageLabel, packet.messageLabel))
        matlabNUDP('send', udpHandle, obj.ACKNOWLEDGMENT);
    else
        packet.mismatchedMessageLabel = expectedMessageLabel;
        matlabNUDP('send', udpHandle, obj.UNEXPECTED_MESSAGE_LABEL_RECEIVED);
    end
end

    