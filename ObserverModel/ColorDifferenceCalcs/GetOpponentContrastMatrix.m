function M_LMSContrastToOpponentContrast = GetOpponentContrastMatrix(colorDiffParams)
% Get matrix that goes from LMS contrast to opponent contrast
%
% Syntax:
%    M_LMSContrastToOpponentContrast = GetOpponentContrastMatrix(colorDiffParams)
%
% Inputs:
%     colorDiffParams       - Structure of parameters describing color
%                             difference model, with fields:
%                               type: String with model type.  Only current
%                                 option is 'opponentContrast', but you never
%                                 know what the future will bring.
%                               LMRatio: LM cone ratio, determines opponent
%                                 luminance sensitivity.
%                               lumWeight: Weight on luminance mechanism.
%                               rgWeight: Weight on rg mechanism.
%                               byWeight: Weight on by mechanism.
%
% Outputs:
%    M_LMSContrastToOpponentContrast - Matrix that goes from cone contrast
%                                      to opponent contrast.
%
% Optional key/value pairs
%
% See also DefaultColorDiffParams, LMSToOpponentContrast, OpponentContrastToLMS

% History
%   08/15/19  dhb  Wrote it.

% Build up matrix
M_LMSContrastToOpponentContrast = diag([colorDiffParams.lumWeight colorDiffParams.rgWeight colorDiffParams.byWeight])*[ [colorDiffParams.LMRatio 1 0]/(colorDiffParams.LMRatio+1) ; ...
      [1 -1 0] ; ...
      [-0.5 -0.5 1] ];

end