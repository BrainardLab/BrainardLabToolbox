function params = mockModulationTrialSequencePupilometry()

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
        'verbosity', 'normal' ...             % optional with possible values {'min', 'normal', 'max'}, and default 'normal'
        );

    params = trialLoop(params, block, UDPobj);
    
    fprintf('\nBye bye from the mac.');
end


function params = trialLoop(params, block, UDPobj)

    % List of message label-value pairs to send
    messageList = {...
        {'NUMBER_OF_TRIALS', 10} ... 
        {'NUMBER_OF_TRIALS', -20} ... 
        };
    
    communicationIsInSync = true; messageIndex = 0;
    while ((communicationIsInSync) && (messageIndex < numel(messageList)))
        
        messageIndex = messageIndex + 1;
        messageLabel = messagesExpected{messageIndex}{1};
        messageValue = messagesExpected{messageIndex}{2};
        
        % send command
        status = UDPobj.sendMessage( messageLabel, 'withValue', messageValue, 'timeOutSecs', 2, 'maxAttemptsNum', 1);
        
        % check status for errors
        if (~strcmp(status, 'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE'))
            fprintf('sendMessage returned with this message: ''%s''\n', status);
            error('Aborting run at this point');
        end
    
    end  % while
    
    
   
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

