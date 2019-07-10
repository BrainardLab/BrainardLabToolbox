function rgb = contrastTorgb(cal, contrast, varargin)
% Convert cone contrast values to rgb primaries or RGB settings 
%
% Syntax:
%  	 contrastTorgb(cal, contrast) 
%
% Description:
%    Using the calibration file for a particular monitor, converts cone 
%    contrast values to monitor primaries (rgb) or to monitor settings 
%    (RGB). Assumes that a calibration file and cone fundamentals have 
%    already been loaded. 
%
% Inputs: 
%    cal                -calibration struct for the monitor
%
%    contrast           -1x3 row vector containing cone contrast values for   
%                        the stimulus. Each value must be a decimal between 
%                        -1 and 1.
% 
% Outputs:
%    rgb                -1x3 row vector containing monitor primary values 
%                        r, g, and b for the stimulus. Each value must be a
%                        decimal between 0 and 1. 
%
% Optional key/value pairs:
%    'Background'       -1x3 row vector containing rgb/RGB values for 
%                        background. Each value must be a decimal between 0 
%                        and 1. Defaults to [0.5 0.5 0.5]. 
%
%    'RGB'              -logical value. If set to true, the program treats
%                        the background inputs as RGB values and returns
%                        RGB settings rather than rgb primaries. Default is
%                        false. 

% History:
%    07/01/19  dce       Wrote routine
%    07/10/19  dce       Minor edits 

% Examples:
%{
    contrastTorgb(cal, [0.1 0 0])
    contrastTorgb(cal, [0.1 0 0], 'Background', [0 0 0])
    contrastTorgb(cal, [0.1 0 0], 'RGB', true)
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

%calculate stimulus lms values from background and contrast
l = (contrast(1) * lBg) + lBg;
m = (contrast(2) * mBg) + mBg;
s = (contrast(3) * sBg) + sBg;

%convert stimulus lms values to rgb or RGB 
if p.Results.RGB
    rgb = SensorToSettings(cal, [l m s]')'; 
else 
    rgb = SensorToPrimary(cal, [l m s]')'; 
end 

end 