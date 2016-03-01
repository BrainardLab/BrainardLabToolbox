classdef OLVSGcommunicator < UDPcommunicator
    % OLVSGcommunicator Class to facilitate communication between Win, Mac
    % computers involved in the OneLight - VSG setup
    %   Detailed explanation
    
    % Read-only properties
    properties (SetAccess = private)
        validParamValues;
    end
    
    
    % Pre-defined param names 
    properties (Constant)
        
        WAIT_STATUS                 = 'Wait Status Label';
        PROTOCOL_NAME               = 'Protocol Name Label';
        OBSERVER_ID                 = 'Observer ID Label';
        OBSERVER_ID_AND_RUN         = 'Observer ID and Run Label';
        NUMBER_OF_TRIALS            = 'Number of Trials Label';
        STARTING_TRIAL_NO           = 'Starting Trial No Label';
        OFFLINE                     = 'Offline Label';
        
        USER_READY_STATUS           = 'User Ready Status Label';
        EYE_TRACKER_STATUS          = 'Eye Tracker Status Label';
        EYE_TRACKER_DATA_POINTS_NUM = 'Eye Tracker Data Points Num Label';
        TRIAL_OUTCOME               = 'Trial Outcome Label';
        
        DATA_TRANSFER_STATUS        = 'Data Transfer Status Label';
        DATA_TRANSFER_POINTS_NUM    = 'Data Points To Be Transfered Label';
        DATA_TRANSFER_REQUEST_FOR_POINT = 'Data Trasnfer Request For Point Label';
        DATA_FOR_POINT              = 'Data For Point Label';
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
        
            % Initialize validValues
            obj.validParamValues = containers.Map('UniformValues',false);
            
            obj.flashQueue();
        end % constructor

        % param value validation 
        setValidValuesForParam(obj, paramName, validValues);
        
        % Method to receive a parameter value.
        % ex.: protocolNameStr = VSGOL.receiveParamValue(VSGOL.protocolName);
        % or   userReady = VSGOL.receiveParamValue('User Ready', timeOutSecs, 2.0);
        paramValue = receiveParamValue(obj, paramName, varargin);
        
        % Method to send a parameter value
        % ex.: OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.protocolName, 'something');
        % or   OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.protocolName, 'something', params.protocolName, timeOutSecs, 2.0, 'maxAttemptsNum', 3);
        % or   OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.go, []);
        sendParamValue(obj, paramName, paramValue, varargin);
        
        % Method to send a parameter value and wait for a response with a specified label
        response = sendParamValueAndWaitForResponse(obj, paramNameAndValue, expectedResponseLabel, varargin);
        
        % Method ro receive a parameter value, check its value and send a response
        receiveParamValueAndSendResponse(obj, paramNameAndValueToBeReceived, paramNameAndValueToBeSent, varargin);
    end % Public methods
    
    methods (Access = private)
        validateValueForParam(obj, paramName, paramValue, backTrace);
    end
end

