classdef UDPcommunicator2 < handle
% Class for robust UDP-based communication between two computers.
% 9/15/2017   NPC   Wrote it
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
        waitForMessageSignature = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPcommunicator2.waitForMessage'));
        sendMessageSignature    = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPcommunicator2.sendMessage'));
        selfSignature           = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPcommunicator2'));
    end
    
    properties (Constant)
        % SPECIAL STATUSES
        TRANSMITTED_MESSAGE_MATCHES_EXPECTED = 'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE';
        ABORT_MESSAGE = struct('label', 'ABORT', 'value', 'NOW');
    end
    
	% Public methods
    methods
        % Constructor
        function obj = UDPcommunicator2(varargin)
           
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
            p.addParameter('localIP',   'none', @ischar);
            p.addParameter('remoteIP',  'none', @ischar);
            p.addParameter('udpPort',   defaultUDPport, @isnumeric);
            p.addParameter('verbosity', defaultVerbosity, @ischar);
            p.addParameter('useNativeUDP', defaultUseNativeUDP, @islogical);
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

