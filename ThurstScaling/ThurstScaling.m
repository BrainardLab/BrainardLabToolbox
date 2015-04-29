function [stimulusFit, logLikelyFit, predictedResponses] = ThurstScaling(thePairs,theResponses,nTrialsPerPair, numberOfStimuli)
% function [stimulusFit, logLikelyFit, predictedResponses] = ThurstScaling(thePairs,theResponses,nTrialsPerPair, numberOfStimuli)
%
% Main Thurstonian Scaling function. Takes as input set of observers and returns the inferred position of the target and each competitors. 
% 
% Input: 
%   thePairs -            stimulus pair for each trial. 
%   theResponses -        set of responses for this pair (number of times first
%                         stimulus is chosen as "more X" where X is whatever is being scaled. 
%   nTrialsPerPair -      total number of trials run. Vector of same size as theResponses.
%   numberOfCompetitors - number of competitors in the set. 
%
% Output: 
%   stimulusFit -         inferred positions for the stimuli
%   logLikelyFit -        log likelihood of the fit.
%   predictedResponses -  responses predicted from the fit.
%
% NOTE.  A number of hard coded parameters in this routine were developed for
% the specific color selection experiments we have been doing over the past
% year (2012-2013).  It may be that this routine is brittle with respect to
% major changes in the experimental design, and fussing with these parameters
% might help:
%  sigma
%  sigmaFactor
%  trySpacings
%
% 4/28/15  dhb  Started to write this, based on MLDS code.

%% The number of responses in theResponses cannot ever exceed nTrialsPerPair.
% Check this and throw error message if it does not hold.
if (length(theResponses(:)) ~= length(nTrialsPerPair(:)))
    error('Passed theResponses and nTrialsPerPair must be of same length');
end
if (any(theResponses > nTrialsPerPair))
    error('An entry of input theResponses exceeds passed nTrialsPerPair.  No good!');
end

%% Set fixed parameters
%
% Standard deviation for the MLDS solution.
% This determines the scale of the solution.
sigma = 0.1;

% Set spacings for initializing the search.  
% Try different ones in the hope that we thus avoid local minima in 
% the search.
%
% Note that these spacings are hard coded and were determined
% from experience.  Thus they are rather 
% specific to the type of color selection experiment we
% have been doing.  It is possible that there would be a
% cleverer thing to do here.
trySpacings = [0.5 1 2];

% Standard fmincon options
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');

%% Search
%
% We search over various initial spacings and take the best result.
% There are two loops.  One sets the positions of the competitors
% in the solution.  The other tries different places for the target
% in the solution.
%
% In terms of variable names below, Y indicates competitor positoins,
% while X is (unfortunately
maxLogLikely = -Inf; 
for k1 = 1:length(trySpacings)
    % Choose initial competitor positions based on current spacing to try.
    initialStimulusPositions = linspace(0,trySpacings(k1)*numberOfStimuli*sigma,numberOfStimuli);
    
    % We don't actually search on the position of the first competitor, since the model predictions don't change
    % if we add a constant to all of the positions.  Thus we pull out the first competitor from the parameters
    % vector.  Saving it here just allows us to plop it back in for computations later.
    y1 = initialStimulusPositions(1);
    
    % Get reasonable upper and lower bound. These are most easily computed from the initial parameters.
    % We enforce that the competitor solutions head off in the positive direction, but the target can
    % be anywhere.  (We take 100 times the maximum value in the intial parameters to equal 'anyware');
    %
    % Because the first competitor is at 0, the rest cannot be lower
    % than sigma/sigmaFactor.  This has the effect of enforcing C2 >
    % sigma/sigmaFactor.  And since C3 > C2 etc, using this as a lower
    % bound for C3 etc is OK.
    vlb = (sigma/sigmaFactor)*ones(size(initialParams));
    vub = 100*max(abs(initialParams))*ones(size(initialParams));
    
    % Remember that the searched vector is [T C2 C3 ...].  We don't
    % want a strong lower bound constraint on the target, so we make
    % this the negative our our large upper bound.  This lets the
    % target, in effect, go anywhere.  That's what we want.
    vlb(1) = -vub(1);
    
    % Run the search
    fitParams = fmincon(@(x)FitContextFCScalingFun(x,y1,thePairs,theResponses,nTrialsPerPair,sigma),initialParams,[],[],[],[],vlb,vub,[],options);
    
    % Extract stimulus positions from the solution, and prepend the first stimulus postion to
    % final positions (see comment above).
    fitStimulusPositions = [y1 fitParams];
    
    % Compute log likelihood for this solution.  We need this so that we can keep track of the best
    % solution that comes out of the multiple starting points.
    % Save this solution if it's better than the current best.
    temp = ThurstComputeLogLikelihood(thePairs,theResponses,nTrialsPerPair,fitStimulusPositions,sigma);
    if (temp > maxLogLikely)
        maxLogLikely = temp;
        [logLikelyFit,predictedResponses] = ThurstComputeLogLikelihood(thePairs,theResponses,nTrialsPerPair,fitStimulusPositions,sigma);
        stimulusFit = fitStimulusPositions;
    end
end
end

function f = FitContextFCScalingFun(x,y1,thePairs,theResponses,nTrials,sigma)
%function f = FitContextFCScalingFun(x,y1,thePairs,theResponses,nTrials,sigma)
% The error function we are minimizing in the numerical search.
% Computes the negative log likelyhood of the current solution i.e. inferred
% positio of the target and the competitors. 
% Input: 
%   x           - current target position fit. 
%   y1          - current competitor position fits. 
%   thePairs    - competitor pairs. 
%   theResponses- set of responses for this pair (number of times first
%                 competitor is chosen. 
%   nTrialsPerPair - total number of trials run. 
%   sigma          - fixed standard deviation
% Output: 
%   f - negative log likelihood for the current solution. 


% Sanity check. 
if (any(isnan(x)))
    error('Entry of x is NaN');
end

% Reorganize the solution vector.  
% Pull the target from the solution, put the fixed competitor 1 back in the competitor array.  
yFit = [y1 x];

% compute negative log likelyhood of the current solution
logLikely = ThurstComputeLogLikelihood(thePairs,theResponses,nTrials,yFit,sigma);
f = -logLikely;

end
