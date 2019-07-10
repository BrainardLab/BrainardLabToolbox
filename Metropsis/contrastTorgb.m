function rgb = contrastTorgb(cal, contrast, varargin)
% Convert cone contrast values to rgb primaries 
%
% Syntax:
%  	 contrastTorgb(cal, contrast) 
%
% Description:
%    Using the calibration file for a particular monitor, converts cone 
%    contrast values to monitor primaries (rgb). Assumes that a calibration
%    file and cone fundamentals have already been loaded. 
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
%    'Background'       -1x3 row vector containing monitor primary values 
%                        r, g, and b for the background. Each value must be 
%                        a decimal between 0 and 1. Defaults to 
%                        [0.5 0.5 0.5]. 

% History:
%    07/01/19  dce       Wrote routine
%    07/10/19  dce       Minor edits 

% Examples:
%{
    contrastTorgb(cal, [0.1 0 0])
    contrastTorgb(cal, [0.1 0 0], 'Background', [0 0 0])
%}

%parse input
if nargin < 2
    error('Too few inputs'); 
end 
p = inputParser;
p.addParameter('Background', [0.5 0.5 0.5], @(x) isnumeric(x) && isvector(x));
p.parse(varargin{:});

%express background color in terms of cone fundamentals (lms)
lmsBackground = PrimaryToSensor(cal, p.Results.Background')';
lBg = lmsBackground(1);
mBg = lmsBackground(2);
sBg = lmsBackground(3); 

%calculate stimulus lms values from background and contrast
l = (contrast(1) * lBg) + lBg;
m = (contrast(2) * mBg) + mBg;
s = (contrast(3) * sBg) + sBg;

%convert stimulus lms values to rgb 
rgb = SensorToPrimary(cal, [l m s]')'; 

end 