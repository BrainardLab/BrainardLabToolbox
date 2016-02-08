function mockOLPDPupilDiameterSubjectWindows

    % Start this program first.
    clc
    fprintf('\nStarting windows client\n');
    params = initParams();

    UDPobj = UDPcommunicator( ...
          'localIP', params.winHostIP, ...    % required: the IP of this computer
         'remoteIP', params.macHostIP, ...    % required: the IP of the computer we want to conenct to
          'udpPort', params.udpPort, ...      % optional, with default value: 2007
        'verbosity', 'normal' ...             % optional, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        );
    
    
    % List of message label-value pairs to expect
    for k = 0:39
        messageList{k+1} = {'NUMBER_OF_TRIALS', round(40*0.5*(1+sin(2*pi*k/40)))};
    end
    for k = 40 + (0:39)
        messageList{k+1} = {'FREQUENCY', round(40*0.5*(1+sin(2*pi*k/40)))};
    end
    
    % Start communication
    
    messageCount = 0;
    communicationIsInSync = true;
    while (communicationIsInSync)
        messageIndex = 0;
        while (messageIndex < numel(messageList))
        
            messageCount = messageCount + 1;
            messageIndex = messageIndex + 1;
            messageLabel = messageList{messageIndex}{1};
            messageValue = messageList{messageIndex}{2};
        
            % wait for expected command
            response = UDPobj.waitForMessage(messageLabel, 'timeOutSecs', Inf);

            % check for errors
            if (~strcmp(response.msgLabel, messageLabel)) 
                communicationIsInSync = false;
                error('Communication out of sync');
            end
            
            % visualize message received
            UDPobj.showMessageValueAsStarString('received', response.msgLabel, response.msgValue, 40, 40);
            
        end % while
    end % Infinite loop
    
    fprintf(2, '\nOut of sync adter %d messages.\n', messageCount);

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

