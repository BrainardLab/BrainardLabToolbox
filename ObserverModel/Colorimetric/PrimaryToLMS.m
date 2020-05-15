function [spectrumLMS,spectrum] = PrimaryToLMS(apparatusParams,T,spectrumPrimary)
% Get LMS coordinates given apparatus and primary weights
%
% Syntax:
%    [spectrumLMS,spectrum] = PrimaryToLMS(apparatusParams,T,spectrumPrimary)
%
% Description:
%    Compute LMS coordinates given apparatus primary weights. Also returns
%    spectrum.
%
% Inputs:
%    apparatusParams                       - Structure describing apparatus.    
%    T                                     - Cone fundametals
%    spectrumPrimary                       - Spectrum primary weights.
%
% Outputs:
%    spectrumLMS                           - Desired LMS coordinates.
%    spectrum                              - Spectrum of metamer
%
% Optional key/value pairs:
%    None.
%
% See also: DefaultApparatusParams, FindMetamer, LMSToPrimary
%

% History:
%   08/11/19  dhb  Wrote it.

% Examples:
%{
    S = [400 1 301];
    spectrumPrimary = [0.5 0.7 0.5]';
    apparatusParams = DefaultMatchApparatusParams('monochromatic',S);
    coneParams = DefaultConeParams('cie_asano');
    T = ComputeObserverFundamentals(coneParams,apparatusParams.S);
    [spectrumLMS,spectrum1] = PrimaryToLMS(apparatusParams,T,spectrumPrimary);
    spectrumPrimaryCheck = LMSToPrimary(apparatusParams,T,spectrumLMS);
    spectrum2 = apparatusParams.primaryBasis*spectrumPrimaryCheck;
    if (max(abs(spectrum1 - spectrum2)) > 1e-8)
        error('Do not recover the same spectrum both ways tried.');
    end
    if (max(abs(spectrumPrimary-spectrumPrimaryCheck)) > 1e-8)
        error('Routines do not properly self-invert');
    end
%}

switch (apparatusParams.type)
    case 'monochromatic'
        
        % Get spectrum
        spectrum = apparatusParams.primaryBasis*spectrumPrimary;
        
        % Get LMS
        spectrumLMS = T*spectrum;
        
    otherwise
        error('Unknown apparatus type specified in parameter structure');
end


