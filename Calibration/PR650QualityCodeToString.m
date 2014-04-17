function qualityString = PR650QualityCodeToString(qualityCode)
% PR650QualityCodeToString - Converts a PR-650 quality code to a string.
%
% Syntax:
% qualityString = PR650QualityCodeToString(qualityCode)
%
% Description:
% When making a measurement with the PR-640, a quality code is returned,
% which indicates success, failure, or problems during measurement.  This
% function converts the code into the descriptive string form.  The
% descriptive string forms come from the "PR-650 Operating Manual" on page
% B-30.
%
% Input:
% qualityCode (scalar) - The integer quality code from the measurement.
%
% Output:
% qualityString (string) - The string form of the quality code.

% Check the number of inputs.
error(nargchk(1, 1, nargin));

% Validate the input.
assert(isscalar(qualityCode), 'PR650QualityCodeToString:NonScalarInput', ...
	'Input must be a scalar integer value.');

switch qualityCode
	case 0
		qualityString = 'Measurement okay';
		
	case 1
		qualityString = 'No EOS signal at start of measurement';
		
	case 3
		qualityString = 'No start signal';
		
	case 4
		qualityString = 'No EOS signal to start integration time';
		
	case 5
		qualityString = 'DMA failure';
		
	case 6
		qualityString = 'No EOS after changed to SYNC mode';
		
	case 7
		qualityString = 'Unable to sync to light source';
		
	case 8
		qualityString = 'Sync lost during measurement';
		
	case 10
		qualityString = 'Weak light signal';
		
	case 12
		qualityString = 'Unspecified hardware malfunction';
		
	case 13
		qualityString = 'Software error';
		
	case 14
		qualityString = 'No sample in L*u*v* or L*a*b* calculation';
		
	case 16
		qualityString = 'Adaptive integration taking too much time finding correct integration time indicating possible variable light source';
		
	case 17
		qualityString = 'Main battery is low';
	
	case 18
		qualityString = 'Low light level';
		
	case 19
		qualityString = 'Light level is too high (overload)';
		
	case 20
		qualityString = 'No sync signal';
		
	case 21
		qualityString = 'RAM error';
		
	case 29
		qualityString = 'Corrupted data';
		
	case 30
		qualityString = 'Noisy signal';
		
	otherwise
		error('Unknown quality code: %d', qualityCode);
end
