function [T_energyNormalized,T_quantalIsomerizations,nominalLambdaMax] = GetHumanPhotopigmentSS(S, photoreceptorClasses, fieldSizeDegrees, ageInYears, pupilDiameterMm, lambdaMaxShift, fractionPigmentBleached)
% [T_energyNormalized,T_quantalIsomerizations,nominalLambdaMax] = GetHumanPhotopigmentSS(S, photoreceptorClasses, fieldSizeDegrees, ageInYears, pupilDiameterMm, lambdaMaxShift, fractionPigmentBleached)
%
% Produces photopigment sensitivities that we often need, and allowing
% variation in age and lambda-max.  T_energyNormalized are the sensitivities
% in energy units, normalized to max of 1.  T_quantalIosmerizations are the
% probability of an isomerization for quantal unit input.
%
% If empty variables are passed for any of the following variables,
% defaults will be assumed.
%
% Input:
%   S (1x3)                         - Wavelength spacing.
%                                     Default: [380 2 201]
%   photoreceptorClasses (cell)     - Cell with names of photoreceptor classes.
%                                     Supported options: 'LCone', 'MCone', 'SCone', 'Melanopsin', 'Rods', ...
%                                                        'LConeR+2', 'LConeR-2', 'MConeR+2', 'MConeR-2', 'SConeR+2', 'SConeR-2', ...
%                                                        'MelanopsinR+2', 'MelanopsinR-2', 'RodsR+2', 'RodsR-2', ...
%                                                        'LCone10DegTabulatedSS', 'MCone10DegTabulatedSS', 'SCone10DegTabulatedSS', ...
%                                                        'MelanopsinLegacy', 'RodsLegacy', 'CIE1924VLambda'. ...
%                                                        'LConeHemo', 'MConeHemo', 'SConeHemo'
%                                     Default: {'LCone' ; 'MCone' ; 'SCone'}
%   fieldSizeDegrees (1x1)          - Field size in degrees.
%                                     Default: 10
%   ageInYears (1x1)                - Observer age in years.
%                                     Default: 32
%   pupilDiameterMm (1x1)           - Pupil diameter in mm.
%                                     Default: 3
%   lambdaMaxShift (1x1)            - Shift of lambda-max.
%                                     Default: 0
%   fractionPigmentBleached         - Fraction of pigment bleached.
%                                     Default: 0
%
% Output:
%   T_energyNormalized              - Spectral sensitivities in energy
%                                     units (normalized to max.).
%   T_quantaIsomerization           - Spectral sensitivities in quanta
%                                     units.  These may be used to compute
%                                     isomerizations from retinal illuminance
%   nominalLambdaMax                - Peak of photopigment spectral sensitivities.
%
% NOTES:
%   a) The R+2 and R-2 variants shift lambda max +/- 2nm from nominal value.  This is on top of any omnibus shift
%   passed in scalar lambdaMaxShift.
%   b) The Hemo variants take into account an estimate of the absorption spectrum of hemoglobin as seen through retinal
%   blood vessels.
%   c) Not all variants have a meaningful T_quantalIsomerizations variable returned.  When we don't have that sensitivity
%   easily, a vector of NaN's of the right size is returned instead.
%
% 1/21/14   ms    Wrote it based on old code.
% 5/24/14   dhb   Remove vestigal references to a returned labels variable.
% 5/26/14   dhb   Fix bug: 'Melanopsin-2' was being computed with a shift of -1.
%           dhb   Simplify return interface.  Add many comments.
%           dhb   Return isomerization sensitivities for hemoglobin variants.

% Check if all variables have been passed with a value, fill in defaults in
% cases where empty passed.
if isempty(S)
    S = [380 2 201];
end

if isempty(photoreceptorClasses)
    photoreceptorClasses = {'LCone' ; 'MCone' ; 'SCone'};
end

if isempty(fieldSizeDegrees)
    fieldSizeDegrees = 10;
end

if isempty(ageInYears)
    ageInYears = 32;
end

if isempty(pupilDiameterMm)
    pupilDiameterMm = 3;
end

if isempty(lambdaMaxShift)
    lambdaMaxShift = 0;
end

if (isempty(fractionPigmentBleached)) && length(photoreceptorClasses) > 1
    fractionPigmentBleached = zeros(3,1);
