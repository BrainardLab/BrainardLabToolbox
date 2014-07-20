function glwObj = addGrating(glwObj, center, dimensions, spatialFrequency, varargin)
% glwObj = addGrating(glwObj, center, dimensions, spatialFrequency, [gratingOpts])
%
% Description:
% Adds a grating to the GLWindow scene.
%
% Input:

if nargin < 4
	error('Usage:  glwObj = addGrating(glwObj, center, dimensions, spatialFrequency, [gratingOpts])');
end

parser = inputParser;

parser.addRequired('center', @(x)isvector(x) && length(x) == 2);
parser.addRequired('dimensions', @(x)isvector(x) && length(x) == 2);
parser.addRequired('spatialFrequency', @isscalar);

parser.addParamValue('rotation', 0, @isscalar);
parser.addParamValue('enabled', true, @islogical);
parser.addParamValue('name', 'gratingObject', @ischar);
parser.addParamValue('opacity', 1, @(x)isscalar(x) && x >= 0 && x <= 1);

% Execute the parser to make sure input is good.
parser.parse(center, dimensions, spatialFrequency, varargin{:});

obj = parser.Results;
obj.rendermethod = glwObj.private.consts.renderMethods.texture;
obj.objecttype = glwObj.private.consts.objectTypes.grating;

% Generate the data for the grating.
obj.gratingData = {GenGrating([1024 1024], obj.spatialFrequency)};

switch glwObj.displaytype
	% HDR
	case glwObj.private.consts.displayTypes.hdr
		obj.gratingData = processHDRColor(obj.gratingData{1});
		for i = 1:2
			obj.gratingData{i} = obj.gratingData{i} * 255;
		end
		
		% Stereo/Stereo Bits++
	case {glwObj.private.consts.displayTypes.stereo, ...
			glwObj.private.consts.displayTypes.stereobitspp}
		error('Stereo mode not supported for addGrating.');
		
	case glwObj.private.consts.displayTypes.normal
		obj.gratingData{1} = obj.gratingData{1} * 255;
end

% Look to see if this object already exists in the object queue.  If so,
% we'll replace the old object.  If not, we add the new one to the end of the queue.
queueIndex = GLW_FindObjectIndex(glwObj.private.objects, obj.name);

% Create the texture now if the window is open.  Otherwise, it will be done
% when the window is first opened.
if glwObj.private.isOpen
	% Delete previously generated textures attached to the original object.
	if queueIndex ~= -1
		GLW_DeleteTextures(glwObj.private.objects{queueIndex}, glwObj.windowid, glwObj.diagnosticmode);
	end

	obj = makeGLWTexture(obj, glwObj.private.consts.objectTypes, glwObj.windowid);
end

% queueIndex == -1 if the object was not found in the queue.
if queueIndex == -1
	queueIndex = length(glwObj.private.objects) + 1;

	if glwObj.diagnosticmode
		fprintf('* New object "%s" in slot %d\n', obj.name, queueIndex);
	end
else
	if glwObj.diagnosticmode
		fprintf('* Replacing object "%s" in slot %d\n', obj.name, queueIndex);
	end
end

% Add the image to drawing queue.
glwObj.private.objects{queueIndex} = obj;
