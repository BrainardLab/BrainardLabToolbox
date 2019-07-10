function contrast = rgbToContrast(cal,rgb,varargin)
% Convert rgb primaries to cone contrast values
%
% Syntax:
%  	 rgbToContrast(cal, rgb)
%
% Description:
%    Using the calibration file for a particular monitor, converts monitor
%    primaries (rgb) to cone contrast values. Assumes that a calibration
%    file and cone fundamentals have already been loaded.
%
% Inputs:
%    cal                -calibration struct for the monitor
%
%    rgb                -1x3 row vector containing monitor primary values
%                        r, g, and b for the stimulus. Each value must be a
%                        decimal between 0 and 1.
%
% Outputs:
%   contrast            -1x3 row vector containing cone contrast values for
%                        the l, m, and s cones. Each contrast value must be
%                        a decimal between -1 and 1.
%
% Optional key/value pairs:
%    'Background'       -1x3 row vector containing monitor primary values
%                        r, g, and b for the background. Each value must be
%                        a decimal between 0 and 1. Defaults to
%                        [0.5 0.5 0.5].
%
%    'RGB'              -logical value. If set to true, the program treats
%                        background and stimulus inputs as RGB settings 
%                        rather than rgb primaries. Default is false.

% History:
%    07/01/19  dce       Wrote routine
%    07/09/19  dce       Minor edits

% Examples:
%{
    rgbToContrast(cal, [0.3, 0.4, 0.5])
    rgbToContrast(cal, [0.3, 0.4, 0.5], 'Background', [0 0 0])
    rgbToContrast(cal, [0.3, 0.4, 0.5], 'RGB', true)
%}

%parse input
if nargin < 2
    error('Too few inputs');
end
p = inputParser;
p.addParameter('Background', [0.5 0.5 0.5], @(x) isnumeric(x) && isvector(x));
p.addParameter('RGB', false, @(x) islogical(x));
p.parse(varargin{:});

%express background color in terms of cone fundamentals (lms)
if p.Results.RGB
    lmsBackground = SettingsToSensor(cal, p.Results.Background')';
else 
    lmsBackground = PrimaryToSensor(cal, p.Results.Background')';
end
lBg = lmsBackground(1);
mBg = lmsBackground(2);
sBg = lmsBackground(3);

%express stimulus color in terms of cone fundamentals (lms)
if p.Results.RGB
    lms = SettingsToSensor(cal, rgb')';
else
    lms = PrimaryToSensor(cal, rgb')';
end

%calculate contrast from stimulus and background lms values
lC = (lms(1) - lBg) / lBg;
mC = (lms(2) - mBg) / mBg;
sC = (lms(3) - sBg) / sBg;
contrast = [lC, mC, sC];

end