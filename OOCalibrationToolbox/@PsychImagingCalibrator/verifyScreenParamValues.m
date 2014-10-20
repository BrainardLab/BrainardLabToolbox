% Method to ensure that the parameters of the screen match those specified by the user
function obj = verifyScreenParamValues(obj)
    
    % Make sure we have an OpenGL Psychtoolbox
    AssertOpenGL;

    screensIDarray = Screen('Screens');
    
    for k = 1:numel(screensIDarray)
        screenID = screensIDarray(k);
        
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
    
        % isMain
        if (screenID == 0)
            d.isMain = 1;
        else
            d.isMain = 0;
        end
        
        % screen Size in MM
        [w,h] = Screen('DisplaySize', screenID);
        d.screenSizeMM = [w,h]; 
        
        % screenSizePixel & refreshRate
        res = Screen('Resolution', screenID);
        d.screenSizePixel = [res.width res.height];
        d.refreshRate = res.hz;

         % unitNumber
        d.unitNumber = screenID;
        
        % gammaTableLength & samplesPerPixel
        [obj.origLUT, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', screenID);
        d.gammaTableLength = size(obj.origLUT,1);
        d.samplesPerPixel  = size(obj.origLUT,2);
        
        % bitsPerSample, bitsPerPixel, samplesPerPixel
        pixelSize           = Screen('PixelSize', screenID);
        d.bitsPerSample     = pixelSize/d.samplesPerPixel;
        alphaBits = 8; % this wiould be 2 for a 30-bit display
        d.bitsPerPixel      = d.bitsPerSample*d.samplesPerPixel + alphaBits;
        
        % Update list of display structs
        a(k) = d;
    end
    
    obj.displaysDescription = a;
    
    if (length(a) < obj.screenToCalibrate)
        error('System has %d attached screen. The screenID specified for calibration (%d) is out of range !\n', length(a), obj.screenToCalibrate);
    end
    obj.screenInfo = a(obj.screenToCalibrate);

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