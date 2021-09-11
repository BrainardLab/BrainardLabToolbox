function [primary, inGamut, gamutMargin] = CheckPrimaryGamut(primary,varargin)
% Check whether primaries are sufficiently in gamut, guarantee return in 0-1
%
% Syntax:
%   truncatedPrimaryValues = OLCheckPrimaryGamut(primaryValues)
%   [truncatedPrimaryValues, inGamut] = OLCheckPrimaryGamut(primaryValues)
%   [truncatedPrimaryValues, inGamut, gamutMargin] = OLCheckPrimaryGamut(primaryValues)
%   [...] = OLCheckPrimaryGamut(...,'differentialMode',true);
%   [...] = OLCheckPrimaryGamut(...,'primaryHeadroom',.005);
%   [...] = OLCheckPrimaryGamut(...,'primaryTolerance',1e-6);
%   [...] = OLCheckPrimaryGamut(...,'checkPrimaryOutOfRange',true);
%
% Description:
%    If primaries are very close to in gamut, truncate to gamut.  If they
%    are too far out of gamut, throw an error.
%
%    This routine respects a set of keyword arguments that are common to
%    many of our routines for finding and dealing with primaries.  These
%    allow it to, for example, enforce headroom as part of what it means
%    to be in gamut. See below for details.
%
%    The purpose of this routine is to check the primaries, but to accept a
%    very small violation of gamut as in gamut.  In cases where the
%    primaries are just a hair out of gamut, it puts them in gamut.  It
%    does not, however, touch input primaries that are out of gamut by more
%    than the primaryTolerance (default 1e-6).
%
%    One reason we need to do this is that some of the underlying search
%    routines (e.g. fmincon) respect their constraints only up to a
%    tolerance, and this routine can be used to handle such cases in a
%    unified manner.
%
%    The inGamut flag refers to whether the passed primaries were within
%    primaryTolerance of being within gamut. That is, the flat state
%    tolerates a small amount of out of gamut before it is set to false.
%
%    Note that primaryTolerance is different from primaryHeadroom.  We used
%    primaryHeadroom (default 0) as a way to use only the central part of
%    the full [0,1] primary gamut. We might want to do this to leave room
%    for spectrum seeking routines to have somewhere to go, for example.
%
% Inputs:
%    primary                  - Numeric matrix (NxM), of primary values to
%                               be checked
%
% Outputs:
%    primary                  - Numeric matrix (NxM) of primary values,
%                               after truncation and check
%    inGamut                  - Boolean scalar. True if passed primaries
%                               were within primaryTolerance of being in
%                               gamut, false if not.  You can only get
%                               false if checkPrimaryOutOfRange is false,
%                               because when that flag is true the same
%                               conditions that would cause this flag to be
%                               false cause an error to be thrown before
%                               return.
%    gamutMargin              - Numeric scalar. Negative if primaries are
%                               in gamut, amount negative tells you
%                               magnitude of margin. Otherwise this is the
%                               magnitude of the largest deviation
%
% Optional keyword arguments:
%    'differentialMode'       - Boolean scalar. If true, allowable gamut
%                               starts at [-1,1] not at [0,1], and then is
%                               adjusted by primaryHeadroom. Default false
%    'primaryHeadroom'        - Numeric scalar.  Headroom to leave on
%                               primaries. How much headroom to protect in
%                               definition of in gamut.  Range used for
%                               check and truncation is [primaryHeadroom
%                               1-primaryHeadroom]. Default 0; do not
%                               change this default
%    'primaryTolerance'       - Numeric scalar. Truncate to range [0,1] if
%                               primaries are within this tolerance of
%                               [0,1]. Default 1e-6; do not change this
%                               default
%    'checkPrimaryOutOfRange' - Boolean scalar. Throw error if primary
%                               (after tolerance truncation) is out of
%                               gamut. When false, the inGamut flag is set
%                               according to the input and the returned
%                               primaries are truncated into gamut no
%                               matter how far out of gamut they were.
%                               Default true; Do not change this default,
%                               Sometimes assumed to be true by a caller
%
% Examples are provided in the source code.
%
% See also: SpdToPrimary, PrimaryInvSolveChrom, FindMaxSpd,
%           PrimaryToSpd.
%

% History:
%   09/11/21  dhb  Wrote from OL version

% Examples:

