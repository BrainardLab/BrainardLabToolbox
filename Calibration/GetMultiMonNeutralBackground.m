function [backgroundRGBs,backgroundRecs,backgroundrgbs] = GetMultiMonNeutralBackground(calsRec,targetFactor)
% [backgroundRGBs,backgroundRecs,backgroundrgbs] = GetMultiMonNeutralBackground(calsRec,targetFactor)
%
% Find a common background near the white point of each monitor, for a set of
% calibrated monitors.  This might be useful if you have a stereo setup
% with two calibrated monitors and want to make sure the same background
% shows up on each.
%
% Algorithm is to figure out which monitor is most limiting in terms of overall
% intensity and use that to set target background, then convert to
% settings.
%
% This produces a decent white point for human viewing, and is probably
% a reasonable choice for neutral for other species in the absence of
% specific info about what 'looks' achromatic to that species.
%
% Passed targetFactor determines max rgb value for the background.
% You might think the natural value to use for the target is 0.5, but monitors
% tend to dim over time, so using a slightly lower value (e.g. 0.45) leaves
% some room to compensate for this over time when the monitor is
% recalibrated.
% 
% % See also GetMultiMonContrastRGB, GetMultiMonMaxContrast.
%
% 7/22/09  dhb Wrote as function from earlier code, generalize to N monitors
%          dhb Don't rely on XYZ, write so that it can work with any sensors.

% Compute monitor midpiont Recs.  In general
% the calibration structure records the ambient light so
% that the min output is not necessarily zero light.
for i = 1:length(calsRec)
    midRecs(:,i) = PrimaryToSensor(calsRec{i},[0.5 0.5 0.5]');
end

% Find mean value across monitors
meanMidRec = mean(midRecs,2);
for i = 1:length(calsRec)
    meanMidrgbs(:,i) = SensorToPrimary(calsRec{i},meanMidRec);
end

% Find the maximum of the linear rgb values, and scale the
% mean mid point so that the maximum linear rgb for the scaled version
% is the targetFactor.
maxOfMeanMidrgbs = max(meanMidrgbs(:));
backgroundRec = targetFactor/maxOfMeanMidrgbs*meanMidRec;

%% Find linear rgb values required to make each monitor have the
% the desired background_XYZ values.  Also compute the gamma
% corrected RGB values and verify by the inverse call that
% we in fact predict the same output for each monitor when
% we use its computed RGB values.
for i = 1:length(calsRec)
    backgroundRecs(:,i) = backgroundRec;
    backgroundrgbs(:,i) = SensorToPrimary(calsRec{i},backgroundRec);
    backgroundRGBs(:,i) = SensorToSettings(calsRec{i},backgroundRec);
end
