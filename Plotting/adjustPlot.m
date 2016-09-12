function adjustPlot(theFig)
% adjustPlot(theFig)
%
% Makes cosmetic adjustments to a figure.

% Ticks are going out
axesHandles = findobj(theFig, 'type', 'axes');
set(axesHandles, 'TickDir', 'out');

% Make the axes square and turns the bounding box off
for ii = 1:length(axesHandles)
    pbaspect(axesHandles(ii), [1 1 1]);
    box(axesHandles(ii), 'off')
end

% Sets the size of the figure to be [5 5], if there is only one subplot
if length(axesHandles) == 1
    set(theFig, 'PaperPosition', [0 0 5 5]);
    set(theFig, 'PaperSize', [5 5]);
end