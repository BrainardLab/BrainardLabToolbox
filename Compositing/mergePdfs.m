function mergePdfs(fileNames, outputFile)
% Merge PDF files into single document
%
% Synopsis:
%    mergePdfs(fileNames, outputFile)
%
% Description:
%     Merges the pdf-Documents in the input cell array fileNames into one
%     single pdf-Document with file name outputFile
%     
%     This function uses the apache pdfbox (included in Matlab) to merge multiple pdf files into one document.
% 
% Usage:
%     inputFiles = {'foo.pdf', 'bar.pdf}; 
%     outputFileName = 'foobar.pdf'; 
%     mergePdfs(inputFiles, outputFileName);
%
% Benjamin Großmann (2023). Merge PDF-Documents
% (https://www.mathworks.com/matlabcentral/fileexchange/89127-merge-pdf-documents),
% MATLAB Central File Exchange. Retrieved April 8, 2023.

    memSet = org.apache.pdfbox.io.MemoryUsageSetting.setupMainMemoryOnly();
    merger = org.apache.pdfbox.multipdf.PDFMergerUtility;
    cellfun(@(f) merger.addSource(f), fileNames);
    merger.setDestinationFileName(outputFile);
    merger.mergeDocuments(memSet);
end