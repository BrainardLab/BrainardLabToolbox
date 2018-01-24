%function bootstrappedDataStruct = ColorMaterialModelBootstrapData(theData, nBlocks, nRepetitions, pairInfo, params)
 function bootstrappedDataStruct = ColorMaterialModelBootstrapData(theData, nBlocks, nRepetitions, pairInfo, params)
% Perform bootstraping to find confidence intervals for model paramters. 
% 
% Input: 
% theData - full data from one experimental condition. This is a marix of
%           zeros and ones in the format nTrials x nBlocks (rows x columns). 
% nBlocks - number of experimental blocks
% nRepetitions - how many resampling repetitions. 
% pairInfo - structure defining the pairs in each trial. 
% params - parameter structure. Will not run unless bootstrap method is
%          initialized. 
% 
% Output:
% bootstrappedDataStruct - structure with the results (model fits for nRepetitions of the resampling)

% 03/??/2017 ar Wrote it.
% 06/19/2017 ar Functionalized it, added comments.

for kk = 1:nRepetitions
    
    nTrialTypes = size(theData,1);
    
    % Sanity check. 
    if (size(theData,2) ~= nBlocks)
        error('Oops');
    end
    
    % initialize the bootstrap data structure on this trial
    bootstrapData = zeros(nTrialTypes,1);
    switch params.bootstrapMethod
        case 'perTrialPerBlock'
            bootstrapData = zeros(nTrialTypes,1);
            for bb = 1:nTrialTypes
                id = randi(nBlocks,[nBlocks 1]);
                bootstrapData(bb) = sum(theData(bb,id));
            end
            
        case 'qPlusPerTrialPerBlock'
            bootstrapData = zeros(nTrialTypes,1);
            for bb = 1:nTrialTypes
                id = randi(nBlocks,[nBlocks 1]);
                bootstrapData(bb) = sum(theData(bb,id));
            end
            
        case 'perBlock'
            id = randi(nBlocks,[nBlocks 1]);
            bootstrapData = sum(theData(:,id));
        
        otherwise
            error('This bootstrap method is not implemented.')
    end
    
    nBootstrapTrials = nBlocks*ones(nTrialTypes,1);
    [bootstrappedDataStruct.returnedParams(kk,:), ...
        bootstrappedDataStruct.logLikelyFit(kk), ... 
        bootstrappedDataStruct.predictedProbabilitiesBasedOnSolution(kk,:)] = ...
        FitColorMaterialModelMLDS(pairInfo.pairColorMatchColorCoords, pairInfo.pairMaterialMatchColorCoords,...
        pairInfo.pairColorMatchMaterialCoords, pairInfo.pairMaterialMatchMaterialCoords,...
        bootstrapData, nBootstrapTrials,params);
end