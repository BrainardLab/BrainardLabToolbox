% Class with static methods for various path manipulations
%
% 3/13/2014  npc Wrote it.
%

classdef PathConfigurator
    
    methods (Static = true)
        % Method for determining all toolboxes that a function 
        % with name 'functionName' may depend on
        findToolboxDependencies(functionName);
        
        % Method to remove all native Matlab toolboxes from the current path
        removeNativeToolboxes();
        
        % Method to remove all non-native Matlab toolboxes from the current path
        removeNonNativeToolboxes(toolboxPath);
    
        % Method that returns a cell array with the directories corresponding to the installed native Matlab toolboxes
        toolboxDirs = getListOfInstalledToolboxes();
        
        % Method to restore the default path
        restoreDefaultPath();
        
        % Method to display the path as a cell array
        displayCurrentPath(varargin);
        
        % Method to refresh caches etc.
        rehash();
        
    end
end