elseif (isempty(fractionPigmentBleached)) && length(photoreceptorClasses) == 1
    fractionPigmentBleached = 0;
end

% If the passed observer age is <20 or >80, we assume that the observer is
% 20, and 80, which are the maximum ages given by the CIE standard.
if ageInYears < 20
    ageInYears = 20;
    fprintf('Observer age truncated at 20\n');
end

if ageInYears > 80
    ageInYears = 80
    fprintf('Observer age truncated at 80\n');
end

% Assign empty vectors
T_quanta = [];
T_energyNormalized = [];
T_quantalIsomerizations = [];
nominalLambdaMax = [];

% The fractionPigmentBleached vectors come in the same dimensions as
% photoreceptors. However, ComputeCIEConeFundamentals expects LMS triplets.
% So, we sort out the hemo vs. non-hemo fractions. We do that because we do
% not know the order of photopigment classes passed into this function. In
% case we only have one cone type passed, which sometimes happens, we
% still extract the triplet of fractions of pigment bleached, under the
% assumption that in the input vector, the order is LMS. This is a bit
% kludge-y, but works.
if length(photoreceptorClasses) > 1
    for i = 1:length(photoreceptorClasses)
        switch photoreceptorClasses{i}
            case 'LCone'
                fractionBleachedFromIsom(1) = fractionPigmentBleached(i);
            case 'MCone'
                fractionBleachedFromIsom(2) = fractionPigmentBleached(i);
            case 'SCone'
                fractionBleachedFromIsom(3) = fractionPigmentBleached(i);
            case 'LConeHemo'
                fractionBleachedFromIsomHemo(1) = fractionPigmentBleached(i);
            case 'MConeHemo'
                fractionBleachedFromIsomHemo(2) = fractionPigmentBleached(i);
            case 'SConeHemo'
                fractionBleachedFromIsomHemo(3) = fractionPigmentBleached(i);
        end
    end
    % If only one cone class is passed, which can happen in splatter
    % calculations, we set the fraction pigment bleached for the pigments that
    % are not passed to be 0. This is because PTB machinery expects triplets.
elseif length(photoreceptorClasses) == 1
    switch photoreceptorClasses{1}
        case 'LCone'
            fractionBleachedFromIsom(1) = fractionPigmentBleached;
            fractionBleachedFromIsom(2) = 0;
            fractionBleachedFromIsom(3) = 0;
        case 'MCone'
            fractionBleachedFromIsom(1) = 0;
            fractionBleachedFromIsom(2) = fractionPigmentBleached;
            fractionBleachedFromIsom(3) = 0;
        case 'SCone'
            fractionBleachedFromIsom(1) = 0;
            fractionBleachedFromIsom(2) = 0;
            fractionBleachedFromIsom(3) = fractionPigmentBleached;
        case 'LConeHemo'
            fractionBleachedFromIsomHemo(1) = fractionPigmentBleached;
            fractionBleachedFromIsomHemo(2) = 0;
            fractionBleachedFromIsomHemo(3) = 0;
        case 'MConeHemo'
            fractionBleachedFromIsomHemo(1) = 0;
            fractionBleachedFromIsomHemo(2) = fractionPigmentBleached;
            fractionBleachedFromIsomHemo(3) = 0;
        case 'SConeHemo'
            fractionBleachedFromIsomHemo(1) = 0;
            fractionBleachedFromIsomHemo(2) = 0;
            fractionBleachedFromIsomHemo(3) = fractionPigmentBleached;
    end
end

% Transpose if we can. We do this because the PTB machinery expects this.
if exist('fractionBleachedFromIsom', 'var')
    fractionBleachedFromIsom = fractionBleachedFromIsom';
end

if exist('fractionBleachedFromIsomHemo', 'var')
    fractionBleachedFromIsomHemo = fractionBleachedFromIsomHemo';
end

