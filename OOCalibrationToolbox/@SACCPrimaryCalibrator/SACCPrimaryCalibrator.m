% Subclass of @Calibrator based on PsychImaging-controlled (Psychtoolbox-3) graphics
% and the subprimary control of the SACC display.
%
% 8/27/2021  dhb   Wrote it.
%

classdef SACCPrimaryCalibrator < Calibrator  
    % Public properties (specific to the @SACCPrimaryCalibrator class) 
    properties

    end

    % --- PRIVATE PROPERTIES ----------------------------------------------
    properties (Access = private) 
        % handle to screen to be calibrated
        masterWindowPtr;
        
        % handle to the other screen (if it exists)
        slaveWindowPtr;
        
        % array with all the open textures
        texturePointers = [];
        
        % screenRect of screen to be calibrated
        screenRect;

        % whichPrimary. This tells us which primary we are calibrating the
        % subprimaries of.
        whichPrimary = 1;

        % normalMode. True if LEDs should be in normal mode.  False
        % otherwise.
        normalMode = true;
        
        % the original LUT (to be restored upon termination)
        origLUT;
        
        % logical to physical mapping
        logicalToPhysical = [0:7 9:15];
        
        % number of subprimaries
        nSubprimaries = 15;
        
        % number of projector primaries
        nPrimaries = 3;
        
        % nInputLevels
        nInputLevels = 253;
        
        % subprimary setting to determine black level for measurements.
        arbitraryBlack = 0.05; % Range = 0-1
        
    end
    
    
    % Public methods
    methods
        % Constructor
        function obj = SACCPrimaryCalibrator(varargin)  
            % Call the super-class constructor.
            obj = obj@Calibrator(varargin{:});
            
            % Other properties
            obj.graphicsEngine = 'SACCPrimary';
            
            % Verify validity of screen params values
            obj.verifyScreenParamValues();
        end
    end % Public methods

    % Implementations of required -- Public -- Abstract methods defined in the @Calibrator interface   
    methods
        % Method to set the initial state of the displays
        setDisplaysInitialState(obj, userPrompt);

        % Method to update the stimulus and conduct a single radiometric measurement by 
        % calling the corresponding method of the attached @Radiometer object.
        [measurement, S] = updateStimulusAndMeasure(obj, bgSettings, targetSettings, useBitsPP);

        % Method to ensure that the parameters of the screen match those specified by the user
        obj = verifyScreenParamValues(obj);
        
        % Method to shutdown the Calibrator
        obj = shutdown(obj);    
    end % Implementations of required -- Public -- Abstract methods defined in the @Calibrator interface

    % Private methods that only the PsychImagingCalibrator object can call
    methods (Access = private)  
        
        % Method to change the background and target color
        updateBackgroundAndTarget(obj, bgSettings, targetSettings, useBitsPP);   
    end  % Private methods 

end