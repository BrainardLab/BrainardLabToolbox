function convertOverUnderParamsToSideBySideParameters(win, leftOffset, leftScale, rightOffset, rightScale)
% Change parameters for over under to side by side so that the imaging mode
% will work in a display that horizontally stretches left and right frames
% to fill the full res window.


%       The display stretches half frames to full width
%  _________        _________       _________ 
%  | A | B |   ---> | <-A->  |  +   | <-B->  |
%  ---------        ---------       ---------
% Side-by-side compressed images are one of several popular stereo HDMI formats

% The stereo mode must be set to 2 or 3 for this to work.  

% Example function call ConvertOverUnderToSideBySideParameters(windowPtr, [0, 0], [0.5, 1], [0.5, 0], [0.5, 1])

% Call this function after the win = PsychImaging('OpenWindow',...); call on an
% onscreen window in Top/Bottom stereo mode to change the parameters
% of drawing the stereo views.
%
% All parameters except the onscreen 'win'dowhandle are optional and have
% reasonable builtin defaults:
%
% 'leftOffset' = Top-Left [x,y] offset of left eye framebuffer in relative
% coordinates [0,0] == top-left of framebuffer, [1,0] == 1 stereo window
% width to the right, [2,0] == 2 stereo window width to the right etc.
%
% 'leftScale' = Scaling of left eye image buffer. E.g., [1,1] == Don't
% scale. [0.75, 0.5] scale to 75% of original width, 50% of original
% height.
%
% 'rightOffset', 'rightScale' == Ditto for right eye image.
%

    % Test if a window handle is provided...
    if nargin < 1
        error('You must provide the windowhandle for the onscreen window as 1st parameter!');
    end

    % ... and if it is a valid onscreen window in frame-sequential stereo mode:
    if Screen('WindowKind', win) ~= 1
        error('Provided windowhandle is not a valid and open onscreen window!');
    end

    winfo = Screen('GetWindowInfo', win);
    
    if ~ismember(winfo.StereoMode, [2,3])
        % Only do conversion if we are in top bottom mode, else abort and do normal processing
        fprintf('SetStereoSideBySideParameters: Info: Provided onscreen window is not in appropriate mode. Call ignored.\n');

        fprintf('WARNING:  *********************************************');
        fprintf('WARNING:  *********************************************');
        fprintf('WARNING:  *********************************************');
        fprintf('WARNING:  *********************************************');
        fprintf('WARNING:  ******Aborting Side_by_Side Conversion*******');
        fprintf('WARNING:  *********************************************');
        fprintf('WARNING:  *********************************************');
        fprintf('WARNING:  *********************************************');
        fprintf('WARNING:  *********************************************');
        return;
    end

    % Query size of onscreen window in pixels w x h:
    [w, h] = Screen('WindowSize', win);

    % Parse other arguments, assign defaults if none passed:
    if nargin < 2 || isempty(leftOffset)
        leftOffset = [0, 0];
    end

    if nargin < 3 || isempty(leftScale)
        leftScale = [0.5, 1];
    end

    if nargin < 4 || isempty(rightOffset)
        rightOffset = [0.5, 0];
    end

    if nargin < 5 || isempty(rightScale)
        rightScale = [0.5, 1];
    end

    % Query full specification of processing slot for left eye view shader:
    % 'slot' is position in processing chain, others are parameters for the
    % operation:

    [slot shaderid blittercfg voidptr glsl] = Screen('HookFunction', win, 'Query', 'StereoCompositingBlit', 'StereoCompositingShaderCompressedTop');
    if slot == -1
        disp('ERROR: Could not find processing slot for left-eye view!... Please check that StereoMode is set to 2 or 3');
        error('Could not find processing slot for left-eye view!... Please check that StereoMode is set to 2 or 3');
    end

    % Delete old processing slot from pipeline:
    Screen('HookFunction', win, 'Remove', 'StereoCompositingBlit' , slot);

    % Define new blitter configuration for changed parameters:
    leftOffset(1) = floor(leftOffset(1) * w);
    leftOffset(2) = floor(leftOffset(2) * h);
    blittercfg = sprintf('Builtin:IdentityBlit:Offset:%i:%i:Scaling:%f:%f', leftOffset(1), leftOffset(2), leftScale(1), leftScale(2));

    % Insert modified processing function at old position (slot) in the
    % pipeline, effectively replacing the slot:
    posstring = sprintf('InsertAt%iShader', slot);
    Screen('Hookfunction', win, posstring, 'StereoCompositingBlit', shaderid, glsl, blittercfg);

    % Query full specification of processing slot for right eye view shader:
    % 'slot' is position in processing chain, others are parameters for the
    % operation:

    [slot shaderid blittercfg voidptr glsl] = Screen('HookFunction', win, 'Query', 'StereoCompositingBlit', 'StereoCompositingShaderCompressedBottom');
    if slot == -1
        disp('ERROR: Could not find processing slot for right-eye view!... Please check that StereoMode is set to 2 or 3');
        error('Could not find processing slot for right-eye view!... Please check that StereoMode is set to 2 or 3');
    end

    % Delete old processing slot from pipeline:
    Screen('HookFunction', win, 'Remove', 'StereoCompositingBlit' , slot);

    % Define new blitter configuration for changed parameters:
    rightOffset(1) = floor(rightOffset(1) * w);
    rightOffset(2) = floor(rightOffset(2) * h);
    blittercfg = sprintf('Builtin:IdentityBlit:Offset:%i:%i:Scaling:%f:%f', rightOffset(1), rightOffset(2), rightScale(1), rightScale(2));

    % Insert modified processing function at old position (slot) in the
    % pipeline, effectively replacing the slot:
    posstring = sprintf('InsertAt%iShader', slot);
    Screen('Hookfunction', win, posstring, 'StereoCompositingBlit', shaderid, glsl, blittercfg);

end
