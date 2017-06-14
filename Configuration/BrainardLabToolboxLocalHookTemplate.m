% BrainardLabToolboxLocalHookTemplate
%
% Template for setting preferences and other configuration things, for the
% BrainardLabToolbox.

% 6/14/17  dhb, ar  Wrote it.

%% ColorMaterialModel preferences

% We have some demo data, typically in the repository, so that our demos will run.  Where is it?
setpref('ColorMaterialModel','demoDataDir','/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/');

% If we ever needed some user/machine specific preferences, this is one way
% we could do that.
% sysInfo = GetComputerInfo();
% switch (sysInfo.localHostName)
%     case 'eagleray'
%         % DHB's desktop
%         baseDir = fullfile(filesep,'Volumes','Users1','Dropbox (Aguirre-Brainard Lab)');
%  
%     otherwise
%         % Some unspecified machine, try user specific customization
%         switch(sysInfo.userShortName)
%             % Could put user specific things in, but at the moment generic
%             % is good enough.
%             otherwise
%                 baseDir = ['/Users/' sysInfo.userShortName 'Dropbox (Aguirre-Brainard Lab)'];
%         end
% end


