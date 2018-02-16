function paramsOK = qpPFColorMaterialModelParamsCheck(psiParams,maxStimValue,maxPosition,minSpacing)
% qpPFCircularParamsCheck  Parameter check for qpPFCicula
%
% Usage:
%     paramsOK = qpPFCircularParamCheck(psiParams,maxStimValue,maxPosition,minSpacing)
%
% Description:
%     Check whether passed parameters are valid for qpPFCircular
%
% Inputs:
%     psiParams      See qpPFCircular.
%
% Output:
%     paramsOK       Boolean, true if parameters are OK and false otherwise.

% 02/16/18 dhb, ar  Under development.

%% Assume ok
paramsOK = true;

%% Check that concentration is non-negative
if (psiParams(1) < 0)
    paramsOK = false;
end

%% Check whether boundary parameters are OK
%
% This is signaled by returning NaN when the boundaries are
% not in increasing order.
[boundaries,sortIndex] = sort(psiParams(2:end),'ascend');
nOutcomes = length(boundaries);
if (any(sortIndex ~= 1:nOutcomes))
    paramsOK = false;
end

