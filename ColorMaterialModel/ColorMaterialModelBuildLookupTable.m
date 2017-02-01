% ColorMaterialModelBuildLookupTable
%
% Build a table to allow lookup of probabilities for various positions and
% dimension weight.

% Initialize; 
clear; close all; 

%% It's a 5D table
% We're trying 2D first. 

% Fixed general parameters.  
sigma = 1; 
targetColorCoord = 0; 
targetMaterialCoord = 0; 
endPosition = 3;

% Fixed temporary parameters. 
nSamplePoints = 100; 
materialMatchColorCoords = 2;
materialMatchMaterialCoords = 1;
weight = 0.3;

% Set dimensions of interest (2 for now)
colorMatchColorCoords = linspace(-endPosition,endPosition,nSamplePoints);
colorMatchMaterialCoords =  linspace(-endPosition,endPosition,nSamplePoints);

%% Define grid sample points
[X,Y] = ndgrid(colorMatchMaterialCoords,colorMatchMaterialCoords);

tic
for i = 1:length(colorMatchColorCoords)
    for j = 1:length(colorMatchMaterialCoords)
        %         for k = 1:length(materialMatchColorCoord)
        %             for l = 1:length(materialMatchMaterialCoord)
        %                 for m = 1:length(weight)
        CMLookUp(i,j) = ColorMaterialModelComputeProb(targetColorCoord,targetMaterialCoord, ...
            colorMatchColorCoords(i),materialMatchColorCoords,...
            colorMatchMaterialCoords(j), materialMatchMaterialCoords, weight, sigma);
        %                 end
        %             end
        %         end
    end
end
toc

% Extrapolate and visualize
F = griddedInterpolant(X,Y,CMLookUp,'linear');
mesh(X,Y,CMLookUp);



