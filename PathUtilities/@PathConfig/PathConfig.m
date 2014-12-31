% Class with static methods for various path manipulations
%
% 3/13/2014  npc Wrote it.
%

classdef PathConfig
    
    methods (Static = true)
        % Method for determining all toolboxes that a function 
        % with name 'functionName' may depend on
        findToolboxDependencies(functionName);
        
        % Method to remove all native Matlab toolboxes from the current path
        removeNativeToolboxes(toolboxPathsList);
        
        % Method to add select native toolboxes
        addNativeToolboxes(s, listOfToolboxesToAdd);
        
        % Method to add select non-native toolboxes
        addNonNativeToolboxes(listOfToolboxesToAdd);
        
        % Method to remove all non-native Matlab toolboxes from the current path
        removeNonNativeToolboxes(toolboxPath);
    
        % Method that returns a cell array with the directories corresponding to the installed native Matlab toolboxes
        s = getListOfInstalledToolboxes(beVerbose);
        
        % Method that returns a cell array with the directories of a user-selected list of native toolboxes
        nativeToolboxesDirList = getSelectNativeToolboxesDirList()
        
        % Method to restore the default path
        restoreDefaultPath();
        
        % Method to display the path as a cell array
        displayCurrentPath(varargin);
        
        % Method to refresh caches etc.
        rehash();
        
    end
end
