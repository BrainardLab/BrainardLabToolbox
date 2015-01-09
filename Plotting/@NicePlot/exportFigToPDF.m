function exportFigToPDF(pdfFileName,figHandle,dpi)

    % Verify correct number of arguments
    error(nargchk(0,3,nargin));

    % If no handle is provided, use the current figure as default
    if nargin<1
        [fileName,pathName] = uiputfile('*.pdf','Save to PDF file:');
        if fileName == 0; return; end
        pdfFileName = [pathName,fileName];
    end
    if nargin<2
        handle = gcf;
    end
    if nargin<3
        dpi = 150;
    end
        
    % Backup previous settings
    prePaperType = get(figHandle,'PaperType');
    prePaperUnits = get(figHandle,'PaperUnits');
    preUnits = get(figHandle,'Units');
    prePaperPosition = get(figHandle,'PaperPosition');
    prePaperSize = get(figHandle,'PaperSize');

    % Make changing paper type possible
    set(figHandle,'PaperType','<custom>');

    % Set units to all be the same
    set(figHandle,'PaperUnits','inches');
    set(figHandle,'Units','inches');

    % Set the page size and position to match the figure's dimensions
    paperPosition = get(figHandle,'PaperPosition');
    position = get(figHandle,'Position');
    set(figHandle,'PaperPosition',[0,0,position(3:4)]);
    set(figHandle,'PaperSize',position(3:4));

    set(figHandle,'InvertHardCopy','off')
    % Save the pdf (this is the same method used by "saveas")
    print(figHandle,'-dpdf',pdfFileName,sprintf('-r%d',dpi))

    % Restore the previous settings
    set(figHandle,'PaperType',prePaperType);
    set(figHandle,'PaperUnits',prePaperUnits);
    set(figHandle,'Units',preUnits);
    set(figHandle,'PaperPosition',prePaperPosition);
    set(figHandle,'PaperSize',prePaperSize);

end