function lmsContrast = rgbToContrast(rgb, background, cal)
% Convert rgb primaries to cone contrast values 
%
% Syntax:
%  	 rgbToContrast(rgb, background) 
%
% Description:
%    Using the calibration file for a particular monitor, converts monitor
%    primaries (rgb) to cone contrast values. 
%
% Inputs: 
%    rgb                -1x3 vector containing monitor primary values r, g,
%                        and b for the stimulus. Each value must be a 
%                        decimal between 0 and 1.
%    background         -1x3 vector containing monitor primary values r, g,
%                        and b for the background. Each value must be a 
%                        decimal between 0 and 1.
% 
% Outputs:
%    lmsContrast        -1x3 vector containing cone contrast values for the 
%                        l, m, and s cones. Each contrast value must be a
%                        decimal between -1 and 1. 
%
% Optional key/value pairs:
%    none

% History:
%    07/01/19  dce       Wrote routine

% Examples:
%{
    rgbToContrast([0.3, 0.4, 0.5], [0.5 0.5 0.5])
%}0

%background lms values 
lmsBackground = PrimaryToSensor(cal, background')';
lBg = lmsBackground(1);
mBg = lmsBackground(2);
sBg = lmsBackground(3); 

%calculate contrast from stimulus and background lms values 
lC = (lms(1) - lBg) / lBg;
mC = (lms(2) - mBg) / mBg;
sC = (lms(3) - sBg) / sBg;
lmsContrast = [lC, mC, sC]; 

end