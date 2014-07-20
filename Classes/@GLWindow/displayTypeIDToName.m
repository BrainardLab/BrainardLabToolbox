function displayTypeName = displayTypeIDToName(displayTypeID)
% displayTypeName = displayTypeIDToName(displayTypeID)
%
% Description:
% Converts a display type ID into the human readable name.
%
% Input:
% displayTypeID (integer) - One of the values from GLWindow.DisplayTypes.
%
% Ouput:
% displayTypeName (string) - The human readable name of the
%   "displayTypeID".

if nargin ~= 1
	error('Usage: displayTypeName = displayTypeIDToName(displayTypeID)');
end

fNames = fieldnames(GLWindow.DisplayTypes);
displayTypeName = [];
for i = 1:length(fNames)
	if GLWindow.DisplayTypes.(fNames{i}) == displayTypeID
		displayTypeName = fNames{i};
		break;
	end
end

if isempty(displayTypeName)
	error('Unable to find matching display name for display type %d.', displayTypeID)
end
