function [x, logLikelyFit, predictedResponses] = FitColorMaterialModelMLDS(...
    pairColorMatchColorsCoords, pairMaterialMatchColorCoords,...
    pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
    theResponses,nTrials, params)
% [x, logLikelyFit, predictedResponses] = FitColorMaterialModelMLDS(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponses,nTrials, params, varargin)

% This is the main fitting/search routine in the model.
% It takes the data (from experiment or simulation) and returns inferred position of the
% competitors on color and material dimension as well as the weigths.
%
% Input:
%   pairColorMatchMatrialCoordIndices - index to get color match material coordinate for each trial type.
%   pairMaterialMatchColorCoordIndices - index to get material match color coordinate for each trial type.
%   theResponses - set of responses for this pair (number of times color match is chosen.
%   nTrials - total number of trials run. Vector of same size as theResponses.
%   params - structure giving experiment design parameters
%
% Output:
%   x - returned parameters. needs to be converted using xToParams routine to get the positions and weigths.
%   logLikelyFit - log likelihood of the fit.
%   predictedResponses - responses predicted from the fit.
%
% % Optional key/value pairs
% %   'whichPositions' - string (default 'full').  Which model to fit
% %      'full' - Fit all parameters.
% %      'smoothSpacing - Force spacing between stimulus positions to vary smoothly.
% %   'whichWeight' - string (default 'weightVary').  How to handle weights.
% %     'weightVary' - Allow the weight to vary
% %     'weightFixed' - Fix the weight at value in tryWeightValues(1).
% %   'tryWeightValues' - vector (default [0.5 0.2 0.8]). Value to use when fixing weight.
% %   'tryColorSpacingValues' - vector (default [0.5 1 2]).  Values to try for color spacings.
% %   'tryMaterialSpacingValues' - vector (default [0.5 1 2]).  Values to try for material spacings.

%% Run some sanity checks.
%
tic
% These are the same checks we were implemented for the MLDSColorSelection model.
% And it seems reasonable to do them here as well. Check this and throw error message if it does not hold.
if (length(theResponses(:)) ~= length(nTrials(:)))
    error('Passed theResponses and nTrialsPerPair must be of same length');
end

% The number of responses in theResponses cannot ever exceed nTrialsPerPair.
if (any(theResponses > nTrials))
    error('An entry of input theResponses exceeds passed nTrialsPerPair.  No good!');
end

%% Set up A and b constraints.
%
% This only applies when we are searching on all of the positions.  When
% the positions are found by applying a parametric function to the nominal
% positions, then we have to use the nonlinear constraint feature of
% fmincon.
switch (params.whichPositions)
    case 'full'
        % Enforce the spacing between competitors. This needs to be done in color and material space, separately.
        %
        % Plus, for each we need to append two columns for parameter weight and sigma, that are not going
        % to be modified in this way.
        AMaterialPositions = zeros(params.numberOfMaterialCompetitors-1,params.numberOfMaterialCompetitors);
        for i = 1:params.numberOfMaterialCompetitors-1
            AMaterialPositions(i,i) = 1;
            AMaterialPositions(i,i+1) = -1;
        end
        AMaterialPositionsIgnore = zeros(size(AMaterialPositions));
        bMaterialPositions = -params.sigma/params.sigmaFactor*ones(params.numberOfMaterialCompetitors-1,1);
        
        AColorPositions = zeros(params.numberOfColorCompetitors-1,params.numberOfColorCompetitors);
        for i = 1:params.numberOfColorCompetitors-1
            AColorPositions(i,i) = 1;
            AColorPositions(i,i+1) = -1;
        end
        AColorPositionsIgnore = zeros(size(AColorPositions));
        bColorPositions = -params.sigma/params.sigmaFactor*ones(params.numberOfColorCompetitors-1,1);
        
        AMaterialPositionsFull = [AColorPositionsIgnore, AMaterialPositions,  zeros(size(AMaterialPositions(:,1))),  zeros(size(AMaterialPositions(:,1)))];
        AColorPositionsFull = [AColorPositions, AMaterialPositionsIgnore, zeros(size(AColorPositions(:,1))),  zeros(size(AColorPositions(:,1)))];
        
        A = [AMaterialPositionsFull; AColorPositionsFull];
        b = [bMaterialPositions; bColorPositions];
    case 'smoothSpacing'
        % Don't use A and b in this case.
        A = [];
        b = [];
    otherwise
        error('Unknown whichPositions method specified.')
end

%% Set spacings for initializing the search.
% Try different ones in the hope that we thus avoid local minima in
% the search.
%
% Note that these spacings are hard coded. We have used the same spacing as in the color selection experiment.
% We will try the same spacings for both color and material space. As for MLDS-CS: it is possible that there would be a
% cleverer thing to do here.
switch (params.whichWeight)
    case 'weightFixed'
        params.tryWeightValues = params.tryWeightValues(1);
    case 'weightVary'
        params.tryWeightValues = params.tryWeightValues;
    otherwise
        error('Unknown whichWeight method specified');
end

% Standard fmincon options
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set','MaxIter',300);

%% Search
%
% We search over various initial spacings and take the best result.
% There are two loops. One sets the positions of the competitors
% in the solution in the color dimension, the other tries different initial spacings for material dimension.
if params.qpParamsStart
    params.tryMaterialSpacingValues = params.tryColorSpacingValues(1); 
    params.tryColorSpacingValues = params.tryColorSpacingValues(1); 
    params.tryWeightValues = params.tryWeightValues(1); 
end
logLikelyFit = -Inf;
for k1 = 1:length(params.tryMaterialSpacingValues)
    for k2 = 1:length(params.tryColorSpacingValues)
        for k3 = 1:length(params.tryWeightValues)
            % Choose initial competitor positions based on current spacing to try.
            switch (params.whichPositions)
                case 'smoothSpacing'
                    % In this method, the positions are just specified by
                    % the spacing, so we simply use the regular variable to
                    % specify it.
                    initialColorMatchMaterialCoords = [params.tryMaterialSpacingValues(k1) zeros(1,params.smoothOrder-1)];
                    initialMaterialMatchColorCoords = [params.tryColorSpacingValues(k2) zeros(1,params.smoothOrder-1)];
                case 'full'
                    initialMaterialMatchColorCoords = params.tryColorSpacingValues(k2)*[linspace(params.competitorsRangeNegative(1),...
                        params.competitorsRangeNegative(2), params.numberOfCompetitorsNegative),params.targetColorCoord,...
                        linspace(params.competitorsRangePositive(1),params.competitorsRangePositive(2), params.numberOfCompetitorsPositive)];
                    initialColorMatchMaterialCoords = params.tryMaterialSpacingValues(k1)*[linspace(params.competitorsRangeNegative(1),params.competitorsRangeNegative(2), ...
                        params.numberOfCompetitorsNegative),params.targetMaterialCoord,linspace(params.competitorsRangePositive(1),params.competitorsRangePositive(2), ...
                        params.numberOfCompetitorsPositive)];
                    
                otherwise
                    error('Unknown whichPosition method specified');
                    
            end
            if params.qpParamsStart
                initialParams = params.qpInitialParams;
            else
                initialParams = ColorMaterialModelParamsToX(initialMaterialMatchColorCoords,initialColorMatchMaterialCoords,...
                    params.tryWeightValues(k3),params.sigma);
            end
            % Create bounds vectors and start with situation where no
            % parameters can vary.  This then gets adjusted according to
            % the particular fit method we are running, just below.
            vlb = initialParams; vub = initialParams;
            
            % Set reasonable upper and lower bounds on position parameters
            % for each method.
            switch (params.whichPositions)
                case 'smoothSpacing'
                    % Weights on coefficients should be bounded.
                    vlb(1:end-2) = -params.maxPositionValue+0.1;
                    vub(1:end-2) = params.maxPositionValue-0.1;
                case 'full'
                    % Loose bounds on positions
                    vlb = (-params.maxPositionValue+0.1)*ones(size(initialParams));
                    vub = (params.maxPositionValue-0.1)*ones(size(initialParams));
                    
                    % Lock target into place
                    vlb(params.targetIndexMaterial) = 0;
                    vub(params.targetIndexColor) = 0;
                    vlb(params.targetIndexColor) = 0;
                    vub(params.targetIndexMaterial) = 0;
                otherwise
                    error('Unknown whichPosition method specified');
            end
            
            % Allow weight to vary, or not.
            switch (params.whichWeight)
                case 'weightFixed'
                    % Fix weight
                    vlb(end-1) = initialParams(end-1);
                    vub(end-1) = initialParams(end-1);
                case 'weightVary'
                    % Limit variation in w.
                    vlb(end-1) = 0;
                    vub(end-1) = 1;
                otherwise
                    error('Unknown whichWeight method specified');
            end
            
            % Bounds on sigma, which we just keep fixed
            if (params.sigma ~= 1)
                error('We really are assuming that sigma is 1 in our thinking, so check why it is not here');
            end
            vub(end) = params.sigma;
            vlb(end) = params.sigma;
            
            % Print out log likelihood of where we started
            %             [fTemp,~] = FitColorMaterialModelMLDSFun(initialParams, ...
            %                 pairColorMatchColorsCoords,pairMaterialMatchColorCoords, ...
            %                 pairColorMatchMaterialCoords,pairMaterialMatchMaterialCoords, ...
            %                 theResponses,nTrials,params);
            %            fprintf('Initial position log likelihood %0.2f.\n', -fTemp);
            
            % Run the search
            switch (params.whichPositions)
                case 'smoothSpacing'
                    % Need to use nonlinear constraint function for this
                    % version.
                    xTemp = fmincon(@(x)FitColorMaterialModelMLDSFun(x, ...
                        pairColorMatchColorsCoords,pairMaterialMatchColorCoords, ...
                        pairColorMatchMaterialCoords,pairMaterialMatchMaterialCoords, ...
                        theResponses, nTrials, params),initialParams,A,b,[],[],vlb,vub,@(x)FitColorMaterialModelMLDSConstraint(x,params),options);
                case 'full'
                    % Constraints are linear in parameter, so don't call
                    % nonlinear constraint function here.
                    xTemp = fmincon(@(x)FitColorMaterialModelMLDSFun(x,...
                        pairColorMatchColorsCoords,pairMaterialMatchColorCoords, ...
                        pairColorMatchMaterialCoords,pairMaterialMatchMaterialCoords, ...
                        theResponses, nTrials, params),initialParams,A,b,[],[],vlb,vub,[],options);
                otherwise
                    error('Unknown whichPosition method specified');
            end
            
            % Compute log likelihood for this solution.  Keep track of the best
            % solution that comes out of the multiple starting points.
            % Save this solution if it's better than the current best.
            [fTemp,predictedResponsesTemp] = FitColorMaterialModelMLDSFun(xTemp, ...
                pairColorMatchColorsCoords,pairMaterialMatchColorCoords, ...
                pairColorMatchMaterialCoords,pairMaterialMatchMaterialCoords, ...
                theResponses,nTrials,params);
            if (-fTemp > logLikelyFit)
                x = xTemp;
                logLikelyFit = -fTemp;
                predictedResponses = predictedResponsesTemp;
                
                % Report log likelihood
                fprintf('Current solution log likelihood %0.2f.\n', -fTemp)
            end
        end
    end
end

%% Right here, have option to start with passed initial parameters and compare
% how we did to the above, and take the final best.

toc
end




