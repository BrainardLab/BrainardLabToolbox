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
        ACKNOWLEDGMENT = 'EXPECTED_MESSAGE_RECEIVED';
        ABORT_MESSAGE = struct('label', 'ABORT', 'value', 'NOW');
        
        % TRANSMISSION STATUS
        GOOD_TRANSMISSION = 'GOOD_TRANSMISSION';
        BAD_ACKNOWLDGMENT = 'BAD_ACKNOWLEDGMENT';
        NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD = 'NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD';
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
        packet = waitForMessage(obj, msgLabel, varargin);
        transmissionStatus = sendMessage(obj, msgLabel, msgData, varargin);
        flashedContents = flashQueue(obj);
        
        % Method that transmits a communication packet and acts for the received acknowledgment
        errorReport = transmitCommunicationPacket(obj, communicationPacket, varargin);

        % Close UDP
        shutDown(obj);
        
    end % public method
    
    methods (Access = private)
        displayMessage(obj, message);
    end % private methods
end

