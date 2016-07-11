function combinePDFfilesInSinglePDF(sourcePDFFileNames, pdfFileName)

    if (~exist('/usr/local/bin/pdfunite'))
        fprintf(2,'NOTE: pdfunite not found in /usr/local/bin.\nTo install pdfunite, open Terminal.app and type ''''brew install poppler''.\nWill not generate summary PDF.\n');
        return;
    end
    
    for k = 1:numel(sourcePDFFileNames)
        theFileName = sourcePDFFileNames{k};
        if (k == 1)
            system(sprintf('cp %s %s', theFileName, pdfFileName));
            fprintf('\nNicePlot: file %s appended as the first page of %s.\n', theFileName, pdfFileName);
        else
            mergedFileName = sprintf('mergedPDF.pdf');
            status = system(sprintf('/usr/local/bin/pdfunite %s %s %s', pdfFileName, theFileName, mergedFileName));
            if (status ~= 0)
                fprintf('Error during pdfunite. Have you installed poppler (''brew install poppler'')?');
            else
                system(sprintf('mv %s %s', mergedFileName, pdfFileName));
                fprintf('\nNicePlot: file %s appended as the last page of %s.\n', theFileName, pdfFileName);
            end
        end
    end
end

