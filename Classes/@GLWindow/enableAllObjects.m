function enableAllObjects(GLWObj, objectExclusions)
% enableAllObjects - Enables all GLWindow objects minus any exclusions.
%
% Syntax:
% obj.enableAllObjects
% obj.enableAllObjects(objectExclusions)
%
% Description
% Enables all objects in the scene.  A list of exclusions may be passed.
%
% Input:
% objectExclusions (string|1xN cell) - A string or cell array of strings
%     containing the objects to be disabled.

error(nargchk(1, 2, nargin));

if nargin == 1
	objectExclusions = [];
end

for i = 1:length(GLWObj.Objects)
	if any(strcmp(GLWObj.Objects{i}.Name, objectExclusions))
		GLWObj.Objects{i}.Enabled = false;
	else
		GLWObj.Objects{i}.Enabled = true;
	end
end
