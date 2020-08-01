function contrast = ExcitationsToContrast(excitations,backgroundExcitations)
% Convert excitations (e.g., cone excitations) to contrast
%
% Syntax:
%     contrast = ExcitationsToContrast(excitations,backgroundExcitations)
%
%     This will operate in any space, as long as the passed excitations and
%     background excitations are in the same units.
%
% Description:
%     Convert excitations (e.g., cone excitations) to contrast
%
% Inputs:
%     excitations            - Matrix excitations with LMS values in each column.
%     backgroundExcitations  - Column vector of background excitations.
%
% Outputs:
%     contrast               - Contrast representation of the excitations
%
% Optional key/value pairs:
%   None:
%
% See also: ContrastToExcitations
%

% History:
%   05/16/20  dhb   Wrote it.

% Examples:
%{
    clear;
    backgroundLMS = [1 1 1]';
    comparisonLMS = [2 0.5 1.5 ; 1.5 2 0.5]';
    contrast = ExcitationsToContrast(comparisonLMS,backgroundLMS)
%}

% Go to contrast         
contrast = (excitations - backgroundExcitations) ./ backgroundExcitations;
