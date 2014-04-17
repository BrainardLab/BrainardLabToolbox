% Subclass of @Calibrator based on the MGL graphics library.
%
% 3/27/2014  npc   Wrote it.
%

classdef MGLcalibrator < Calibrator  
     % Public properties (specific to the @MGLcalibrator class) 
    properties
       
    end
    
    % --- PRIVATE PROPERTIES ----------------------------------------------
    properties (Access = private) 
        % identity gamma table for bitsPP
        identityGammaForBitsPP = [];
    end
    % --- END OF PRIVATE PROPERTIES ---------------------------------------
    
    % Public methods
    methods
        % Constructor
        function obj = MGLcalibrator(varargin)  
            % Call the super-class constructor.
            obj = obj@Calibrator(varargin{:});
            
            obj.graphicsEngine = 'MGL';
            
            % Verify validity of screen params values
            obj.verifyScreenParamValues();
        end
    end % Public methods
    
    % Implementations of required -- Public -- Abstract methods defined in the @Calibrator interface   
    methods
        % Method to conduct an mgl-based calibration sequence
        obj = calibrate(obj);
        
        % Method to ensure that the parameters of the screen match those specified by the user
        obj = verifyScreenParamValues(obj);
        
        % Method to shutdown the Calibrator
        obj = shutdown(obj);    
    end % Implementations of required -- Public -- Abstract methods defined in the @Calibrator interface
    
    
    % Private methods that only the MGLcalibrator object can call
    methods (Access = private)  
        % Method to set the initial state of the displays
        setDisplaysInitialState(obj, userPrompt);
        
        % Method to load the background and target indices of the current LUT and 
        % subsequently conduct a single radiometric measurement by calling the corresponding
        % method of the attached @Radiometer object.
        [measurement, S] = loadClutAndMeasure(obj, bgSettings, targetSettings, useBitsPP);
        
    end  % Private methods 
    
end % classdef