classdef UDPcommunicator < handle
% Class for UDP-based communication between two computers.
% UDPcommunicator is built on top of matlabUDP.mex located in BrainardLabToolbox/UDP.
%
% 2/4/2016   npc   Wrote it
%
	% Read-only properties
	properties (SetAccess = private)
		localIP
		remoteIP
        portUDP
        verbosity
    end

    properties (Access = private)
        waitForMessageSignature = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPcommunicator.waitForMessage'));
        sendMessageSignature    = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPcommunicator.sendMessage'));
        selfSignature           = sprintf('\n<strong>%s:</strong>', sprintf('%35s','UDPcommunicator'));
    end
    
	% Public methods
    methods
        % Constructor
        function obj = UDPcommunicator(varargin)
           
            % Set default values for some params
            defaultUDPport =  2007;
            defaultVerbosity = 'min';

            % Parse input parameters.
            p = inputParser;
            p.addParameter('localIP', 'none', @ischar);
            p.addParameter('remoteIP', 'none', @ischar);
            p.addParameter('udpPort', defaultUDPport, @isnumeric);
            p.addParameter('verbosity', defaultVerbosity, @ischar);
            
            p.parse(varargin{:});
            obj.localIP  = p.Results.localIP;
            obj.remoteIP = p.Results.remoteIP;
            obj.portUDP  = p.Results.udpPort;
            obj.verbosity = p.Results.verbosity;

            if strcmp(obj.localIP, 'none')
                error('%s No ''localIP'' was specified', obj.selfSignature);
            end
            if strcmp(obj.remoteIP, 'none')
                error('%s No ''remoteIP'' was specified', obj.selfSignature);
            end
            
            if (~strcmp(obj.verbosity,'min'))
                fprintf('%s Initializing (local:%s remote:%s)\n', obj.selfSignature, obj.localIP, obj.remoteIP);
            end

            % initialize UDP communication
            matlabUDP('close');
            matlabUDP('open', obj.localIP, obj.remoteIP, obj.portUDP);

            if (~strcmp(obj.verbosity,'min'))
                fprintf('%s Initialized.', obj.selfSignature);
            end
        end
        
        % Public API
        response = waitForMessage(obj, msgLabel, varargin);
        status = sendMessage(obj, msgLabel, varargin);
        showMessageValueAsStarString(obj, direction, msgLabel, msgValue, maxValue, maxStars);
        
    end % public method
    
    methods (Access = private)
        % method to transmit a parameter (paramName, paramValue, [timeOutInSeconds])
        ack = send(obj, paramName, paramValue, timeOutInSeconds);
        
        % method to transmit a parameter (paramName, paramValue, [timeOutInSeconds])
        dStruct = receive(obj, timeOutInSeconds);
    end % private methods
end

