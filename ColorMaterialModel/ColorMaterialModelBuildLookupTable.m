% ColorMaterialModelBuildLookupTable
%
% Build a 5-dimensional table to allow lookup of probabilities for various positions and
% dimension weight.

% 05/16/2017 ar Reviewed,added comments and gridParams structure. 

%% Initialize; 
clear; close all; 

%% Fixed general parameters.  
gridParams.sigma = 1; 
gridParams.targetColorCoord = 0; 
gridParams.targetMaterialCoord = 0; 
gridParams.endPosition = 20;
gridParams.whichDistance = 'euclidean';

%% Fixed temporary parameters. 
gridParams.nSamplePoints = 20; 
gridParams.nSimulate =  3000; 

%% Set dimensions of interest
gridParams.colorMatchColorCoords = linspace(-gridParams.endPosition,gridParams.endPosition,gridParams.nSamplePoints);
gridParams.materialMatchColorCoords = linspace(-gridParams.endPosition,gridParams.endPosition,gridParams.nSamplePoints);
gridParams.colorMatchMaterialCoords =  linspace(-gridParams.endPosition,gridParams.endPosition,gridParams.nSamplePoints);
gridParams.materialMatchMaterialCoords = linspace(-gridParams.endPosition,gridParams.endPosition,gridParams.nSamplePoints);
gridParams.weight = linspace(0,1,gridParams.nSamplePoints/2);
gridParams.addNoise = true; 

%% Define grid sample points
[gridParams.colorMatchColorCoordGrid,gridParams.materialMatchColorCoordGrid,gridParams.colorMatchMaterialCoordGrid, ...
    gridParams.materialMatchMaterialCoordsGrid, gridParams.weightGrid] = ...
    ndgrid(gridParams.colorMatchColorCoords,gridParams.materialMatchColorCoords,...
    gridParams.colorMatchMaterialCoords, gridParams.materialMatchMaterialCoords, gridParams.weight);
CMLookUp = zeros(size(gridParams.colorMatchColorCoordGrid));
tic
for i = 1:length(gridParams.colorMatchColorCoords)
    for j = 1:length(gridParams.materialMatchColorCoords)
        for k = 1:length(gridParams.colorMatchMaterialCoords)
            for l = 1:length(gridParams.materialMatchMaterialCoords)
                for m = 1:length(gridParams.weight)
                    
                    % Build the gridded data that we'll interpolate on
                    CMLookUp(i,j,k,l,m) = ColorMaterialModelComputeProbBySimulation(gridParams.nSimulate, gridParams.targetColorCoord,gridParams.targetMaterialCoord, ...
                        gridParams.colorMatchColorCoordGrid(i,j,k,l,m),gridParams.materialMatchColorCoordGrid(i,j,k,l,m),...
                        gridParams.colorMatchMaterialCoordGrid(i,j,k,l,m), gridParams.materialMatchMaterialCoordsGrid(i,j,k,l,m), gridParams.weightGrid(i,j,k,l,m), ...
                        gridParams.sigma, gridParams.addNoise, gridParams.whichDistance);
                end
                
            end
        end
    end
end
toc 

% Build interpolator
colorMaterialInterpolatorFunction = griddedInterpolant(gridParams.colorMatchColorCoordGrid,gridParams.materialMatchColorCoordGrid,...
    gridParams.colorMatchMaterialCoordGrid,gridParams.materialMatchMaterialCoordsGrid, gridParams.weightGrid, CMLookUp,'linear');
save(['colorMaterialInterpolateFunLinear' gridParams.whichDistance],'colorMaterialInterpolatorFunction','CMLookUp','gridParams');
clear colorMaterialInterpolatorFunction
colorMaterialInterpolatorFunction = griddedInterpolant(gridParams.colorMatchColorCoordGrid,...
    gridParams.materialMatchColorCoordGrid,gridParams.colorMatchMaterialCoordGrid,...
    gridParams.materialMatchMaterialCoordsGrid, gridParams.weightGrid, CMLookUp,'cubic');

% Save all parameters. 
save(['colorMaterialInterpolateFunCubic' gridParams.whichDistance],'colorMaterialInterpolatorFunction','CMLookUp','gridParams'); 
