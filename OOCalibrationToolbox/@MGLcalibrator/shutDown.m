% Method to shutdown the device
function obj = shutDown(obj)
    if (obj.options.verbosity > 9)
        fprintf('In MglCalibrator.shutDown() method\n');
    end

    % Close the screen that was calibrated.
    mglSwitchDisplay(obj.cal.describe.whichScreen);
    mglClose;

    if obj.cal.describe.blankOtherScreen
        mglSwitchDisplay(obj.cal.describe.whichBlankScreen);
        mglClose;
    end

end