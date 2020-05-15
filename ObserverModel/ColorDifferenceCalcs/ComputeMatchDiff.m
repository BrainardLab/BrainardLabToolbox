function [colorDiff,comparisonContrast] = ComputeMatchDiff(colorDiffParams,adaptationLMS,referenceLMS,comparisonLMS)
%
% Syntax:
%     [colorDiff,comparisonContrast] = ComputeMatchDiff(colorDiffParams,adaptationLMS,referenceLMS,comparisonLMS)
%
% Description:
%     Compute a single number color difference between two vectors
%     specified in cone coordinates. 
%
%     A vector length of the difference between reference and comparison
%     is taken in an opponent contrast representation. The opponent
%     representation is defined by LMSToOpponentContrast.
%
% Inputs:
%     colorDiffParams        - Structure understood LMSToOpponentContrast
%     M                      - Matrix that goes from LMS contrast to opponent contrast
%     adpatationLMS          - LMS coordinates of the adapting feield
%     referenceLMS           - LMS coordinates of the reference.
%     comparisonLMS          - LMS coordinates of the stimulus whose
%                              contrast is computed.
%
%
% Outputs:
%   colorDiff                - Single number color difference measure.
%   comparisonContrast       - Contrast representation of the comparison
%
% Optional key/value pairs:
%   None:
%
% See also: LMSToOpponentContrast, OpponentContrastToLMS
%

% History:
%   08/09/19  dhb   Wrote it.

% Examples:
%{
    colorDiffParams.type = 'opponentContrast';
    colorDiffParams.LMRatio = 2;
    colorDiffParams.lumWeight = 4;
    colorDiffParams.rgWeight = 2;
    colorDiffParams.byWeight = 0.5;
    colorDiffParams.M = GetOpponentContrastMatrix(colorDiffParams);
    referenceLMS = [1 1 1]';
    comparisonLMS = [2 0.5 1.5]';
    colorDiff = ComputeMatchDiff(colorDiffParams,referenceLMS,referenceLMS,comparisonLMS)
%}

% Get opponent representations
referenceContrast = LMSToOpponentContrast(colorDiffParams,adaptationLMS,referenceLMS);
comparisonContrast = LMSToOpponentContrast(colorDiffParams,adaptationLMS,comparisonLMS);

% Take appropriate weighted vector length
colorDiff = norm(comparisonContrast-referenceContrast);
         
end

