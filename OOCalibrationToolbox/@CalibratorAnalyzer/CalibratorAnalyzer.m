% Subclass of @Calibrator that analyzes 
% and displays data from a given calibration file.
%
% 4/10/2014  npc   Wrote it.
%

classdef CalibratorAnalyzer < Calibrator  
    % Public properties
    properties
    end
    
    properties (SetAccess = private) 
       analysisScriptName;
    end
    
    % Private properties. These must be specified at initialization time
    properties (Access = private)
        desktopHandle;
        figureGroupName;
        figureHandlesArray;
    end
    
    % Public methods
    methods
        % Constructor
        function obj = CalibratorAnalyzer(varargin)  
            % Call the super-class constructor, with 
            obj = obj@Calibrator( ...
                    'executiveScriptName',      [], ...
                    'radiometerObj',            [], ...
                    'screenToCalibrate',        [], ...
                    'desiredScreenSizePixel',   [], ...
                    'desiredRefreshRate',       [], ...
                    'displayPrimariesNum',      [], ...
                    'displayDeviceType',        [], ...
                    'displayDeviceName',        [], ...
                    'calibrationFile',          [], ...
                    'comment',                  [] ...
                 );
            
            % Configure an inputParser to examine whether the options passed to us are valid
            parser = inputParser;
            parser.addParamValue('analysisScriptName', obj.analysisScriptName);
            
            % Execute the parser
            parser.parse(varargin{:});
            % Create a standard Matlab structure from the parser results.
            parserResults = parser.Results;
            pNames = fieldnames(parserResults);
            for k = 1:length(pNames)
                obj.(pNames{k}) = parserResults.(pNames{k}); 
            end
            
            % Get the desktop's Java handle
            obj.desktopHandle = com.mathworks.mde.desk.MLDesktop.getInstance;
        end
        
        % Method to analyze the loaded calStruct
        obj = analyze(obj, calStruct);
    end % Public methods
    
    
    % Implementations of required -- Public -- Abstract methods defined in the @Calibrator interface   
    methods
        % Empty implementation of calibrate() method. Not needed.
        function obj = calibrate(obj)
            % do nothing
        end
        % Empty implementation of verifyScreenParamValues() method. Not needed.
        function obj = verifyScreenParamValues(obj)
        end
        
        % Method to shutdown the CalibratorAnalyzer
        function obj = shutdown(obj)
        end
    end % Implementations of required -- Public -- Abstract methods defined in the @Calibrator interface

    % Private methods
    methods (Access = private)

        % Method to refit the data (if the user so chooses)
        refitData(obj);
        
        % Method to plot all the data
        plotAllData(obj);
        
        % Method to plot essential data from a calStruct
        plotEssentialData(obj);
        
        % Method to add a figure to the Figures group
        updateFiguresGroup(obj, figureHandle);
        
        % Method to dock a figure to a window representing a group of figues
        dockFigureToGroup(obj, figureHandle, groupName)
    end  % private methods
    
end

