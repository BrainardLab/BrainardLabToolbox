function paramsOK = qpQuestPlusColorMaterialCubicModelParamsCheck(psiParams,maxStimValue,maxPosition,minSpacing)
% qpQuestPlusColorMaterialCubicModelParamsCheck  Parameter check for cubic model
% Usage:
%     paramsOK = qpQuestPlusColorMaterialCubicModelParamsCheck(psiParams,maxStimValue,maxPosition,minSpacing)
%
% Description:
%     Check whether passed parameters are valid for color material cubic
%     model
%
% Inputs:
%     psiParams      See qpPFColorMaterialCubicModel.
%     maxStimValue   Maximum absolute nominal stimulus value
%     maxPosition    Maximum absolute perceptual stimulus value
%     minSpacing     Minimum spacing between perceptual positions
%
% Output:
%     paramsOK       Boolean, true if parameters are OK and false otherwise.

% 02/16/18 dhb, ar  Wrote it.

%% Extract model parameters
colorCoordinateSlope = psiParams(1);
colorCoordinateQuad = psiParams(2);
colorCoordinateCubic = psiParams(3);
materialCoordinateSlope = psiParams(4);
materialCoordinateQuad = psiParams(5);
materialCoordinateCubic = psiParams(6);
weight = psiParams(7);

%% Set up stim values, assuming integer nominal spacing
stimParams = -maxStimValue:maxStimValue;

%% Extract and get extrema of positive stim
colorCoords = colorCoordinateSlope*stimParams+colorCoordinateQuad*(stimParams.^2)+colorCoordinateCubic*(stimParams.^3);
materialCoords = materialCoordinateSlope*stimParams+materialCoordinateQuad*(stimParams.^2)+materialCoordinateCubic*(stimParams.^3);

%% This constraint forces the solution to be monotonic
cVec1 = diff(colorCoords);
cVec2 = diff(materialCoords);
c1 = -[cVec1 cVec2]' + minSpacing;

%% This constraint forces the values to be within range
c1Vec = abs(colorCoords) - maxPosition;
c2Vec = abs(materialCoords) - maxPosition;
c2 = [c1Vec(:) ; c2Vec(:)];

%% This is the whole constraint
c = [c1(:) ; c2(:)];

%% Evaluate constraint and set return
if (any(c > 0))
    paramsOK = false;
else
    paramsOK = true;
end

