function [warpstruct, filterMode] = CreateDisplayWarp(window, calibfilename, showCalibOutput, varargin)
% This is the Override function.
% [warpstruct, filterMode] = CreateDisplayWarp(window, calibfilename/calibStruct [, showCalibOutput=0]);
%
% Helper routine for Geometric display undistortion mapping, not to be
% called inside normal PTB scripts!
%
% This function reads a display calibration file 'calibfilename' and builds
% a "geometric warp function" based on the calibration information in
% 'calibfilename' for the onscreen window with handle 'window'. It returns
% a struct 'warpstruct' that defines the created warp function. You could
% pass this 'warpstruct' as a parameter to the Psychtoolbox command...
%
% PsychImaging('AddTask', viewchannel, 'GeometryCorrection', warpstruct);
%
% However, you normally do not call this routine directly from your script. Its
% called internally by the PsychImaging() command...
% 
% PsychImaging('AddTask', viewchannel, 'GeometryCorrection', calibfilename);
%
% ...in order to setup PTB's imaging pipeline for realtime geometry
% correction, based on the calibration info in the file 'calibfilename'.
%
% Example: You created a calibration file 'mycalib.mat' to undistort the
% left view display of a stereo setup. Then you could apply this
% undistortion function via the following setup code:
%
% PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask', 'LeftView', 'GeometryCorrection', 'mycalib.mat');
% window = PsychImaging('OpenWindow', screenid);
%
% This would open an onscreen window just as window=Screen('OpenWindow', screenid);
% would do. It would configure the window for automatic undistortion based
% on the data in 'mycalib.mat'.
%
% --------------------------------------------------------------------------
%   History:
%   7/3/2014   npc   Wrote it by modifying the PTB-3 version to use our own grid deformation methods
% 


    fprintf('\n ----------------------\n');
    fprintf('\n\nBrainard lab''s own version (overrides) !!!\n\n');
    fprintf('\n ----------------------\n');
    % Global GL handle for access to OpenGL constants needed in setup:
    global GL;

    % Cache last generated warpstruct, so code can easily query it:
    persistent oldwarpstruct;

    if isempty(GL)
        sca;
        error('PTB internal error: GL struct not initialized?!?');
    end

    % Special case of simple query of last created 'warpstruct'?
    if nargin == 1
        if ~ischar(window)
            error('Single provided argument is not a command string!');
        end

        if ~strcmpi(window, 'Query')
            error('Single provided argument is not the command string ''Query''!');
        end

        % "Query" command recognized. Return last created warpstruct:
        warpstruct = oldwarpstruct;
        return;
    end

    if nargin < 2
        sca;
        error('PTB internal error: Must provide all parameters!');
    end

    if nargin < 3 || isempty(showCalibOutput)
        showCalibOutput = 0;
    end

    % Is calibfilename a struct with calibration settings, or a filename of a
    % calibration file?
    if isstruct(calibfilename)
        % A struct: Assign it directly.
        calib = calibfilename;
    else
        % Supposedly the filename of a calibration file:
        if ~ischar(calibfilename)
            error('In setup of geometry undistortion: Parameter "calibfilename" is not a filename string!');
        end

        % Load calibration file:
        if ~exist(calibfilename, 'file')
            sca;
            error('In setup of geometry undistortion: No such calibration file %s!', calibfilename);
        end

        calib = load(calibfilename);
    end

    % Preinit warpstruct:
    warpstruct.glsl = [];
    warpstruct.gld = [];

    % Assume no need for texture filter shader:
    needFilterShader = 0;
    filterMode = ':Bilinear';

    % Do we need a GLSL texture filter shader? We'd need one if the given
    % gfx-hardware is not capable of filtering the input image buffer:
    winfo = Screen('GetWindowInfo', window);
    effectivebpc = 8;
    if winfo.BitsPerColorComponent >= 16
        % Window is a floating point window with at least 16bpc.
        effectivebpc = 16;

        if winfo.BitsPerColorComponent >= 32
            % All buffers are 32 bpc for certain:
            effectivebpc = 32;
        end

        if (winfo.BitsPerColorComponent == 16)
            % First buffer is 16 bpc, following ones could be 32 bpc:
            if bitand(winfo.ImagingMode, kPsychUse32BPCFloatAsap)
                % All following buffers are 32bpc float. In the tradition of
                % "better safe than sorry", we assume that the warp op will use
                % one of the 32 bpc float buffers as input.
                effectivebpc = 32;            
            end
        end    
    end

    % Highres input buffer?
    if effectivebpc > 8
        % Yes. Our input is a float texture. Check if the hardware can filter
        % textures of effectivebpc bpc in hardware:
        if effectivebpc > winfo.GLSupportsFilteringUpToBpc
            % Hardware not capable of handling such deep textures. We need to
            % create and attach our own bilinear texture filter shader:
            needFilterShader = 1;
            filterMode = '';
        end
    end


    if strcmp(calib.warpType, 'ArbitraryDeformation')
        % Build warp display list for calibration/remapping method
        % based on the 'distortedGridVertexArray', and
        % 'calibrationGridVertexArray' vertex arrays contained in the 
        % input calibration file
        
        % Get the vertex data for the two grids
        calibrationGridVertexArray = calib.calibrationGridVertexArray;  % the recti-linear grid
        distortedGridVertexArray   = calib.distortedGridVertexArray;    % the distorted grid
        
        if (showCalibOutput)
            figure();
            clf; hold on;
            axis 'equal'; axis ij;

            % alignment grid nodes in red
            xGridPos1  = calibrationGridVertexArray(1:2:end);
            yGridPos1  = calib.screenHeightInPixels - calibrationGridVertexArray(2:2:end);
            plot(xGridPos1, yGridPos1, 'ro', 'MarkerFaceColor', [1.0 0.5 0.5]);

            % distorted grid nodes in blue
            xGridPos2 = distortedGridVertexArray(1:2:end);
            yGridPos2 = distortedGridVertexArray(2:2:end);
            plot(xGridPos2, yGridPos2, 'bo', 'MarkerFaceColor', [0.5 0.5 1.0]);
            
            % black lines connecting corresponding nodes in alignment and distorted grids
            for k = 1:numel(xGridPos1)
                x = [xGridPos1(k) xGridPos2(k)];
                y = [yGridPos1(k) yGridPos2(k)];
                plot(x,y, 'k-');
            end
            
            set(gca, 'XLim', [-50 calib.screenWidthInPixels+50], 'YLim', [-50 calib.screenHeightInPixels+50]);
            drawnow;
        end
        
        % Build the unwarp mesh display list within the OpenGL context of Psychtoolbox:
        Screen('BeginOpenGL', window, 1);
                
        % Build a display list that corresponds to the current calibration:
        gld = glGenLists(1);
        glNewList(gld, GL.COMPILE);
        
        % "Draw" the warp-mesh once, so it gets recorded in the display list:
        glColor4f(1,1,1,1);
        glEnableClientState(GL.VERTEX_ARRAY);
        glVertexPointer(2, GL.DOUBLE, 0, distortedGridVertexArray);
        glEnableClientState(GL.TEXTURE_COORD_ARRAY);
        glTexCoordPointer(2, GL.DOUBLE, 0, calibrationGridVertexArray);

        glDrawArrays(GL.QUADS, 0, length(distortedGridVertexArray)/2);

        glDisableClientState(GL.TEXTURE_COORD_ARRAY);
        glDisableClientState(GL.VERTEX_ARRAY);

        % List ready - and already updated in the imaging pipeline:
        glEndList;

        Screen('EndOpenGL', window);

        % Assign display list to output warpstruct:
        warpstruct.gld = gld;
    end

    warpstruct.glsl = LoadGLSLProgramFromFiles('BilinearTextureFilterShader');
    glUseProgram(warpstruct.glsl);
    glUniform1i(glGetUniformLocation(warpstruct.glsl, 'Image'), 0);
    glUseProgram(0);

    % Cache created warptstruct for later queries:
    oldwarpstruct = warpstruct;
end

