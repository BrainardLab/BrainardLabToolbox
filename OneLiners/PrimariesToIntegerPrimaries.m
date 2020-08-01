function integerPrimaries = PrimariesToIntegerPrimaries(primaries,nLevels)
% Convert [0-1] primaries to [0 nLevels-1] integer values
%
% Syntax:
%     integerPrimaries = PrimariesToIntegerPrimaries(primaries,nLevels)
%
% Description:
%     Convert [0-1] primaries to [0 nLevels-1] integer values. Useful for
%     simulating what happens on devices of various bit depths.
%
%     Input values outside range [0-1] are truncated into range.
%
%     Although returned values are integers, format is double
%
% Inputs:
%     primaries              - Matrix with values between 0 and 1.
%     nLevels                - Number of quantization levels
%
% Outputs:
%     integerPrimaries       - Quantized values between 0 and nLevels-1
%
% Optional key/value pairs:
%   None:
%
% See also: IntegerPrimariesToPrimaries, QuantizePrimaries
%

% History:
%   08/01/20  dhb   Wrote it.

% Examples:
%{
    clear;
    primaries = [0.2 0.3333 1 ; -0.01 0.84 2];
    nLevels = 10;
    integerPrimaries = PrimariesToIntegerPrimaries(primaries,nLevels)
%}

primaries(primaries < 0) = 0;
primaries(primaries > 1) = 1;
integerPrimaries = round((nLevels-1)*primaries);
