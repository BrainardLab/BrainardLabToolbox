% ColorMaterialModelBuildLookupTable
%
% Build a table to allow lookup of probabilities for various positions and
% dimension weight.

%% Initialize; 
clear; close all; 

%% It's a 5D table
% We're trying 2D first. 

%% Fixed general parameters.  
sigma = 1; 
targetColorCoord = 0; 
targetMaterialCoord = 0; 
endPosition = 20;
whichDistance = 'euclidean';
%% Fixed temporary parameters. 
nSamplePoints = 20; 
nSimulate =  3000; 

%% Set dimensions of interest
colorMatchColorCoords = linspace(-endPosition,endPosition,nSamplePoints);
materialMatchColorCoords = linspace(-endPosition,endPosition,nSamplePoints);
colorMatchMaterialCoords =  linspace(-endPosition,endPosition,nSamplePoints);
materialMatchMaterialCoords = linspace(-endPosition,endPosition,nSamplePoints);
weight = linspace(0,1,nSamplePoints/2);
addNoise = true; 
%% Define grid sample points
[colorMatchColorCoordGrid,materialMatchColorCoordGrid,colorMatchMaterialCoordGrid, materialMatchMaterialCoordsGrid, weightGrid] = ...
    ndgrid(colorMatchColorCoords,materialMatchColorCoords,colorMatchMaterialCoords, materialMatchMaterialCoords,weight);
CMLookUp = zeros(size(colorMatchColorCoordGrid));
tic
for i = 1:length(colorMatchColorCoords)
    for j = 1:length(materialMatchColorCoords)
        for k = 1:length(colorMatchMaterialCoords)
            for l = 1:length(materialMatchMaterialCoords)
                
                for m = 1:length(weight)
                    
                    % Build the gridded data that we'll interpolate on
                    CMLookUp(i,j,k,l,m) = ColorMaterialModelComputeProbBySimulation(nSimulate, targetColorCoord,targetMaterialCoord, ...
                        colorMatchColorCoordGrid(i,j,k,l,m),materialMatchColorCoordGrid(i,j,k,l,m),...
                        colorMatchMaterialCoordGrid(i,j,k,l,m), materialMatchMaterialCoordsGrid(i,j,k,l,m), weightGrid(i,j,k,l,m), ...
                        sigma, addNoise, whichDistance);
                end
                
            end
        end
    end
end
toc 
save('LookUpCurrent', 'CMLookUp');
% Build interpolator

gridParams.colorMatchColorCoords = colorMatchColorCoords;
gridParams.materialMatchColorCoords = materialMatchColorCoords;
gridParams.colorMatchMaterialCoords = colorMatchMaterialCoords;
gridParams.materialMatchMaterialCoords = materialMatchMaterialCoords;
gridParams.weight = weight; 
gridParams.nSamplePoints = nSamplePoints;
gridParams.nSimulate = nSimulate;
gridParams.sigma = sigma;
gridParams.targetColorCoord = targetColorCoord;
gridParams.targetMaterialCoord = targetMaterialCoord; 
gridParams.endPosition = endPosition;
gridParams.colorMatchColorCoordGrid = colorMatchColorCoordGrid;
gridParams.materialMatchColorCoordGrid = materialMatchColorCoordGrid;
gridParams.colorMatchMaterialCoordGrid = colorMatchMaterialCoordGrid;
gridParams.materialMatchMaterialCoordsGrid = materialMatchMaterialCoordsGrid;
gridParams.weightGrid = weightGrid;
gridParams.addNoise = addNoise; 

colorMaterialInterpolatorFunction = griddedInterpolant(colorMatchColorCoordGrid,materialMatchColorCoordGrid,colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid, CMLookUp,'linear');
save(['colorMaterialInterpolateFunLinear' whichDistance],'colorMaterialInterpolatorFunction','CMLookUp','gridParams');
clear colorMaterialInterpolatorFunction
colorMaterialInterpolatorFunction = griddedInterpolant(colorMatchColorCoordGrid,materialMatchColorCoordGrid,colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid, CMLookUp,'cubic');
save(['colorMaterialInterpolateFunCubic' whichDistance],'colorMaterialInterpolatorFunction','CMLookUp','gridParams'); 
