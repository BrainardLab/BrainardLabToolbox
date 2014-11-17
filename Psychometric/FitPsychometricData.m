function [pFit,interpStimuli,pInterp,pse,loc25,loc75] = FitPsychometricData(theStimuli,nYesResponses,nTotalResponses)
% [pFit,interpStimuli,pInterp,pse,loc25,loc75] = FitPsychometricData(theStimuli,nYesResponses,nTotalResponses)
%
% Fit [0-1] psychometric data with cumulative normal.  Allows independent guess and lapse values in
% the range 0 to 5%.
%
% Fit with Palemedes Toolbox.  Some thinking is required to initialize the parameters sensibly.
% We know that the mean of the cumulative normal should be
% roughly within the range of the comparison stimuli, so we initialize this to the mean.  The standard deviation
% should be some moderate fraction of the range of the stimuli, so again this is used as the initializer.
%
% 6/29/12 dhb      Wrote from some earlier version.
% 2/22/14 dhb      Improved comments.

interpStimuli = linspace(min(theStimuli),max(theStimuli),100)';
%interpStimuli = linspace(0,1,100)';
nYes = nYesResponses;
nTrials = nTotalResponses;
PF = @PAL_CumulativeNormal;         % Alternatives: PAL_Gumbel, PAL_Weibull, PAL_CumulativeNormal, PAL_HyperbolicSecant
PFI = @PAL_inverseCumulativeNormal;
paramsFree = [1 1 1 1];             % 1: free parameter, 0: fixed parameter
paramsValues0 = [mean(theStimuli) 1/((max(theStimuli,[],1)-min(theStimuli,[],1))/4) 0 0];
options = optimset('fminsearch');   % Type help optimset
options.TolFun = 1e-09;             % Increase required precision on LL
options.Display = 'off';            % Suppress fminsearch messages
lapseLimits = [0 0.05];                % Limit range for lambda
guessLimits = [0 0.05];                % Limit range for guessing
[paramsValues] = PAL_PFML_Fit(...
    theStimuli,nYes,nTrials, ...
    paramsValues0,paramsFree,PF,'searchOptions',options, ...
    'guessLimits',guessLimits, ...
    'lapseLimits',lapseLimits);
pInterp = PF(paramsValues,interpStimuli);
pFit = PF(paramsValues,theStimuli);
pse = PFI(paramsValues,0.5);
loc25 = PFI(paramsValues,0.25);
loc75 = PFI(paramsValues,0.75);

end
