function displayInfo = getDisplayInfo(glwObj)
% displayInfo = getDisplayInfo(glwObj)
%
% Description:
% Retrieves display information.
%
% Input:
% glwObj (GLWindow) - The GLWindow object whose display you're interested
%	in.
%
% Output:
% displayInfo (struct) - Struct(s) containing display information.

if glwObj.windowid == -1
	index = length(glwObj.private.displayInfo);
else
	index = glwObj.windowid;
end

displayInfo = glwObj.private.displayInfo(index);
