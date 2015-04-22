function setHyperspectralNaturalImageImportToolboxPreferences

    % Specify project-specific preferences
    p = struct( ...
        'projectName', 'HyperSpectralNaturalImageImportToolbox', ...
        'originalDataBaseDir',  '/Volumes/SDXC_64GB/Matlab/Analysis/HyperSpectralImages/ManchesterData/manchester_database',...
        'isetbioSceneDataBaseDir', 'Users1/Shared/Matlab/Analysis/HyperSpectalNaturalImageBasedIsetbioScenes' ...
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
