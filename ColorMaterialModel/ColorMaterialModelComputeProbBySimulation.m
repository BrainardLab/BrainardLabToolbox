% function predictedProbabilities = ColorMaterialModelComputeProbBySimulation(nSimulate,targetColorCoord,targetMaterialCoord, ...
%     colorMatchColorCoord,materialMatchColorCoord,colorMatchMaterialCoord, materialMatchMaterialCoord, w, sigma, addNoise, whichDistance)
function predictedProbabilities = ColorMaterialModelComputeProbBySimulation(nSimulate,targetColorCoord,targetMaterialCoord, ...
    colorMatchColorCoord,materialMatchColorCoord,colorMatchMaterialCoord, materialMatchMaterialCoord, w, sigma, addNoise, whichDistance)
% 
% Computes probabilities for a given pair of stimuli by simulating certain
% number of trials. 
% Input
% 	nSimulate - number of trials to simulate
%   targetColorCoord  - target position on color dimension (fixed to 0).
%   targetMaterialCoord  - target position on material dimension (fixed to 0).
%   colorMatchColorCoord - inferred position on the color dimension for the first competitor in the pair
%   materialMatchColorCoord - inferred position on the material dimension for the first competitor in the pair
%   colorMatchMaterialCoord - inferred position on the color dimension for the second competitor in the pair
%   materialMatchMaterialCoord - inferred position on the material dimension for the second competitor in the pair
%   w - weight for color dimension.
%   sigma - noise around the target position (we assume it is equal to 1).
%   addNoise  -  add noise to the target (true) or not (false)
%   whichDistance - which method for computing distance should be used (e.g. 'euclidean', 'cityblock'). Check help 
%   pdist for options.  
% Output
%   predictedProbabilities - mean probabilities over n simulations.

% 01/28/17 dhb, ar - Wrote it. 

predictedResponses = zeros(nSimulate,1);
for kk = 1:nSimulate
    predictedResponses(kk) = ColorMaterialModelSimulateResponse(targetColorCoord, targetMaterialCoord, ...
        colorMatchColorCoord, materialMatchColorCoord, ...
        colorMatchMaterialCoord, materialMatchMaterialCoord, w, sigma, 'addNoiseToTarget', addNoise, 'whichDistance', whichDistance);
end
predictedProbabilities = mean(predictedResponses);

end