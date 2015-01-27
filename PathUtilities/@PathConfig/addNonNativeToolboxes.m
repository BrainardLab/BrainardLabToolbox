% Method to add select non-native toolboxes
function addNonNativeToolboxes(listOfToolboxesToAdd)

    for k = 1:numel(listOfToolboxesToAdd)
        toolboxPath = listOfToolboxesToAdd{k}{1};
        position = listOfToolboxesToAdd{k}{2};
        fprintf('\nAdding non-native toolbox: %s\n', toolboxPath);
        addpath(genpath(toolboxPath), position);
    end
end