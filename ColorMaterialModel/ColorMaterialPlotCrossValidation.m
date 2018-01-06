% ColorMaterialPlotCrossValidation
% Plots results of cross validation for WeightFixed and WeightVaried results for the real experimental data. 
%
% April 15, 2017 ar     Wrote it. 

% Initialize
clear; close all;

% Specify other experimental parameters
whichExperiment = 'E1P2';
switch whichExperiment
    case 'E1P2'
        subjectList = { 'mdc'};
        conditionCode = {'NC', 'CY', 'CB'};
        figAndDataDir = [analysisDir '/Experiment1'];
        
    case 'Pilot'
        subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
        conditionCode = {'NC'};
        figAndDataDir = [analysisDir, '/Pilot'];
        dataDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/data/';
end
whichError = 'logLik';
fixedWValue = 0.1:0.1:0.9; 

cd(figAndDataDir); 
% Make a seprate plot for each subject and each condition. 
for s = 1:length(subjectList)
    for whichCondition = 1:length(conditionCode)
         
        figure; clf; hold on;
        clear V
        V = load([subjectList{s} conditionCode{whichCondition} 'weightVary-6Folds.mat']);
        nFolds = length(V.thisSubject.condition{whichCondition}.crossVal(1,1).returnedParamsTraining(:,end-1)); 
        
        clear meanVariedWeight SEMVariedWeight
        meanVariedWeight = mean(V.thisSubject.condition{whichCondition}.crossVal(1,1).returnedParamsTraining(:,end-1)); 
        SEMVariedWeight = std(V.thisSubject.condition{whichCondition}.crossVal(1,1).returnedParamsTraining(:,end-1))/sqrt(nFolds); 
        
        for i  = 1:length(fixedWValue)
            tic
            clear thisSubject
            load([subjectList{s} conditionCode{whichCondition} 'weightFixed-' num2str(fixedWValue(i)) '6Folds.mat']);
        
            switch whichError
                case 'rmse'
                    SEMFixedWeigth(i) = std(thisSubject.condition{whichCondition}.crossVal(1,i).returnedParamsTraining(:,end-1))/sqrt(nFolds);
                    meanFixedWeigth(i) = mean(thisSubject.condition{whichCondition}.crossVal(1,i).returnedParamsTraining(:,end-1));
                    errorbarX(fixedWValue(i), thisSubject.condition{whichCondition}.crossVal(1,i).meanRMSError, SEMFixedWeigth(i), 'ro')
                    errorbarX(meanVariedWeight, V.thisSubject.condition{whichCondition}.crossVal(1,1).meanRMSError, SEMVariedWeight, 'bo')
                    legend('FixedW', 'VariedW', 'Location', 'Best')
           
                    ylabel('RMSE')
                    xlabel('FixedWeigth')
                    axis([0 1  0 .3])
                    line([meanVariedWeight, meanVariedWeight], [0 1], 'color', 'b')
           
                case 'logLik'
                    SEMFixedWeigth(i) = std(thisSubject.condition{whichCondition}.crossVal(1,i).returnedParamsTraining(:,end-1))/sqrt(nFolds);
                    meanFixedWeigth(i) = mean(thisSubject.condition{whichCondition}.crossVal(1,i).returnedParamsTraining(:,end-1));
                    errorbarX(fixedWValue(i), thisSubject.condition{whichCondition}.crossVal(1,i).meanLogLikelihood, SEMFixedWeigth(i), 'ro')
                    errorbarX(meanVariedWeight, V.thisSubject.condition{whichCondition}.crossVal(1,1).meanLogLikelihood, SEMVariedWeight, 'bo')
                    legend('FixedW', 'VariedW', 'Location', 'Best')
           
                    axis([0 1  -80 -60])
                    ylabel('logLik')
                    xlabel('FixedWeigth')
                    line([meanVariedWeight, meanVariedWeight], [-100 0], 'color', 'b')
            end
            
            
            if (meanFixedWeigth(i) ~= fixedWValue(i)) && (SEMFixedWeigth(i) == 0)
                error;
            end
        end
        FigureSave([subjectList{s} conditionCode{whichCondition} whichError 'FigCrossVal'], gcf, 'pdf')
    end
end

