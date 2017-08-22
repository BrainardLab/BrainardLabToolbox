function wipe(GLWObj, exclusions)
% wipe - Deletes all objects attached to the GLWindow.
%
% Syntax:
% obj.wipe
% obj.wipe(exclusions)
%
% Description:
% Removes any attached objects attached to the GLWindow and frees up any
% memory consumed by them.  Any exclusions won't be wiped.
%
% Input:
% exclusions (string|1xN cell) - List of object names that shouldn't be
%     wiped.

narginchk(1, 2);

if nargin == 1
	exclusions = [];
end

% Keep a list of objects that we don't want to delete.
keepMe = [];

for i = 1:length(GLWObj.Objects)
	if any(strcmp(GLWObj.Objects{i}.Name, exclusions))
		keepMe(end+1) = i; %#ok<AGROW>
	else
		% Delete any textures attached to the object.
		GLWObj.deleteTexture(i);
	end
end

% Clear the queue.
GLWObj.Objects = GLWObj.Objects(keepMe);
