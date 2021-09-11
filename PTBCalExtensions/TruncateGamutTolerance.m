function truncatedPrimaryValues = TruncateGamutTolerance(primaryValues, gamutMinMax, primaryTolerance)
% Truncate primary values towards gamut by no more than specified tolerance
%
% Syntax:
%   truncatedPrimaryValues = TruncateGamutTolerance(primaryValues, gamut, tolerance)
%
% Description:
%    Truncate primary values towards gamut limits, up to specified
%    tolerance. Any primary values in gamut before truncation remain the
%    same; any values out of gamut by up to tolerance are truncated to
%    gamut; any values out of gamut by more than tolerance are truncated by
%    tolerance, but remain out of gamut.
%
%    Generally, we use this function to get rid of small rounding errors.
%
% Inputs:
%    primaryValues          - Numeric matrix (NxM), of primary values to be 
%                             truncated
%    gamutMinMax            - Numeric 1x2 vector specifying [min, max] of 
%                             gamut
%    primaryTolerance       - Numeric Scalar, maximum amount to truncate
%
% Outputs:
%    truncatedPrimaryValues - Numeric matrix (NxM) of primary values, now 
%                             truncated by no more than primaryTolerance.
%                             Any primary values in gamut before truncation
%                             remain the same; any values out of gamut by
%                             up to tolerance are truncated to gamut; any
%                             values out of gamut by more than tolerance
%                             are truncated by tolerance, but remain out of
%                             gamut.
% 
% Optional keyword arguments:
%    None.
%
% Examples are provided in the source code.
%
% See also:
%    TruncatePrimaryValues, CheckPrimaryValues, CheckPrimaryGamut

% History:
%    09/11/21  dhb  Wrote from OL version

% Examples:
%{
    %% Truncate value smaller than tolerance; truncates to gamut
    primaryValues = 1+1e-6;
    primaryTolerance = 1e-5;
    gamut = [0 1];
    truncatedPrimaryValues = TruncateGamutTolerance(primaryValues,...
    gamut, primaryTolerance);
    assert(truncatedPrimaryValues == 1);
%}
%{
    %% Truncate value smaller than tolerance; truncates to gamut
    primaryValues = 0-1e-6;
    primaryTolerance = 1e-5;
    gamut = [0 1];
    truncatedPrimaryValues = TruncateGamutTolerance(primaryValues,...
    gamut, primaryTolerance);
    assert(truncatedPrimaryValues == 0);
%}
%{
    %% Truncate value smaller than tolerance; truncates to gamut
    primaryValues = -1-1e-6;
    primaryTolerance = 1e-5;
    gamut = [-1 1];
    truncatedPrimaryValues = TruncateGamutTolerance(primaryValues,...
    gamut, primaryTolerance);
    assert(truncatedPrimaryValues == -1);
%}
%{
    %% Truncate value larger than tolerance; truncates by tolerance
    primaryValues = 1+1e-4;
    primaryTolerance = 1e-5;
    gamut = [0 1];
    truncatedPrimaryValues = TruncateGamutTolerance(primaryValues,...
    gamut, primaryTolerance);
    assert(round(truncatedPrimaryValues,6) == 1+(1e-4)-(1e-5));
%}
%{
    %% Truncate value larger than tolerance; truncates by tolerance
    primaryValues = 0-1e-4;
    primaryTolerance = 1e-5;
    gamut = [0 1];
    truncatedPrimaryValues = TruncateGamutTolerance(primaryValues,...
    gamut, primaryTolerance);
    assert(round(truncatedPrimaryValues,6) == 0-(1e-4)+(1e-5));
%}
%{
    %% Primary value initially in gamut remains unaffected
    primaryValues = .5;
    primaryTolerance = 1e-5;
    gamut = [0 1];
    truncatedPrimaryValues = TruncateGamutTolerance(primaryValues,...
    gamut, primaryTolerance);
    assert(truncatedPrimaryValues == primaryValues)
%}
%{
    %% Truncate both top and bottom, in and out of gamut:
    primaryValues = [.9 1.04 1.1 .1 -.04 -.1];
    primaryTolerance = .05;
    gamut = [0 1];
    truncatedPrimaryValues = TruncateGamutTolerance(primaryValues,...
    gamut, primaryTolerance);
    assert(all(round(truncatedPrimaryValues,7) == [.9 1 1.05 .1 0 -.05]));
%}

%% Sort gamutMinMax
% ensure gamut = [min, max]
gamutMinMax = sort(gamutMinMax);

%% Truncate
% Top of gamut
primaryErrorTop = (max(primaryValues - gamutMinMax(2),0));
truncatedErrorTop = (min(primaryErrorTop, primaryTolerance));
primaryValues = primaryValues - truncatedErrorTop;

% Bottom of gamut
primaryErrorBottom = (min(primaryValues - gamutMinMax(1),0));
truncatedErrorBottom = (max(primaryErrorBottom, -primaryTolerance));
primaryValues = primaryValues - truncatedErrorBottom;

%% Return
truncatedPrimaryValues = primaryValues;
end