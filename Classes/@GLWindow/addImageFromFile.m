function addImageFromFile(GLWObj, center, dimensions, imageFileName, varargin)
% addImageFromFile(center, dimensions, imageFileName, [imageOpts])
%
% Description:
% Adds an image to the GLWindow from an image file.
%
% Input:
% center (1x2 double) - (x,y) center of the image.
% dimensions (1x2 double) - Image width and height.
% imageFileName (string) - Image file name.

if nargin < 4
	error('Usage: addImage(center, dimensions, imageFileName, [imageOpts])');
end

parser = inputParser;

parser.addRequired('Center', @(x)isvector(x) && length(x) == 2);
parser.addRequired('Dimensions', @(x)isvector(x) && length(x) == 2);
parser.addRequired('ImageFileName');

parser.addParamValue('Rotation', 0, @isscalar);
parser.addParamValue('Enabled', true, @islogical);
parser.addParamValue('Name', 'imageObject', @ischar);
parser.addParamValue('Opacity', 1, @(x)isscalar(x) && x >= 0 && x <= 1);
parser.addParamValue('TextureParams', []);

% Execute the parser to make sure input is good.
parser.parse(center, dimensions, imageFileName, varargin{:});

obj = parser.Results;
obj.ObjectType = GLWindow.ObjectTypes.Image;
obj.RenderMethod = GLWindow.RenderMethods.Texture;

% % Check to see if the file exists.
% if ~exist(obj.ImageFileName, 'file')
% 	error('Image "%s" does not exist.', obj.ImageFileName);
% end

% Validate the image filename(s).
obj.ImageFileName = GLW_ValidateFileName(obj.ImageFileName, GLWObj.DisplayTypeID);

% Load the image file data.
for i = 1:length(obj.ImageFileName)
	obj.ImageData{i} = flipdim(double(imread(obj.ImageFileName{i})), 1) ./ 255;
end

GLWObj.addObjectToQueue(obj);
