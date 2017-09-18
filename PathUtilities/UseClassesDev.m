function UseClassesDev
% UseClassesDev
%
% Description:
% Changes the Classes folder on your path to Classes-Dev, which is the
% developer copy.

% Look for the regular Classes folder on the path.
classesPath = GetToolboxDirectory('Classes', true);

% If Classes is on the path, get rid of it and its subfolders.
if ~isempty(classesPath)
	rmpath(RemoveSVNPaths(genpath(classesPath)));
end

% Now look to see if Classes-Dev is local or on ColorShare.
classesDevPath = '/Users/colorlab/Documents/MATLAB/toolboxes/BrainardLabToolbox/Classes/';
if ~exist(classesDevPath, 'dir')
	classesDevPath = '/Volumes/ColorShare/ToolboxesUse/Classes-Dev';
	
	% If we don't see Classes-Dev on the network path, then we can't
	% automatically set things up.
	if ~exist(classesDevPath, 'dir')
		error('Classes-Dev not in its usual local or network location, you will have to set the path manually.');
	end
	
	disp('* Classes-Dev isn''t local, using the ColorShare copy.');
end

% Add Classes-Dev to the path minus the .svn folders.
addpath(RemoveSVNPaths(genpath(classesDevPath)), '-end');
