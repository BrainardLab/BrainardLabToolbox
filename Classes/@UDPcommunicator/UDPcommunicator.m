classdef UDPcommunicator < handle
% Class for robust UDP-based communication between two computers.
% -------------------------------------------------------------------------
% Demo usage:  computerA (mac, the master) -> computer B (windows, the listener)
% -------------------------------------------------------------------------
%
% [STEP 1A.] Instantiate a UDPcommunicator object (the listener) on the  windows computer
%
% UDPobjWin = UDPcommunicator( ...
%    'localIP',   params.winHostIP, ... % REQUIRED: the IP of this computer
%    'remoteIP',  params.macHostIP, ... % REQUIRED: the IP of the computer we want to connect to
%    'udpPort',   params.udpPort, ...   % OPTIONAL, with default value: 2007
%    'verbosity', 'min', ...            % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
%    'useNativeUDP', false ...          % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile
%  );
%
% [STEP 1B.] Instantiate a UDPcommunicator object (the master) on the mac computer
% UDPobjMac = UDPcommunicator( ...
%    'localIP',   params.macHostIP, ... % REQUIRED: the IP of this computer
%    'remoteIP',  params.winHostIP, ... % REQUIRED: the IP of the computer we want to connect to
%    'udpPort',   params.udpPort, ...   % OPTIONAL with default 2007
%    'verbosity', 'min' ...             % OPTIONAL with possible values {'min', 'normal', 'max'}, and default 'normal'
%    'useNativeUDP', false ...          % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile
%  );
%
% -------------------------------------------------------------------------
%
% [STEP 2A] Set the windows computer to listen indefinitely for a message
% with a specific label here, 'NUMBER_OF_TRIALS'.
% response = UDPobjWin.waitForMessage(...
%    'NUMBER_OF_TRIALS', ...   % REQUIRED field: the label of the message we expect, so we can provide a useful acknowledgment to the sender
%    'timeOutSecs', 10, ...    % OPTIONAL field: how long to wait for a message, with default value: Inf
%         );
%
% [STEP 2B.] Send a command message from the mac to the windows
%  status = UDPobjMac.sendMessage(...
%     'NUMBER_OF_TRIALS', 12, ...  % REQUIRED field: every message must have a label
%     'timeOutSecs',    2, ... % OPTIONAL field: expect to receive an acknowdegment from the windows machine within 2 seconds, default: 5 seconds 
%     'maxAttemptsNum', 3 ...  % OPTIONAL field: if we get no ACK within the timeout period, resend this message up to a total of 3 times, default: 1 times
%   );
%
% -------------------------------------------------------------------------
%
% [STEP 3.] Check the status parameter returned by the sendMessage command in [STEP 2B]
% If the windows computer received the message we sent, and the message label it
% received matched the message label it was expecting, it will inform the mac computer
% that it did so, and in turn, the status param returned by the sendMessage 
% will be set to 'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE'. Any other status
% reflects a failure: either that a different message was received by the windows machine, 
% or that the windows machine failed to provide an acknowlegmet within the
% specified timeout period during any of the specied attempts
%
% if (~strcmp(status, 'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE'))
%     fprintf('sendMessage returned with this message: ''%s''\n', status);
%     error('Cannot communicate reliably with the windows computer. Aborting run at this point.');
% end
%
% -------------------------------------------------------------------------
%
% Additional notes:
% We can send messages whose values are one of the following three types:
% (a) numerical (i.e., int, double etc), i.e.:
%      status = UDPobjMac.sendMessage('Modulation Frequency', 0.466);
%      status = UDPobjMac.sendMessage('X-Offset',  -123);
% (b) boolean (i.e., true or false), i.e.:
%      status = UDPobjMac.sendMessage('Invert Yaxis', false);
% (c) strings (i.e., character arrays), i.e.:
%      status = UDPobjMac.sendMessage('Experimenter name', 'Manuel Spitschan');
%
% These three different types are all transmitted as character strings together with
% an additional field that specifies their type, so that the receiver can
% reconstruct the actual type.
%
% Finally, we can send messages with no values, i.e.:
% status = UDPobjMac.sendMessage('Exit loop');
%
%
%
% 2/4/2016   NPC   Wrote it
%

	% Protected properties. All subclasses of UDPcommunicator can read these, but they cannot set them. 
	properties (SetAccess = protected)
        useNativeUDP = false
        udpClient
		localIP
		remoteIP
        portUDP
        verbosity             % choose from {'min', 'normal', 'max'}
        sentMessagesCount     % number of messages sent
        receivedMessagesCount % number of messages received
        timeOutsCount         % number of timeouts
    end

    properties (Access = private)
        waitForMessageSignature = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPcommunicator.waitForMessage'));
        sendMessageSignature    = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPcommunicator.sendMessage'));
        selfSignature           = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPcommunicator'));
    end
    
    properties (Constant)
        % SPECIAL STATUSES
        TRANSMITTED_MESSAGE_MATCHES_EXPECTED = 'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE';
        ABORT_MESSAGE = struct('label', 'ABORT', 'value', 'NOW');
    end
    
	% Public methods
    methods
        % Constructor
        function obj = UDPcommunicator(varargin)
           
            % Reset counters
            obj.sentMessagesCount = 0;       % number of messages sent
            obj.receivedMessagesCount = 0;   % number of messages received
            obj.timeOutsCount = 0;           % number of timeouts
        
            % Set default values for optional config params
            defaultUDPport =  2007;
            defaultVerbosity = 'min';
            defaultUseNativeUDP = false;
            
            % Parse input parameters.
            p = inputParser;
            % addParameter is available after 2013b
            %p.addParameter('localIP', 'none', @ischar);
            %p.addParameter('remoteIP', 'none', @ischar);
            %p.addParameter('udpPort', defaultUDPport, @isnumeric);
            %p.addParameter('verbosity', defaultVerbosity, @ischar);
            
            % For earlier versions use addParamValue
            p.addParamValue('localIP',   'none',           @ischar);
            p.addParamValue('remoteIP',  'none',           @ischar);
            p.addParamValue('udpPort',   defaultUDPport,   @isnumeric);
            p.addParamValue('verbosity', defaultVerbosity, @ischar);
            p.addParamValue('useNativeUDP', defaultUseNativeUDP, @islogical);
            
            p.parse(varargin{:});
            obj.localIP  = p.Results.localIP;
            obj.remoteIP = p.Results.remoteIP;
            obj.portUDP  = p.Results.udpPort;
            obj.verbosity = p.Results.verbosity;
            obj.useNativeUDP = p.Results.useNativeUDP;
            
            if strcmp(obj.localIP, 'none')
                error('%s No ''localIP'' was specified', obj.selfSignature);
            end
            if strcmp(obj.remoteIP, 'none')
                error('%s No ''remoteIP'' was specified', obj.selfSignature);
            end
            
            if strcmp(obj.verbosity,'max')
                fprintf('%s Initializing (local:%s remote:%s)\n', obj.selfSignature, obj.localIP, obj.remoteIP);
            end

            % initialize UDP communication
            if (obj.useNativeUDP)
                fprintf('\nOpening udp channel ...');
                echoudp('off');
                echoudp('on', 4012);
                obj.udpClient = udp(obj.remoteIP, obj.portUDP);
                fopen(obj.udpClient);
                fprintf('Opened udp channel\n');
            else
                matlabUDP('close');
                matlabUDP('open', obj.localIP, obj.remoteIP, obj.portUDP);
            end
            
            % flash any remaining bits
            obj.flashQueue();
            
            if strcmp(obj.verbosity,'max')
                fprintf('%s Initialized.\n', obj.selfSignature);
            end
        end
        
        % Public API (low-level)
        response = waitForMessage(obj, msgLabel, varargin);
        status = sendMessage(obj, msgLabel, varargin);
        flashedContents = flashQueue(obj);
        
        % Public API (higher level)
        % Wait for ever to get a message. Return the message value if the
        % expected and received labels match or fail if the labels do not match, providing the strack trace
        parameterValue = getMessageValueWithMatchingLabelOrFail(obj, messageLabel);
        
        % Send a message and wait for an good acknowledgment of fail,
        % providing the stack trace. 
        % messageTuple = {messageLabel} or {messageLabel, messageValue}
        sendMessageAndReceiveAcknowldegmentOrFail(obj, messageTuple);
        
        % Method that transmits a communication packet and acts for the received acknowledgment
        errorReport = transmitCommunicationPacket(obj, communicationPacket, varargin);

    
        % Just a utility method for testing message transmission
        showMessageValueAsStarString(obj, msgCount, direction, msgLabel, msgValueType, msgValue, maxValue, maxStars);
        
        % Close UDP
        shutDown(obj);
        
    end % public method
    
    methods (Access = private)
        % method to transmit a parameter (paramName, paramValue, [timeOutInSeconds])
        ack = send(obj, paramName, paramValue, timeOutInSeconds);
        
        % method to transmit a parameter (paramName, paramValue, [timeOutInSeconds])
        dStruct = receive(obj, timeOutInSeconds);
    end % private methods
end

