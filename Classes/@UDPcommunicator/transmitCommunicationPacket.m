% Method that transmits a communication packet and acts for the received acknowledgment
function errorReport = transmitCommunicationPacket(obj, communicationPacket, varargin)

    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('withLocalHostActionOnFailure', 'catch error', @(x)ismember(x, {'catch error', 'throw error'}));
    p.addParameter('withRemoteHostActionOnFailure', '', @ischar);
    p.parse(varargin{:});
    localHostActionOnFailure = p.Results.withLocalHostActionOnFailure;
    remoteHostActionOnFailure = p.Results.withRemoteHostActionOnFailure;
    
    % Send the message
    status = obj.sendMessage(communicationPacket.message.label, communicationPacket.message.value, ...
        'timeOutSecs', communicationPacket.transmitTimeOut, ...
        'maxAttemptsNum', communicationPacket.attemptsNo, ...
        'dealWithErrors', false ...
    );
    
    if (~strcmp(status, 'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE')) && (strcmp(remoteHostActionOnFailure, 'abort'))
        fprintf('\nCommunication failure during transmission: notifying remote host to ABORT!\n');
        obj.sendMessage(obj.ABORT_MESSAGE.label, obj.ABORT_MESSAGE.value, ...
            'dealWithErrors', false);
    end
            
    if (strcmp(localHostActionOnFailure, 'throw error'))
        errorReport = '';
        % Make sure the remote host received the expected label
        assert(strcmp(status,'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE'), sprintf('\nRemote host reports a communication failure: %s', status));
        % Make sure we did not hit the ACK timeOut limit, otherwise throw an error
        assert(~strcmp(status,'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT'), '\nRemote host did not send an acknowledgment within the timeout period.');
    else
        if (strcmp(status,'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE'))
            errorReport = '';
        else
            % Relay the error report to the caller, so that it knows that there was a problem
            errorReport = status;
        end
    end
end