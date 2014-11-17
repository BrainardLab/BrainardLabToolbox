function  [flickerRate, framesPerCycle] = CheckFlickerRate(flickerRate, monitorFrameRate, stimDuration)
% [flickerRate, framesPerCycle]  = CheckFlickerRate(flickerRate, monitorFrameRate, stimDuration)
%
% Description:
% Verifies that the specified flicker rate will work out to be able to go
% for an integer number of cycles given the duration of the stimulus and a
% specified monitor framerate.  Returns the closest available flicker rate
% that satisifies the criterion.
%
% Input:
% flickerRate (scalar) - The flicker rate that we want. (Hz)
% monitorFrameRate (scalar) - Refresh rate of the monitor. (Hz)
% stimDuration (scalar) - The stimulus duration, i.e. how long we're
%	flickering. (s)
%
% Output:
% flickerRate (scalar) - The adjust flicker rate to suit the monitor and
%	stimulus duration. (Hz)
% framesPerCycle (integer) - The number of frames that constitutes 1 cycle.

if nargin ~= 3
	error('Usage: flickerRate = CheckFlickerRate(flickerRate, monitorFrameRate, stimDuration)');
end

% Generate a list of all valid frame rates.  We do this by dividing
% the framerate by a list of integer numbers since the most
% atomic value we can divide things up by is 1 frame.  We then divide by
% 2 because 1 flash cycle is actually 2 frames.
validFlickerRates = monitorFrameRate ./ (2:2:monitorFrameRate);

% We need to make sure that our flash rate is an integer number
% over the duration of the stimulus
validFlickerRates = validFlickerRates(mod(validFlickerRates * stimDuration, 1) == 0);

if isempty(validFlickerRates)
	error('Could not find any flicker rates that result in an integer number of cycles for the duration specified.');
end

% Check to see if the chosen flash rate is in the valid list.  If
% it isn't, change it for the user and let them know what happened.
[minVal, index] = min(abs(validFlickerRates - flickerRate));
if minVal ~= 0
    safeValue = validFlickerRates(index);
	beep;
    fprintf('\n*** Warning *** Flicker rate of %f is invalid.  Changed to %f.\n', flickerRate, safeValue);
    flickerRate = safeValue;
end

framesPerCycle = monitorFrameRate / flickerRate;
