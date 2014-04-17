function [T_energy, T_energy_raw, T_quanta, T_quanta_raw, nominalLambdaMax] = GetHumanPhotopigmentSS(S, photoreceptorClasses, fieldSizeDegrees, ageInYears, pupilDiameterMm, lambdaMaxShift)
% [T_energy, T_energy_raw, T_quanta, T_quanta_raw, nominalLambdaMax] = GetHumanPhotopigmentSS(S, photoreceptorClasses, fieldSizeDegrees, ageInYears, pupilDiameterMm, lambdaMaxShift)
%
% Produces photopigment sensitivities that we often need, and allowing
% variation in age and lambda-max.  T_energy and T_quantal normalize
% each fundamental to a maximum of one.
%
% If empty variables are passed for any of the following variables,
% defaults will be assumed.
%
% Input:
%   S (1x3)                         - Wavelength spacing.
%                                     Default: [380 2 201]
%   photoreceptorClasses (cell)     - Cell with names of photoreceptor classes.
%                                     Supported options: 'LCone', 'MCone', 'SCone', 'Melanopsin', 'Rods'
%                                     Default: {'LCone' ; 'MCone' ; 'SCone'}
%   fieldSizeDegrees (1x1)          - Field size in degrees.
%                                     Default: 10
%   ageInYears (1x1)                - Observer age in years.
%                                     Default: 32
%   pupilDiameterMm (1x1)           - Pupil diameter in mm.
%                                     Default: 3
%   lambdaMaxShift (1x1)            - Shift of lambda-max.
%                                     Default: 0
%
% Output:
%   T_energy                        - Spectral sensitivities in energy
%                                     units (normalized to max.).
%   T_energy_raw                    - Spectral sensitivities in energy
%                                     units (unnormalized).
%   T_quanta                        - Spectral sensitivities in quanta
%                                     units.
%   T_labels                        - Labels of the spectral sensitivities.
%   nominalLambdaMax                 - Peak spectral sensitivities.
%
% 1/21/14   ms    Wrote it based on old code.

% Check if all variables have been passed with a value

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

% Assign empty vectors
T_quanta = [];
T_energy = [];
T_labels = {};
nominalLambdaMax = [];

