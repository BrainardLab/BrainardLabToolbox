function excitations = ContrastToExcitations(contrast,backgroundExcitations)
% Convert contrast (e.g., cone contrast) to excitations
%
% Syntax:
%     excitations = ContrastToExcitations(contrast,backgroundExcitations)
%
%     This will operate in any space, as long as the passed excitations and
%     background excitations are in the same units.
%
% Description:
%     Convert excitations (e.g., cone excitations) to contrast
%
% Inputs:
%     contrast               - Contrast representation of the excitations
%     backgroundExcitations  - Column vector of background excitations.
%
% Outputs:
%     excitations            - Column vector of excitations to be converted.
%
% Optional key/value pairs:
%   None:
%
% See also: ExcitationsToContrast
%

% History:
%   05/16/20  dhb   Wrote it.

% Examples:
%{
    clear;
    backgroundLMS = [1 1 1]';
    contrast = [1 -0.5 0.5]';
    comparisonLMS = ContrastToExcitations(contrast,backgroundLMS)
    contrastCheck = ExcitationsToContrast(comparisonLMS,backgroundLMS);
    if (any(contrast-contrastCheck) > 1e-8)
        error('Contrast conversion routines do not self invert');
    end
%}

% Go to contrast         
excitations = (contrast .* backgroundExcitations) + backgroundExcitations;
