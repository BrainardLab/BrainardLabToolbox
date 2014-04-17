function [T_xyzKleinK10A, T_xyzKleinK10A_norm, T_xyzKleinCIE, T_xyzKleinCIE_norm]  = GetKleinK10AColorimeterXYZ(S)
% [T_xyzKleinK10A, T_xyzKleinCIE],  = GetKleinK10AColorimeter(S)
%
% Returns Klein K10A Colorimeter XYZ functions at specific wavelength
% spacing, including their tabulated CIE functions.
%
% If empty variables are passed for any of the following variables,
% defaults will be assumed.
%
% Input:
%   S (1x3)                         - Wavelength spacing.
%                                     Default: [380 2 201]
%
% Output:
%   T_xyzKleinK10A                  - Klein K10A sensor XYZ. 
%   T_xyzKleinK10A_norm             - Klein K10A sensor XYZ (normalized). 
%   T_xyzKleinCIE                   - Reported CIE XYZ functions.
%   T_xyzKleinCIE_norm              - Reported CIE XYZ functions (normalized). 
%
% 1/23/14   ms    Wrote it based on old code.

% Check if all variables have been passed with a value

if isempty(S)
    S = [380 2 201];
end

load T_xyzKleinK10A
T_xyzKleinK10A = SplineCmf(S_xyzKleinK10A, T_xyzKleinK10A, S);

load T_xyzKleinCIE
T_xyzKleinCIE = SplineCmf(S_xyzKleinCIE, T_xyzKleinCIE, S);

% Normalize
for i = 1:size(T_xyzKleinK10A)
    T_xyzKleinK10A_norm(i, :) = T_xyzKleinK10A(i, :)/max(T_xyzKleinK10A(i, :));
end

for i = 1:size(T_xyzKleinCIE)
    T_xyzKleinCIE_norm(i, :) = T_xyzKleinCIE(i, :)/max(T_xyzKleinCIE(i, :));
end