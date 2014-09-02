function addImage(GLWObj, center, dimensions, imageData, varargin)
% addImage(center, dimensions, imageData, [imageOpts])
%
% Description:
% Adds an image to the GLWindow from raw image data.
%
% Input:
% center (1x2) - (x,y) center of the image.
% dimensions (1x2) - Image width and height.
% imageData (MxNx3) - Raw image data in the range [0,1].

if nargin < 4
	error('Usage: addImage(center, dimensions, imageData, [imageOpts])');
end

parser = inputParser;

parser.addRequired('Center', @(x)(isvector(x) && length(x) == 2) || (isnumeric(x) && numel(x) == 4));
parser.addRequired('Dimensions', @(x)isvector(x) && length(x) == 2);
parser.addRequired('ImageData');

parser.addParamValue('Rotation', 0, @isscalar);
parser.addParamValue('Enabled', true, @islogical);
parser.addParamValue('Name', 'imageObject', @ischar);
parser.addParamValue('Opacity', 1, @(x)isscalar(x) && x >= 0 && x <= 1);
parser.addParamValue('TextureParams', []);

% Execute the parser to make sure input is good.
parser.parse(center, dimensions, imageData, varargin{:});

obj = parser.Results;
obj.ObjectType = GLWindow.ObjectTypes.Image;
obj.RenderMethod = GLWindow.RenderMethods.Texture;

% Make sure that the image data input is legit.
obj.ImageData = GLW_ValidateImageData(imageData, GLWObj.DisplayTypeID);

GLWObj.addObjectToQueue(obj);
