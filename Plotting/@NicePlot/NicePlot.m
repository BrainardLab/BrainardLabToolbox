% Class with static methods with various plot utilities
%
% 11/14/2014  npc Wrote it.
%
classdef NicePlot
    
    methods (Static = true)
        % Method to return position vectors for all subplots
        posVectors = getSubPlotPosVectors(varargin);
        
        % Method to set the fonts for the axes, labels
        setFontSizes(figHandle, varargin);
    end
end