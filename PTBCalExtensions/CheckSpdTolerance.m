function [spdOK, errorFraction] = CheckSpdTolerance(targetSpd,predictedSpd,varargin)
% Check whether a predicted spd is sufficiently close to its target
%
% Syntax:
%     [spdOK, errorFraction] = CheckSpdTolerance(targetSpd,predictedSpd)  
%
% Description:
%     Compare a target and predicted spd, compute fractional error, and
%     determine whether it is within tolerance.  Can either throw error on
%     failure or just return the factional error along with the Boolean
%     check outcome.
%
%     This routine respects a set of key/value pairs that are common to
%     many of our routines for finding and dealing with primaries.  These
%     allow it to, for example, enforce headroom as part of what it means
%     to be in gamut. See below for details.
%
%     The fracitonal error (aka errorFraction) that is evaluated is:
%       ||targetSpd-predictedSpd||/||targetSpd||
%     This seems as sensible to think about as anything else.
%
% Inputs:
%     targetSpd               - Vector containing a target spd.
%     predictedSpd            - Vector containing predicted spd.  Should be
%                               on same wavelenght samples as target.
%
% Outputs:
%     spdOK                   - Boolean.  True if predicted is within tolerance of 
%                               target.
%     errorFraction           - The fractional error between target and
%                               predicted spds.
% 
% Optional key/value pairs:
%    'checkSpd'               - Boolean (default false). Because of smoothing and
%                               gamut limitations, this is not guaranteed to
%                               produce primaries that lead to the predictedSpd
%                               matching the targetSpd.  Set this to true to check
%                               force an error if difference exceeds tolerance.
%                               Otherwise, the toleranceFraction actually obtained
%                               is retruned. Tolerance is given by spdTolerance.
%    'spdToleranceFraction'   - Scalar (default 0.01). If checkSpd is true, the
%                               tolerance to avoid an error message is this
%                               fraction times the maximum of targetSpd.
%
% See also: SpdToPrimary, PrimaryInvSolveChrom, FindMaxSpd, PrimaryToSpd.
%

% History:
%   09/11/21  dhb  Wrote it from OLVersion

%% Parse input
%
% Don't change defaults.  Some calling routines count on them.
p = inputParser;
p.addParameter('checkSpd', false, @islogical);
p.addParameter('spdToleranceFraction', 0.01, @isscalar);
p.parse(varargin{:});

%% Initialize
spdOK = true;

spdDiff = targetSpd(:)-predictedSpd(:);
errorFraction = norm(spdDiff)/norm(targetSpd(:));
%errorFraction = max(abs(targetSpd(:)-predictedSpd(:)))/max(abs(targetSpd(:)));

if (errorFraction > p.Results.spdToleranceFraction)
    if (p.Results.checkSpd)
        error('Predicted spd not within tolerance of target');
    else
        spdOK = false;
    end
end

end