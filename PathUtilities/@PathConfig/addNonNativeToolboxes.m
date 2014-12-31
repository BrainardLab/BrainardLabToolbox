% Method to add select non-native toolboxes
function addNonNativeToolboxes(listOfToolboxesToAdd)

    for k = 1:numel(listOfToolboxesToAdd)
        addpath(genpath(listOfToolboxesToAdd{k})); 
    end
end