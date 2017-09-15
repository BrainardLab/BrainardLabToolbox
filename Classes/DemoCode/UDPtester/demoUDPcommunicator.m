function demoUDPcommunicator

    %% Define the host names, IPs, and roles
    % In this demo we have IPs for manta.psych.upenn.edu and ionean.psych.upenn.edu
    hostNames       = {'manta',                  'ionean'};
    hostIPs         = {'128.91.12.90',           '128.91.12.144'};
    hostRoles       = {'master',                  'slave'};
    

    %% Instantiate a UDPcommunicator object according to computer name
    systemInfo = GetComputerInfo();
    localHostName = lower(systemInfo.networkName);
    
    % Generate the parallel communication protocol for the 2 hosts
    if (strfind(localHostName, 'manta'))
        protocolToRun = designCommunicationProtocolForManta(hostNames);
    else
        protocolToRun = designCommunicationProtocolForIonean(hostNames);
    end
    
    %% Run protocol for local host
    messageList = runProtocol(localHostName, hostNames, hostIPs, hostRoles, protocolToRun);
end

function protocol = designCommunicationProtocolForManta(hostNames)
    % Define the communication  protocol
    protocol = {};
    
    % Manta sending
    protocol{numel(protocol)+1} = makePacket(hostNames,...
        'manta -> ionean', struct('label', 'test1Alabel', 'value', 1));
    
    % Ionean sending
    protocol{numel(protocol)+1} = makePacket(hostNames,...
        'manta <- ionean', struct('label', 'test2'));
    
    % Manta sending
    protocol{numel(protocol)+1} = makePacket(hostNames,...
        'ionean <- manta', struct('label', 'test3', 'value', true));
    
    % Ionean sending
    protocol{numel(protocol)+1} = makePacket(hostNames,...
        'ionean -> manta', struct('label', 'test4'));
    
    % Ionean sending
    protocol{numel(protocol)+1} = makePacket(hostNames,...
         'ionean -> manta', struct('label', 'test5'));
end


function protocol = designCommunicationProtocolForIonean(hostNames)
    % Define the communication  protocol
    protocol = {};
    
    % Manta sending
    protocol{numel(protocol)+1} = makePacket(hostNames,...
        'manta -> ionean', struct('label', 'test1'));
    
    % Ionean sending
    protocol{numel(protocol)+1} = makePacket(hostNames,...
        'manta <- ionean', struct('label', 'test2', 'value', -2.34));
    
    % Manta sending
    protocol{numel(protocol)+1} = makePacket(hostNames,...
        'ionean <- manta', struct('label', 'test3'));
    
    % Ionean sending
    protocol{numel(protocol)+1} = makePacket(hostNames,...
        'ionean -> manta', struct('label', 'test4', 'value', false));
    
    % Ionean sending
    protocol{numel(protocol)+1} = makePacket(hostNames,...
         'ionean -> manta', struct('label', 'test5', 'value', 'bye now'));
end


function messageList = runProtocol(localHostName, hostNames, hostIPs, hostRoles, commProtocol)

    %% Clear the command window
    clc
    
    UDPobj = instantiateUDPcomObject(localHostName, hostNames, hostIPs, 'beVerbose', true);
    
    %% Initiate the communication protocol
    initiateCommunication(UDPobj, localHostName, hostRoles,  hostNames);

    %% Run the communication protocol
    for commStep = 1:numel(commProtocol)
        messageList{commStep} = communicate(UDPobj, localHostName, commStep, commProtocol{commStep}, 'beVerbose', true);
        pause
    end
        
    %% Shutdown the UDPobj
    fprintf('\nAll done\n');
    UDPobj.shutDown();
end


