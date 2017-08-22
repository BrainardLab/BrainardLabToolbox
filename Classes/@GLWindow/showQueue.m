function objectList = showQueue(GLWObj, quiet)
% showQueue
%
% Syntax:
% objectList = showQueue
% objectList = showQueue(quiet)
%
% Description:
% Prints a list of all objects in the queue to the console.
%
% Input:
% quiet (logical) - Supresses command window output if true.  Default:
%     false
%
% Output:
% objectList (1xN cell) - Cell array of the object names in the queue.

% Validate the number of inputs.
narginchk(1, 2);

if nargin == 1
	quiet = false;
end

numObjects = length(GLWObj.Objects);

objectList = {};

if numObjects > 0
	for i = 1:numObjects
		if ~quiet
			fprintf('- Object %d: %s\n', i, GLWObj.Objects{i}.Name);
		end
		
		objectList{i} = GLWObj.Objects{i}.Name; %#ok<AGROW>
	end
else
	disp('* No objects in the queue');
end
