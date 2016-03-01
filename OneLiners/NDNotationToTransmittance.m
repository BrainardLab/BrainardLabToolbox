function [transmittance opticalDensity] = NDNotationToTransmittance(ndNotation)
% [transmittance opticalDensity] = NDNotationToTransmittance(NDNotation)
%
% Takes an 'ND notation' string and returns the transmittance in percent. The
% ND notation is: NDxx, where xx correspond to the optical density (OD).
%
% For example, ND30 refers to a filter with an optical density of 3.0. The
% period is omitted so that files with an ND notation in them can be saved
% properly. We'll be assuming that the maximum number of decimals is 3, and
% that 0 is also given for optical densities <1.
%
% Transmittance is calculated as 10^-(OD).
%
% This function achieves nothing great apart from occasional convenience.
%
% 7/11/14       ms          Wrote it.

% Retrieve the reg exp match
theRegExp = regexp(ndNotation, 'ND[0-9][0-9]?[0-9]?[0-9]?', 'match');

% Check if we have something
if isempty(theRegExp)
    fprintf('*** No valid ND notation found in input\n');
    opticalDensity = 0;
else
    % Extract the value. xy is converted to x.y, xyz to xyz, etc.
    ODstring = regexp(theRegExp, '[0-9][0-9]?[0-9]?[0-9]?', 'match');
    ODstring = char(ODstring{1});
    opticalDensity = 0;
    for i = 1:length(ODstring)
        opticalDensity = opticalDensity + 10^-(i-1)*str2num(ODstring(i));
    end
end

% Convert to transmittance and return.
transmittance = 10^-opticalDensity;