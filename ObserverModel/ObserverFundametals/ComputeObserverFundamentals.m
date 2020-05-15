function T = ComputeObserverFundamentals(coneParams,S)
% Compute cone fundamentals from cone parameter structure
%
% Syntax:
%     T = ComputeObserverFundamentals(coneParams,S)
%
% Description:
%     Compute cone fundamentals from a structure describing the parameters
%     of a cone fundamentlals model.
%
%     Fundamentals are in energy units and normalized to a max of one.
%
% Inputs:
%     coneParams                      - Structure providing parameters for
%                                       the fundamentals.  See
%                                       DefaultConeParams.
%     S                               - Wavelength sampling, PTB conventions.
% 
% Outputs:
%     T                               - Matrix of fundamentals, PTB matrix
%                                       format with each fundamental in a
%                                       row.
%
% Optional key/value pairs:
%    None.
%
% See also: DefaultConeParams, ObserverParamsToVec, ObserverVecToParams
%

% History:
%   08/10/19  dhb  Wrote it.

% Examples:
%{
    coneParams = DefaultConeParams('cie_asano');
    S = [400 1 301];
    T = ComputeObserverFundamentals(coneParams,S);
	figure; clf; hold on;
    plot(SToWls(S),T(1,:)','r','LineWidth',2);
    plot(SToWls(S),T(2,:)','g','LineWidth',2);
    plot(SToWls(S),T(3,:)','b','LineWidth',2);
    xlabel('Wavelength (nm)');
    ylabel('Fundamental');
%}

switch (coneParams.type)
    case 'cie_asano'
        
        % Get cone spectral sensitivities
        T_quantal = ...
            ComputeCIEConeFundamentals(MakeItS(S),coneParams.fieldSizeDegrees,coneParams.ageYears,coneParams.pupilDiamMM, ...
            [],[],[], ...
            [],[],[],coneParams.indDiffParams);
        T = EnergyToQuanta(S,T_quantal')';
        for ii = 1:3
            T(ii,:) = T(ii,:)/max(T(ii,:));
        end        
     
    otherwise
        error('Unknown cone parameters type passed.');
end