function UDPobj = instantiateUDPcomObject(localHostName, hostNames, hostIPs, varargin)

    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('beVerbose', false, @islogical);
    p.parse(varargin{:});
    beVerbose = p.Results.beVerbose;
    
    if (beVerbose)
        verbosity = 'max';
    else
        verbosity = 'min';
    end
    
    if (strfind(localHostName, hostNames{1}))
        UDPobj = UDPcommunicator( ...
            'localIP',   hostIPs{1}, ...        % REQUIRED: the IP of manta.psych.upenn.edu (local host)
            'remoteIP',  hostIPs{2}, ...        % REQUIRED: the IP of ionean.psych.upenn.edu (remote host)
            'verbosity', verbosity, ...          % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
            'useNativeUDP', false ...           % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile)
        );
    elseif (strfind(localHostName, hostNames{2}))
        UDPobj = UDPcommunicator( ...
        'localIP',   hostIPs{2}, ...            % REQUIRED: the IP of ionean.psych.upenn.edu (local host)
        'remoteIP',  hostIPs{1}, ...            % REQUIRED: the IP of manta.psych.upenn.edu (remote host)
        'verbosity', verbosity, ...             % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        'useNativeUDP', false ...               % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile)
        );
    else
        error('No configuration for computer named ''%s''.', systemInfo.networkName);
    end
end

function initiateCommunication(UDPobj, localHostName, hostRoles, hostNames)

    beVerbose = true;
    triggerMessage = 'GO!';
    
    if (strcmp(hostRoles{1}, 'master'))
        masterHostName = hostNames{1};
    elseif (strcmp(hostRoles{2}, 'master'))
        masterHostName = hostNames{2};
    else
        error('There is no master role in hostRoles');
    end
    
    if (strcmp(hostRoles{1}, 'slave'))
        slaveHostName = hostNames{1};
    elseif (strcmp(hostRoles{2}, 'slave'))
        slaveHostName = hostNames{2};
    else
        error('There is no slave role in hostRoles');
    end
    
    assert(ismember(masterHostName, hostNames), sprintf('master host (''%s'') is not a valid host name.\n', masterHostName));
    assert(ismember(slaveHostName, hostNames), sprintf('slave host (''%s'') is not a valid host name.\n', slaveHostName));
    
    if (beVerbose)
        fprintf('<strong>Setting ''%s'' as MASTER and ''%s'' as SLAVE</strong>\n', masterHostName, slaveHostName);
    end
    
    if (strfind(localHostName, slaveHostName))
        % Wait for ever to receive the trigger message from the master
        messageReceived = UDPobj.waitForMessage(triggerMessage, 'timeOutSecs', Inf);
    
    elseif (strfind(localHostName, masterHostName))
        fprintf('Is ''%s'' running on the slave (''%s'') computer?. Hit enter if so.\n', mfilename, slaveHostName); pause; clc;
        % Send trigger and wait for up to 4 seconds to receive acknowledgment
        UDPobj.sendMessage(triggerMessage, '', ...
            'timeOutSecs', 4, ...
         'maxAttemptsNum', 3 ...
        );
    else
        error('Local host name (''%s'') does not match the slave (''%s'') or the master (''%s'') host name.', localHostName, slaveHostName, masterHostName);
    end
end


function packet = makePacket(hostNames, direction, message, varargin) 
    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('timeoutSecsForAckReceipt',  5, @isnumeric);
    p.addParameter('timeoutSecsForReceivingExpectedPacket',  Inf, @isnumeric);
    p.addParameter('attemptsNo', 1, @isnumeric);
    p.parse(varargin{:});
   
    % validate direction
    assert((contains(direction, '->')) || (contains(direction, '<-')), sprintf('direction field does not contain correct direction information: ''%s''.\n', direction));
    assert(contains(direction, hostNames{1}), sprintf('direction field does not contain correct host name: ''%s''.\n', direction));
    assert(contains(direction, hostNames{2}), sprintf('direction field does not contain correct host name: ''%s''.\n', direction));
    
    packet = struct(...
        'direction', direction, ...
        'message', message, ...
        'attemptsNo', p.Results.attemptsNo, ...                               % How many times to re-transmit if we did not get an ACK within the receiveTimeOut
        'transmitTimeOut', p.Results.timeoutSecsForAckReceipt, ...            % Timeout for receiving an ACK in response to a transmitted message
        'receiveTimeOut', p.Results.timeoutSecsForReceivingExpectedPacket ... % Timeout for waiting to receive a regular message
    );
