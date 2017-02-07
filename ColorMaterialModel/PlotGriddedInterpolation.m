% plot Gridded Interpolation

% Initialize
clear; close all; 

% lookup
lookupMethod = 'linear';

% Load lookup table
switch lookupMethod
    case  'linear'
        load colorMaterialInterpolateFunctionLinear.mat
        colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunctionLinear;
    case 'cubic'
        load colorMaterialInterpolateFunctionCubic.mat
        colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunctionCubic;
end
[plotXGrid,plotYGrid] = ndgrid(gridParams.colorMatchColorCoords,gridParams.colorMatchMaterialCoords);

% we need to fix 3 dimensions
value3 = gridParams.colorMatchMaterialCoords(randi(20)); 
value4 = gridParams.materialMatchMaterialCoords(randi(20));
value5 = gridParams.weightCoords(randi(10));

xSamples = linspace(-gridParams.endPosition,gridParams.endPosition,100); 
ySamples = linspace(-gridParams.endPosition,gridParams.endPosition,100); 
zSamples = linspace(-gridParams.endPosition,gridParams.endPosition,100); 

[newXgrid,newYgrid] = ndgrid(xSamples, ySamples);

% video writer object (MPEG-4)
writerObj = VideoWriter('Grid.mp4', 'MPEG-4');
writerObj.FrameRate = 5;
writerObj.Quality = 100;
open(writerObj);

theFig = figure; clf; 
for k = 1:length(zSamples)
    for i = 1:length(xSamples)
        for j = 1:length(ySamples)
            newProbs(i,j) = colorMaterialInterpolatorFunction(xSamples(i),ySamples(j),zSamples(k), value4, value5);
        end
    end
    
    mesh(newXgrid,newYgrid,newProbs);
    view(60,45)
    axis([-gridParams.endPosition gridParams.endPosition -gridParams.endPosition gridParams.endPosition 0 ,1])
    xlabel('CM color')
    ylabel('MM color')
    zlabel('prob')
    title(['CM Mat  ' num2str(zSamples(k)) '; MM Mat  ' num2str(value4) '; w ' num2str(value5)])
    drawnow;
    writeVideo(writerObj,getframe(theFig));
end
close(writerObj);