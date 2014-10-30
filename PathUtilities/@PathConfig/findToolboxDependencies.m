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
    [requiredFilesList, productsList] = matlab.codetools.requiredFilesAndProducts(functionName);
    
    fprintf('\n Function ''%s'' requires %3d files to run', which(functionName), numel(requiredFilesList));
    fprintf('\n and it has the following %3d dependencies:\n', numel(productsList));
    for k = 1:numel(productsList)
        fprintf('\t[%d]: %s\n', k, char(productsList(k).Name));
    end
    
end