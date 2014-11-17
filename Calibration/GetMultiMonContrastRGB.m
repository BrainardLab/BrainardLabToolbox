function [minModulationRGBs,maxModulationRGBs] = GetMultiMonContrastRGB(calsRec,backgroundRecs,normDir,contrast)
% [minModulationRGBs,maxModulationRGBs] = GetMultiMonContrastRGB(calsRec,backgroundRecs,normDir,contrast)
%
% Compute the RGB settings required to produce the specified contrast in
% the contrast direction specified by normDir.  This should be normalized
% to have vector length equal to sqrt(nRec).
%
% Contrast magnitude (absolute value) should be less than maximum possible.
% It can be positive or negative.
%
% See also GetMultiMonNeutralBackground, GetMultiMonMaxContrast.
%
% 7/22/09  dhb  Wrote it

% Make sure direction normalized and contrast doesn't violate constraint
if (norm(normDir) ~= sqrt(length(normDir)))
	error('Passed direction is not normalized\n');
end
[maxContrast] = GetMultiMonMaxContrast(calsRec,backgroundRecs,normDir);
if (abs(contrast) > maxContrast)
	error('Requested contrast not within gamut\n');
end

% First step, find the two ends of the modulation in receptor space.  Then
% comptue gamma corrected RGB values that produce the target min and max
% values.
for i = 1:length(calsRec)
	minModulationRecs(:,i) = backgroundRecs(:,i)-contrast*(backgroundRecs(:,i).*normDir);
	maxModulationRecs(:,i) = backgroundRecs(:,i)+contrast*(backgroundRecs(:,i).*normDir);
	minModulationRGBs(:,i) = SensorToSettings(calsRec{i},minModulationRecs(:,i));
	maxModulationRGBs(:,i) = SensorToSettings(calsRec{i},maxModulationRecs(:,i));
end
