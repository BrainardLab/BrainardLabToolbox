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

    if (1==2)
    for k = 1:numel(fList)
        filename = sprintf('%s', char(fList{k}));
        %fprintf('\t[%d]: %s \n', k, char(fList{k}));
        [pathstr,name,ext] = fileparts(filename);
        if (strcmp(ext, '.m'))
            [~,pList2] = matlab.codetools.requiredFilesAndProducts(filename);
            for kk = 1:numel(pList2)
                if (strcmp(pList2(kk).Name, 'Mapping Toolbox'))
                    fprintf('\n[%d/%d]. REQUIRES MappingToolbox !!!!!!!! (''%s'')', k, numel(fList), filename);
                else
                    fprintf('\n[%d/%d]. Does not require MappingToolbox  (''%s'')', k, numel(fList), filename);
                end
            end
        end
    end
    end
    
    fprintf('\n Function ''%s'' has the following %d dependencies:\n', which(functionName), numel(pList));
    for k = 1:numel(pList)
        fprintf('\t[%d]: %s \n', k, char(pList(k).Name));
    end
    
end