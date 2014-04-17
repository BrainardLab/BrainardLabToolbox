function [cal,calFileName] = GetCalibrationStructure(prompt,defaultName,defaultWhichCal)
% [cal,calFileName = GetCalibrationStructure(prompt,defaultName,[defaultWhichCal])
% 
% Prompt for a calibration file and pull out a specfic calibration from it.
%
% Mostly useful for diagnostic programs that analyze what is in calibration
% files.
%
% Pass empty matrix to defaultWhichCal get it to prompt you for which calibration.  Pass
% -1 to get most recent calibration.
%
% 4/3/10   dhb  Wrote it.
% 6/10/10  dhb  Add -1 option for defaultWhichCal.
% 10/05/10 dhb  Optional return of filename

% Get calibration file and choose date
calFileName = GetWithDefault(prompt,defaultName);
[cal,cals] = LoadCalFile(calFileName);
if (isempty(cal))
    error('Can''t find calibration file: %s',calFileName);
else
    fprintf('Calibration file %s read\n',calFileName);
end

% Print out available dates
fprintf('Calibration file contains %d calibrations\n',length(cals));
fprintf('Dates:\n');
for i = 1:length(cals)
    fprintf('\tCalibration %d, date %s\n',i,cals{i}.describe.date);
end
    
% Get which to compare
if (isempty(defaultWhichCal))
    defaultWhichCal = length(cals);
end
if (defaultWhichCal ~= -1)

    calIndex = GetWithDefault('Enter number of calibration to use',defaultWhichCal);
else
    calIndex = length(cals);
    fprintf('Using calibration %d\n',calIndex);
end
if (calIndex < 1 || calIndex > length(cals))
    error('Calibration number out of range\n');
end
cal = cals{calIndex};