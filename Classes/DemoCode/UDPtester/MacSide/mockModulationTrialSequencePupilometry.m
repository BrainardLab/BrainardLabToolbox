function params = mockModulationTrialSequencePupilometry()

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
        messageList{k+1} = {'FREQUENCY', round(40*0.5*(1+sin(2*pi*k/40)))};
    end
    
    
    communicationIsInSync = true;
    messageCount = 0;
    
    while (communicationIsInSync)
        
        messageIndex = 0;
        while (messageIndex < numel(messageList))
            messageIndex = messageIndex + 1;
            messageCount =  messageCount + 1;
            messageLabel = messageList{messageIndex}{1};
            messageValue = messageList{messageIndex}{2};

            % change the value type transmitted
            if (mod(floor(messageCount/1000), 3) == 0)
                changeToBoolean = true;
                changeToString = false;
            elseif (mod(floor(messageCount/1000), 3) == 1)
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
            status = UDPobj.sendMessage( messageLabel, 'withValue', messageValue, 'timeOutSecs', 2, 'maxAttemptsNum', 1);

            % check status for errors
            if (~strcmp(status, 'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE'))
                fprintf('sendMessage returned with this message: ''%s''\n', status);
                error('Aborting run at this point');
            end
            
            % visualize message sent
            if (ischar(messageValue))
                messageValueType = 'string';
            elseif (isnumeric(messageValue))
                messageValueType = 'numeric';
            elseif (islogical(messageValue))
                messageValueType = 'boolean';
            end
            UDPobj.showMessageValueAsStarString('transmit', messageLabel, messageValueType, messageValue, 40, 40);
            
        end  % while
    end % Infinite loop as long as we are in sync
    
    fprintf(2, 'UDP communication came of sync after %d messages. \n', messageCount);
   
end

    
    
function params = initParams()
    params.macHostIP = '130.91.72.120';
    params.winHostIP = '130.91.74.15';
    params.udpPort = 2007;

    debug = true;
    if (debug)
        params.winHostIP = '130.91.72.17';  % IoneanPelagos
        params.macHostIP = '130.91.74.10';  % Manta
    end

    params.nTrials = 13;
end

