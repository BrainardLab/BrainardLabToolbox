function testWindowsClient

    % Start this program first.
    clc
    fprintf('\nStarting windows client\n');
    params = initParams();

    UDPobj = UDPcommunicator( ...
          'localIP', params.winHostIP, ...    % required: the IP of this computer
         'remoteIP', params.macHostIP, ...    % required: the IP of the computer we want to conenct to
          'udpPort', params.udpPort, ...      % optional, with default value: 2007
        'verbosity', 'min' ...             % optional, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        );
    
    
    % List of message label-value pairs to expect
    for k = 0:39
        messageList{k+1} = {'NUMBER_OF_TRIALS', 0};
    end
    for k = 40 + (0:39)
        messageList{k+1} = {'FREQUENCY', 0};
    end
    
    % Start listening to mac
    communicationIsInSync = true;
    remainInListeningLoop = true;
    
    while (communicationIsInSync) && (remainInListeningLoop)
        
        messageIndex = 0;
        while (messageIndex < numel(messageList)) && (communicationIsInSync) && (remainInListeningLoop) 
            
            messageIndex = messageIndex + 1;
            messageLabel = messageList{messageIndex}{1};
        
            % wait for expected command
            response = UDPobj.waitForMessage(messageLabel, 'timeOutSecs', Inf);

            % check for 'Exit Listening Loop' command
            if (strcmp(response.msgLabel, 'Exit Listening Loop'))
                remainInListeningLoop = false;
                
            % check for incorrect message 
            elseif (~strcmp(response.msgLabel, messageLabel)) 
                communicationIsInSync = false;
            end
            
            % visualize message received
            UDPobj.showMessageValueAsStarString(UDPobj.receivedMessagesCount, 'received', response.msgLabel, response.msgValueType, response.msgValue, 40, 40);
        
        end % while (messageIndex < numel(messageList)) && (remainInListeningLoop)
    end %  while (communicationIsInSync) && (remainInListeningLoop)
    
    if (~communicationIsInSync)
        fprintf(2, '\nUDP communication went out of sync after %d messages.\n', UDPobj.receivedMessagesCount);
    else
        fprintf('\nExiting after receiving ''%s'' command\n', response.msgLabel);
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
    end
end

