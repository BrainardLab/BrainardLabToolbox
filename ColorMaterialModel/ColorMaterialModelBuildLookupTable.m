% ColorMaterialModelBuildLookupTable
%
% Build a table to allow lookup of probabilities for various positions and
% dimension weight.

%% It's a 5D table
% 
lowPosition = -3;
highPoistion = 3;
colorMatchColorCoords = -lowPosition:lowPosition;
colorMatchMaterialCoords = -lowPosition:lowPosition;
materialMatchColorCoord = 2;
materialMatchMaterialCoord = 1;
weight = 0.3;
sigma = 1;

%% Build gridded interpolant on the co
