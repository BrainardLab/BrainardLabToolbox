function [fig,figinfo] = StartFigure(type)
% [fig,figinfo] = StartFigure(type)
%
% Initialize figure and info structure.  Idea
% is that by changing variables here we can
% reformat most of the figure structure without
% having to go redo calling code.
%
% 1/3/09   dhb  Wrote it.
% 10/28/10 dhb  Save type for FinishFigure

% Process type and set params
figinfo.type = type;
switch (type)
    case 'standard'
        figinfo.fontname = 'Helvetica';
        figinfo.axisfontsize = 14;
        figinfo.labelfontsize = 18;
        figinfo.titlefontsize = 18;
        figinfo.basicmarkersize = 6;
        figinfo.smallmarkersize = 2;
        figinfo.basiclinewidth = 2;
        figinfo.smalllinewidth = 1;
        figinfo.grid = 1;
        figinfo.xsize = 600;
        figinfo.ysize = 480;
    case '3colsub'
        figinfo.fontname = 'Helvetica';
        figinfo.axisfontsize = 12;
        figinfo.labelfontsize = 16;
        figinfo.titlefontsize = 16;
        figinfo.basicmarkersize = 5;
        figinfo.smallmarkersize = 3;
        figinfo.basiclinewidth = 1.5;
        figinfo.smalllinewidth = 0.5;
        figinfo.grid = 1;
        figinfo.xsize = 1200;
        figinfo.ysize = 350;
    otherwise
        error('Unknown figure type passed');
end

% Open figure
fig = figure; clf; hold on

% Set position
position = get(gcf,'Position');
position(3) = figinfo.xsize; position(4) = figinfo.ysize;
set(gcf,'Position',position);
set(gca,'FontName',figinfo.fontname,'FontSize',figinfo.axisfontsize);