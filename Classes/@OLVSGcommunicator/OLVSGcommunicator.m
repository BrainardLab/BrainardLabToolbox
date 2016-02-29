classdef OLVSGcommunicator < UDPcommunicator
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    % Read-only properties
    properties (SetAccess = private)
    end
    
    % Public methods
    methods
        % Constructor
        function obj = OLVSGcommunicator(varargin)  
            
            % Set default values for optional config params
            defaultUDPport =  2007;
            defaultVerbosity = 'min';
            defaultSignature = ' ';
            
            % Parse input parameters.
            p = inputParser;
            
            p.addParamValue('localIP',   'none',           @ischar);
            p.addParamValue('remoteIP',  'none',           @ischar);
            p.addParamValue('udpPort',   defaultUDPport,   @isnumeric);
            p.addParamValue('verbosity', defaultVerbosity, @ischar);
            p.addParamValue('signature', defaultSignature, @ischar);
            p.parse(varargin{:});
            
            % Call the super-class constructor.
            obj = obj@UDPcommunicator( ...
                'localIP', p.Results.localIP, ...    % required: the IP of this computer
                'remoteIP', p.Results.remoteIP, ...    % required: the IP of the computer we want to conenct to
                'udpPort', p.Results.udpPort, ...      % optional, with default value: 2007
                'verbosity', p.Results.verbosity ...             % optional, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
            );
        end
        
    end
    
end

