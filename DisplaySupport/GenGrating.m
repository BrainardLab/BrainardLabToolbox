function grating = GenGrating(dims, spatialFreq, ampRange, phaseOffset, gratingType)
% grating = GenGrating(dims, spatialFreq, [ampRange], [phaseOffset], [gratingType])
%
% Description:
% Generates a sinusoidal grating.

if nargin < 2 || nargin > 5
	error('Usage: GenGrating(dims, spatialFreq, [ampRange], [phaseOffset], [gratingType])');
end

if ~exist('ampRange', 'var') || isempty(ampRange)
	ampRange = [0 1];
end
if ~exist('gratingType', 'var') || isempty(gratingType)
	gratingType = 'rgb';
end
if ~exist('phaseOffset', 'var') || isempty(phaseOffset)
	phaseOffset = 0;
end

g = sin(linspace(0, 2*pi*spatialFreq, dims(2)+1) + pi/2 + phaseOffset);
g = g(1:dims(2));

% Normalize the grating to the [0,1] range.
g = (g + 1) / 2;

% Now normalize to the user specified range.
maxAmp = ampRange(2) - ampRange(1);
g = g * maxAmp + ampRange(1);

switch gratingType
	case 'rgb'
		grating = zeros([dims 3]);
		for i = 1:3
			grating(:,:,i) = repmat(g, dims(1), 1);
		end
		
	case 'sqrtrgb'
		grating = zeros([dims 3]);
		g = sqrt(g);
		for i = 1:3
			grating(:,:,i) = repmat(g, dims(1), 1);
		end
		
	otherwise
		error('Unknown gratingType: %s', gratingType);
end