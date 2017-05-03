%% Initialize and set directories and some plotting params.
clear; close all;
currentDir = pwd;
dataDir = ['/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData'];


nBlocks1 = 56; 
nBlocks2 = 24; 
w = [0.25, 0.5, 0.75]; 
nSets = 10; 
cd([currentDir '/'])
for whichWeight = 1:length(w)
    for whichSet = 1:nSets
        clear a b
        a = load(['DemoData' num2str(w(whichWeight)) 'W' num2str(nBlocks1) 'Blocks10SetsFitVary.mat']);
        b = load(['DemoData' num2str(w(whichWeight)) 'W' num2str(nBlocks2) 'Blocks10SetsFitVary.mat']);
        
        getWeight1(whichSet, whichWeight) = a.dataSet{whichSet}.returnedParams(end-1);
        getWeight2(whichSet, whichWeight) = b.dataSet{whichSet}.returnedParams(end-1);
        
    end
end