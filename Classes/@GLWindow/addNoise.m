function glwObj = addNoise(glwObj, center, dimensions, density, varargin)
% glwObj = addNoise(glwObj, center, dimensions, density, varargin)
%
% Description:
% Adds a patch of noise to the GLWindow.
%
% Required Input:
% glwObj (GLWindow) - The GLWindow into which we are drawing.
% center (1x2 double) - Center of the noise patch (x, y).
% dimensions (1x2 double) - Width and Height of the noise patch.
% density (double scalar) - Density of noise.  Number of points per
%     GLWindow scene dimension unit squared.

global g_GLWNoiseData;

parser = inputParser;

parser.addRequired('center', @(x)isvector(x) && length(x) == 2);
parser.addRequired('dimensions', @(x)isvector(x) && length(x) == 2);
parser.addRequired('density', @isscalar);

parser.addParamValue('rotation', 0, @isscalar);
parser.addParamValue('enabled', true, @islogical);
parser.addParamValue('name', 'rectObject', @ischar);
parser.addParamValue('rendermethod', 'normal', @ischar);
parser.addParamValue('color', [1 1 1], @(x)isnumeric(x) && size(x,2) == 3 && ndims(x) == 2);

% Execute the parser to make sure input is good.
parser.parse(center, dimensions, density, varargin{:});

obj = parser.Results;
obj.objecttype = glwObj.private.consts.objectTypes.noise;

% We store the noise data as a global variable to avoid passing large
% amounts of data within the class.
if isempty(g_GLWNoiseData)
	nIndex = 1;
else
	nIndex = length(g_GLWNoiseData) + 1;
end
obj.noiseIndex = nIndex;

% Generate the x and y positions of the noise.
numPts = round(obj.density * prod(obj.dimensions));
obj.numVertices = numPts;
x = rand(1, numPts) * obj.dimensions(1) - obj.dimensions(1)/2 + obj.center(1);
y = rand(1, numPts) * obj.dimensions(2) - obj.dimensions(2)/2 + obj.center(2);
g_GLWNoiseData{nIndex} = [x;y];

% Add the noise to drawing queue.
objIndex = length(glwObj.private.objects) + 1;
glwObj.private.objects{objIndex} = obj;
