classdef UDPBaseSatelliteCommunicator < handle
% Class for BASE <-> Multi-Satellite UDP-based communication.
% 10/20/2017   NPC   Wrote it
%

	% Protected properties.
	properties (SetAccess = protected)
        localHostName
        localIP
        baseInfo
        satelliteInfo
        localHostIsBase       % boolean indicating whether the local host is thebase
        localHostIsSatellite  % boolean indicating whether the local host is a satellite
        verbosity             % choose from {'min', 'normal', 'max'}
        sentMessagesCount     % number of messages sent
        receivedMessagesCount % number of messages received
        timeOutsCount         % number of timeouts
        flushDelay            % seconds to wait before flushing the UDP queue
        transmissionMode      % either 'SINGLE_BYTES', or 'WORDS'
    end

    properties (Access = private)
        udpHandle             % always set by obj.communicate
        waitForMessageSignature = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPBaseSatelliteCommunicator.waitForMessage'));
        sendMessageSignature    = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPBaseSatelliteCommunicator.sendMessage'));
        selfSignature           = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPBaseSatelliteCommunicator'));
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

        % RANGE OF HANDLES ALLOWED IN matlabNUDP mexfile (CURRENTLY UP TO 5, SO: 0..4)
        MIN_UDP_HANDLE = 0;
        MAX_UDP_HANDLE = 4;
        
        WORD_LENGTH = 80;
    end

	% Public methods
    methods
        % Constructor
        function obj = UDPBaseSatelliteCommunicator(localIP, baseInfo, satelliteInfo, varargin)

            % Reset counters
            obj.sentMessagesCount = 0;       % number of messages sent
            obj.receivedMessagesCount = 0;   % number of messages received
            obj.timeOutsCount = 0;           % number of timeouts

            % Set default values for optional config params
            defaultVerbosity = 'min';
            defaultTransmissionMode = 'SINGLE_BYTES';
            
            % Parse input parameters.
            p = inputParser;
            p.addRequired('localIP',  @ischar);
            p.addRequired('baseInfo');
            p.addRequired('satelliteInfo');
            p.addParameter('verbosity', defaultVerbosity, @ischar);
            p.addParameter('transmissionMode', defaultTransmissionMode, @(x)((ischar(x))&&(ismember(x,  {'SINGLE_BYTES','WORDS'}))));
            p.parse(localIP, baseInfo, satelliteInfo, varargin{:});

            obj.localIP  = p.Results.localIP;
            obj.baseInfo = p.Results.baseInfo;
            obj.satelliteInfo = p.Results.satelliteInfo;
            obj.verbosity = p.Results.verbosity;
            obj.transmissionMode = p.Results.transmissionMode;
            obj.localHostName = obj.getLocalHostName();
            obj.flushDelay = 0.1;
            
            
            if strcmp(obj.verbosity,'max')
                fprintf('%s Initialized.\n', obj.selfSignature);
            end
        end

        % Public API (low-level)
        packet = waitForMessage(obj, msgLabel, varargin);
        transmissionStatus = sendMessage(obj, msgLabel, msgData, varargin);
        displayMessage(obj, action,  messageLabel, messageData, packetNo, varargin);
        flushedContents = flushQueue(obj);

        % Public API (higher-level)

        % Method that established communication between local and remote host
        initiateCommunication(obj, hostRoles, hostNames, triggerMessage, varargin);

        % Method that constructs a communication packet
        packet = makePacket(obj, satelliteChannel, direction, message, varargin);

        % Method that sends/received a communicaiton packet
        [messageReceived, status, abortRequestedFromRemoteHost, roundTipDelayMilliSecs] = ...
            communicate(obj, packetNo, communicationPacket, varargin);

        % Close UDP
        shutDown(obj);
    end % public method

    % Convenience methods
    methods (Static)
        UDPobj = instantiateObject(hostNames, hostIPs, hostRoles, beVerbose, varargin);
        localHostName = getLocalHostName();
    end

    methods (Access = private)
        timedOutFlag = waitForMessageOrTimeout(obj, timeoutSecs, pauseTimeSecs, timeOutMessage);
        executeTimeOut(obj, timeOutMessage);
    end % private methods
end
