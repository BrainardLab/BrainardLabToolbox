function rgb = contrastTorgb(contrast, background, cal)
% Convert cone contrast values to rgb primaries 
%
% Syntax:
%  	 contrastTorgb(contrast, background) 
%
% Description:
%    Using the calibration file for a particular monitor, converts cone 
%    contrast values to monitor primaries (rgb). 
%
% Inputs: 
%    contrast           -1x3 vector containing cone contrast values for the  
%                        stimulus. Each value must be a decimal between 
%                        -1 and 1.
%    background         -1x3 vector containing monitor primary values r, g,
%                        and b for the background. Each value must be a 
%                        decimal between 0 and 1.
% 
% Outputs:
%    rgb                -1x3 vector containing monitor primary values r, g, 
%                        and b for the stimulus. Each value must be a
%                        decimal between 0 and 1. 
%
% Optional key/value pairs:
%    none

% History:
%    07/01/19  dce       Wrote routine

% Examples:
%{
    contrastTorgb([0.1 0 0], [0.5 0.5 0.5])
%}

%background lms values 
lmsBackground = PrimaryToSensor(cal, background')';
lBg = lmsBackground(1);
mBg = lmsBackground(2);
sBg = lmsBackground(3); 

%calculate stimulus lms values from background and contrast
l = (contrast(1) * lBg) + lBg;
m = (contrast(2) * mBg) + mBg;
s = (contrast(3) * sBg) + sBg;

rgb = SensorToPrimary(cal, [l m s]')'; %stimulus rgb values 

end 