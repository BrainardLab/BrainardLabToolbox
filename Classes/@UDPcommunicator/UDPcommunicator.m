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
        waitForMessageSignature = sprintf('\n\t<strong>UDPcommunicator.waitForMessage:</strong>');
        sendMessageSignature    = sprintf('\n\t<strong>UDPcommunicator.sendMessage:</strong>');
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
                error('No ''localIP'' was specified\n');
            end
            if strcmp(obj.remoteIP, 'none')
                error('No ''remoteIP'' was specified\n');
            end
            
            if (~strcmp(obj.verbosity,'min'))
                fprintf('\nInitializing UDPcommunicator (local:%s remote:%s)\n', obj.localIP, obj.remoteIP);
            end

            % initialize UDP communication
            matlabUDP('close');
            matlabUDP('open', obj.localIP, obj.remoteIP, obj.portUDP);

            if (~strcmp(obj.verbosity,'min'))
                fprintf('UDPcommunicator  initialized! \n');
            end
        end
        
        % Public API
        response = waitForMessage(obj, msgLabel, varargin);
        status = sendMessage(obj, msgLabel, msgArgument, varargin);
        
    end % public method
    
    methods (Access = private)
        % method to transmit a parameter (paramName, paramValue, [timeOutInSeconds])
        ack = send(obj, paramName, paramValue, timeOutInSeconds);
        
        % method to transmit a parameter (paramName, paramValue, [timeOutInSeconds])
        dStruct = receive(obj, timeOutInSeconds);
    end % private methods
end

