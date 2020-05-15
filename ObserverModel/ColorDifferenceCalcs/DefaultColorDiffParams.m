function colorDiffParams = DefaultColorDiffParams(type)
% Generate default color difference params structure
%
% Syntax:
%    colorDiffParams = DefaultConeParams(type)
%
% Description:
%    Generate a structure describing and observer's cone fundamentals, with
%    reasonable defaults.
%
%    The input string type allows some flexibility about the description.
%
% Inputs:
%     type                          - String specifying cone parameterization type.
%                                     'opponentContrast': An opponent
%                                      contrast color difference model
% Outputs:
%     colorDiffParams               - Structure with field for each parameter.
%
% Optional key/value pairs:
%     None.
%
% See also: ObserverVecToParams, ObserverParamsToVec
%

% History:
%   08/10/19  dhb  Wrote it.

% Examples:
%{
    colorDiffParams = DefaultColorDiffParams('opponentContrast');
    colorDiffParams
%}

switch (type)
    case 'opponentContrast'
        
        colorDiffParams.type = 'opponentContrast';
        colorDiffParams.LMRatio = 2;
        colorDiffParams.lumWeight = 4;
        colorDiffParams.rgWeight = 2;
        colorDiffParams.byWeight = 0.5;
        colorDiffParams.noiseSd = 0.02;
        colorDiffParams.M = GetOpponentContrastMatrix(colorDiffParams);
     
    otherwise
        error('Unknown colordiff parameters type passed.');
end

