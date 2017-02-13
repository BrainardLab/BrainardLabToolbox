load('/Users/Shared/Matlab/Experiments/ColorMaterial/code/PilotImageList.mat')
competitorPairs = nchoosek(1:length(imageNames),2);
for i = 1:length(competitorPairs) % reconstruct the image names, using the same logic as in the exp. code.
    competitorPairList(i,:) = {[imageNames{competitorPairs(i,1)}, '-' imageNames{competitorPairs(i,2)}]};
end

n = 0; 
k = 0; 
r = 0; 
rowIndex = nan(7,7);
columnIndex = nan(7,7);
overallColorMaterialPairIndices = nan(7,7);
overallColorMatchFirst = []; 
% loop through the competitor list
for i = 1:length(competitorPairList)
    for whichMaterialOfTheColorMatch = 1:7
        for whichColorOfTheMaterialMatch = 1:7
            tempString = competitorPairList{i};
            colorMatchString = ['C4M' num2str(whichMaterialOfTheColorMatch)];
            materialMatchString = ['C' num2str(whichColorOfTheMaterialMatch) 'M4'];
            colorMatchFirstString = {[colorMatchString '-' materialMatchString]}; % search for these strings.
            colorMatchSecondString = {[materialMatchString '-' colorMatchString]};
            if strcmp(tempString, colorMatchFirstString)
                rowIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = whichColorOfTheMaterialMatch;
                columnIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = whichMaterialOfTheColorMatch;
                overallColorMaterialPairIndices(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = i;
                overallColorMatchFirst = [overallColorMatchFirst, i]; 
            elseif strcmp(tempString, colorMatchSecondString)
                rowIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = whichColorOfTheMaterialMatch;
                columnIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = whichMaterialOfTheColorMatch;
                overallColorMaterialPairIndices(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = i;
           else
                r = r+1;
            end
        end
    end
end
save('pilotIndices', 'rowIndex', 'columnIndex', 'overallColorMaterialPairIndices', 'overallColorMatchFirst')

% n = 0;
% clear rowIndex columnIndex overallIndex
% for whichColorOfTheMaterialMatch = 1:length(params.materialMatchColorCoords)
%     for whichMaterialOfTheColorMatch = 1:length(params.colorMatchMaterialCoords)
%         rowIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = [whichColorOfTheMaterialMatch];
%         columnIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = [whichMaterialOfTheColorMatch];
%         n = n + 1;
%         overallColorMaterialPairIndices(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = n;
%         
%         