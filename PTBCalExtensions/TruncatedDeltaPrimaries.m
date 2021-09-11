function [truncatedDeltaPrimaries,truncatedPrimaries] = TruncatedDeltaPrimaries(deltaPrimaries,primariesUsed,cal)
% OLTruncatedDeltaPrimaries  Figure out truncated delta primaries
%  [truncatedDeltaPrimaries,truncatedPrimaries] = TruncatedDeltaPrimaries(primariesUsed,deltaPrimaries,cal)
%
% Determine what deltaPrimaries will actually be added to primariesUsed,
% given input deltaPrimaries and the fact that the OneLight primaries need
% to go between 0 and 1.

truncatedPrimaries = primariesUsed + deltaPrimaries;
truncatedPrimaries(truncatedPrimaries < 0) = 0;
truncatedPrimaries(truncatedPrimaries > 1) = 1;
truncatedDeltaPrimaries = truncatedPrimaries - primariesUsed;
end