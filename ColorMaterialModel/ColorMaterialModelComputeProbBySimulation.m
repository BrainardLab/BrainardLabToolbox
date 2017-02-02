function predictedProbabilities = ColorMaterialModelComputeProbBySimulation(nSimulate,targetColorCoord,targetMaterialCoord, ...
    colorMatchColorCoord,materialMatchColorCoord,colorMatchMaterialCoord, materialMatchMaterialCoord, w, sigma)
%
% PLEASE COMMENT ME
%

predictedResponses = zeros(nSimulate,1);
for kk = 1:nSimulate
    predictedResponses(kk) = ColorMaterialModelSimulateResponse(targetColorCoord, targetMaterialCoord, ...
        colorMatchColorCoord, materialMatchColorCoord, ...
        colorMatchMaterialCoord, materialMatchMaterialCoord, w, sigma);
end
predictedProbabilities = mean(predictedResponses);

end