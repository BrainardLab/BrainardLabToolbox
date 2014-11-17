function [data,wls,S] = GetCVRLData(theName,wlSpacing,theUnits)
% [data,wls,S] = GetCVRLData(theName,[wlSpacing],[theUnits])
%
% Get spectral data from CVRL database.  This function connects
% to the CVRL database (http://www.cvrl.org) and downloads
% the requested spectral function.
%
% The data are provided in the returned matrix data.  The wavelength
% sampling info is provided in two forms:
%   wls - The column vector wls provides the wavelengths as a list.
%   S   - The 3 by 1 row vector S specifies [start delta number_of_samples],
%         with start and delta in nm.
% You can convert back and forth with Psychtoolbox functions SToWls and
% WlsToS.
%
% CVRL provides functions at 5 nm, 1 nm or 0.1 nm spacing, although
% not all spacings are provided for all data. You can specify which of
% these three spacings you want. If the particular function you ask for
% isn't supported at that spacing on CVRL, this routine splines to the
% requested spacing.
%
% CVRL provides functions as energy sensitivities, log10 energy
% sensitivities, or log10 quantal sensitivities, although not all formats
% are provided for all data.  You can specify which format you want.  If
% the particualr function you ask for isn't supported in the units you request,
% this routine will do the conversion.
%
% Options for theName (pass as a string):
%   Cone fundamentals (returned in 3 rows of data, L, M, and S)
%     cie2007_2     - CIE (2007) 2-deg (same as ss2)
%     cie2007_10    - CIE (2007) 10-deg (same as ss10)
%     ss2           - Stockman & Sharpe (2000) 2-deg, based on Stiles and Burch 10-deg CMFs
%     ss10          - Stockman & Sharpe (2000) 10-deg, based on Stiles and Burch 10-deg CMFs
%     smj2_10       - Stockman, MacLeod, & Johnson (1993) 2-deg, based on CIE 10-deg CMFs
%     sjm10         - Stockman, MacLeod, & Johnson (1993) 10-deg, based on CIE 10-deg CMFs
%     smj2          - Stockman, MacLeod, & Johnson (1993), based on the Stiles and Burch 2-deg CMFs
%     vew           - Vos, Estevez, & Walraven (1990) 2-deg, based on Stiles and Burch 2-deg CMFs
%     vw            - Vos & Walraven (1971) 2-deg, based on CIE Judd-Vos 2-deg CMFs
%     sp            - Smith & Pokorny (1975) 2-deg, based on CIE Judd-Vos 2-deg CMFs
%     dps           - DeMarko, Pokorny, and Smith (1992) version of sp, 2-deg, based on CIE Judd-Vos 2-deg CMFs
%
% Options for wlSpacing (pass as a number):
%   5             - 5   nm spacing [default]
%   1             - 1   nm spacing
%   0.1           - 0.1 nm spacing
%
% Options for units (pass as a string):
%  'energy'         - Energy units [default]
%  'logenergy'      - Log10 energy units
%  'logquanta'      - Log10 quantal units
%
% This routine relies on fucntions in the Psychophysics Toolobox.  See
% http://psychtoolbox.org, from which you can download it free of charge.
%
% 1/2/10 dhb  Wrote initial version

% Fill in wavelength spacing
if (nargin < 2 || isempty(wlSpacing))
    wlSpacing = 5;
end
switch (wlSpacing)
    case {5}
        spacingStr = '5';
    case {1}
        spacingStr = '1';
    case {0.1}
        spacingStr = 'fine';
    otherwise
        error('Unsupported wavelength spacing %d specified',wlSpacing);
end

% Fill in units
if (nargin < 3 || isempty(theUnits))
    theUnits = 'energy';
end
switch (theUnits)
    case {'energy', 'logenergy', 'logquanta'}
    otherwise
        error('Unsupported units %s specified',theUnits);
end

% Set up the right name and options.  This needs to match the CVRL website, and
% there are lots of special cases that are handled here.
switch (theName)
    case {'cie2007_2', 'ss2'}
        theURL = 'http://www.cvrl.org/conerequest_ss2.php';
        params = {'Cone_units',theUnits,'Cone_steps',spacingStr,'Cone_format','csv','Submit','Submit'};
        
    case {'cie2007_10', 'ss10'}
        theURL = 'http://www.cvrl.org/conerequest_ss10.php';
        params = {'Cone_units',theUnits,'Cone_steps',spacingStr,'Cone_format','csv','Submit','Submit'};
        
    case 'smj2_10'
        theURL = 'http://www.cvrl.org/offercsvcones.php';
        switch (theUnits)
            case {'energy', 'logenergy'}
                params = {'whichfile','smj2_10.csv','Submit','Submit'};
            case {'logquanta'}
                params = {'whichfile','smj2_10q.csv','Submit','Submit'};
        end
        
    case 'smj10'
        theURL = 'http://www.cvrl.org/offercsvcones.php';
        switch (theUnits)
            case {'energy', 'logenergy'}
                params = {'whichfile','smj10.csv','Submit','Submit'};
            case {'logquanta'}
                params = {'whichfile','smj10q.csv','Submit','Submit'};
        end
        
    case 'smj2'
        theURL = 'http://www.cvrl.org/offercsvcones.php';
        switch (theUnits)
            case {'energy', 'logenergy'}
                params = {'whichfile','smj2.csv','Submit','Submit'};
            case {'logquanta'}
                params = {'whichfile','smj2q.csv','Submit','Submit'};
        end
        
    case 'vew'
        theURL = 'http://www.cvrl.org/offercsvcones.php';
        switch (theUnits)
            case {'energy', 'logenergy'}
                params = {'whichfile','vew.csv','Submit','Submit'};
            case {'logquanta'}
                params = {'whichfile','vewq.csv','Submit','Submit'};
        end
        
    case 'vw'
        theURL = 'http://www.cvrl.org/offercsvcones.php';
        switch (theUnits)
            case {'energy', 'logenergy'}
                params = {'whichfile','vw.csv','Submit','Submit'};
            case {'logquanta'}
                params = {'whichfile','vwq.csv','Submit','Submit'};
        end
        
    case 'sp'
        theURL = 'http://www.cvrl.org/offercsvcones.php';
        switch (theUnits)
            case {'energy', 'logenergy'}
                params = {'whichfile','sp.csv','Submit','Submit'};
            case {'logquanta'}
                params = {'whichfile','spq.csv','Submit','Submit'};
        end
        
    case 'dps'
        theURL = 'http://www.cvrl.org/offercsvcones.php';
        switch (wlSpacing)
            case 5
                params = {'whichfile','dpse.csv','Submit','Submit'};
            case {1, 0.1}
                params = {'whichfile','dpse_1.csv','Submit','Submit'};
        end
        
    otherwise
        error('Unknown data name %s',theName);
end

%% Get the data from CVRL
[theCSV,status] = urlread(theURL,'POST',params);

%% If call worked, translated returned text string to
% the requested format
if (status == 1)
    % Convert CSV data to data,wls,S format used by Psychtoolbox
    switch (theName)
        case {'cie2007_2', 'ss2', 'cie2007_10', 'ss10', 'smj2_10', 'smj10', ...
                'smj2', 'vew', 'vw', 'sp' 'dps'}
            theRawData = textscan(theCSV,'%n%n%n%n','Delimiter',',','CollectOutput',true);
            wls = theRawData{1}(:,1);
            S = WlsToS(wls);
            data = theRawData{1}(:,2:end)';
        otherwise
            error('Internal inconsistency in available data name');
    end
    
    % Postprocessing for cases where the CVRL page doesn't provide data in
    % requested format.
    switch (theName)
        % These functions are provided at 5 nm spacing in log energy
        % and log quantal units.  Need to convert to linear energy 
        % if that is specified, and also spline to spacings other than
        % 5 nm.
        case {'smj2_10', 'smj10','smj2', 'vew', 'vw', 'sp'}
            switch (theUnits)
                % Convert to energy, and replace NaN's by 0.
                case {'energy'}
                    data = 10.^data;
                    data(isnan(data)) = 0;
            end
            
            switch (wlSpacing)
                case {1, 0.1}
                    minWl = min(wls);
                    maxWl = max(wls);
                    newWls = (minWl:wlSpacing:maxWl)';
                    newS = WlsToS(newWls);
                    data = SplineCmf(S,data,newS);
                    S = newS;
                    wls = newWls;
            end
        
        % These functions are given in log energy units at 5 nm and 1 nm
        % spacing.  Need to convert to energy or log quantal units, and
        % spline if 0.1 spacing is requested
        case {'dps'}
            switch (theUnits)
                % Convert to energy, and replace NaN's by 0.
                case {'energy'}
                    data = 10.^data;
                    data(isnan(data)) = 0;
                    
                % Convert to log quantal units.
                % Note that although we are converting quantal sensitivities
                % to energy sensitivities, we call Psychtoolbox routine QuantaToEnergy.
                % That's because the toolbox routine is specified with respect to spectra,
                % and the conversion for sensitivities is the inverse of the conversion
                % for spectra.
                case {'logquanta'}
                    data = log10(QuantaToEnergy(wls,10.^data')');
                    for i = 1:3
                        data(i,:) = data(i,:)-max(data(i,:));
                    end
            end
           
            % Spline to 0.1 spacing if requested
            switch (wlSpacing)
                case 0.01;
                    minWl = min(wls);
                    maxWl = max(wls);
                    newWls = (minWl:wlSpacing:maxWl)';
                    newS = WlsToS(newWls);
                    data = SplineCmf(S,data,newS);
                    S = newS;
                    wls = newWls;
            end
        
        % For these, CVRL supplies requested format.  Just need to handle
        % NaN for energy unit case, where we replace them by 0.
        otherwise
            % For energy units replace NaN's by 0.
            switch (theUnits)
                case {'energy'}
                    data(isnan(data)) = 0;    
            end
    end
    
%% Call to web failed. Handle
else
    error('Web read failed with error %d',status');
end
