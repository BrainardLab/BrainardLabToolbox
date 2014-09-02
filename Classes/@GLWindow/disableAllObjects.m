function disableAllObjects(GLWObj, objectExclusions)
% disableAllObjects - Disables all objects and enables any exclusions.
%
% Syntax:
% obj.disableAllObjects
% obj.disableAllObjects(objectExlusions)
%
% Description:
% Disables all objects in the scene and enables any specified exclusions.
%
% Input:
% objectExclusions (string|1xN cell) - List of object names
%	that should be excluded from this command and instead be set to
%	enabled.

error(nargchk(1, 2, nargin));

if nargin == 1
	objectExclusions = '';
end

for i = 1:length(GLWObj.Objects)
	if any(strcmp(GLWObj.Objects{i}.Name, objectExclusions))
		GLWObj.Objects{i}.Enabled = true;
	else
		GLWObj.Objects{i}.Enabled = false;
	end
end
