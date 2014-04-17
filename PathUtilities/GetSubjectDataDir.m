function [subject,subjectDataDir,saveFileName] = GetSubjectDataDir(protocolDataDir,protocolList,protocolIndex)
% [subject,subjectDataDir,saveFileName] = GetSubjectDataDir(protocolDataDir,protocolList,protocolIndex)
%
% Interact with user to get the subject info and set up where the data
% goes.
%
% 8/19/12  dhb  Pull out as a separate function
% 7/2/13   dhb  Don't list subdir with name 'xBadData'

% In the data directory, we can see the list of subjects available if the
% protocol has been run before.  If it hasn't been run, then we will create
% the top level data directory, then ask the user to create a subject.
availableSubjects = {};
if exist(protocolDataDir, 'dir')
	% Get a list of available subjects.
	dirList = dir(protocolDataDir);
	
	% Skip the first two results because they are '.' and '..'.
	for i = 3:length(dirList)
		% Filter out non directory files.  We assume all directories are
		% subject directories.
		if dirList(i).isdir
			if (~strcmp(dirList(i).name, '.svn') & ~strcmp(dirList(i).name,'xBadData'))
				availableSubjects{end+1} = dirList(i).name; %#ok<AGROW>
			end
		end
	end
else
	mkdir(protocolDataDir);
end

% Display the list of available subjects and also give an option to create
% one.
while true
	fprintf('- Subject Selection\n\n');
	
	fprintf('0 - Create a new subject\n');
	
	for i = 1:length(availableSubjects)
		fprintf('%d - %s\n', i, availableSubjects{i});
	end
	fprintf('\n');
	
	subjectIndex = GetInput('Choose a subject number', 'number', 1);
	
	if subjectIndex == 0
		% Create a new subject.
		newSubject = GetInput('Enter a new subject name', 'string');
		mkdir(sprintf('%s/%s', protocolDataDir, newSubject));
		availableSubjects{end+1} = newSubject; %#ok<AGROW>
	elseif any(subjectIndex == 1:length(availableSubjects))
		% We got our subject, now setup the proper variables and get out of
		% this loop.
		subject = availableSubjects{subjectIndex};
		subjectDataDir = sprintf('%s/%s', protocolDataDir, ...
			subject);
		break;
	else
		disp('*** Invalid subject selected, try again.');
	end
end

% Find the largest iteration number in the data filenames.
iter = 0;
d = dir(subjectDataDir);
for i = 3:length(d)
	s = textscan(d(i).name, '%s%s%s', 'Delimiter', '-');
	if ~isempty(s{3})
		% Get rid of the .mat part.
		n = strtok(s{3}, '.');
		
		val = str2double(n);
		if ~isnan(val) && val > iter
			iter = val;
		end
	end
end
iter = iter + 1;

saveFileName = sprintf('%s/%s-%s-%d.mat', subjectDataDir, ...
	subject, protocolList(protocolIndex).dataDirectory, iter);