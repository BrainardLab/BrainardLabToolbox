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
endPosition = 5;

%% Fixed temporary parameters. 
nSamplePoints = 20; 
nSimulate =  1000; 

%% Set dimensions of interest
colorMatchColorCoords = linspace(-endPosition,endPosition,nSamplePoints);
materialMatchColorCoords = linspace(-endPosition,endPosition,nSamplePoints);
colorMatchMaterialCoords =  linspace(-endPosition,endPosition,nSamplePoints);
materialMatchMaterialCoords = linspace(-endPosition,endPosition,nSamplePoints);
weight = linspace(0,1,nSamplePoints/2);

%% Define grid sample points
[colorMatchColorCoordGrid,materialMatchColorCoordGrid,colorMatchMaterialCoordGrid, materialMatchMaterialCoordsGrid, weightGrid] = ...
    ndgrid(colorMatchColorCoords,materialMatchColorCoords,colorMatchMaterialCoords, materialMatchMaterialCoords,weight);
CMLookUp = zeros(size(colorMatchColorCoordGrid));
for i = 1:length(colorMatchColorCoords)
    for j = 1:length(materialMatchColorCoords)
        for k = 1:length(colorMatchMaterialCoords)
            for l = 1:length(materialMatchMaterialCoords)
                
                for m = 1:length(weight)
                    
                    % Build the gridded data that we'll interpolate on
                    CMLookUp(i,j,k,l,m) = ColorMaterialModelComputeProbBySimulation(nSimulate, targetColorCoord,targetMaterialCoord, ...
                        colorMatchColorCoordGrid(i,j,k,l,m),materialMatchColorCoordGrid(i,j,k,l,m),...
                        colorMatchMaterialCoordGrid(i,j,k,l,m), materialMatchMaterialCoordsGrid(i,j,k,l,m), weightGrid(i,j,k,l,m), sigma);
                end
                
            end
        end
    end
end
 
% Build interpolator
colorMaterialInterpolatorFunction = griddedInterpolant(colorMatchColorCoordGrid,materialMatchColorCoordGrid,colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid, CMLookUp,'linear');

save('colorMaterialInterpolateFunction','colorMaterialInterpolatorFunction','CMLookUp','nSimulate','nSamplePoints','targetColorCoord','targetMaterialCoord','endPosition','sigma');

% % Apply interpolator
% tempValue = 2;
% [~,index] = min(abs(materialMatchColorCoords-tempValue));
% valueForMaterialMatchColorCoords = materialMatchColorCoords(index);
% 
% newColorMatchColorCoords = [0.3322 2.47 -1.3];
% newMaterialMatchColorCoords = [valueForMaterialMatchColorCoords valueForMaterialMatchColorCoords valueForMaterialMatchColorCoords];
% newColorMatchMaterialCoords = [1.623774 0.001 2.38];
% 
%% newProbs = F(newColorMatchColorCoords,newMaterialMatchColorCoords,newColorMatchMaterialCoords);
% 
% %[Xi,Yi] = ndgrid(newColorMatchColorCoords,newColorMatchMaterialCoords);
% %newProbs = F(Xi,Yi);
% [plotXGrid,plotZGrid] = ndgrid(colorMatchColorCoords,colorMatchMaterialCoords);
% plotYGrid = valueForMaterialMatchColorCoords*ones(size(plotXGrid));
% %plotProbs = F(plotXGrid,plotYGrid,plotZGrid);
% 
% % Visualize the 2D table we built and something we interpolated from it
% figure; clf; hold on;
% mesh(plotXGrid,plotZGrid,plotProbs);
% 
% plot3(newColorMatchColorCoords,newColorMatchMaterialCoords,newProbs,'ko','MarkerSize',8,'MarkerFaceColor','k');
% xlabel('X'); ylabel('Y');





