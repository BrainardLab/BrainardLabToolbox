function opponentContrast = LMSToOpponentContrast(colorDiffParams,referenceLMS,comparisonLMS)
%
% Syntax:
%     opponentContrast = LMSToOpponentContrast(colorDiffParams,,referenceLMS,comparisonLMS)
%
% Description:
%     Convert LMS representation to opponent contrast respresentation
%
%     When the type field is 'opponentColor', converts comparison to
%     contrast with respect to reference, then transforms to a lum, rg, by
%     opponent representation. The contrast differences in each direction
%     are scaled by the weights specified in the parameters structure.
%
% Inputs:
%     colorDiffParams        - Structure with color difference parameters.
%     referenceLMS           - LMS coordinates of the reference with
%                              respect to which contrast is computed.
%     comparisonLMS          - LMS coordinates of the stimulus whose
%                              contrast is computed.
%
% Outputs:
%   opponentContrast         - Contrast representation of the comparison
%
% Optional key/value pairs:
%   None:
%
% See also: GetOpponentContrastMatrix, OpponentContrastToLMS, ComputeMatchDiff
%

% History:
%   08/09/19  dhb   Wrote it.

% Examples:
%{
    colorDiffParams.type = 'opponentContrast';
    colorDiffParams.LMRatio = 2;
    colorDiffParams.lumWeight = 1;
    colorDiffParams.rgWeight = 3;
    colorDiffParams.byWeight = 1.5;
    colorDiffParams.M = GetOpponentContrastMatrix(colorDiffParams);
    referenceLMS = [1 1 1]';
    comparisonLMS = [1 0.99 1.00]';
    opponentContrast = LMSToOpponentContrast(colorDiffParams,referenceLMS,comparisonLMS)
    opponentContrast = LMSToOpponentContrast(colorDiffParams,referenceLMS,2*referenceLMS)
    if (any(abs(opponentContrast - [1 0 0]')) > 1e-6)
       error('Don''t get right answer in simple test case.');
    end
%}

% Go to cone contrast         
coneContrast = (comparisonLMS - referenceLMS) ./ referenceLMS;

% And then to opponent contrast
opponentContrast = colorDiffParams.M*coneContrast;

COMPARE_LAB = true;
CHECK_MATRIX = false;
if (COMPARE_LAB)
    load T_xyz1931;
    load T_cones_ss2
    T_cones = T_cones_ss2;
    S = S_cones_ss2;
    T_xyz = SplineCmf(S_xyz1931,T_xyz1931,S);
    M_LMSToXYZ = (T_cones'\T_xyz')';
    M_XYZToLMS = inv(M_LMSToXYZ);
    if (CHECK_MATRIX)
        T_xyzCheck = M_LMSToXYZ*T_cones;
        figure; clf; hold on
        plot(T_xyz','r','LineWidth',4);
        plot(T_xyzCheck','b','LineWidth',2);
    end
    referenceXYZ = M_LMSToXYZ*referenceLMS;
    comparisonXYZ = M_LMSToXYZ*comparisonLMS;
    referenceLab = XYZToLab(referenceXYZ,referenceXYZ);
    comparisonLab = XYZToLab(comparisonXYZ,referenceXYZ);
    comparisonDE = ComputeDE(comparisonLab,referenceLab); 
end

% Choose some LMS coordinates.  We can think later about exactly what these
% should be
refLMS = [whatsi];

% Convert reference to Lab, using reference as white point
refLab = [100 0 0];

% Sample LAB points on a unit sphere around refLab.
% There is a routine called SampleSphere that might be helpful.
nPointsOnSpere = 100;
sphereLab = SampleSphere(...);
    
% Convert sphere Lab points back to LMS
sphereLMS = [ ...];
    
% Now we want to choose our opponent metric scalings so that the opponent
% space distance between refLMS and sphereLMS is as close to one (on
% average) as we can make it.
%
% Set the noise sd to XX as part of this.
% Then use parameter search on the three axis scalings to bring the average
% opponent distance as close to XX as possible.
   
