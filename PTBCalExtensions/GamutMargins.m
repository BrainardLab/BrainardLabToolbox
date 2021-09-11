function gamutMargins = GamutMargins(primaryValues,gamutMinMax)
% Calculate how much room/margin is left in gamut
%
% Syntax:
%   gamutMargins = GamutMargins(primaryValues, gamut)
%
% Description:
%    Compare given primary values to given gamut, and see what the gamut
%    margin is, i.e., how much room between the lowest primary value and
%    the bottom of the gamut, and the highest primary value and the top of
%    the gamut. If primar values are outside of gamut, gamutMargins are
%    negatively signed and indicate the overage.
%
% Inputs:
%    primaryValues - Numeric matrix (NxM), of primary values to be 
%                    truncated
%    gamutMinMax   - Numeric 1x2 vector specifying [min, max] of 
%                    gamut
%
% Outputs:
%    gamutMargins  - 1x2 numeric, distance between min primary and gamut
%                    min, and max primary and gamut max, respectively.
%                    Positive margin indicates primary is within gamut,
%                    negative margin indicates how far value is outside
%                    gamut.
%
% Optional keyword arguments:
%    None.
%
% Examples are provided in the source code.
%
% See also:
%    CheckPrimaryGamut

% History:
%    09/11/21  dhb  Wrote from OL version

% Examples:
%{
    %% [-.9] compared to gamut [-1, 1] has margins [.1, 1.9]
    primaryValues = -.9;
    gamut = [-1 1];
    [~, gamutMargins] = CheckPrimaryValues(primaryValues, gamut);
    assert(all(round(gamutMargins,3) == [.1, 1.9]));
%}
%{
    %% [-.9, .8] compared to gamut [-1, 1] has margins [.1, .2]
    primaryValues = [-.9, .8];
    gamut = [-1 1];
    [~, gamutMargins] = CheckPrimaryValues(primaryValues, gamut);
    assert(all(round(gamutMargins,3) == [.1, .2]));
%}
%{
    %% Adding a non min or max primary value does not affect margins
    primaryValues = [-.9, .8, .5];
    gamut = [-1 1];
    [~, gamutMargins] = CheckPrimaryValues(primaryValues, gamut);
    assert(all(round(gamutMargins,3) == [.1, .2]));
%}

gamut = sort(gamutMinMax); % ensure gamut = [min, max]
primaryValuesMinMax = [min(primaryValues(:)) max(primaryValues(:))];
gamutMargins = [primaryValuesMinMax(1) - gamut(1), gamut(2) - primaryValuesMinMax(2)]; 
end