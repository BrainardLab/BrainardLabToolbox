function [spectrumPrimary] = LMSToPrimary(apparatusParams,T,spectrumLMS)
% Get primary weights and spectrum that have passed LMS coordinates
%
% Syntax:
%    [spectrumPrimary] = LMSToPrimary(apparatusParams,T,spectrumLMS)
%
% Description:
%    Get apparatus primary weights to produce spectrum with desired LMS
%    coordinates.
%
%    If you want the spectrum, obtain it as:
%        spectrum = apparatusParams.primaryBasis*spectrumPrimary;
%
% Inputs:
%    apparatusParams                       - Structure describing apparatus.
%    T                                     - Cone fundametals
%    spectrumLMS                           - Target LMS coordinates.
%
% Outputs:
%    spectrumPrimary                       - Spectrum primary weights.
%
% Optional key/value pairs:
%    None.
%
% See also: DefaultApparatusParams, FindMetamer, PrimaryToLMS
%

% History:
%   08/11/19  dhb  Wrote it.

switch (apparatusParams.type)
    case 'monochromatic'
        
        % Get conversion matrices
        M_PrimaryToLMS = T*apparatusParams.primaryBasis;
        
        % Convert
        spectrumPrimary = M_PrimaryToLMS\spectrumLMS;
        
        CHECK = false;
        if (CHECK)
            spectrum = apparatusParams.primaryBasis*spectrumPrimary;
            checkLMS = T*spectrum;
            if (max(abs(checkLMS-spectrumLMS)./spectrumLMS) > 1e-6)
                error('Failed to reproduce desired LMS');
            end
        end
        
    case 'rayleigh'
        % Act like S cones don't exist
        
        % Get conversion matrices
        M_PrimaryToLM = T(1:2,:)*apparatusParams.primaryBasis;
        
        % Convert
        spectrumPrimary = M_PrimaryToLM\spectrumLMS(1:2);
        
        CHECK = false;
        if (CHECK)
            spectrum = apparatusParams.primaryBasis*spectrumPrimary;
            checkLM = T(1:2,:)*spectrum;
            if (max(abs(checkLM-spectrumLM)./spectrumLM) > 1e-6)
                error('Failed to reproduce desired LM');
            end
        end
        
    otherwise
        error('Unknown apparatus type specified in parameter structure');
end


