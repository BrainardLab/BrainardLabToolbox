% Method to add select non-native toolboxes
function addNonNativeToolboxes(listOfToolboxesToAdd)

    for k = 1:numel(listOfToolboxesToAdd)
        toolboxPath = listOfToolboxesToAdd{k}{1};
        position = listOfToolboxesToAdd{k}{2};
        addpath(genpath(toolboxPath), position); 
    end
end