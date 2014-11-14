% Subclass of @Calibrator that analyzes 
% and displays data from a given calibration file.
%
% 4/10/2014  npc   Wrote it.
%

classdef CalibratorAnalyzer < handle
    % Public properties
    properties
        essentialDataGridDims       = [3 3]; % 3 columns x 3 rows
        linearityChecksGridDims     = [2 3]; % 2 columns x 3 rows
        backgroundEffectsGridDims   = [2 3]; % 2 columns x 3 rows
    end
    
    properties (SetAccess = private) 
       analysisScriptName;
    end
    
    % Private properties. These must be specified at initialization time
    properties (Access = private)
        % specific to the display system
        desktopHandle;
        figureGroupName;
        figureHandlesArray;
        
        % calStructOBJ to access imported cal data in unified way
        calStructOBJ;
        
        % the imported cal
        newStyleCal;
        
        % where to save plots
        plotsExportsFolder;
    end
    
    % Public methods
    methods
        % Constructor
        function obj = CalibratorAnalyzer(cal, calFileName)
            
            % Generate CalStructOBJ to handle the (new-style) cal struct
            [obj.calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(cal);
    
            if (obj.calStructOBJ.inputCalHasNewStyleFormat)
                % Make a copy of the imported cal
                obj.newStyleCal = cal;
                
                calFolder = CalDataFolder([],calFileName);
                calPlotFolder = fullfile(calFolder,'Plots');
                if (~exist(calPlotFolder,'dir'))
                    unix(['mkdir ' calPlotFolder]);
                end
                calFilePlotFolder = fullfile(calPlotFolder,calFileName);
                if (~exist(calFilePlotFolder,'dir'))
                    unix(['mkdir ' calFilePlotFolder]);
                end
                calDate = obj.calStructOBJ.get('date');
                thePlotFolder = fullfile(calFilePlotFolder,calDate(1:11));
                if (~exist(thePlotFolder,'dir'))
                    unix(['mkdir ' thePlotFolder]);
                end
    
                obj.plotsExportsFolder = thePlotFolder;
            else
                fprintf('The imported cal struct has an old-style format.\n');
                error('Use ''mglAnalyzeMonCalSpd'' for analysis, instead.\n');
            end
    
            % Turn off JavaFrame will become obsolete warning
            warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            
            % Get the desktop's Java handle
            obj.desktopHandle = com.mathworks.mde.desk.MLDesktop.getInstance;
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
        plotEssentialData(obj, figureGroupIndex);
        
        % Method to generate plots of the linearity check data.
        plotLinearityCheckData(obj, figureGroupIndex);
        
        % Method to add a figure to the Figures group
        updateFiguresGroup(obj, figureHandle, figureGroupIndex);
        
        % Method to dock a figure to a window representing a group of figues
        dockFigureToGroup(obj, figureHandle, groupName);
        
        % Method to generate a shaded (filled) plot
        makeShadedPlot(obj, x,y, faceColor, edgeColor);
        
        % Method to export a plot
        SaveFigure_Callback(obj, hObject, eventdata, current_gcf, fileDir, fileName)
    end  % private methods
    
end

