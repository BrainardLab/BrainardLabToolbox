% Method to ensure that the parameters of the screen match those specified by the user
function obj = verifyScreenParamValues(obj)
    % Make sure we have an OpenGL Psychtoolbox
    %AssertOpenGL;

    %screensIDarray = Screen('Screens');

    d = struct(...
        'isMain', [], ...
        'screenSizeMM', [], ...
        'screenSizePixel', [], ...
        'refreshRate', [], ...
        'openGLacceleration', 1, ...
        'unitNumber', [], ...
        'bitsPerPixel', [], ...
        'bitsPerSample', [], ...
        'samplesPerPixel', [], ...
        'gammaTableLength', [] ...
    );

    % Get the screen size in pixels
    screenSizePixel = get(0, 'ScreenSize'); % Returns [left, bottom, width, height]
    d.screenSizePixel = screenSizePixel(3:4);

    % Assuming the primary screen is the only screen in MATLAB
    % isMain
    d.isMain = 1;
    d.unitNumber = 1;

    % Get the refresh rate (this is a bit tricky as MATLAB does not provide a direct way)
    % You may need to use Java or .NET integration to get the refresh rate
    % Example using Java (works on Windows):
    if ispc
        import java.awt.*;
        gd = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice();
        d.refreshRate = gd.getDisplayMode().getRefreshRate();
    else
        d.refreshRate = NaN; % Not available on non-Windows platforms with this method
    end
    
    % Get bits per pixel
    % MATLAB does not provide a direct way to get bits per pixel, so you may need to use Java or system commands
    if ispc
        import java.awt.*;
        gd = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice();
        d.bitsPerPixel = gd.getDisplayMode().getBitDepth();
    else
        d.bitsPerPixel = NaN; % Not available on non-Windows platforms with this method
    end
    
    % Assume standard values for bits per sample and samples per pixel
    d.bitsPerSample = 8; % Assuming 8 bits per color channel
    d.samplesPerPixel = 3; % Assuming RGB (3 color channels)
    
    % Gamma table length is not available directly in MATLAB
    d.gammaTableLength = NaN;
    
    % Display the struct
    disp(d);

    % % screen Size in MM
    % [w,h] = Screen('DisplaySize', screenID);
    % d.screenSizeMM = [w,h]; 
    % 
    % % screenSizePixel & refreshRate
    % res = Screen('Resolution', screenID);
    % d.screenSizePixel = [res.width res.height];
    % d.refreshRate = res.hz;
    % 
    %  % unitNumber
    % d.unitNumber = screenID;
    % 
    % % gammaTableLength & samplesPerPixel
    % [obj.origLUT, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', screenID);
    % d.gammaTableLength = size(obj.origLUT,1);
    % d.samplesPerPixel  = size(obj.origLUT,2);
    % 
    % % bitsPerSample, bitsPerPixel, samplesPerPixel
    % pixelSize           = Screen('PixelSize', screenID);
    % d.bitsPerSample     = pixelSize/d.samplesPerPixel;
    % alphaBits = 8; % this wiould be 2 for a 30-bit display
    % d.bitsPerPixel      = d.bitsPerSample*d.samplesPerPixel + alphaBits;

    obj.displaysDescription = d;
    
    if (length(d) < obj.screenToCalibrate)
        error('System has %d attached screen. The screenID specified for calibration (%d) is out of range !\n', length(a), obj.screenToCalibrate);
    end
    obj.screenInfo = d(obj.screenToCalibrate);
    
    if (~isempty(obj.desiredRefreshRate))
        if (obj.screenInfo.refreshRate ~= obj.desiredRefreshRate)
            error('Current frame rate (%4.2f Hz) does not match that specified (%4.2f Hz) for this calibration !\n', obj.screenInfo.refreshRate, obj.desiredRefreshRate);
        end
    end
    
    if (~isempty(obj.desiredScreenSizePixel))
        if (obj.screenInfo.screenSizePixel(1) ~= obj.desiredScreenSizePixel(1) || obj.screenInfo.screenSizePixel(2) ~= obj.desiredScreenSizePixel(2))
            error('Current resolution [%d x %d] does not match that specified [%d x %d] for this calibration !', obj.screenInfo.screenSizePixel(1), obj.screenInfo.screenSizePixel(2), obj.desiredScreenSizePixel(1), obj.desiredScreenSizePixel(2));
        end
    end
end
