function EyeData2ConditionFile(baseConditionFile, eyeDataFile, outputConditionFile)
% function EyeData2ConditionFile(baseConditionFile, eyeDataFile, outputConditionFile)
%	Converts eye data into a condition file based on a base condition
%	file.

if nargin ~= 3
	error('Usage: EyeData2ConditionFile(baseConditionFile, eyeDataFile, outputConditionFile)');
end

% Make sure the base condition file and the eye data file exist.
if ~exist(baseConditionFile, 'file')
	error('The base condition file does not exist');
end
if ~exist(eyeDataFile, 'file')
	error('The eye data file does not exist.');
end

% Read the base condition file in.
baseData = ReadStructsFromText(baseConditionFile);

% Load the eye data.
load(eyeDataFile);

% For every radius value, add a row to the condition file.
for i = 1:size(eye_coord.disk_radius, 2)
	% Get the defaults.
	newData(i) = baseData(1);
	
	% Override the location and size info.
	newData(i).location = sprintf('[%f,%f]', eye_coord.disk_radius(1, i), ...
		eye_coord.disk_radius(2, i));
	%newData(i).size = eye_coord.disk_size / 2;
	newData(i).size = 0.25;
end

% Now stick in all the arc values.
offset = length(newData);
for i = 1:size(eye_coord.disk_arc, 2)
	% Get the defaults.
	newData(i + offset) = baseData(1);
	
	% Override the location and size info.
	newData(i + offset).location = sprintf('[%f,%f]', eye_coord.disk_arc(1, i), ...
		eye_coord.disk_arc(2, i));
	%newData(i + offset).size = eye_coord.disk_size / 2;
	newData(i + offset).size = 0.25;
end

% Write out our new structure.
WriteStructsToText(outputConditionFile, newData);
