function [responseStruct]= RunExperimentalLoopWithSliderSLC(obj, params)
%   Method that presents a stereo-pair stimulus with a number of selectable targets and returns
%   a response struct that contains detailed information related to the subject's selection.
%
%   Parameters:
%   obj: The parent StereoViewController object
%
%   History:
%   @code
%   4/06/2013    ar    Adapted it from the RunExperimentalLoopWithCubeStimulus.
%   @endcode
%

% initialize response structure.
responseStruct = struct('reactionTime', NaN, ...
    'reactionTimeCorrected', NaN, ...
    'selectedChip', []);

% Present stimulus and obtain the timestamp of its onset
% Make sure observer sees the stimulus.

stimulusOnset = obj.showStimulus();
%obj.exportStimulusToTiffFile('Test') 
keepDrawing = true;
 
while (keepDrawing) && isempty(responseStruct.selectedChip)
    [responseStruct.selectedChip, sliderTime] = sliderLoop(params, true);
    responseStruct.reactionTime = sliderTime - stimulusOnset;
    obj.stereoGLWindow.draw;
end % while keepDrawing

obj.hideStimulus();
pause(1);

end

