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
    end


	% Public methods
    methods
        % Constructor
        function obj = UDPcommunicator(varargin)
            % Parse input parameters.

            defaultUDPport =  2007;
            defaultVerbosity = 'normal';

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

            % initialize UDP communication
            matlabUDP('close');
            q = matlabUDP('open', obj.localIP, obj.remoteIP, obj.portUDP);

            if (strcmp(obj.verbosity,'normal'))
                fprintf('Opened UDP channel\n.')
            end
        end
end