%% Iterate over the photoreceptor classes that have been passed.
for i = 1:length(photoreceptorClasses)
    theClass = photoreceptorClasses{i};
    switch theClass
        case 'LCone'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7]';
            
            %% Construct cones, pull out L cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsom);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(1,:)];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(1,:)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(1)];
        case 'MCone'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7]';
            
            %% Construct cones, pull out M cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsom);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(2,:)];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(2,:)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(2)];
        case 'SCone'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7];
            
            %% Construct cones, pull out S cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsom);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(3,:)];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(3,:)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(3)];
        case {'Melanopsin'}
            % Melanopsin
            photoreceptors = DefaultPhotoreceptors('LivingHumanMelanopsin');
            photoreceptors.nomogram.S = S;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax+lambdaMaxShift;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees;
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; photoreceptors.energyFundamentals];
            T_quantalIsomerizations = [T_quantalIsomerizations ; photoreceptors.isomerizationAbsorptance];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];
        case 'Rods'
            % Rods
            photoreceptors = DefaultPhotoreceptors('LivingHumanRod');
            photoreceptors.nomogram.S = S;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax+lambdaMaxShift;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees;
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; photoreceptors.energyFundamentals];
            T_quantalIsomerizations = [T_quantalIsomerizations ; photoreceptors.isomerizationAbsorptance];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];
            
        case 'LConeR+2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9+2 530.3 420.7]';
            
            %% Construct cones, pull out L cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsom);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(1,:)];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(1,:)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(1)];
        case 'LConeR-2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9-2 530.3 420.7]';
            
            %% Construct cones, pull out L cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsom);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(1,:)];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(1,:)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(1)];
        case 'MConeR+2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3+2 420.7]';
            
            %% Construct cones, pull out M cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsom);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(2,:)];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(2,:)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(2)];
        case 'MConeR-2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3-2 420.7]';
            
            %% Construct cones, pull out M cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsom);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(2,:)];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(2,:)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(2)];
        case 'SConeR+2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7+2];
            
            %% Construct cones, pull out S cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsom);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(3,:)];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(3,:)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(3)];
        case 'SConeR-2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7-2];
            
            %% Construct cones, pull out S cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsom);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(3,:)];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(3,:)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(3)];
        case 'MelanopsinR-2'
            %% Melanopsin
            photoreceptors = DefaultPhotoreceptors('LivingHumanMelanopsin');
            % Override fields
            photoreceptors.nomogram.S = S;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax-2;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax+lambdaMaxShift;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees;
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; photoreceptors.energyFundamentals];
            T_quantalIsomerizations = [T_quantalIsomerizations ; photoreceptors.isomerizationAbsorptance];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];
        case 'MelanopsinR+2'
            %% Melanopsin
            photoreceptors = DefaultPhotoreceptors('LivingHumanMelanopsin');
            % Override fields
            photoreceptors.nomogram.S = S;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax+2;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax+lambdaMaxShift;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees;
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; photoreceptors.energyFundamentals];
            T_quantalIsomerizations = [T_quantalIsomerizations ; photoreceptors.isomerizationAbsorptance];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];
        case 'RodsR-2'
            %% Rods
            photoreceptors = DefaultPhotoreceptors('LivingHumanRod');
            % Override fields
            photoreceptors.nomogram.S = S;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax-2;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax+lambdaMaxShift;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees;
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; photoreceptors.energyFundamentals];
            T_quantalIsomerizations = [T_quantalIsomerizations ; photoreceptors.isomerizationAbsorptance];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];
        case 'RodsR+2'
            %% Rods
            photoreceptors = DefaultPhotoreceptors('LivingHumanRod');
            % Override fields
            photoreceptors.nomogram.S = S;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax+2;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax+lambdaMaxShift;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees;
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; photoreceptors.energyFundamentals];
            T_quantalIsomerizations = [T_quantalIsomerizations ; photoreceptors.isomerizationAbsorptance];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];
        case 'LCone10DegTabulatedSS'
            % Load in the tabulated 10-deg S-S fundamentals
            targetRaw = load('T_cones_ss10');
            T_energy_tmp = SplineCmf(targetRaw.S_cones_ss10,targetRaw.T_cones_ss10(1,:),S,2);
            T_energyNormalized = [T_energyNormalized ; T_energy_tmp];
            T_quanta = [T_quanta ; QuantaToEnergy(S,T_energy_tmp')'];
            T_quantalIsomerizations = [T_quantalIsomerizations ; NaN*ones(size(T_quanta))];
        case 'MCone10DegTabulatedSS'
            % Load in the tabulated 10-deg S-S fundamentals
            targetRaw = load('T_cones_ss10');
            T_energy_tmp = SplineCmf(targetRaw.S_cones_ss10,targetRaw.T_cones_ss10(2,:),S,2);
            T_energyNormalized = [T_energyNormalized ; T_energy_tmp];
            T_quanta = [T_quanta ; QuantaToEnergy(S,T_energy_tmp')'];
            T_quantalIsomerizations = [T_quantalIsomerizations ; NaN*ones(size(T_quanta))];
        case 'SCone10DegTabulatedSS'
            % Load in the tabulated 10-deg S-S fundamentals
            targetRaw = load('T_cones_ss10');
            T_energy_tmp = SplineCmf(targetRaw.S_cones_ss10,targetRaw.T_cones_ss10(3,:),S,2);
            T_energyNormalized = [T_energyNormalized ; T_energy_tmp];
            T_quantalIsomerizations = [T_quantalIsomerizations ; NaN*ones(size(T_quanta))];
        case 'MelanopsinLegacy'
            % Construct the melanopsin receptor
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9, 530.3, 480+lambdaMaxShift];
            
            % Make a call to ComputeCIEConeFundamentals() which makes appropriate calls
            T_quanta_tmp = ComputeCIEConeFundamentals(S,10,ageInYears,3,lambdaMax,whichNomogram);
            T_energyNormalized = [T_energyNormalized ; EnergyToQuanta(S,T_quanta_tmp(3,:)')'];
            T_quantalIsomerizations = [T_quantalIsomerizations ; NaN*ones(size(T_quanta))];
            nominalLambdaMax = [nominalLambdaMax 480];
        case 'RodsLegacy'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9, 530.3, 480];
            ageInYears = 32;
            pupilSize = 3;
            fieldSize = 10;
            lambdaMaxRods = 500;
            DORODS = true;
            T_quanta_tmp = ComputeCIEConeFundamentals(S,fieldSize,ageInYears,pupilSize,lambdaMaxRods,whichNomogram,[],DORODS);
            T_energyNormalized = [T_energyNormalized ; EnergyToQuanta(S,T_quanta_tmp')'];
            T_quantalIsomerizations = [T_quantalIsomerizations ; NaN*ones(size(T_quanta))];
        case 'CIE1924VLambda'
            % Load in the CIE 1959 scotopic luminosity function
            targetRaw = load('T_rods');
            T_energyNormalized = [T_energyNormalized ; SplineCmf(targetRaw.S_rods,targetRaw.T_rods,S,2)];
            T_quantalIsomerizations = [T_quantalIsomerizations ; NaN*ones(size(T_quanta))];
            
        case 'LConeHemo'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7]';
            
            %% Construct cones, pull out L cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsomHemo);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Multiply with blood transmissivity
            oxyFraction = 0.85;
            overallThicknessUm = 5;
            source = 'Prahl';
            trans_Hemoglobin = GetHemoglobinTransmittance(S,oxyFraction,overallThicknessUm,source);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(1,:) .* trans_Hemoglobin'];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(1,:) .* trans_Hemoglobin'];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(1)];
        case 'MConeHemo'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7]';
            
            %% Construct cones, pull out M cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsomHemo);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Multiply with blood transmissivity
            oxyFraction = 0.85;
            overallThicknessUm = 5;
            source = 'Prahl';
            trans_Hemoglobin = GetHemoglobinTransmittance(S,oxyFraction,overallThicknessUm,source);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(2,:) .* trans_Hemoglobin'];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(2,:) .* trans_Hemoglobin'];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(2)];
        case 'SConeHemo'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7];
            
            %% Construct cones, pull out S cone
            [T_quantalNormalized1,~,T_quantalIsomerizations1] = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram,[],[],[],fractionBleachedFromIsomHemo);
            T_energy1 = EnergyToQuanta(S,T_quantalNormalized1')';
            
            % Multiply with blood transmissivity
            oxyFraction = 0.85;
            overallThicknessUm = 5;
            source = 'Prahl';
            trans_Hemoglobin = GetHemoglobinTransmittance(S,oxyFraction,overallThicknessUm,source);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; T_energy1(3,:).* trans_Hemoglobin'];
            T_quantalIsomerizations = [T_quantalIsomerizations ; T_quantalIsomerizations1(3,:) .* trans_Hemoglobin'];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(3)];
    end
end

%% Normalize energy sensitivities.
%
% They might already be normalized in most cases, but this makes sure.
for i = 1:size(T_energyNormalized)
    T_energyNormalized(i,:) = T_energyNormalized(i,:)/max(T_energyNormalized(i,:));
end

