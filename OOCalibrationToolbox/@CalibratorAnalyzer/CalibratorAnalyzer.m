% Subclass of @Calibrator that analyzes 
% and displays data from a given calibration file.
%
% 4/10/2014  npc   Wrote it.
% 9/12/2024  rb changed to allow for comparisons between calibrations.

classdef CalibratorAnalyzer < handle
    % Public properties
    properties
        essentialDataGridDims       = [3 3]; % 3 columns x 3 rows
        linearityChecksGridDims     = [2 3]; % 2 columns x 3 rows
        backgroundEffectsGridDims   = [3 2]; % 3 columns x 2 rows
        luminanceVsChromaticityGridDims = [2 1]; % 2 columns x 1 row
        comparisonGridDims          = [2 2]; % 2 columns x 2 rows
    end
    
    properties (SetAccess = private) 
       analysisScriptName;
    end
    
    % Private properties. These must be specified at initialization time
    properties (Access = private)

        figureGroupName;  
        figureHandlesArray;  

        % calStructOBJ to access imported cal data in unified way
        calStructOBJ;
        % cell array to store calStructOBJ for each file
        calStructOBJarray = {};
        % the imported cal
        newStyleCal;
        % cell array to store the imported cal for each file
        newStyleCalarray = {};
        % where to save plots
        plotsExportsFolder = {};
    end
    
    % Public methods
    methods
        % Constructor
        function obj = CalibratorAnalyzer(cals, calFilenames, calDirs)

            numFiles = length(calFilenames);
            
             % Preallocate cell arrays 
            obj.calStructOBJarray = cell(numFiles, 1);
            obj.newStyleCalarray = cell(numFiles, 1);
            obj.plotsExportsFolder = cell(numFiles, 1);

            for ii = 1:numFiles
                % Extract arguments for the i-th file
                cal = cals{ii};
                calFilename = calFilenames{ii};
                calDir = calDirs{ii};
            
                % Generate CalStructOBJ to handle the (new-style) cal struct
                [obj.calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(cal);

                if (obj.calStructOBJ.inputCalHasNewStyleFormat)
                    % Make a copy of the imported cal
                    obj.newStyleCal = cal;
                    calFolder = calDir; % CalDataFolder([],calFilename, calDir);
                    calPlotFolder = fullfile(calFolder,'Plots');
                    if (~exist(calPlotFolder,'dir'))
                        unix(['mkdir ' calPlotFolder]);
                    end
                    calFilePlotFolder = fullfile(calPlotFolder,calFilename);
                    if (~exist(calFilePlotFolder,'dir'))
                        unix(['mkdir ' calFilePlotFolder]);
                    end
                    calDate = obj.calStructOBJ.get('date');
                    thePlotFolder = fullfile(calFilePlotFolder,calDate(1:11));
                    if (~exist(thePlotFolder,'dir'))
                        unix(['mkdir ' thePlotFolder]);
                    end
    
                obj.plotsExportsFolder{ii} = thePlotFolder;

                obj.calStructOBJarray{ii} = obj.calStructOBJ;

                obj.newStyleCalarray{ii} = obj.newStyleCal;

                else
                    fprintf('The imported cal struct has an old-style format.\n');
                    error('Use ''mglAnalyzeMonCalSpd'' for analysis, instead.\n');
                end
            end
     
        end
                     
        % Method to analyze the loaded calStruct
        obj = analyze(obj, essentialDataGridDims, linearityChecksGridDims);

    end % Public methods

    
    % Private methods
    methods (Access = private)
        % Method to refit the data (if the user so chooses)
        refitData(obj);
        
        % Method to plot all the data
        plotAllData(obj, essentialDataGridDims, linearityChecksGridDims);
        
        % Method to generate plots of the essential data.
        plotEssentialData(obj, figureGroupIndex, gridDims);
        
        % Method to generate plots of the linearity check data.
        plotLinearityCheckData(obj, figureGroupIndex, gridDims);

        % Method to generate plots of the background effects data.
        plotBackgroundEffectsData(obj, figureGroupIndex, gridDims);

        % Method to generate plots of the chromaticity stability across luminance.
        plotLuminanceVsChromaticityData(obj, figureGroupIndex, gridDims);

        % Method to generate comparison plots for the essential data.
        plotCalibrationComparison(obj, figureGroupIndex, gridDims); 

        % Method to generate gamma comparison plots for the essential data.
        plotGammaComparison(obj, figureGroupIndex, gridDims);
        
        % Method to generate a shaded (filled) plot
        makeShadedPlot(obj, x,y, faceColor, edgeColor, ax);
       
    end  % private methods
    
    % Static methods
    methods (Static)
        [calFilename, calDir, cal, calIndex] = singleSelectCalFile();
        [calFilename, calDir, cal, additionalCalIndex] = selectCalFile();
    end
    
end

