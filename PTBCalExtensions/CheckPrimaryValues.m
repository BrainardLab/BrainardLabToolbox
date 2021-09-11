function [inGamut, gamutMargins] = CheckPrimaryValues(primaryValues,gamutMinMax)
% Check whether primary values are within gamut
%
% Syntax:
%   inGamut = CheckPrimaryValues(primaryValues, gamut)
%   [inGamut, gamutMargins] = CheckPrimaryValues(...)
%
% Description:
%    Compare given primary values to given gamut, and see whether primary
%    values fall completely within gamut, i.e., is the lowest primary value
%    greater than the bottom of the gamut, and the highest primary value
%    lower than the top of the gamut.
%
% Inputs:
%    primaryValues - Numeric matrix (NxM), of primary values to be 
%                    truncated
%    gamutMinMax   - Numeric 1x2 vector specifying [min, max] of 
%                    gamut
%
% Outputs:
%    inGamut       - Boolean scalar, are primary values within gamut
%
% Optional keyword arguments:
%    None.
%
% Examples are provided in the source code.
%
% See also:
%    OLCheckPrimaryGamut, OLGamutMargins

% History:
%    09/11/21  dhb  Wrote from OL version

% Examples:
%{
    %% .9 is in gamut = [0, 1]
    primaryValues = .9;
    gamut = [0 1];
    inGamut = CheckPrimaryValues(primaryValues, gamut);
    assert(inGamut);
%}
%{
    %% 1.1 is not in gamut = [0, 1]
    primaryValues = 1.1;
    gamut = [0 1];
    inGamut = CheckPrimaryValues(primaryValues, gamut);
    assert(~inGamut);
%}
%{
    %% -.9 is not in gamut = [0,1]
    primaryValues = -.9;
    gamut = [0 1];
    inGamut = CheckPrimaryValues(primaryValues, gamut);
    assert(~inGamut);
%}
%{
    %% -.9 is in gamut = [-1,1]
    primaryValues = -.9;
    gamut = [-1 1];
    inGamut = CheckPrimaryValues(primaryValues, gamut);
    assert(inGamut);
%}

%%
gamutMargins = OLGamutMargins(primaryValues,gamutMinMax); 
    
inGamut = all(gamutMargins >= 0);
end