end

function [messageReceived, errorReport] = communicate(UDPobj, hostName, packetNo, communicationPacket, varargin)
    % Set default state of return arguments
    messageReceived = [];
    errorReport = '';
    
    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('beVerbose', false, @islogical);
    p.addParameter('withLocalHostActionOnFailure', 'catch error', @(x)ismember(x, {'catch error', 'throw error'}));
    p.addParameter('withRemoteHostActionOnFailure', 'abort', @(x)ismember(x, {'abort', 'nothing'}));
    localHostActionOnFailure = p.Results.withLocalHostActionOnFailure;
    remoteHostActionOnFailure = p.Results.withRemoteHostActionOnFailure;
    p.parse(varargin{:});
    beVerbose = p.Results.beVerbose;
    
    if (isATransmissionPacket(communicationPacket.direction, hostName))
        if (beVerbose)
            fprintf('\n%s is sending packet %d', hostName, packetNo);
        end
        errorReport = UDPobj.transmitAndActOnAcknowledgmentStatus(...
            communicationPacket, ...
            'withLocalHostActionOnFailure', localHostActionOnFailure, ...
            'withRemoteHostActionOnFailure', remoteHostActionOnFailure...
        );
        if (beVerbose)
            displayMessage(hostName, 'transmitted',  communicationPacket.message, packetNo);
        end    
    else
        if (beVerbose)
            fprintf('\n%s is waiting to receive packet %d', hostName, packetNo);
        end
        messageReceived = UDPobj.waitForMessage(communicationPacket.message, 'timeOutSecs', communicationPacket.receiveTimeOut);
        if (beVerbose)
            displayMessage(hostName, 'received', messageReceived, packetNo);          
        end   
    end
end

function transmitAction = isATransmissionPacket(direction, hostName)

    transmitAction = false;
    p = strfind(hostName, '.');
    hostName = hostName(1:p(1)-1);
    hostEntry = strfind(direction, hostName);
    rightwardArrowEntry = strfind(direction, '->');
    leftwardArrowEntry = strfind(direction, '<-');
    if (~isempty(rightwardArrowEntry))
        if (hostEntry < rightwardArrowEntry)
            transmitAction = true;
        end
    else
        if (isempty(leftwardArrowEntry))
            error('direction field does not contain correct direction information: ''%s''.\n', direction);
        end
        if (hostEntry > leftwardArrowEntry)
            transmitAction = true;
        end
    end
end

function displayMessage(hostName, action, message, packetNo)
    booleanString = {'FALSE', 'TRUE'};
    if (~isempty(message))
        if isfield(message, 'msgValueType')
            switch (message.msgValueType)
                case  'NUMERIC'
                    fprintf('\n<strong> [packet no %03d]: ''%s'' %s message with label ''%s'' and Numeric value: %g.</strong>', packetNo, hostName, action, message.msgLabel, message.msgValue);
                case  'BOOLEAN'
                    fprintf('\n<strong> [packet no %03d]: ''%s'' %s message with label ''%s'' and Boolean value: %s.</strong>', packetNo, hostName, action, message.msgLabel, booleanString{message.msgValue+1});
                case 'STRING'
                    fprintf('\n<strong> [packet no %03d]: ''%s'' %s message with label ''%s'' and String value: ''%s''.</strong>', packetNo, hostName, action, message.msgLabel, message.msgValue);
            end
        else
            if (ischar(message.value))
                fprintf('\n<strong> [packet no %03d]: ''%s'' %s message with label ''%s'' and String value: ''%s''.</strong>', packetNo, hostName, action, message.label, message.value);
            elseif (islogical(message.value))
                fprintf('\n<strong> [packet no %03d]: ''%s'' %s message with label ''%s'' and Boolean value: %s.</strong>', packetNo, hostName, action, message.label, booleanString{message.value+1});
            elseif (isnumeric(message.value))
                fprintf('\n<strong> [packet no %03d]: ''%s'' %s message with label ''%s'' and Numeric value: %g.</strong>', packetNo, hostName, action, message.label, message.value);
            end
        end
    end
end