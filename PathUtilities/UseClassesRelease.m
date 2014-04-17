function UseClassesRelease
% UseClassesRelease
%
% Description:
% Changes the Classes-Dev folder on your path to Classes, which is the
% release (stable) copy.

% Not anymore
fprintf('WARNING!!!\n')
fprintf('June 2, 2013\n');
fprintf('We don''t think any of our current programs should be using the release version\n');
fprintf('Please talk to David or Nicolas about updating your program\n');
fprintf('Sooner or later we will make this a fatal error rather than a warning\n');

% Look for the regular Classes folder on the path.
classesPath = GetToolboxDirectory('Classes-Dev', true);

% If Classes-Dev is on the path, get rid of it and its subfolders.
if ~isempty(classesPath)
	rmpath(RemoveSVNPaths(genpath(classesPath)));
end

% Now look to see if Classes is local or on ColorShare.
classesPath = '/Users/Shared/Matlab/Toolboxes/Classes';
if ~exist(classesPath, 'dir')
	classesPath = '/Volumes/ColorShare/ToolboxesUse/Classes';
	
	% If we don't see Classes on the network path, then we can't
	% automatically set things up.
	if ~exist(classesPath, 'dir')
		error('Classes not in its usual local or network location, you will have to set the path manually.');
	end
	
	disp('* Classes isn''t local, using the ColorShare copy.');
end

% Add Classes-Dev to the path minus the .svn folders.
addpath(RemoveSVNPaths(genpath(classesPath)), '-end');
