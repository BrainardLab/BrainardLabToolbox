function combinePDFfilesInSinglePDF(sourcePDFFileNames, pdfFileName)

    for k = 1:numel(sourcePDFFileNames)
        theFileName = sourcePDFFileNames{k};
        if (k == 1)
            system(sprintf('cp %s %s', theFileName, pdfFileName));
            fprintf('file %s appended as the first page of %s.\n', theFileName, pdfFileName);
        else
            mergedFileName = sprintf('mergedPDF.pdf');
            status = system(sprintf('/usr/local/bin/pdfunite %s %s %s', pdfFileName, theFileName, mergedFileName));
            if (status ~= 0)
                fprintf('Error during pdfunite. Have you installed poppler (''brew install poppler'')?');
            else
                system(sprintf('mv %s %s', mergedFileName, pdfFileName));
                fprintf('file %s appended as the last page of %s.\n', theFileName, pdfFileName);
            end
        end
    end
    
    
end

