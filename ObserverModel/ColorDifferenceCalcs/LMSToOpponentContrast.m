function opponentContrast = LMSToOpponentContrast(colorDiffParams,referenceLMS,comparisonLMS)
%
% Syntax:
%     opponentContrast = LMSToOpponentContrast(colorDiffParams,,referenceLMS,comparisonLMS)
%
% Description:
%     Convert LMS representation to opponent contrast respresentation
%
%     When the type field is 'opponentColor', converts comparison to
%     contrast with respect to reference, then transforms to a lum, rg, by
%     opponent representation. The contrast differences in each direction
%     are scaled by the weights specified in the parameters structure.
%
% Inputs:
%     colorDiffParams        - Structure with color difference parameters.
%     referenceLMS           - LMS coordinates of the reference with
%                              respect to which contrast is computed.
%     comparisonLMS          - LMS coordinates of the stimulus whose
%                              contrast is computed.
%
% Outputs:
%   opponentContrast         - Contrast representation of the comparison
%
% Optional key/value pairs:
%   None:
%
% See also: GetOpponentContrastMatrix, OpponentContrastToLMS, ComputeMatchDiff
%

% History:
%   08/09/19  dhb   Wrote it.

% Examples:
%{
    colorDiffParams.type = 'opponentContrast';
    colorDiffParams.LMRatio = 2;
    colorDiffParams.lumWeight = 1;
    colorDiffParams.rgWeight = 3;
    colorDiffParams.byWeight = 1.5;
    colorDiffParams.M = GetOpponentContrastMatrix(colorDiffParams);
    referenceLMS = [1 1 1]';
    comparisonLMS = [2 0.5 1.5]';
    opponentContrast = LMSToOpponentContrast(colorDiffParams,referenceLMS,comparisonLMS)
    opponentContrast = LMSToOpponentContrast(colorDiffParams,referenceLMS,2*referenceLMS)
    if (any(abs(opponentContrast - [1 0 0]')) > 1e-6)
       error('Don''t get right answer in simple test case.');
    end
%}

% Go to cone contrast         
coneContrast = (comparisonLMS - referenceLMS) ./ referenceLMS;

% And then to opponent contrast
opponentContrast = colorDiffParams.M*coneContrast;

   
