function quantizedPrimaries = QuantizePrimaries(primaries,nLevels)
% Quantize[0 1] primariesto nLevels discrete values 
%
% Syntax:
%     quantizedPrimaries = QuantizePrimaries(primaries,nLevels)
%
% Description:
%     Convert [0 nLevels-1] integer values to range [0 1]. Output remains
%     in range [0 1] but only at discrete levels. Useful for simulating
%     what happens on devices of various bit depths.
%
%     Input values outside range [0 1] are truncated into range.
%
% Inputs:
%     primaries              - Matrix with values between 0 and 1.
%     nLevels                - Specifies max of input as nLevels-1
%
% Outputs:
%     quantizedPrimaries      - Quantized values in range [0 1]
%
% Optional key/value pairs:
%   None:
%
% See also: PrimariesToIntegerPrimaries, IntegerPrimariesToPrimaries
%

% History:
%   08/01/20  dhb   Wrote it.

% Examples:
%{
    clear;
    primaries = [0.2 0.3333 1 ; 0 0.84 0.97]
    nLevels = 10;
    quantizedPrimaries = QuantizePrimaries(primaries,nLevels)
%}

quantizedPrimaries = IntegerPrimariesToPrimaries(PrimariesToIntegerPrimaries(primaries,nLevels),nLevels);