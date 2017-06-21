% PlotGriddedInterpolation
% The script makes the movies of three dimensional cross sections (two
% dimensions + time) showing the extrapolation of probabilities from the
% look up table. Two remaining dimensions are always set to the middle of
% the parameter range. 

% 03/01/16 ar Wrote it

% Initialize
clear; close all;
figDir = '/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/DemoData';
cd(figDir)

% movie parametes. 
frameRate = 5;
quality = 100;

% interpolation parameters
nSamples = 100;
setValues = {'xSamples', 'ySamples', 'zSamples', 'wSamples', 'qSamples'};
labels = {'CMCol', 'MMCol', 'CMMat', 'MMMat', 'w'};
nDim = length(labels);

% Set of varied dimensions for each movie.
comb = nchoosek(1:nDim,3);

% Set of fixed dimensions for each movie.
for i  = 1:size(comb,1)
    comb2(i,:) = setdiff([1:5], comb(i,:));
end
    
% fix 2 dimensions in the middle (there are 100 samples)
randValue1 = 50;
randValue2 = 50;

% Which distance metric is used to compute the table? 
% Options: Euclidean or CityBlock
distance = 'Euclidean'; 

% Loops through different dimension combination for linear and cubic
% interpolation from the lookup table. 
for whichInterpolation =1:2 
    if whichInterpolation == 1
        lookupMethod = ['cubic' distance];
    elseif whichInterpolation == 2
        lookupMethod = ['linear' distance];
    end
    
    % Load lookup table
    switch lookupMethod
        case  'linearEuclidean'
            load colorMaterialInterpolateFunLineareuclidean.mat
            colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunction;
            interpCode = 'L-Euc';
        case 'cubicEuclidean'
            load colorMaterialInterpolateFunCubiceuclidean.mat
            colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunction;
            interpCode = 'C-Euc';
        case  'linearcityblock'
            load colorMaterialInterpolateFunLinearcityblock.mat
            colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunction;
            interpCode = 'L-CB';
        case 'cubiccityblock'
            load colorMaterialInterpolateFunCubiccityblock.mat
            colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunction;
            interpCode = 'C-CB';
    end
    
    for ii = 1:size(comb,1)
        close all
        xSamples = linspace(-gridParams.endPosition,gridParams.endPosition,nSamples);
        ySamples = linspace(-gridParams.endPosition,gridParams.endPosition,nSamples);
        zSamples = linspace(-gridParams.endPosition,gridParams.endPosition,nSamples);
        wSamples = linspace(-gridParams.endPosition,gridParams.endPosition,nSamples);
        qSamples = linspace(gridParams.weightCoords(1),gridParams.weightCoords(end),nSamples);
        [newXgrid,newYgrid] = ndgrid(eval(setValues{(comb(ii,1))}),  eval(setValues{(comb(ii,2))}));
        
        % video writer object (MPEG-4)
        writerObj = VideoWriter([interpCode, 'Grid' num2str(comb(ii,1)) num2str(comb(ii,2)) num2str(comb(ii,3)) '.mp4'], 'MPEG-4');
        writerObj.FrameRate = frameRate;
        writerObj.Quality = quality;
        open(writerObj);
        
        % Careful building of the executable string to make the correct
        % intrerpolation. 
        currentOrder = [comb(ii,:) comb2(ii,:)];
        tempString = {[setValues{comb(ii,1)} '(i)'], [setValues{comb(ii,2)}  '(j)'], [setValues{comb(ii,3)}  '(k)'], ...
            [setValues{comb2(ii,1)} '(randValue1)'], [setValues{comb2(ii,2)} '(randValue2)']};
        toEval = ['colorMaterialInterpolatorFunction('];
        for kk = 1:length(currentOrder)
            tmpIndex = find(currentOrder==kk);
            if kk == length(currentOrder)
                toEval = [toEval, [tempString{tmpIndex}, ')']];
            else
                toEval = [toEval, [tempString{tmpIndex}, ',']];
            end
        end
        
        theFig = figure; clf;
        for k = 1:length(eval(setValues{comb(ii,3)}))
            for i = 1:length(eval(setValues{comb(ii,1)}))
                for j = 1:length(eval(setValues{comb(ii,2)}))
                    newProbs{k}(i,j) = eval(toEval);
                end
            end
            
            mesh(newXgrid,newYgrid,newProbs{k});
            view(60,45)
            
            % Create correct axis
            x1 = eval(setValues{(comb(ii,1))});
            y1 = eval(setValues{(comb(ii,2))});
            z1 = eval(setValues{(comb(ii,3))});
            w1 = eval(setValues{(comb2(ii,1))});
            q1 = eval(setValues{(comb2(ii,2))});
            axis([x1(1), x1(end), y1(1), y1(end), 0 ,1])
            
            xlabel(labels(comb(ii,1)))
            ylabel(labels(comb(ii,2)))
            zlabel('prob')
            
            % Labels with the right title.
            title([labels{comb(ii,3)} '=' num2str(z1(k)) ' '  labels{comb2(ii,1)} '=' num2str(w1(randValue1))  ' ' labels{comb2(ii,2)} '=' num2str(q1(randValue2))])
            drawnow;
            writeVideo(writerObj,getframe(theFig));
        end
        close(writerObj);
    end
end