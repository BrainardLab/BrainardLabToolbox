classdef OLVSGcommunicator < UDPcommunicator
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    % Read-only properties
    properties (SetAccess = private)
    end
    
    % Pre-defined labels
    properties (Constant)
        PROTOCOL_NAME       = 'Protocol Name';
        OBSERVER_ID         = 'Observer ID';
        OBSERVER_ID_AND_RUN = 'Observer ID and Run';
        NUMBER_OF_TRIALS    = 'Number of Trials';
        STARTING_TRIAL_NO   = 'Starting Trial No';
        OFFLINE             = 'Offline';
        EYE_TRACKER_STATUS  = 'Eye Tracker Status';
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
        end % constructor

        % Method to receive a parameter value.
        % ex.: protocolNameStr = VSGOL.receiveParamValue(VSGOL.protocolName);
        % or   userReady = VSGOL.receiveParamValue('User Ready', timeOutSecs, 2.0);
        paramValue = receiveParamValue(obj, paramName, varargin);
        
        % Method to send a parameter value
        % ex.: OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.protocolName, 'something');
        % or   OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.protocolName, 'something', params.protocolName, timeOutSecs, 2.0, 'maxAttemptsNum', 3);
        % or   OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.go, []);
        sendParamValue(obj, paramName, paramValue, varargin);
        
    end % Public methods
    
end

