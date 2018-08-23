function deg = rotm2deg(R)
% Extract rotation in degrees from 2D rotation matrix
%
% Syntax:
%   deg = rotm2deg(R)
%
% Description:
%   Takes in a 2x2 rotation matrix and returns an angle in degrees.
%
% Inputs:
%  R               - A 2x2 rotation matrix
%
% Outputs:
%  deg             - The desired angle of rotation (in degrees) 
%
% Optional key/value pairs:
%   none
%
% Examples are provided in the source code.
%
% See also:
%

% History
%  8/23/18  mab  Created.

% Examples:
%{
    deg = 45;
    R = deg2rotm(deg);
    deg1 = rotm2deg(R);
    if (abs(deg-deg1) > 1e-6)
        error('Failure to self-invert');
    end
%}

deg = acosd(R(1,1));

end