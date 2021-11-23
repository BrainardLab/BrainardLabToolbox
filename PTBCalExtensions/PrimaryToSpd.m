function predictedSpd = PrimaryToSpd(calOrCalStruct, primary, varargin)
% Predict spectral power distribution from primary values
%
% Syntax:
%   predictedSpd = PrimaryToSpd(calOrCalStruct, calibration);
%   predictedSpd = PrimaryToSpd(calOrCalStruct, calibration, 'differentialMode', true);
%
% Description:
%    Takes in vectors of primary values, and a calibration, and
%    returns the spectral power distribution predicted from the calibration
%    for each vector of primary values.
%
% Inputs:
%    calOrCalStruct - Calibration struct or object
%    primary     - PxN matrix, where P is the number of primaries, and N is
%                  the number of vectors of primary values. Each should be
%                  in range [0-1] for normal mode and [-1,1] for
%                  differential mode (see  below). Those values out of
%                  range are truncated to be in range.
%
% Outputs:
%    predictedSpd - Spectral power distribution(s) predicted from the
%                  primary values and calibration information
%
% Optional key/value pairs:
%    'differentialMode' - Boolean. Do not add in the
%                         dark light and allow primaries to be in range
%                         [-1,1] rather than [0,1]. Default false.
%
% History:
%    09/10/21  dhb  Wrote this from OL version.


%% Parse input
p = inputParser;
p.addRequired('calOrCalStruct');
p.addRequired('primary',@isnumeric);
p.addParameter('differentialMode', false, @islogical);
p.parse(calOrCalStruct,primary,varargin{:});

%% Make sure we have @CalStruct object that will handle all access to the calibration data.
%
% From this point onward, all access to the calibration data is accomplised via the calStructOBJ.
[calStructOBJ, inputArgIsACalStructOBJ] = ObjectToHandleCalOrCalStruct(calOrCalStruct);
if (~inputArgIsACalStructOBJ)
    error('The input (calOrCalStruct) is not a cal struct.');
end

%% Predict spd
%
% Allowable primary range depends on whether differential mode is true or
% not.
if (p.Results.differentialMode)
    predictedSpd = calStructOBJ.get('P_device') * primary;
else
    predictedSpd = calStructOBJ.get('P_device')  * primary + calStructOBJ.get('P_ambient');
end