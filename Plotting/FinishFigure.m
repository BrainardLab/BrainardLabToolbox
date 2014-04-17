function FigureFigure(fig,figinfo)
% FigureFigure(fig,figinfo)
%
% Post-processing for standard figure;
%
% 01/03/10  dhb  Wrote it.
% 05/24/10  dhb  Be sure to set axis label font.
% 10/28/10  dhb  Handle types

% Bring figure to front
figure(fig);

switch (figinfo.type)
    case 'standard'
        % Format x tick labels
        xlim(figinfo.xrange);
        xTicks = linspace(figinfo.xrange(1),figinfo.xrange(2),figinfo.nxticks);
        xTickLabel = cell(size(xTicks));
        for i = 1:length(xTicks)
            xTickLabel{i} = sprintf(figinfo.xtickformat,xTicks(i));
        end
        set(gca,'XTick',xTicks,'XTickLabel',xTickLabel);
        
        % And y tick labels
        ylim(figinfo.yrange);
        yTicks = linspace(figinfo.yrange(1),figinfo.yrange(2),figinfo.nyticks);
        yTickLabel = cell(size(yTicks));
        for i = 1:length(yTicks)
            yTickLabel{i} = sprintf(figinfo.ytickformat,yTicks(i));
        end
        set(gca,'YTick',yTicks,'YTickLabel',yTickLabel);
        set(gca,'FontName',figinfo.fontname,'FontSize',figinfo.axisfontsize);
        
        % Set grid
        if (figinfo.grid)
            set(gca,'XGrid','on','YGrid','on');
        end
    case '3colsub'
        for i = 1:3
            subplot(1,3,i);
            % Format x tick labels
            xlim(figinfo.xrange);
            xTicks = linspace(figinfo.xrange(1),figinfo.xrange(2),figinfo.nxticks);
            xTickLabel = cell(size(xTicks));
            for i = 1:length(xTicks)
                xTickLabel{i} = sprintf(figinfo.xtickformat,xTicks(i));
            end
            set(gca,'XTick',xTicks,'XTickLabel',xTickLabel);
            
            % And y tick labels
            ylim(figinfo.yrange);
            yTicks = linspace(figinfo.yrange(1),figinfo.yrange(2),figinfo.nyticks);
            yTickLabel = cell(size(yTicks));
            for i = 1:length(yTicks)
                yTickLabel{i} = sprintf(figinfo.ytickformat,yTicks(i));
            end
            set(gca,'YTick',yTicks,'YTickLabel',yTickLabel);
            set(gca,'FontName',figinfo.fontname,'FontSize',figinfo.axisfontsize);
            
            % Set grid
            if (figinfo.grid)
                set(gca,'XGrid','on','YGrid','on');
            end
        end
        
    otherwise
        error('Unknown figure type passed');
end
