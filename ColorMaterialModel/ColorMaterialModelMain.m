function [x, logLikelyFit, predictedResponses] = ColorMaterialModelMain(thePairs,theResponses,nTrialsPerPair)
% function [x, logLikelyFit, predictedResponses] = ColorMaterialModelMain(thePairs,theResponses,nTrialsPerPair)

% This is the main fitting/search routine in the model. 
% It takes the data (from experiment or simulation) and returns inferred position of the
% competitors on color and material dimension as well as the weigths. 
% WARNING: It required loading a structure that specifies hardcoded experimental
% parameters. Here we load ExampleStructure.mat which is identical 
% to the structure of our Experiment1. 
% Input: 
%   thePairs -            competitor pairs. 
%   theResponses -        set of responses for this pair (number of times
%                         color match is chosen. 
%   nTrialsPerPair -      total number of trials run. Vector of same size as theResponses.
%
% Output: 
%   x -                   returned parameters. needs to be converted using xToParams routine to get the positions and weigths.
%   logLikelyFit -        log likelihood of the fit.
%   predictedResponses -  responses predicted from the fit.

%% Load and unwrap parameter structure which contains all fixed parameters. 
load('ExampleStructure.mat')
targetPosition = params.targetPosition;
targetIndex = params.targetIndex; % WE SHOULD NOT HAVE THIS ONE. 
targetIndexColor = params.targetIndexColor; % target position in the color position vector.
targetIndexMaterial = params.targetIndexMaterial; % target position in the material position vector.
numberOfColorCompetitors = params.numberOfColorCompetitors; 
numberOfMaterialCompetitors = params.numberOfMaterialCompetitors; 

% NEED TO ALLOW FOR POSSIBLY DIFFERENT NUMBER OF POSITIVE AND NEGATIVE
% COMPETITORS FOR COLOR AND MATERIAL
numberOfCompetitorsPositive = params.numberOfCompetitorsPositive;
numberOfCompetitorsNegative = params.numberOfCompetitorsNegative;
competitorsRangePositive = params.competitorsRangePositive;
competitorsRangeNegative = params.competitorsRangeNegative;

% Standard deviation for the solution. This determines the scale of the solution.
sigma = params.sigma;
% Determine minimum size of interval between the color and material position elements relative to sigma.
% That is, the minimum spacing will be sigma/sigmaFactor.
sigmaFactor = params.sigmaFactor;

%% Run some sanity checks.
%
% These are the same checks we were implemented for the MLDSColorSelection model.
% And it seems reasonable to do them here as well. Check this and throw error message if it does not hold.
if (length(theResponses(:)) ~= length(nTrialsPerPair(:)))
    error('Passed theResponses and nTrialsPerPair must be of same length');
end

% The number of responses in theResponses cannot ever exceed nTrialsPerPair.
if (any(theResponses > nTrialsPerPair))
    error('An entry of input theResponses exceeds passed nTrialsPerPair.  No good!');
end

%% Enforce the spacing between competitors. This needs to be done in color and material space, separately. 
% Plus, for each we need to append two columns for parameter weight and sigma, that are not going
% to be modified in this way. 
AMaterialPositions = zeros(numberOfMaterialCompetitors-1,numberOfMaterialCompetitors);
for i = 1:numberOfMaterialCompetitors-1
    AMaterialPositions(i,i) = 1;
    AMaterialPositions(i,i+1) = -1;
end
AMaterialPositionsIgnore = zeros(size(AMaterialPositions));
bMaterialPositions = -sigma/sigmaFactor*ones(numberOfMaterialCompetitors-1,1);

AColorPositions = zeros(numberOfColorCompetitors-1,numberOfColorCompetitors);
for i = 1:numberOfColorCompetitors-1
        AColorPositions(i,i) = 1;
        AColorPositions(i,i+1) = -1;
end
AColorPositionsIgnore = zeros(size(AColorPositions));
bColorPositions = -sigma/sigmaFactor*ones(numberOfColorCompetitors-1,1);

AMaterialPositionsFull = [AColorPositionsIgnore, AMaterialPositions,  zeros(size(AMaterialPositions(:,1))),  zeros(size(AMaterialPositions(:,1)))]; 
AColorPositionsFull = [AColorPositions, AMaterialPositionsIgnore, zeros(size(AColorPositions(:,1))),  zeros(size(AColorPositions(:,1)))]; 

A = [AMaterialPositionsFull; AColorPositionsFull];
b = [bMaterialPositions; bColorPositions];

%% Set spacings for initializing the search.
% Try different ones in the hope that we thus avoid local minima in
% the search.
%
% Note that these spacings are hard coded. We have used the same spacing as in the color selection experiment.
% We will try the same spacings for both color and material space. As for MLDS-CS: it is possible that there would be a
% cleverer thing to do here.
trySpacing = [1 2 0.5];
tryWeights = [0.5 0.8 0.1];

% Standard fmincon options
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');

%% Search
%
% We search over various initial spacings and take the best result.
% There are two loops. One sets the positions of the competitors
% in the solution in the color dimension, the other tries different initial spacings for material dimension.
maxLogLikely = -Inf;
for k1 = 1%:length(trySpacing)
    for k2 = 1%:length(trySpacing)
        for k3 = 1%:size(tryWeights)
            % Choose initial competitor positions based on current spacing to try.
            initialCompetitorPositionsMaterial = [trySpacing(k1)*linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,trySpacing(k1)*linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];
            initialCompetitorPositionsColor = [trySpacing(k2)*linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,trySpacing(k2)*linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];
            initialParams = [initialCompetitorPositionsMaterial initialCompetitorPositionsColor tryWeights(k3) sigma];
            
            % Get reasonable upper and lower bound. These are most easily computed from the initial parameters.
            % For now we just say - go anywhere (+/-100 times the maximum value in the intial parameters);
            vlb = -100*max(abs(initialParams))*ones(size(initialParams));
            vub = 100*max(abs(initialParams))*ones(size(initialParams));
            vlb(targetIndexMaterial) = 0;
            vub(targetIndexColor) = 0; % fix search for target position at 0.
            vlb(targetIndexColor) = 0;
            vub(targetIndexMaterial) = 0; % fix search for target position at 0.
            vlb(end-1) = 0; % limit variation in w. 
            vub(end-1) = 1; 
            vub(end) = 1; % fix sigma to 1. 
            vlb(end) = 1; 
            
            % Run the search
            x = fmincon(@(x)FitColorMaterialScalingFun(x, thePairs, theResponses, nTrialsPerPair, params),initialParams,A,b,[],[],vlb,vub,[],options);
            
            % Compute log likelihood for this solution.  Keep track of the best
            % solution that comes out of the multiple starting points.
            % Save this solution if it's better than the current best.
            [materialPositions, colorPositions, sigma, w] = ColorMaterialModelXToParams(x, params); 
            temp = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses, nTrialsPerPair, materialPositions, colorPositions, targetIndex, w, sigma);
            if (temp > maxLogLikely)
                maxLogLikely = temp;
                [logLikelyFit, predictedResponses] = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrialsPerPair, materialPositions, colorPositions,targetIndex, w, sigma);
            end
        end
    end
end
end

function f = FitColorMaterialScalingFun(x, thePairs,theResponses,nTrials, params)
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
[colorPositions, materialPositions,w,sigma] = ColorMaterialModelXToParams(x, params); 
           
% Compute negative log likelyhood of the current solution
%           ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials, colorPositions,materialPositions, targetIndex, w, sigma)
logLikely = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials, colorPositions,materialPositions, params.targetIndex, w, sigma);
f = -logLikely;

end


