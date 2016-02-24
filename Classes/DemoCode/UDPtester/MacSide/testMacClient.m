function params = testMacClient()

    clc
    fprintf('Make sure the windows program is running, then hit enter to continue\n');
    pause;
    
    params = initParams();
    
    % setup the trial blocks
    block = struct();
    for i = 1:params.nTrials 
        block(i).data = i;
    end % i
    
    
    fprintf('\n* Creating keyboard listener\n');
    mglListener('init');

    % Instantiate a UDPcommunictor object
    UDPobj = UDPcommunicator( ...
          'localIP', params.macHostIP, ...
         'remoteIP', params.winHostIP, ...
          'udpPort', params.udpPort, ...      % optional with default 2007
        'verbosity', 'min' ...             % optional with possible values {'min', 'normal', 'max'}, and default 'normal'
        );

    params = trialLoop(params, block, UDPobj);
    
    fprintf('\nBye bye from the mac.');
end


function params = trialLoop(params, block, UDPobj)

    % List of message label-value pairs to send
    for k = 0:39
        messageList{k+1} = {'NUMBER_OF_TRIALS', round(40*0.5*(1+sin(2*pi*k/40)))};
    end
    for k = 40 + (0:39)
        messageList{k+1} = {'FREQUENCY', 40*0.5*(1+sin(2*pi*k/40))};
    end
    
    % start talking to windows
    communicationIsInSync = true;
    loopIndex = 0;
    
    while (communicationIsInSync) && (loopIndex < params.nTrials)
        loopIndex = loopIndex + 1;
        messageIndex = 0;
        
        while (messageIndex < numel(messageList)) && (communicationIsInSync)
            messageIndex = messageIndex + 1;
            messageLabel = messageList{messageIndex}{1};
            messageValue = messageList{messageIndex}{2};

            % change the value type transmitted
            if (mod(floor(UDPobj.sentMessagesCount/1000), 3) == 1)
                changeToBoolean = true;
                changeToString = false;
            elseif (mod(floor(UDPobj.sentMessagesCount/1000), 3) == 2)
                changeToBoolean = false;
                changeToString = true;
            else
                changeToBoolean = false;
                changeToString = false;
            end
            
            if (changeToBoolean)
                messageValue = messageValue > 20;
            end
            
            if (changeToString)
                if (messageValue > 20)
                    messageValue = 'large string';
                else
                    messageValue = 'small value string';
                end
            end
            
            % send command
            status = UDPobj.sendMessage(messageLabel, 'withValue', messageValue, 'timeOutSecs', 2, 'maxAttemptsNum', 3);

            % check status for errors
            if (~strcmp(status, UDPobj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED))
                fprintf(2,'Transmitted and expected (by the other end) messages do not match! sendMessage() returned with this message: ''%s''\n', status);
                communicationIsInSync = false;
            end
            
            % visualize message sent
            if (ischar(messageValue))
                messageValueType = 'string';
            elseif (isnumeric(messageValue))
                messageValueType = 'numeric';
            elseif (islogical(messageValue))
                messageValueType = 'boolean';
            end
            UDPobj.showMessageValueAsStarString(UDPobj.sentMessagesCount, 'transmit',  messageLabel, messageValueType, messageValue, 40, 40);
            
        end  % while (messageIndex < numel(messageList))
    end %  while (communicationIsInSync) && (loopIndex < 10)
    
    if (~communicationIsInSync)
        fprintf(2, '\nUDP communication went out of sync after %d messages. \n', UDPobj.sentMessagesCount);
    else
        fprintf('\n\nFinished %d loops. Sending ''Exit Listening Loop'' to windows machine ...\n', loopIndex);
        status = UDPobj.sendMessage('Exit Listening Loop', 'doNotReplyToThisMessage', true)
    end
   
end

    
    
function params = initParams()
    params.macHostIP = '130.91.72.120';
    params.winHostIP = '130.91.74.15';
    params.udpPort = 2007;

    debug = false;
    if (debug)
        params.winHostIP = '130.91.72.17';  % IoneanPelagos
        params.macHostIP = '130.91.74.10';  % Manta
        params.udpPort = 2007;
    end

    params.nTrials = 100;
end

