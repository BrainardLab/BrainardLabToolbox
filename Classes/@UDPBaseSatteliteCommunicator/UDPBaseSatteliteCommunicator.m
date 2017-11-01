classdef UDPBaseSatteliteCommunicator < handle
% Class for BASE <-> Multi-Sattelite UDP-based communication.
% 10/20/2017   NPC   Wrote it
%

	% Protected properties. 
	properties (SetAccess = protected)
        localHostName
        localIP 
        satteliteInfo
        localHostIsBase       % boolean indicating whether the local host is thebase
        localHostIsSattelite  % boolean indicating whether the local host is a sattelite
        verbosity             % choose from {'min', 'normal', 'max'}
        sentMessagesCount     % number of messages sent
        receivedMessagesCount % number of messages received
        timeOutsCount         % number of timeouts
    end

    properties (Access = private)
        udpHandle             % always set by obj.communicate
        waitForMessageSignature = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPBaseSatteliteCommunicator.waitForMessage'));
        sendMessageSignature    = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPBaseSatteliteCommunicator.sendMessage'));
        selfSignature           = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPBaseSatteliteCommunicator'));
    end
    
    properties (Constant)
        % SPECIAL STATUSES
        ACKNOWLEDGMENT = 'EXPECTED_MESSAGE_RECEIVED';
        ABORT_MESSAGE = struct('label', 'ABORT', 'value', 'NOW');
        
        % TRANSMISSION STATUS
        BAD_TRANSMISSION = 'BAD_TRANSMISSION';
        GOOD_TRANSMISSION = 'GOOD_TRANSMISSION';
        UNEXPECTED_MESSAGE_LABEL_RECEIVED = 'UNEXPECTED_MESSAGE_LABEL_RECEIVED';
        NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD = 'NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD';
        
        % TIMEOUT/BAD_TRANSMISSION ACTIONS
        NOTIFY_CALLER = 'NOTIFY_CALLER';
        THROW_ERROR = 'THROW_ERROR';
        
        % RANGE OF HANDLES ALLOWED IN matlabNUDP mexfile (CURRENTLY UP TO 5, SO: 0..4)
        MIN_UDP_HANDLE = 0;
        MAX_UDP_HANDLE = 4;
    end
    
	% Public methods
    methods
        % Constructor
        function obj = UDPBaseSatteliteCommunicator(localIP, satteliteInfo, varargin)
           
            % Reset counters
            obj.sentMessagesCount = 0;       % number of messages sent
            obj.receivedMessagesCount = 0;   % number of messages received
            obj.timeOutsCount = 0;           % number of timeouts
        
            % Set default values for optional config params
            defaultVerbosity = 'min';
            
            % Parse input parameters.
            p = inputParser;
            p.addRequired('localIP',  @ischar);
            p.addRequired('satteliteInfo');
            p.addParameter('verbosity', defaultVerbosity, @ischar);
            p.parse(localIP, satteliteInfo, varargin{:});
            
            obj.localIP  = p.Results.localIP;
            obj.satteliteInfo = p.Results.satteliteInfo;
            obj.verbosity = p.Results.verbosity;
            obj.localHostName = obj.getLocalHostName();

            if strcmp(obj.verbosity,'max')
                fprintf('%s Initialized.\n', obj.selfSignature);
            end
        end
        
        % Public API (low-level)
        packet = waitForMessage(obj, msgLabel, varargin);
        transmissionStatus = sendMessage(obj, msgLabel, msgData, varargin);
        displayMessage(obj, action,  messageLabel, messageData, packetNo, varargin);
        flashedContents = flashQueue(obj);
        
        % Public API (higher-level)
         
        % Method that established communication between local and remote host
        initiateCommunication(obj, hostRoles, hostNames, triggerMessage, varargin);
        
        % Method that sends/received a communicaiton packet
        [messageReceived, status, abortRequestedFromRemoteHost, roundTipDelayMilliSecs] = ...
            communicate(obj, packetNo, communicationPacket, varargin);

        % Close UDP
        shutDown(obj);
    end % public method
    
    % Convenience methods
    methods (Static)
        [UDPobj,satteliteChannelIDs] = instantiateObject(hostNames, hostIPs, hostRoles, commPorts, beVerbose);
        
        % Method that constructs a communication packet
        packet = makePacket(hostNames, direction, message, varargin)
        
        localHostName = getLocalHostName();
    end
         
    methods (Access = private)
        timedOutFlag = waitForMessageOrTimeout(obj, timeoutSecs);
        executeTimeOut(obj, timeOutMessage, timeOutAction);
    end % private methods
end

