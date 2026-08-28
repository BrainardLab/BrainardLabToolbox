classdef UnityImagingCalibrator < Calibrator  
    % UNITYIMAGINGCALIBRATOR Calibrator subclass for Unity-based display control.
    %
    % This class has a specialized purpose and requires a dual-computer
    % calibration setup. MATLAB runs this class on the conductor computer,
    % which issues calibration commands and controls the radiometer. A separate
    % display computer receives the commands and presents the requested stimuli
    % in Unity; this class does not render those stimuli locally.
    %
    % The conductor and display computers communicate through a text file on a
    % shared network disk that must be accessible to both computers. Set
    % dropbox_filePath to that file before starting calibration. MATLAB appends
    % commands to the file and polls it for acknowledgements written by Unity.
    %
    % Class structure and communication sequence:
    %   1. The constructor initializes the Calibrator superclass, identifies
    %      UnityImaging as the graphics engine, and validates display settings.
    %   2. setDisplaysInitialState writes Initialize_Unity and waits for Unity
    %      to report Finished_Screen_Setup.
    %   3. updateBackgroundAndTarget writes the requested background and target
    %      RGB settings and waits for Image_Successfully_Displayed.
    %   4. updateStimulusAndMeasure triggers the radiometer measurement and
    %      reports measurement completion through the shared file.
    %   5. shutDown writes Done to terminate the display-side sequence.
    %
    % Public methods implement the abstract Calibrator display interface.
    % Private methods format commands, append them to the communication file,
    % and poll the file for Unity acknowledgements.
    %
    % 7/08/2024  fh   Wrote it.
    %

    % Public properties (specific to the @UnityImagingCalibrator class) 
    properties
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
        function obj = UnityImagingCalibrator(varargin)  
            % Call the super-class constructor.
            obj = obj@Calibrator(varargin{:});

            % Set the communication file paths
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
        [measurement, S] = updateStimulusAndMeasure(obj, bgSettings, targetSettings, useBitsPP);

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
        IsLastWord = checkLastWordInFile(obj, word);
    end  % Private methods 

end
