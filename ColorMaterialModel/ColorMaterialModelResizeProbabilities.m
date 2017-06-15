function resizedMatrix = ColorMaterialModelResizeProbabilities(theDataProb, indexMatrix)
% function resizedMatrix = ColorMaterialModelResizeProbabilities(theDataProb, indexMatrix)

% From the data set that includes all probabilities, extracts the data for color/material trade off only.  
% Note: By convention, in the index matrix color differs across rows and
% material differs across columns. 
%
% Input: 
% theDataProb - the data probabilities measured in the experiment.  
% indexMatrix - matrix of indices needed for extracting only the
%                 probabilities for color/material trade-off. 
% Output: 
% resizedMatrix - matrix that contains only color/material trade off data.
% 
% 06/15/2017 ar    Wrote it. 

resizedMatrix = zeros(max(indexMatrix.rowIndex), max(indexMatrix.columnIndex)); 
for i = 1:length(indexMatrix.overallColorMaterialPairIndices)
    resizedMatrix(indexMatrix.rowIndex((i)), indexMatrix.columnIndex((i))) = ...
        theDataProb(indexMatrix.overallColorMaterialPairIndices(i));
end

end

