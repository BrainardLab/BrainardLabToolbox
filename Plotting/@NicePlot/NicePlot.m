% Static class with methods for re-nicing plots
% 
% Example usage:
%
% (1) Set font sizes for axes, labels, legends, and titles to a base size of 12
% NicePlot.setFontSizes(figureHandle, 'FontSize', 12);
%
% (2) Get position vectors for subplots with desired margins
% subplotPosVectors = NicePlot.getSubPlotPosVectors(...
%        'rowsNum', 2, ...
%        'colsNum', 3, ...
%        'heighthMargin',  0.06, ...
%        'widthMargin',    0.05, ...
%        'leftMargin',     0.07, ...
%        'bottomMargin',   0.15, ...
%        'topMargin',      0.1);
%    
% 11/14/2014  npc Wrote it.
%

classdef NicePlot
    
    methods (Static = true)
        % Method to return position vectors for all subplots
        posVectors = getSubPlotPosVectors(varargin);
        
        % Method to set the fonts for the axes, labels
        setFontSizes(figHandle, varargin);
        
        % Method to export fig in figHandle to a PDF doc that looks just
        % like the screen figure
        exportFigToPDF(pdfFileName,figHandle,dpi, varargin);

        exportFigToPNG(pngFileName,figHandle,dpi, varargin);
    end
end