%{
    %% Out of gamut; throw error
    try
        OLCheckPrimaryGamut(1.1);
    catch e
        disp('Threw an error');
    end
%}
%{
    %% Out of gamut, but within tolerance. Get truncated to gamut.
    [outputPrimary,inGamut,gamutMargin] = OLCheckPrimaryGamut(1+1e-7);

    % Check
    assert(round(outputPrimary,5) == 1);
    assert(inGamut);
    assert(round(gamutMargin,5) == 0);

    %% Out of gamut, but within tolerance. Get truncated to gamut.
    [outputPrimary,inGamut,gamutMargin] = OLCheckPrimaryGamut(1+1e-8,...
        'primaryTolerance',1e-7);

    % Check
    assert(round(outputPrimary,5) == 1);
    assert(inGamut);
    assert(round(gamutMargin,5) == 0);
%}
%{
    %% Out of gamut, but force truncate
    [outputPrimary,inGamut,gamutMargin] = OLCheckPrimaryGamut(1.1,...
        'checkPrimaryOutOfRange',false);

    % Check
    assert(~inGamut);
    assert(round(outputPrimary,5) == 1);
    assert(round(gamutMargin,5) == .1);
%}
%{
    %% Truncate to gamut max
    [outputPrimary,inGamut,gamutMargin] = OLCheckPrimaryGamut(1.01, ...
        'checkPrimaryOutOfRange',false);

    % Check
    assert(round(outputPrimary,5) == 1);
    assert(~inGamut);
    assert(round(gamutMargin,5) == .01);
%}
%{
    %% Truncate to gamut min
    [outputPrimary,inGamut,gamutMargin] = OLCheckPrimaryGamut(-0.01, ...
        'checkPrimaryOutOfRange',false);

    % Check
    assert(round(outputPrimary,5) == 0);
    assert(~inGamut);
    assert(round(gamutMargin,5) == .01);
%}
%{
    %% Truncate to gamut
    [outputPrimary,inGamut,gamutMargin] = OLCheckPrimaryGamut([-0.01 .4 1.005], ...
        'checkPrimaryOutOfRange',false);

    % Check
    assert(all(round(outputPrimary,5) == [0 .4 1]));
    assert(~inGamut);
    assert(round(gamutMargin,5) == .01);
%}
%{
    %% In gamut, but out of headroom. Throw error
    try
        OLCheckPrimaryGamut(.98,'primaryHeadroom',.05);
    catch e
        disp('Threw an error');
    end
%}
%{
    %% Truncate up to headroom
    [outputPrimary,inGamut,gamutMargin] = OLCheckPrimaryGamut(-0.01, ...
        'checkPrimaryOutOfRange',false,'primaryHeadroom',0.005);

    % Check
    assert(round(outputPrimary,5) == 0.005);
    assert(~inGamut);
    assert(round(gamutMargin,5) == .0150);
%}
%{
    %% Truncate down to headroom
    [outputPrimary,inGamut,gamutMargin] = OLCheckPrimaryGamut(1.01, ...
        'checkPrimaryOutOfRange',false,'primaryHeadroom',0.005);

    % Check
    assert(round(outputPrimary,5) == 0.9950);
    assert(~inGamut);
    assert(round(gamutMargin,5) == .0150);
%}

%% Parse input
%
% Don't change defaults.  Some calling routines count on them.
p = inputParser;
p.addParameter('differentialMode', false, @islogical);
p.addParameter('primaryHeadroom', 0, @isscalar);
p.addParameter('primaryTolerance', 1e-6, @isscalar);
p.addParameter('checkPrimaryOutOfRange', true, @islogical);
p.parse(varargin{:});

%% Set up gamut / Handle differential mode
if (p.Results.differentialMode)
    gamutMinMax = [-1 1];
else
    gamutMinMax = [0 1];
end

%% Apply primaryHeadroom by adjusting gamut
% Headroom is effectively just shrinking the gamut
gamutMinMax = gamutMinMax + p.Results.primaryHeadroom * [1 -1];

%% Truncate primaries by gamut tolerance
primary = OLTruncateGamutTolerance(primary,gamutMinMax,p.Results.primaryTolerance);

%% Get gamut margins
gamutMargins = OLGamutMargins(primary(:), gamutMinMax);
gamutMargin = max(-gamutMargins);

%% Check if in gamut, get margin
inGamut = OLCheckPrimaryValues(primary(:), gamutMinMax);

%% Error if necessary
if (p.Results.checkPrimaryOutOfRange && ~inGamut)
    error('At least one primary values is out of gamut');
else
    % In this case, force primaries to be within gamut
    primary = OLTruncatePrimaryValues(primary,gamutMinMax);
end

end