% plot Gridded Interpolation

% Initialize
clear; close all;

% lookup
lookupMethod = 'cubic';
load('gridParams.mat');
% Load lookup table
switch lookupMethod
    case  'linear'
        load colorMaterialInterpolateFunctionLinear.mat
        colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunction;
    case 'cubic'
        load colorMaterialInterpolateFunctionCubic.mat
        colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunction;
end
frameRate = 5;
quality = 100;
nSamples = 100;
nDim = length(size(colorMaterialInterpolatorFunction.Values));

% we need to fix 2 dimensions
randValue1 = randi(nSamples);
randValue2 = randi(nSamples);

comb = nchoosek(1:nDim,3);
for i  = 1:size(comb,1)
    comb2(i,:) = setdiff([1:5], comb(i,:));
end

for ii = 1:size(comb,1)
    close all
    xSamples = linspace(-gridParams.endPosition,gridParams.endPosition,nSamples);
    ySamples = linspace(-gridParams.endPosition,gridParams.endPosition,nSamples);
    zSamples = linspace(-gridParams.endPosition,gridParams.endPosition,nSamples);
    wSamples = linspace(-gridParams.endPosition,gridParams.endPosition,nSamples);
    qSamples = linspace(gridParams.weightCoords(1),gridParams.weightCoords(end),nSamples);
    setValues = {'xSamples', 'ySamples', 'zSamples', 'wSamples', 'qSamples'};
    labels = {'CMCol', 'MMCol', 'CMMat', 'MMMat', 'w'};
    [newXgrid,newYgrid] = ndgrid(eval(setValues{(comb(ii,1))}),  eval(setValues{(comb(ii,2))}));
    
    % video writer object (MPEG-4)
    writerObj = VideoWriter(['Grid' num2str(comb(ii,1)) num2str(comb(ii,2)) num2str(comb(ii,3)) '.mp4'], 'MPEG-4');
    writerObj.FrameRate = frameRate;
    writerObj.Quality = quality;
    open(writerObj);
    
    % here I need to write the correct string to implement this.
    currentOrder = [comb(ii,:) comb2(ii,:)];
    tempString = {[setValues{comb(ii,1)} '(i)'], [setValues{comb(ii,2)}  '(j)'], [setValues{comb(ii,3)}  '(k)'], ...
        [setValues{comb2(ii,1)} '(randValue1)'], [setValues{comb2(ii,2)} '(randValue2)']};
    toEval = ['colorMaterialInterpolatorFunction('];
    for kk = 1:length(currentOrder)
        if kk == length(currentOrder)
            toEval = [toEval, [tempString{kk}, ')']];
        else
            toEval = [toEval, [tempString{kk}, ',']];
        end
    end
    
    theFig = figure; clf;
    for k = 1:length(eval(setValues{comb(ii,3)}))
        for i = 1:length(eval(setValues{comb(ii,1)}))
            for j = 1:length(eval(setValues{comb(ii,2)}))
                
                newProbs(i,j) = eval(toEval);
            end
        end
        
        mesh(newXgrid,newYgrid,newProbs);
        view(60,45)
        
        % create correct axis
        x1 = eval(setValues{(comb(ii,1))});
        y1 = eval(setValues{(comb(ii,2))});
        z1 = eval(setValues{(comb(ii,3))});
        w1 = eval(setValues{(comb2(ii,1))});
        q1 = eval(setValues{(comb2(ii,2))});
        axis([x1(1), x1(end), y1(1), y1(end), 0 ,1])
        
        xlabel(labels(comb(ii,1)))
        ylabel(labels(comb(ii,2)))
        zlabel('prob')
        
        % create a correct title.
        title([labels{comb(ii,3)} '=' num2str(z1(k)) ' '  labels{comb2(ii,1)} '=' num2str(w1(randValue1))  ' ' labels{comb2(ii,2)} '=' num2str(q1(randValue2))])
        drawnow;
        writeVideo(writerObj,getframe(theFig));
    end
    close(writerObj);
end