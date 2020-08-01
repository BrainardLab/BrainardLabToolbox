function primaries = IntegerPrimariesToPrimaries(integerPrimaries,nLevels)
% Convert [0 nLevels-1] integer values to [0 1] primaries 
%
% Syntax:
%     primaries = IntegerPrimariesToPrimaries(integerPrimaries,nLevels)
%
% Description:
%     Convert [0 nLevels-1] integer values to range [0 1].  Useful for
%     simulating what happens on devices of various bit depths.
%
%     Input values outside range [0 nLevels-1] are truncated into range.
%
% Inputs:
%     primaries              - Matrix of integer values between 0 and nLevels-1
%     nLevels                - Specifies max of input as nLevels-1
%
% Outputs:
%     primaries              - Input values in range [0 1]
%
% Optional key/value pairs:
%   None:
%
% See also: PrimariesToIntegerPrimaries, QuantizePrimaries
%

% History:
%   08/01/20  dhb   Wrote it.

% Examples:
%{
    clear;
    nLevels = 10;
    integerPrimaries = [0 nLevels-1 round(nLevels/2) 2]
    primaries = IntegerPrimariesToPrimaries(integerPrimaries,nLevels)
    integerPrimariesCheck = PrimariesToIntegerPrimaries(primaries,nLevels)
    if (any(integerPrimaries ~= integerPrimariesCheck))
        error('Primary quantization outines do not self invert');
    end
%}

integerPrimaries(integerPrimaries < 0) = 0;
integerPrimaries(integerPrimaries > (nLevels-1)) = nLevels-1;
primaries = double(integerPrimaries)/(nLevels-1);