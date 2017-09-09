% BrainardLabToolboxLocalHookTemplate
%
% Template for setting preferences and other configuration things, for the
% BrainardLabToolbox.

% 6/14/17  dhb, ar  Wrote it.

%% Define project
projectName = 'BrainardLabToolbox';

%% Clear out old preferences
if (ispref(projectName))
    rmpref(projectName);
end

%% Clear out prefs named 'ColorMaterialModel', if they exist
% 
% We used to have these, but decided not to anymore
if (ispref('ColorMaterialModel'))
    rmpref('ColorMaterialModel');
end

%% Specify project location
toolboxBaseDir = tbLocateToolbox('BrainardLabToolbox');

% Figure out where baseDir for other kinds of data files is.
sysInfo = GetComputerInfo();
switch (sysInfo.localHostName)
    case 'eagleray'
        % DHB's desktop
        baseDir = fullfile(filesep,'Volumes','Users1','Dropbox (Aguirre-Brainard Lab)');
 
    otherwise
        % Some unspecified machine, try user specific customization
        switch(sysInfo.userShortName)
            % Could put user specific things in, but at the moment generic
            % is good enough.
            otherwise
                baseDir = ['/Users/' sysInfo.userShortName '/Dropbox (Aguirre-Brainard Lab)'];
        end
end

%% ColorMaterialModel preferences
%
% These preferences have to do with the ColorMaterialModel section of the
% BrainardLabToolbox
setpref(projectName,'cmmCodeDir',fullfile(toolboxBaseDir,'ColorMaterialModel'));
setpref(projectName,'cmmDemoDataDir', fullfile(toolboxBaseDir,'ColorMaterialModel','DemoData'));

%% RadiometerChecks preferences
%
% These preferences have to do with the RadiometerChecks section of the
% BrainardLabToolbox
setpref(projectName,'RadiometerChecksDir',fullfile(baseDir,'MELA_admin','RadiometerChecks'));





