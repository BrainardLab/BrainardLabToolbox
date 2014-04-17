function [maxContrast,normDir] = GetMultiMonMaxContrast(calsRec,backgroundRecs,contrastDir)
% [maxContrast,normDir] = GetMultiMonMaxContrast(calsRec,backgroundRecs,contrastDir)
% 
% Find the maximum contrast available for a set of monitors in the
% specified contrast direction.  Takes a cell array of cal structures,
% and a matrix of background values specified in the same color space
% as the calibration structures are using.
%
% Contrast specified with respect to a normalized color direction, with
% the convention that 100% contrast for a contrast dir vector ones(nRec,1)
% is the conventional 100% contrast.  So the contrast dir vector should
% have length sqrt(nRec) to make this happen.
%
% See also GetMultiMonContrastRGB, GetMultiMonNeutralBackground.
%
% 7/22/09  dhb  Wrote multi-monitor version.

% Normalize color direction 
nRec = length(contrastDir);
normDir = sqrt(nRec)*contrastDir/norm(contrastDir);

%% Figure out maximum contrast modulation
% available across the monitors.  This is a bit subtle,
% because to do it right you need to make sure to account
% for the ambient light, which may have a chromaticity 
% different from that of the background.  The code below
% accomlishes the trick.

% Here we compute for each monitor the values you'd
% need for the high side of a 100% contrast modulation.  Then
% we find the change in linear rgb values for each monitor needed to 
% acheive this. There is no guarantee that when added to the background
% this modulation leads to rgb values that are in
% the gamut of the monitor.
%
% Then the fiendishly clever routine MaximizeGamutContrast figures out
% just how far you can go in the modulation direction to get right to the
% edge of the gamut. The computation checks in both the positive and negative modulation
% directions.
%
% Because the modulation passed to MaximizeGamutContrast
% corresponds to a 100% contrast modulation (i.e. contrat of 1), the
% returned scalars are in units of contrast.  We take the maximum
% over the three monitors.  This is as much as we can get while still
% keeping all monitors identical in what they do.

% Convert normDir to excitations corresponding to 100% contrast in the
% high direction.  Then compute
for i = 1:length(calsRec)
    normExcitations(:,i) = backgroundRecs(:,i) + normDir.*backgroundRecs(:,i);
    backgroundrgbs(:,i) = SensorToPrimary(calsRec{i},backgroundRecs(:,i));
    targetrgbs(:,i) = SensorToPrimary(calsRec{i},normExcitations(:,i));
    directionrgbs(:,i) = targetrgbs(:,i)-backgroundrgbs(:,i);
    gamutScalars(i) = MaximizeGamutContrast(directionrgbs(:,i),backgroundrgbs(:,i));
end
maxContrast = min(gamutScalars);

end
