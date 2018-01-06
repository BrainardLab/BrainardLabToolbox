% ColorMaterialModelBuildLookupTable
%
% Build a 5-dimensional table to allow lookup of probabilities that color match is chosen, for various positions and
% dimension weight.

% 05/16/17   ar   Reviewed,added comments and gridParams structure. 
% 01/05/18   dhb  Use nearest neighbor extrapolation, to avoid out of range
%                 values.
% 01/06/18   ar   Added options for recomputing the table from scratch or
%                 to load the already computed values.
%% Initialize; 
clear; close all; 

% Simulate (build from scratch) or not?
% If build from scratch SIMULATE is equal to false. 
SIMULATE = false; 

% Set distance type
whichDistance = 'euclidean';
if SIMULATE == false
    % Load the existing table for a desired distance
    % Delete the obsolete interpolation result
    % Save the lookup table computations in a separate file that we can
    % access easily.
    load(['colorMaterialInterpolateFunLinear' whichDistance]);
    clear colorMaterialInterpolatorFunction
    save(['LookupTable-' whichDistance],'CMLookUp','gridParams')
    if ~isfield(gridParams, 'whichDistance')
       gridParams.whichDistance = whichDistance;
    end
else
    %% Fixed general parameters.
    gridParams.sigma = 1;
    gridParams.targetColorCoord = 0;
    gridParams.targetMaterialCoord = 0;
    gridParams.endPosition = 20;
    gridParams.whichDistance = whichDistance;
    
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
end

% Build and save interpolators
colorMaterialInterpolatorFunction = griddedInterpolant(gridParams.colorMatchColorCoordGrid,gridParams.materialMatchColorCoordGrid,...
    gridParams.colorMatchMaterialCoordGrid,gridParams.materialMatchMaterialCoordsGrid, gridParams.weightGrid, CMLookUp,'linear','nearest');
save(['colorMaterialInterpolateFunLinear' gridParams.whichDistance],'colorMaterialInterpolatorFunction','CMLookUp','gridParams');
clear colorMaterialInterpolatorFunction

colorMaterialInterpolatorFunction = griddedInterpolant(gridParams.colorMatchColorCoordGrid,...
    gridParams.materialMatchColorCoordGrid,gridParams.colorMatchMaterialCoordGrid,...
    gridParams.materialMatchMaterialCoordsGrid, gridParams.weightGrid, CMLookUp,'cubic','nearest');
save(['colorMaterialInterpolateFunCubic' gridParams.whichDistance],'colorMaterialInterpolatorFunction','CMLookUp','gridParams');
