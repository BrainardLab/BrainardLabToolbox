function setHyperspectralNaturalImageImportToolboxPreferences

    %originalDataBaseDir = '/Volumes/SDXC_64GB/Matlab/Analysis/HyperSpectralImages/ManchesterData/manchester_database';
    originalDataBaseDir = '/Volumes/ColorShare1/hyperspectral-images/manchester_database';
    isetbioDataBaseDir  = '/Users1/Shared/Matlab/Analysis/hyperspectral-images/manchester_database';
    
    % Specify project-specific preferences
    p = struct( ...
        'projectName', 'HyperSpectralNaturalImageImportToolbox', ...
        'originalDataBaseDir',  originalDataBaseDir,...
        'isetbioSceneDataBaseDir', isetbioDataBaseDir ...
        );
    
    generatePreferenceGroup(p);
end

function generatePreferenceGroup(p)
    % remove any existing preferences for this project
    if ispref(p.projectName)
        rmpref(p.projectName);
    end
    
    % generate and save the project-specific preferences
    preferences = setdiff(fieldnames(p), 'projectName')
    for k = 1:numel(preferences)
        setpref(p.projectName, preferences{k}, p.(preferences{k}));
    end
    fprintf('Generated and saved preferences specific to the ''%s'' project.\n', p.projectName);
end
