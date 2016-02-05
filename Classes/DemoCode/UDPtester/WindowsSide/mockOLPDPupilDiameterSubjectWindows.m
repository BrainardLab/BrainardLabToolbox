function mockOLPDPupilDiameterSubjectWindows

    % Start this program first.
    fprintf('\nStarting windows client\n');
    params = initParams();

    UDPobj = UDPcommunicator( ...
          'localIP', params.winHostIP, ...    % required: the IP of this computer
         'remoteIP', params.macHostIP, ...    % required: the IP of the computer we want to conenct to
          'udpPort', params.udpPort, ...      % optional, with default value: 2007
        'verbosity', 'normal' ...             % optional, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        );
    
    
    % List of message label-value pairs
    messagesExpected = {...
        {'NUMBER_OF_TRIALS', 10} ... 
        {'NUMBER_OF_TRIALS', -20} ... 
        };
    
    % Start communication
    communicationIsInSync = true; messageIndex = 0;
    while ((communicationIsInSync) && (messageIndex < numel(messagesExpected)))
        
        messageIndex = messageIndex + 1;
        messageLabel = messagesExpected{messageIndex}{1};
        messageValue = messagesExpected{messageIndex}{2};
        
        % wait for expected command
        response = UDPobj.waitForMessage(messageLabel, 'timeOutSecs', Inf);
        
        % check for errors
        if (~strcmp(response.msgLabel, messageKey)) 
            communicationIsInSync = false;
            error('Communication out of sync');
        end
    end % while
    
    
    fprintf('\nBye bye from windows\n');

end

function numStims = VSGOLGet(expectedFlag)
    % numStims = VSGOLGetNumberStims
    % Get the number of trials from the Mac
    temp = VSGOLGetInput;
    fprintf('Number of stims (%s) received!',temp);
    numStims = str2num(temp);
    matlabUDP('send',sprintf('Number of stimuli: %f received!!!',numStims));
end

function data = VSGOLGetInput
    % data = VSGOLGetInput Continuously checks for input from the Mac machine
    % until data is actually available.
    while matlabUDP('check') == 0; end
    data = matlabUDP('receive');
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
    
end

