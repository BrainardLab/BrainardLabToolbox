function [spd, S] = mglMeasMondrianHDRSpd(settings, cal, S, syncMode, whichMeterType)
% [spd, S] = mglMeasMondrianHDRSpd(settings, cal, [S], [syncMode], [whichMeterType])
%
% Measure the Spd of a series of monitor settings.
%
% This routine is specific to go with CalibrateMon,
% as it depends on the action of SetMon. 
%
% If whichMeterType is passed and set to 0, then the routine
% returns random spectra.  This is useful for testing when
% you don't have a meter.
%
%
% Other valid types:
%  1 - Use PR650 (default)
%  2 - Use CVI (not implemented)
%  4 - Use PR655
%  5 - Use PR670
%
% 7/12/2010 cgb, ar Adapted it from mglMeasMonSpd so it can work without using a look-up table.
% 4/1/13    dhb     Handle PR-655 and PR-670.

% Check args and make sure window is passed right.
usageStr = 'Usage: [spd,S] = mglMeasMonSpd(settings, cal, [S], [syncMode], [whichMeterType])';
if nargin < 2 || nargin > 5 || nargout > 2
	error(usageStr);
end

% Set defaults
defaultS = [380 5 81];
defaultSync = 0;
defaultWhichMeterType = 1;

% Setup defaults if the input arguments were missing or empty.
if ~exist('whichMeterType', 'var') || isempty(whichMeterType)
	whichMeterType = defaultWhichMeterType;
end
if ~exist('S', 'var') || isempty(S)
	S = defaultS;
end
if ~exist('syncMode', 'var') || isempty(syncMode)
	syncMode = defaultSync;
end

[nil, nMeas] = size(settings); %#ok<ASGLU>
spd = zeros(S(3), nMeas);
for i = 1:nMeas
    useSettings = settings(:,i)';
    
    % Measure spectrum
    switch whichMeterType
        case 0
			DrawMondrianHDRStimulus(cal, useSettings);
            spd(:,i) = sum(useSettings) * ones(S(3), 1);
            WaitSecs(.1);
        case {1, 4 5}
            DrawMondrianHDRStimulus(cal, useSettings);
            spd(:,i) = MeasSpd(S,whichMeterType);
        case 2
            error('CVI interface not yet ported.');
            % cviCal = LoadCVICalFile;
            % spd(:,i) =  CVICalibratedDarkMeasurement(cviCal, S, [], [], [], ...
            % 	window, 1, useSettings');
        otherwise
            error('Invalid meter type set');
    end
end
