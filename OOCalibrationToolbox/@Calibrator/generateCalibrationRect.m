% Method to generate a calibration rectangle
function calibrationRect = generateCalibrationRect(obj)
    cal = obj.cal;
    calibrationRect.x0    = cal.describe.screenSizePixel(1)/2 + cal.describe.boxOffsetX;
    calibrationRect.y0    = cal.describe.screenSizePixel(2)/2 + cal.describe.boxOffsetY;
    calibrationRect.size  = [cal.describe.boxSize cal.describe.boxSize];
    calibrationRect.RGB   = [1 1 1]; % 1.0/255.0 * [1 1 1];
    obj.calibrationRect   = calibrationRect;
end
