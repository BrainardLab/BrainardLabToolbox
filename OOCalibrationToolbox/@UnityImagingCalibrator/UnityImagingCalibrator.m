% Subclass of @Calibrator based on Unity graphics.
%
% 7/08/2024  fh   Wrote it.
%

classdef UnityImagingCalibrator < Calibrator  
    % Public properties (specific to the @UnityImagingCalibrator class) 
    properties
        % a txt file in the drop box that both MATLAB and Unity have access
        % to
        dropbox_filePath;
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
        
        % the original LUT (to be restored upon termination)
        origLUT;
    end
    
    
    % Public methods
    methods
        % Constructor
        function obj = UnityImagingCalibrator(dropbox_filePath, varargin)  
            % Call the super-class constructor.
            obj = obj@Calibrator(varargin{:});

            % Set the communication file paths
            obj.dropbox_filePath = dropbox_filePath;
            
            obj.graphicsEngine = 'UnityImaging';
            
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
        [measurement, S] = updateStimulusAndMeasure(obj, bgSettings, targetSettings);

        % Method to ensure that the parameters of the screen match those specified by the user
        obj = verifyScreenParamValues(obj);
        
        % Method to shutdown the Calibrator
        obj = shutdown(obj);    
    end % Implementations of required -- Public -- Abstract methods defined in the @Calibrator interface

    % Private methods that only the UnityImagingCalibrator object can call
    methods (Access = private)  
        
        % Method to change the background and target color
        updateBackgroundAndTarget(obj, bgSettings, targetSettings);   

        % Append message to the pre-specified text file
        appendMessageToFile(obj, message);

        % Method that checks whether the last word matches 
        checkLastWordInFile(obj, word);
    end  % Private methods 

end