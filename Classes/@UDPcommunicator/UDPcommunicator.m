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


	% Public methods
    methods
        % Constructor
        function obj = UDPcommunicator(varargin)
           
            % Set default values for some params
            defaultUDPport =  2007;
            defaultVerbosity = 'min';

             % Parse input parameters.
            p = inputParser;
            p.addRequired('localIP', @ischar);
            p.addRequired('remoteIP', @ischar);
            p.addOptional('portUDP', defaultRemoteIP, @isnumeric);
            p.addParamValue('verbosity', defaultVerbosity, @ischar);
            
            p.parse(varargin{:});
            obj.localIP  = p.Results.localIP;
            obj.remoteIP = p.Results.remoteIP;
            obj.portUDP  = p.Results.portUDP;
            obj.verbosity = p.Results.verbosity;

            if (~strcmp(obj.verbosity,'min'))
                fprintf('\nInitializing UDPcommunicator ... ');
            end

            % initialize UDP communication
            matlabUDP('close');
            matlabUDP('open', obj.localIP, obj.remoteIP, obj.portUDP);

            if (~strcmp(obj.verbosity,'min'))
                fprintf('UDPcommunicator  initialized! \n');
            end
        end
    end
end

