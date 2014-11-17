function [minLum,maxLum] = FindMinMaxLumAtChrom(cal,xy)
% [minLum,maxLum] = FindMinMaxLumAtChrom(cal,xy)
%
% Find the minimum and maximum luminance available at the passed
% chromaticity.
%
% Assumes that the sensor color space for the passed calibration
% structure has been initialized to the XYZ color matching functions.
%
% 5/14/10  dhb  Wrote it.
% 5/28/10  dhb  Fix bug in what gets checked for diagnostics.

%% Make sure optimization toolbox is available
if (~exist('fsolve','file'))
    error('This function requires fsolve');
end

if (verLessThan('optim','4.1'))
    error('Your version of the optimization toolbox is too old.  Update it.');
end
    

%% Make some reasonable guess
XYZ0 = PrimaryToSensor(cal,[0.5 0.5 0.5]');
Y0 = XYZ0(2);

%% Find the answer
options = optimset('fsolve');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off');
minLum = fsolve(@InlineMinFunction,Y0,options);
maxLum = fsolve(@InlineMaxFunction,Y0,options);

%% Check that it worked
XYZ = xyYToXYZ([xy ; minLum]);
rgb = SensorToSettings(cal,XYZ);
if (min(rgb) < -1e-10)
    error('Min lum needs negative primary');
end
XYZ = xyYToXYZ([xy ; maxLum]);
rgb = SensorToSettings(cal,XYZ);
if (max(rgb) > 1+1e-10)
    error('Max lum needs primary greater than 1');
end
if (minLum > maxLum)
    error('Minimum luminance exceeds maximum luminance');
end
    
%% Inline functions for optimization
% Inline functions have the feature that any variable they use that is
% not defined in the function has its value inherited
% from the workspace of wherever they were invoked.
    function f = InlineMinFunction(Y)
        f = FitMinFunction(Y,cal,xy);
    end

    function f = InlineMaxFunction(Y)
        f = FitMaxFunction(Y,cal,xy);
    end

end

%% Function for min lum
function f = FitMinFunction(Y,cal,xy)

XYZ = xyYToXYZ([xy ; Y]);
rgb = SensorToPrimary(cal,XYZ);
f = min(rgb);

end

%% Function for max lum
function f = FitMaxFunction(Y,cal,xy)

XYZ = xyYToXYZ([xy ; Y]);
rgb = SensorToPrimary(cal,XYZ);
f = 1-max(rgb);

end