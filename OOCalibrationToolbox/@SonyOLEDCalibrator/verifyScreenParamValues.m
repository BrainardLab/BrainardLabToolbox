% Method to ensure that the parameters of the screen match those specified by the user
function verifyScreenParamValues(obj)
    
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
        alphaBits           = 8; % this wiould be 2 for a 30-bit display
        d.bitsPerPixel      = d.bitsPerSample*d.samplesPerPixel + alphaBits;
        
        % Update list of display structs
        a(k) = d;
    end
    
end