function dayDiff = GetCalibrationAge(calOrCalFile)
% dayDiff = GetCalibrationAge(calOrCalFile)
%
% Description:
% Calculates the number of days between now and when the calibration was
% done.
%
% Input:
% cal (struct|string) - Cal struct returned from LoadCalFile or the calibration
%	filename itself.
%
% Output:
% dayDiff (integer) - Number of days passed between now and when the
%	calibration was run.

if nargin ~= 1
	error('Usage: dayDiff = GetCalibrationAge(cal)');
end

if ischar(calOrCalFile)
	cal = LoadCalFile(calOrCalFile);
	
	if isempty(cal)
		error('Could not locate calibration file: "%s"', calOrCalFile);
	end
elseif isstruct(calOrCalFile)
	cal = calOrCalFile;
else
	error('Input must be a calibration file struct or its associated filename.');
end

dayDiff = round(now - datenum(cal.describe.date));
