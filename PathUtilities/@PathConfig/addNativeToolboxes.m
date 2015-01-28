% Method to add select native toolboxes
function addNativeToolboxes(s, listOfToolboxesToAdd)

    for k = 1:numel(listOfToolboxesToAdd)
        for l = 1:numel(s.toolboxNames)
           if (~isempty(strfind(s.toolboxNames{l}, listOfToolboxesToAdd{k})))
              fprintf('\nAdding native toolbox: %s\n', s.toolboxNames{l});
              addpath(genpath(s.toolboxLocalDirs{l})); 
           end
        end
    end
    
end

