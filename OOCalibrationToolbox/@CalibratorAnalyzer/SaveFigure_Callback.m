function SaveFigure_Callback(obj, hObject, eventdata, current_gcf, fileName)
    dpi = 300;
    ExportToPDF(fullfile(obj.plotsExportsFolder, fileName),current_gcf,dpi)
    %FigureSave(fullfile(obj.plotsExportsFolder, fileName),current_gcf,'pdf');
    questdlg(sprintf('''%s'' plot was saved in:', fileName), fileName, obj.plotsExportsFolder,obj.plotsExportsFolder);
end

function ExportToPDF(pdfFileName,handle,dpi)

    % Verify correct number of arguments
    narginchk(0,3);

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
    prePaperType = get(handle,'PaperType');
    prePaperUnits = get(handle,'PaperUnits');
    preUnits = get(handle,'Units');
    prePaperPosition = get(handle,'PaperPosition');
    prePaperSize = get(handle,'PaperSize');

    % Make changing paper type possible
    set(handle,'PaperType','<custom>');

    % Set units to all be the same
    set(handle,'PaperUnits','inches');
    set(handle,'Units','inches');

    % Set the page size and position to match the figure's dimensions
    paperPosition = get(handle,'PaperPosition');
    position = get(handle,'Position');
    set(handle,'PaperPosition',[0,0,position(3:4)]);
    set(handle,'PaperSize',position(3:4));

    % Save the pdf (this is the same method used by "saveas")
    print(handle,'-dpdf', '-noui', pdfFileName, sprintf('-r%d',dpi))

    % Restore the previous settings
    set(handle,'PaperType',prePaperType);
    set(handle,'PaperUnits',prePaperUnits);
    set(handle,'Units',preUnits);
    set(handle,'PaperPosition',prePaperPosition);
    set(handle,'PaperSize',prePaperSize);

end
