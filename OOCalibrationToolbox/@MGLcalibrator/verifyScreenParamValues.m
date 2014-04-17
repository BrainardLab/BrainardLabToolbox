% Method to ensure that the parameters of the screen match those specified by the user
function obj = verifyScreenParamValues(obj)
    
    a = mglDescribeDisplays;
    obj.displaysDescription = a;
    
    if (length(a) < obj.screenToCalibrate)
        error('System has %d attached screen. The screenID (%d) for calibration is out of range !\n', length(a), obj.screenToCalibrate);
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