function [f,predictedResponses] = FitColorMaterialModelMLDSFun(x,...
    pairColorMatchColorCoordPosition,pairMaterialMatchColorCoordPosition,...
    pairColorMatchMaterialCoordPosition,pairMaterialMatchMaterialCoordPosition,...
    theResponses,nTrials,params)
% [f,predictedResponses] = FitColorMaterialModelMLDSFun(x,...
%    pairColorMatchColorCoordPosition,pairMaterialMatchColorCoordPosition,...
%    pairColorMatchMaterialCoordPosition,pairMaterialMatchMaterialCoordPosition,...
%    theResponses,nTrials,params)

% The error function we are minimizing in the numerical search, when we are
% fitting a descriptive Weibull-based function to the data directly,
% without any particular underlying model.
%
% Computes the negative log likelyhood of the current solution i.e. the weights and the inferred
% position of the competitors on color and material axes.
%
% Input:
%   x           - returned parameters vector.
%   pairColorMatchColorCoordPosition - index denoting the position of the color match color coordinate for each trial.
%   pairMaterialMatchColorCoordPosition - index denoting the position of the material match color coordinate for each trial.
%   pairColorMatchMaterialCoordPosition - index denoting the position of the color match material coordinate for each trial.
%   pairMaterialMatchMaterialCoordPosition - index denoting the position of the material match material coordinate for each trial.
%   theResponses- set of responses for this pair (number of times first competitor is chosen).
%   nTrialsPerPair - total number of trials run.
%   targetIndex    - index of the target position in the color and material space.
%   pairSpecs - defines each pair - w
%
% Output:
%   f - negative log likelihood for the current solution.
global iterationX
% Sanity check - is the solution to any of our parameters NaN
iterationX = iterationX+1;
if (any(isnan(x)))
    error('Entry of x is NaN');
end

% We need to convert X to params here
[materialMatchColorCoords,colorMatchMaterialCoords,w,sigma] = ColorMaterialModelXToParams(x,params); 

% Remap pair indices into coordinates, based on the current solution
for i = 1:length(pairColorMatchColorCoordPosition)
    pairColorMatchColorCoords(i) = materialMatchColorCoords(params.materialMatchColorCoords==pairColorMatchColorCoordPosition(i));
    pairMaterialMatchColorCoords(i) = materialMatchColorCoords(params.materialMatchColorCoords==pairMaterialMatchColorCoordPosition(i));
    
    pairColorMatchMaterialCoords(i) = colorMatchMaterialCoords(params.colorMatchMaterialCoords==pairColorMatchMaterialCoordPosition(i));
    pairMaterialMatchMaterialCoords(i) = colorMatchMaterialCoords(params.colorMatchMaterialCoords==pairMaterialMatchMaterialCoordPosition(i));
end

% Compute negative log likelyhood of the current solution
switch params.whichMethod
    case 'lookup'
        [logLikely,predictedResponses] = ColorMaterialModelComputeLogLikelihood(...
            pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
            pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
            theResponses,nTrials,params.materialMatchColorCoords(params.targetIndex),params.colorMatchMaterialCoords(params.targetIndex),w,sigma, ...
            'Fobj', params.F, 'whichMethod', params.whichMethod);
    case 'simulate'
        [logLikely,predictedResponses] = ColorMaterialModelComputeLogLikelihood(...
            pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
            pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
            theResponses,nTrials,params.materialMatchColorCoords(params.targetIndex),params.colorMatchMaterialCoords(params.targetIndex),w,sigma, ...
            'whichMethod', params.whichMethod, 'nSimulate', params.nSimulate);
end
f = -logLikely;

if (f < 0)
    error('Cannot have logLikelihood > 0');
end
if rem(iterationX,1000) == 0
    disp([x; f])
end