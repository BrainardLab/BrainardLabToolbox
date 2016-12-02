function [x, logLikelyFit, predictedResponses, k] = ColorMaterialModelMain(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponses,nTrials, params, varargin)
% function [x, logLikelyFit, predictedResponses] = ColorMaterialModelMain(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponses,nTrials, params, varargin)

% This is the main fitting/search routine in the model. 
% It takes the data (from experiment or simulation) and returns inferred position of the
% competitors on color and material dimension as well as the weigths. 
% WARNING: It required loading a structure that specifies hardcoded experimental
% parameters. Here we load ExampleStructure.mat which is identical 
% to the structure of our Experiment1. 
% Input: 
%   pairColorMatchMatrialCoordIndices - index to get color match material coordinate for each trial type.
%   pairMaterialMatchColorCoordIndices - index to get material match color coordinate for each trial type.
%   theResponses -        set of responses for this pair (number of times
%                         color match is chosen. 
%   nTrials -      total number of trials run. Vector of same size as theResponses.
%   params - structure giving experiment design parameters
% Output: 
%   x -                   returned parameters. needs to be converted using xToParams routine to get the positions and weigths.
%   logLikelyFit -        log likelihood of the fit.
%   predictedResponses -  responses predicted from the fit.
%
% Optional key/value pairs
%   'whichVersion' - string (default 'full').  Which model to fit
%      'full' - Fit all parameters.
%      'weightFixed' - Fix the weight at value in fixedWeightValue
%      'equalSpacing - Force spacing between stimulus positions to have equal spacing on each axis.
%   'fixedWeightValue' - value (default 0.5). Value to use when fixing weight.


%% Parse variable input key/value pairs
p = inputParser;
p = inputParser;
p.addParameter('whichVersion','full',@ischar);
p.addParameter('fixedWeightValue',0.5,@isnumeric);
p.parse(varargin{:});

%% Load and unwrap parameter structure which contains all fixed parameters. 
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
if (length(theResponses(:)) ~= length(nTrials(:)))
    error('Passed theResponses and nTrialsPerPair must be of same length');
end

% The number of responses in theResponses cannot ever exceed nTrialsPerPair.
if (any(theResponses > nTrials))
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
switch (p.Results.whichVersion)
    case 'weightFixed'
        tryWeights = p.Results.weightsFixedValue;
    otherwise
        tryWeights = [0.5 0.8 0.1];
end
sigma = 1;

% Standard fmincon options
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','iter','LargeScale','off','Algorithm','active-set','MaxIter',300);

%% Search
%
% We search over various initial spacings and take the best result.
% There are two loops. One sets the positions of the competitors
% in the solution in the color dimension, the other tries different initial spacings for material dimension.
logLikelyFit = -Inf;
for k1 = 1:length(trySpacing)
    for k2 = 1:length(trySpacing)
        for k3 = 1:size(tryWeights)
            % Choose initial competitor positions based on current spacing to try.
            switch (p.Results.whichVersion)
                case 'equalSpacing'
                    % In this method, the positions are just specified by
                    % the spacing, so we simply use the regular variable to
                    % specify it.
                    initialColorMatchMaterialCoords = trySpacing(k1);
                    initialMaterialMatchColorCoords = trySpacing(k2);
                otherwise
                    initialColorMatchMaterialCoords = [trySpacing(k1)*linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,trySpacing(k1)*linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];
                    initialMaterialMatchColorCoords = [trySpacing(k2)*linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,trySpacing(k2)*linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];
            end
            initialParams = ColorMaterialModelParamsToX(initialColorMatchMaterialCoords,initialMaterialMatchColorCoords,tryWeights(k3),sigma,params);
            
            % Get reasonable upper and lower bounds for each method
            vlb = initialParams; vub = initialParams;
            switch (p.Results.whichVersion)
                case 'equalSpacing'
                    vlb(1) = 0.1;
                    vub(1) = 10;
                    vlb(2) = 0.1;
                    vub(2) = 10;
                           
                    % Limit variation in w.
                    vlb(end-1) = 0;
                    vub(end-1) = 1;
                    
                    % We don't need A and b here.  Override by setting to
                    % empty.
                    A = [];
                    b = [];
                case 'wFixed'
                    % Loose bounds on positions
                    vlb = -10*max(abs(initialParams))*ones(size(initialParams));
                    vub = 10*max(abs(initialParams))*ones(size(initialParams));
                    
                     % Lock target into place
                    vlb(targetIndexMaterial) = 0;
                    vub(targetIndexColor) = 0; 
                    vlb(targetIndexColor) = 0;
                    vub(targetIndexMaterial) = 0;
                    
                    % Fix weight
                    vlb(end-1) = initialParams(end-1);
                    vub(end-1) = initialParams(end-1);
                otherwise
                    % Loose bounds on positions
                    vlb = -10*max(abs(initialParams))*ones(size(initialParams));
                    vub = 10*max(abs(initialParams))*ones(size(initialParams));
                    
                    % Lock target into place
                    vlb(targetIndexMaterial) = 0;
                    vub(targetIndexColor) = 0; 
                    vlb(targetIndexColor) = 0;
                    vub(targetIndexMaterial) = 0;
                    
                     % Weights go between 0 and 1
                    vlb(end-1) = 0;
                    vub(end-1) = 1;
            end
            
            % Bounds on sigma, which we just keep fixed
            vub(end) = sigma;
            vlb(end) = sigma; 
            
            % Run the search
            xTemp = fmincon(@(x)FitColorMaterialScalingFun(x, pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices, theResponses, nTrials, params),initialParams,A,b,[],[],vlb,vub,[],options);
            
            % Compute log likelihood for this solution.  Keep track of the best
            % solution that comes out of the multiple starting points.
            % Save this solution if it's better than the current best.
            [fTemp,predictedResponsesTemp] = FitColorMaterialScalingFun(xTemp,pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponses,nTrials,params);
            if (-fTemp > logLikelyFit)
                x = xTemp;
                logLikelyFit = -fTemp;
                predictedResponses = predictedResponsesTemp;
                k.k1 = k1; 
                k.k2 = k2; 
                k.k3 = k3; 
            end
        end
    end
end
end




