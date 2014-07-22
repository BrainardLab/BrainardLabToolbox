function [responseStruct]= RunExperimentalLoopWithCubeScene(obj)
%   Method that presents a stereo-pair stimulus with a number of selectable targets and returns
%   a response struct that contains detailed information related to the subject's selection.
%
%   Parameters:
%   obj: The parent StereoViewController object
%
%   History:
%   @code
%   4/09/2013    ar    Modified it based on WaitForTargetSelection method.
%   4/20/2013    npc   Cleaned up, reorganized, added Doxygen-comments.
%   6/17/2013    ar    Fixed a bug related to flush events. Eliminated
%                      ListenChar, make sure all events are flushed before
%                      allowing observer to make a response. Clean up. Some
%                      renaming. 
%   @endcode
%

% initialize response structure.
responseStruct = struct('reactionTime', NaN, ...
    'reactionTimeCorrected', NaN, ...
    'selectedTargetIndex', NaN,...
    'waitTime', NaN,...
    'quitTrial', false);

waitTime = 0.25;
% Present stimulus and obtain the timestamp of its onset
% Make sure observer sees the stimulus.

stimulusOnset = obj.showStimulus();
mglWaitSecs(waitTime); 
keepDrawing = true;
 
% Flush any key presses from the previous trial. 
key = -1;
while (~isempty(key))
    key = mglGetKeyEvent(0);
end

while (keepDrawing)
    key = mglGetKeyEvent(Inf);
    if (~isempty(key))
        switch key.charCode
            case 'w'
                responseStruct.reactionTime = mglGetSecs - stimulusOnset;
                responseStruct.reactionTimeCorrected = key.when - stimulusOnset;
                responseStruct.waitTime = waitTime; 
                responseStruct.selectedTargetIndex      = 1;
                keepDrawing = false;
                obj.stereoGLWindow.enableObject(['RightTargetBox' num2str(responseStruct.selectedTargetIndex)]); 
            case 's'
                responseStruct.reactionTime = mglGetSecs - stimulusOnset;
                responseStruct.reactionTimeCorrected = key.when - stimulusOnset;
                responseStruct.waitTime = waitTime; 
                responseStruct.selectedTargetIndex = 2;
                keepDrawing = false;
                obj.stereoGLWindow.enableObject(['RightTargetBox' num2str(responseStruct.selectedTargetIndex)]);
            case 'q'
                keepDrawing = false;
                responseStruct.quitTrial = true;
        end % switch
    end  % ~isempty(key)
    obj.stereoGLWindow.draw;
end % while keepDrawing
mglWaitSecs(0.2)
%obj.hideStereoCursor();
obj.hideStimulus();
end

