function predictedProbabilities = ColorMaterialModelComputeProbBySimulation(nSimulate,targetColorCoord,targetMaterialCoord, ...
    colorMatchColorCoord,materialMatchColorCoord,colorMatchMaterialCoord, materialMatchMaterialCoord, w, sigma)

%s = rng(173);

predictedResponses = zeros(nSimulate,1);
for kk = 1:nSimulate
    predictedResponses(kk) = ColorMaterialModelSimulateResponse(targetColorCoord, targetMaterialCoord, ...
        colorMatchColorCoord, materialMatchColorCoord, ...
        colorMatchMaterialCoord, materialMatchMaterialCoord, w, sigma);
end
predictedProbabilities = mean(predictedResponses);

%rng(s);

end