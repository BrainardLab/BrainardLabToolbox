% Method for determining all toolboxes that a function 
% with name 'functionName' may depend on
%
% 10/23/2014  npc  Wrote it
%

function findToolboxDependencies(functionName)

    if isempty(which(functionName))
        fprintf('Function ''%s'' not found in the path.', functionName); 
        return;
    end
    
    
    fprintf('\nWorking. Plese be patient ...');
    [fList,pList] = matlab.codetools.requiredFilesAndProducts(functionName);
    
    fprintf('\n Function ''%s'' has the following %d dependencies:\n', which(functionName), numel(pList));
    for k = 1:numel(pList)
        fprintf('\t[%d]: %s\n', k, char(pList(k).Name));
    end
    
end