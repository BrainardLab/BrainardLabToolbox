function ImportAxes(figFilename, plotAxes, axesProperties, labelProperties, titleProperties)
% ImportAxes(figFilename, plotAxes, [axesProperties], [labelProperties], [titleProperties])
%
% Description:
% Opens a fig file and places axes contents into another axes such as on a
% subplot.
%
% Input:
% figFilename (string) - Filename of the figure.
% plotAxes (scalar) - Handle to the axes to be replaced.
%
% Optional Input:
% axesProperties (struct) - Struct containing properties and property values
%   to apply to the imported axes.  Look at the set function doc to see
%   more info on how the property struct is used.
% labelProperties (struct) - Struct containing properties and propery
%   values to apply to the imported axes labels.  Labels are their own
%   objects, so axes properties don't apply.
% titleProperties (struct) = Struct containing properties and propery
%   values to apply to the imported axes title.  The title is its own
%   object, so axes properties don't apply.
% Example:
% h = subplot(3,2,1); 
% ImportFigure('plot1.fig', h); 

if nargin < 2 || nargin > 5
	error(help('ImportAxes'));
end

if ~exist('axesProperties', 'var')
	axesProperties = [];
end
if ~exist('labelProperties', 'var')
	labelProperties = [];
end
if ~exist('titleProperties', 'var')
	titleProperties = [];
end

% Import fig info.
importFig = hgload(figFilename, struct('visible','off')); % Open fig file and get handle
importFigAxes = get(importFig, 'Children');				  % Get handle to axes

% Get subplot axes info.
newFig = get(plotAxes, 'Parent');           % Get new (subplot) figure handle.
subplotPos = get(plotAxes, 'Position');     % Get position of subplot axes.
delete(plotAxes);							% Delete blank subplot axes.

% Copy axes over to subplot.
newSubplotAxes = copyobj(importFigAxes, newFig);  % Copy import fig axes to subplot
set(newSubplotAxes, 'Position', subplotPos)		  % Set position to orginal subplot axes

% Set any passed properties for the axes.
if ~isempty(axesProperties)
	set(newSubplotAxes, axesProperties);
end

% Set any passed properties for the labels.
if ~isempty(labelProperties)
	labelList = {'XLabel', 'YLabel', 'ZLabel'};
	for i = 1:length(labelList)
		% Get the handle to the label object.
		h = get(newSubplotAxes, labelList{i});
		
		% Set the label properties.
		set(h, labelProperties);
	end
end

if ~isempty(titleProperties)
	% Handle to the title object.
	h = get(newSubplotAxes, 'Title');
	
	% Set the title properties.
	set(h, titleProperties);
end

% Delete the imported figure.
delete(importFig);