% Iterate over the photoreceptor classes that have been passed.
for i = 1:length(photoreceptorClasses)
    theClass = photoreceptorClasses{i};
    switch theClass
        case 'LCone'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7]';
            
            %% Construct cones, pull out L cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(1, :)];
            T_energy = [T_energy ; T_energy1(1, :)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(1)];
        case 'MCone'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7]';
            
            %% Construct cones, pull out M cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(2, :)];
            T_energy = [T_energy ; T_energy1(2, :)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(2)];
        case 'SCone'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7];
            
            %% Construct cones, pull out S cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(3, :)];
            T_energy = [T_energy ; T_energy1(3, :)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(3)];
        case 'Melanopsin'
            %% Melanopsin
            photoreceptors = DefaultPhotoreceptors('LivingHumanMelanopsin');
            % Override fields
            photoreceptors.nomogram.S = S;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax+lambdaMaxShift;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees;
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; photoreceptors.quantalFundamentals];
            T_energy = [T_energy ; photoreceptors.energyFundamentals];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];
        case 'Rods'
            %% Rods
            photoreceptors = DefaultPhotoreceptors('LivingHumanRod');
            % Override fields
            photoreceptors.nomogram.S = S;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax+lambdaMaxShift;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees;
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; photoreceptors.quantalFundamentals];
            T_energy = [T_energy ; photoreceptors.energyFundamentals];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];
            
            
            %% Robust versions, flanking -2 and +2 nm
        case 'LConeR+2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9+2 530.3 420.7]';
            
            %% Construct cones, pull out L cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(1, :)];
            T_energy = [T_energy ; T_energy1(1, :)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(1)];
        case 'LConeR-2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9-2 530.3 420.7]';
            
            %% Construct cones, pull out L cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(1, :)];
            T_energy = [T_energy ; T_energy1(1, :)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(1)];
        case 'MConeR+2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3+2 420.7]';
            
            %% Construct cones, pull out M cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(2, :)];
            T_energy = [T_energy ; T_energy1(2, :)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(2)];
        case 'MConeR-2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3-2 420.7]';
            
            %% Construct cones, pull out M cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(2, :)];
            T_energy = [T_energy ; T_energy1(2, :)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(2)];
        case 'SConeR+2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7+2];
            
            %% Construct cones, pull out S cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(3, :)];
            T_energy = [T_energy ; T_energy1(3, :)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(3)];
        case 'SConeR-2'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7-2];
            
            %% Construct cones, pull out S cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(3, :)];
            T_energy = [T_energy ; T_energy1(3, :)];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(3)];
        case 'MelanopsinR-2'
            %% Melanopsin
            photoreceptors = DefaultPhotoreceptors('LivingHumanMelanopsin');
            % Override fields
            photoreceptors.nomogram.S = S;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax-1;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = photoreceptors.nomogram.lambdaMax+lambdaMaxShift;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees;
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; photoreceptors.quantalFundamentals];
            T_energy = [T_energy ; photoreceptors.energyFundamentals];
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
            T_quanta = [T_quanta ; photoreceptors.quantalFundamentals];
            T_energy = [T_energy ; photoreceptors.energyFundamentals];
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
            T_quanta = [T_quanta ; photoreceptors.quantalFundamentals];
            T_energy = [T_energy ; photoreceptors.energyFundamentals];
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
            T_quanta = [T_quanta ; photoreceptors.quantalFundamentals];
            T_energy = [T_energy ; photoreceptors.energyFundamentals];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];
        case 'LCone10DegTabulatedSS'
            % Load in the tabulated 10-deg S-S fundamentals
            targetRaw = load('T_cones_ss10');
            T_energy_tmp = SplineCmf(targetRaw.S_cones_ss10,targetRaw.T_cones_ss10(1, :),S,2);
            T_energy = [T_energy ; T_energy_tmp];
            T_quanta = [T_quanta ; QuantaToEnergy(S,T_energy_tmp')'];
        case 'MCone10DegTabulatedSS'
            % Load in the tabulated 10-deg S-S fundamentals
            targetRaw = load('T_cones_ss10');
            T_energy_tmp = SplineCmf(targetRaw.S_cones_ss10,targetRaw.T_cones_ss10(2, :),S,2);
            T_energy = [T_energy ; T_energy_tmp];
            T_quanta = [T_quanta ; QuantaToEnergy(S,T_energy_tmp')'];
        case 'SCone10DegTabulatedSS'
            % Load in the tabulated 10-deg S-S fundamentals
            targetRaw = load('T_cones_ss10');
            T_energy_tmp = SplineCmf(targetRaw.S_cones_ss10,targetRaw.T_cones_ss10(3, :),S,2);
            T_energy = [T_energy ; T_energy_tmp];
            T_quanta = [T_quanta ; QuantaToEnergy(S,T_energy_tmp')'];
        case 'MelanopsinLegacy'
            % Construct the melanopsin receptor
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9, 530.3, 480];
            ageInYears = 32;
            pupilSize = 3;
            fieldSize = 10;
            
            % Make a call to ComputeCIEConeFundamentals() which makes
            % appropriate calls
            T_quanta_tmp = ComputeCIEConeFundamentals(S,fieldSize,ageInYears,pupilSize,lambdaMax,whichNomogram);
            T_quanta = [T_quanta ; T_quanta_tmp(3, :)];
            T_energy = [T_energy ; EnergyToQuanta(S,T_quanta_tmp(3, :)')'];
        case 'RodsLegacy'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9, 530.3, 480];
            ageInYears = 32;
            pupilSize = 3;
            fieldSize = 10;
            lambdaMaxRods = 500; % 500 nm
            DORODS = true;
            T_quanta_tmp = ComputeCIEConeFundamentals(S,fieldSize,ageInYears,pupilSize,lambdaMaxRods,whichNomogram,[],DORODS);
            T_energy = [T_energy ; EnergyToQuanta(S,T_quanta_tmp')'];
            T_quanta = [T_quanta ; T_quanta_tmp];
        case 'CIE1924VLambda'
            % Load in the CIE 1959 scotopic luminosity function
            targetRaw = load('T_rods');
            T_energy = [T_energy ; SplineCmf(targetRaw.S_rods,targetRaw.T_rods,S,2)];
            T_quanta = [T_quanta ; QuantaToEnergy(S,T_energy')'];
        case 'LConeHemo'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7]';
            
            %% Construct cones, pull out L cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Multiply with blood transmissivity
            load den_Hemoglobin;
            den_Hemoglobin = SplineRaw(S_Hemoglobin, den_Hemoglobin, S);
            trans_Hemoglobin = 10.^(-den_Hemoglobin);
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(1, :) .* QuantaToEnergy(SToWls(S), trans_Hemoglobin)'];
            T_energy = [T_energy ; T_energy1(1, :) .* trans_Hemoglobin'];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(1)];
        case 'MConeHemo'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7]';
            
            %% Construct cones, pull out M cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Multiply with blood transmissivity
            load den_Hemoglobin;
            den_Hemoglobin = SplineRaw(S_Hemoglobin, den_Hemoglobin, S);
            trans_Hemoglobin = 10.^(-den_Hemoglobin);
            
            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(2, :) .* QuantaToEnergy(SToWls(S), trans_Hemoglobin)'];
            T_energy = [T_energy ; T_energy1(2, :) .* trans_Hemoglobin'];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(2)];
        case 'SConeHemo'
            whichNomogram = 'StockmanSharpe';
            lambdaMax = [558.9 530.3 420.7];
            
            %% Construct cones, pull out S cone
            T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDegrees,ageInYears,pupilDiameterMm,lambdaMax+lambdaMaxShift,whichNomogram);
            T_energy1 = EnergyToQuanta(S,T_quanta1')';
            
            % Multiply with blood transmissivity
            load den_Hemoglobin;
            den_Hemoglobin = SplineRaw(S_Hemoglobin, den_Hemoglobin, S);
            trans_Hemoglobin = 10.^(-den_Hemoglobin);

            % Add to the receptor vector
            T_quanta = [T_quanta ; T_quanta1(3, :) .* QuantaToEnergy(SToWls(S), trans_Hemoglobin)'];
            T_energy = [T_energy ; T_energy1(3, :).* trans_Hemoglobin'];
            nominalLambdaMax = [nominalLambdaMax lambdaMax(3)];
    end
end

% Normalize
T_energy_raw = T_energy;
for i = 1:size(T_energy)
    T_energy(i, :) = T_energy(i, :)/max(T_energy(i, :));
end

T_quanta_raw = T_quanta;
for i = 1:size(T_quanta)
    T_quanta(i, :) = T_quanta(i, :)/max(T_quanta(i, :));
end