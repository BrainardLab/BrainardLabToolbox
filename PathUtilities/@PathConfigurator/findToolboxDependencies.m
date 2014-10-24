% Method for determining all toolboxes that a function 
% with name 'functionName' may depend on
%
% 10/23/2014  npc  Wrote it
%

function findToolboxDependencies(functionName)

    [fList,pList] = matlab.codetools.requiredFilesAndProducts(functionName);
    
    fprintf('Function ''%s'' has the following %d dependencies:\n', which(functionName), numel(pList));
    for k = 1:numel(pList)
        fprintf('\t[%d]: %s\n', k, char(pList(k).Name));
    end
    
end