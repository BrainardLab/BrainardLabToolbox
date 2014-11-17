function objectIndex = getObjectIndex(glwObj, objectName)
% objectIndex = getObjectIndex(glwObj, objectName)
%
% Description:
% Gets the object index from the rendering pipeline.
%
% Input:
% glwObj (GLWindow) - GLWindow object.
% objectName (string) - Name of the object.
%
% Output:
% objectIndex (integer) - Index of the object in the pipeline.  Returns -1
% if the object wasn't found.

if nargin ~= 2
	error('Usage: objectIndex = getObjectIndex(glwObj, objectName)');
end

objectIndex = -1;
for i = 1:length(glwObj.private.objects)
	o = glwObj.private.objects{i};
	
	if strmatch(objectName, o.name, 'exact')
		objectIndex = i;
		break;
	end
end
