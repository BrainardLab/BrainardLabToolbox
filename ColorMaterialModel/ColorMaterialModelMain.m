
function [x, logLikelyFit, predictedResponses] = ColorMaterialModelMain(thePairs,theResponses,nTrialsPerPair)
% function [targetCompetitorFit, logLikelyFit, predictedResponses] = ColorMaterialModelMain(thePairs,theResponses,nTrialsPerPair)

% NEED TO ADD DEFINITIONS OF IN AND OUT PARAMS.

%% Run some sanity checks.
% These are the same checks we were implemented for the MLDSColorSelection model.
% And it seems reasonable to do them here as well. Check this and throw error message if it does not hold.
if (length(theResponses(:)) ~= length(nTrialsPerPair(:)))
    error('Passed theResponses and nTrialsPerPair must be of same length');
end
% The number of responses in theResponses cannot ever exceed nTrialsPerPair.
if (any(theResponses > nTrialsPerPair))
    error('An entry of input theResponses exceeds passed nTrialsPerPair.  No good!');
end

%% Set fixed parameters
%
% Standard deviation for the solution.This determines the scale of the solution.
sigma = 1;

% Determine minimum size of interval between the color and material position elements relative to sigma.
% That is, the minimum spacing will be sigma/sigmaFactor.
sigmaFactor = 4;

%% Enforce the spacing between competitors. This needs to be done in color and material space, separately. 
% We need to append two columns for parameter weight and sigma, that are not going
% to be modified in this way. 
numberOfCompetitors = max(thePairs(:)); 
AColor = zeros(numberOfCompetitors-1,numberOfCompetitors);
for i = 1:numberOfCompetitors-1
    AColor(i,i) = 1;
    AColor(i,i+1) = -1;
end
AMaterial = AColor; 
A = [AColor,  AMaterial, zeros(size(AColor(:,1))),  zeros(size(AColor(:,1)))]; 
% This is the minimum interval size for use with the A matrix above.
b = -sigma/sigmaFactor*ones(numberOfCompetitors-1,1);

% We have determined that target is going to be at 0.
targetPosition = 0;
targetIndex = 4; % this is going to be target index in the competitor space.
targetIndexColor = 4; % in the vector of parameters, this is the position for target on color dimension.
targetIndexMaterial = 11; % in the vector of parameters, this is the positino for target on material dimension.
competitorsRangePositive = [1 3];
competitorsRangeNegative = [-3 -1];
numberOfCompetitorsPositive = 3;
numberOfCompetitorsNegative = 3;
% Set spacings for initializing the search.
% Try different ones in the hope that we thus avoid local minima in
% the search.
%
% Note that these spacings are hard coded. We have used the same spacing as in the color selection experiment.
% We will try the same spacings for both color and material space. As for MLDS-CS: it is possible that there would be a
% cleverer thing to do here.

trySpacing = [0.5 1 2];
tryWeights = [0.1 0.5 0.8];
% Standard fmincon options
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');

%% Search
%
% We search over various initial spacings and take the best result.
% There are two loops. One sets the positions of the competitors
% in the solution in the color dimension, the other tries different initial spacings for material dimension.

maxLogLikely = -Inf;

for k1 = 1:length(trySpacing)
    for k2 = 1:length(trySpacing)
        for k3 = 1:size(tryWeights)
            % Choose initial competitor positions based on current spacing to try.
            initialCompetitorPositionsColor = [trySpacing(k1)*linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,trySpacing(k1)*linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];
            initialCompetitorPositionsMaterial = [trySpacing(k1)*linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,trySpacing(k1)*linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];
            initialParams = [initialCompetitorPositionsColor initialCompetitorPositionsMaterial tryWeights(k3) sigma];
            
            % Get reasonable upper and lower bound. These are most easily computed from the initial parameters.
            % For now we just say - go anywhere (+/-100 times the maximum value in the intial parameters);
            vlb = -100*max(abs(initialParams))*ones(size(initialParams));
            vub = 100*max(abs(initialParams))*ones(size(initialParams));
            vlb(targetIndexColor) = 0;
            vlb(targetIndexMaterial) = 0;
            vub(targetIndexColor) = vlb(targetIndexColor); % fix search for target position at 0.
            vub(targetIndexMaterial) = vlb(targetIndexMaterial); % fix search for target position at 0.
            vlb(end) = 1; % fix position of the sigma. 
            vub(end) = 1; 
            vub(end-1) = 1; % limit w
            vlb(end-1) = 0; 
            % Run the search
            fitParams = fmincon(@(x)FitColorMaterialScalingFun(x, thePairs, theResponses, nTrialsPerPair, targetIndex),initialParams,A,b,[],[],vlb,vub,[],options);
            
            % Compute log likelihood for this solution.  Keep track of the best
            % solution that comes out of the multiple starting points.
            % Save this solution if it's better than the current best.
            temp = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses, nTrials, colorPositions,materialPositions, targetIndex, w, sigma);
            if (temp > maxLogLikely)
                maxLogLikely = temp;
                [logLikelyFit,predictedResponses] = ColorMaterialComputeLogLikelyhood(thePairs,theResponses,nTrialsPerPair,fitTargetPosition,fitCompetitorPositions, w, sigma);
                targetCompetitorFit = [fitTargetPosition, fitCompetitorPositions];
            end
        end
    end
end
end

function f = FitColorMaterialScalingFun(x, thePairs,theResponses,nTrials, targetIndex)
%function f = FitColorMaterialScalingFun(x, thePairs,theResponses,nTrials, targetIndex)
%
% The error function we are minimizing in the numerical search.
% Computes the negative log likelyhood of the current solution i.e. the weights and the inferred
% position of the competitors on color and material axes.
% Input:
%   x           - returned parameters vector.
%   thePairs    - competitor pairs.
%   theResponses- set of responses for this pair (number of times first competitor is chosen).
%   nTrialsPerPair - total number of trials run.
%   targetIndex    - index of the target position in the color and material space.
%   pairSpecs - defines each pair - w
% Output:
%   f - negative log likelihood for the current solution.

% Sanity check - is the solution to any of our parameters NaN
if (any(isnan(x)))
    error('Entry of x is NaN');
end

% We need to convert X to params here
colorPositions = x(1:7);
materialPositions = x(8:14);
w = x(end-1);
sigma = x(end);


% Compute negative log likelyhood of the current solution
%           ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials, colorPositions,materialPositions, targetIndex, w, sigma)
logLikely = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials, colorPositions,materialPositions, targetIndex, w, sigma);
f = -logLikely;

end
