% SwitchPathConfig
%
% Set up various path configurations for testing.
%
% 4/12/15  dhb  Add UnitTestToolbox to #10, which is the main ISETBIO
%               testing configuration.function SwitchPathConfig

% Restore default path
PathConfig.restoreDefaultPath();

fprintf('\nSelect from the following configurations:');
fprintf('\n\t [0]. Standard Brainad lab config');
fprintf('\n\t [1]. Matlab-main only');
fprintf('\n\t [2]. No select native Matlab toolboxes');
fprintf('\n\t [3]. No native Matlab toolboxes whatsoever');
fprintf('\n\t [4]. No public BrainardLabToolbox');
fprintf('\n\t [5]. No private BrainardLabToolbox');
fprintf('\n\t [6]. No public or private BrainardLabToolbox');
fprintf('\n\t [7]. No Psychtoolbox');
fprintf('\n\t [8]. No public or private BrainardLabToolbox, no Psychtoolbox');
fprintf('\n\t [9]. No ISETBIO');
fprintf('\n\t[10]. ISETBIO, UnitTestToolbox, Matlab, Signal Processing, Image Processing');
fprintf('\n\t[11]. Matlab + Psychtoolbox only');
fprintf('\n\t[12]. All native toolboxes + Psychtoolbox only');
fprintf('\n\t[13]. All native toolboxes + Psychtoolbox + BrainardLabToolbox only');
fprintf('\n\t[14]. Image + Signal + Stats + Optimization + Psychtoolbox only');
fprintf('\n\t[15]. Image + Signal + Stats + Optimization + Psychtoolbox + BrainardLabToolbox only');

pathSelection = input('\nSelect a configuration [default = 0]: ');
if (isempty(pathSelection))
    pathSelection = 0;
end

switch (pathSelection)
    case 0
        % do nothing PathConfig.restoreDefaultPath();
        
    case 1
        PathConfig.removeNativeToolboxes({});
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes');
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/ToolboxesDistrib');
        
    case 2
        nativeToolboxesDirList = PathConfig.getSelectNativeToolboxesDirList();
        PathConfig.removeNativeToolboxes(nativeToolboxesDirList);
        
    case 3
        PathConfig.removeNativeToolboxes({});
        
    case 4
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox');
        
    case 5
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabPrivateToolbox');
        
    case 6
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox');
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabPrivateToolbox');
        
    case 7
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/Psychtoolbox-3');
        
    case 8
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox');
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabPrivateToolbox');
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/Psychtoolbox-3');
        
    case 9
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/isetbio');
        
    case 10
        % Will add the image and signal processing toolboxes
        listOfNativeToolboxesToAdd = { ...
            'Image Processing Toolbox' ...
            'Signal Processing Toolbox' ...
            };
        
        % Will add the isetbio toolbox
        listOfNonNativeToolboxesToAdd = { ...
            {isetbioRootPath(), '-end'} ...
            {'/Users/Shared/Matlab/Toolboxes/UnitTestToolbox', '-end'} ...
            {'/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/PathUtilities', '-begin'} ...
            };
        
        % Get list of currently installed toolboxes
        s = PathConfig.getListOfInstalledToolboxes;
        
        % Remove everything
        restoredefaultpath();
        
        % add the PathUtilities
        addpath('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/PathUtilities');
        
        PathConfig.removeNativeToolboxes({});
        
        % Add what we want.
        PathConfig.addNativeToolboxes(s, listOfNativeToolboxesToAdd);
        PathConfig.addNonNativeToolboxes(listOfNonNativeToolboxesToAdd);
        
    case 11
        
        % Will add the isetbio toolbox
        listOfNonNativeToolboxesToAdd = { ...
            {'/Users/Shared/Matlab/Toolboxes/Psychtoolbox-3', '-end'} ...
            };
        
        % Get list of currently installed toolboxes
        s = PathConfig.getListOfInstalledToolboxes;
        
        % Remove everything
        restoredefaultpath();
        
        % add the PathUtilities
        addpath('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/PathUtilities');
        
        PathConfig.removeNativeToolboxes({});
        
        % Add what we want.
        PathConfig.addNonNativeToolboxes(listOfNonNativeToolboxesToAdd);
        
        
    case 12
        % Native toolboxes + Psychtoolbox only
        % remove all the non-native toolboxes
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes');
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/ToolboxesDistrib');
        
        % Add only the non-native toolboxes that we want.
        listOfNonNativeToolboxesToAdd = { ...
            {'/Users/Shared/Matlab/Toolboxes/Psychtoolbox-3', '-end'} ...
            {'/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/PathUtilities', '-begin'} ...
            };
        PathConfig.addNonNativeToolboxes(listOfNonNativeToolboxesToAdd);
        
    case 13
        % Native toolboxes + Psychtoolbox + BrainardLabToolbox only
        % remove all the non-native toolboxes
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes');
        PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/ToolboxesDistrib');
        
        % Add only the non-native toolboxes that we want.
        listOfNonNativeToolboxesToAdd = { ...
            {'/Users/Shared/Matlab/Toolboxes/Psychtoolbox-3', '-end'} ...
            {'/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox', '-end'} ...
            };
        PathConfig.addNonNativeToolboxes(listOfNonNativeToolboxesToAdd);
        
    case 14
        % image and signal processing toolboxes ONLY + Psychtoolbox
        listOfNativeToolboxesToAdd = { ...
            'Image Processing Toolbox' ...
            'Signal Processing Toolbox' ...
            'Statistics Toolbox' ...
            'Optimization Toolbox' ...
            };
        
        % Will add the isetbio toolbox
        listOfNonNativeToolboxesToAdd = { ...
            {'/Users/Shared/Matlab/Toolboxes/Psychtoolbox-3', '-end'} ...
            {'/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/PathUtilities', '-begin'} ...
            };
        
        % Get list of currently installed toolboxes
        s = PathConfig.getListOfInstalledToolboxes;
        
        % Remove everything
        restoredefaultpath();
        
        % add the PathUtilities
        addpath('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/PathUtilities');
        
        PathConfig.removeNativeToolboxes({});
        
        % Add what we want.
        PathConfig.addNativeToolboxes(s, listOfNativeToolboxesToAdd);
        PathConfig.addNonNativeToolboxes(listOfNonNativeToolboxesToAdd);
        
    case 15
        % image and signal processing toolboxes ONLY + Psychtoolbox + BrainardLabToolbox
        listOfNativeToolboxesToAdd = { ...
            'Image Processing Toolbox' ...
            'Signal Processing Toolbox' ...
            'Statistics Toolbox' ...
            'Optimization Toolbox' ...
            };
        
        % Will add the isetbio toolbox
        listOfNonNativeToolboxesToAdd = { ...
            {'/Users/Shared/Matlab/Toolboxes/Psychtoolbox-3', '-end'} ...
            {'/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox', '-end'} ...
            };
        
        % Get list of currently installed toolboxes
        s = PathConfig.getListOfInstalledToolboxes;
        
        % Remove everything
        restoredefaultpath();
        
        % add the PathUtilities
        addpath('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/PathUtilities');
        
        PathConfig.removeNativeToolboxes({});
        
        % Add what we want.
        PathConfig.addNativeToolboxes(s, listOfNativeToolboxesToAdd);
        PathConfig.addNonNativeToolboxes(listOfNonNativeToolboxesToAdd);
        
        
    otherwise
        % do nothing PathConfig.restoreDefaultPath();
end

PathConfig.rehash();
PathConfig.getListOfInstalledToolboxes(1);



