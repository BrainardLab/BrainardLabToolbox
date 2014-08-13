function SaveFigure_Callback(obj, hObject, eventdata, current_gcf, fileName)
    FigureSave(fullfile(obj.plotsExportsFolder, fileName),current_gcf,'pdf');
    questdlg(sprintf('''%s'' plot was saved in:', fileName), fileName, obj.plotsExportsFolder,obj.plotsExportsFolder);
end