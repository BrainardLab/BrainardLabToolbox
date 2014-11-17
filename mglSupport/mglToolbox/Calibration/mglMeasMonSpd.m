function [spd,S] = mglMeasMonSpd(settings, S, syncMode, whichMeterType,usebitspp, bitsppClut)
% [spd,S] = mglMeasMonSpd(settings, [S], [syncMode], [whichMeterType], [usebitspp, bitsppClut])
%
% Measure the Spd of a series of monitor settings.
%
% This routine is specific to go with CalibrateMon,
% as it depends on the action of SetMon. 
%
% If whichMeterType is passed and set to 0, then the routine
% returns random spectra.  This is useful for testing when
% you don't have a meter.
%
% Other valid types:
%  1 - Use PR650 (default)
%  2 - Use CVI (not implemented)
%  4 - Use PR655
%  5 - Use PR670
%
% 10/26/93  dhb	    Wrote it based on ccc code.
% 11/12/93  dhb	    Modified to use SetColor.
% 8/11/94	dhb	    Sync mode.
% 8/15/94   dhb	    Sync mode as argument, allow S to be [] for default.
% 4/12/97   dhb     New toolbox compatibility, take window and bits args.
% 8/26/97   dhb     pbe Add noMeterAvail arg.
% 4/7/99    dhb     Add argument for radius board. Compact default arg code.
% 8/14/00   dhb     Call to CMETER('SetParams') conditional on OS9.
% 8/20/00   dhb     Remove bits arg to SetColor.
% 8/21/00   dhb     Remove dependence on RADIUS flag.  This is now handled inside of SetColor.
%	        dhb     Change calling conventions to remove unused args.
% 9/14/00   dhb     Sync mode is not actually used.  Arg still passed for backwards compat.
% 2/27/02   dhb     Change noMeterAvail to whichMeterType.
% 11/29/09  dhb     Bye-bye globals
% 2/13/10   dhb     Pass HDRProjector switch
%           dhb     Improve optional arg checking
% 4/21/10   dhb     HDRProjector now takes multiple values. 0 -> normal, 1 -> yoked.
% 4/23/10   dhb, ar Added options for HDRProjector value 2 (not yoked)
% 5/25/10   dhb, ar Liberate ourselves from HDRProjector.
% 8/26/10   dhb     Put a try/catch around MeasSpd.  Do a dump to a .mat file on error.
% 3/9/11    dhb     Sync mode actually does something.  Default on.  Pass meter type to MeasSpd
% 6/7/12    dhb     Comment out dump on error.  Can uncomment if you find yourself trying to debug what is
%                   causing fatal radiometer errors.
% 4/11/13   dhb     Allow for meter types 4 and 5.

% Check args and make sure window is passed right.
usageStr = 'Usage: [spd,S] = mglMeasMonSpd(settings, [S], [syncMode], [whichMeterType], [usebitspp], [bitsppClut])';
if nargin < 1 || nargin > 6 || nargout > 2
	error(usageStr);
end

% Set defaults
defaultS = [380 5 81];
defaultSync = 'on';
defaultWhichMeterType = 1;
defaultUsebitspp = 0;

% Check args and set defaults
if nargin < 6 || isempty(bitsppClut)
	bitsppClut = [];
end
if nargin < 5 || isempty(usebitspp)
	usebitspp = defaultUsebitspp;
end
if nargin < 4 || isempty(whichMeterType)
	whichMeterType = defaultWhichMeterType;
end
if nargin < 3 || isempty(syncMode)
	syncMode = defaultSync;
end
if nargin < 2 || isempty(S)
	S = defaultS;
end

% Get the current gamma table.
if usebitspp
    theClut = bitsppClut;
else
	gTable = mglGetGammaTable;
	theClut = [gTable.redTable', gTable.greenTable', gTable.blueTable'];
end

[nil, nMeas] = size(settings); %#ok<ASGLU>
spd = zeros(S(3), nMeas);
for i = 1:nMeas
    useSettings = settings(:,i)';
    
    % Measure spectrum
    switch whichMeterType
        case 0
            theClut(2,:) = useSettings;
            if usebitspp
                mglBitsPlusSetClut(theClut);
			else
				mglSetGammaTable(theClut');
            end
            spd(:,i) = sum(useSettings) * ones(S(3), 1);
            WaitSecs(.1);
        case {1,4,5}
            theClut(2,:) = useSettings;
            if usebitspp
                mglBitsPlusSetClut(theClut);
			else
				mglSetGammaTable(theClut');
            end
            try
                spd(:,i) = MeasSpd(S,whichMeterType,syncMode);
            catch theMsg
                %save mglMeasMonSpdDump
                rethrow(theMsg);
            end
        case 2
            error('CVI interface not yet ported.');
            % cviCal = LoadCVICalFile;
            % spd(:,i) =  CVICalibratedDarkMeasurement(cviCal, S, [], [], [], ...
            % 	window, 1, useSettings');
        otherwise
            error('Invalid meter type set');
    end
end
