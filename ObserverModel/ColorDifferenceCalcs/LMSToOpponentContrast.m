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
%                              contrast is computed.  This can be a matrix
%                              with multiple columns, and return will be of
%                              same size.
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
%   08/08/20  dhb   Allow matrix for comparisonLMS

% Examples:
%{
    colorDiffParams.type = 'opponentContrast';
    colorDiffParams.LMRatio = 2;
    colorDiffParams.lumWeight = 1;
    colorDiffParams.rgWeight = 3;
    colorDiffParams.byWeight = 1.5;
    colorDiffParams.M = GetOpponentContrastMatrix(colorDiffParams);
    referenceLMS = [1 1 1]';
    comparisonLMS = [1 0.99 1.00 ; 0.99 1 1.01]';
    opponentContrast = LMSToOpponentContrast(colorDiffParams,referenceLMS,comparisonLMS)
    opponentContrast = LMSToOpponentContrast(colorDiffParams,referenceLMS,2*referenceLMS)
    if (any(abs(opponentContrast - [1 0 0]')) > 1e-6)
       error('Don''t get right answer in simple test case.');
    end
%}

% Check sizes
if (size(referenceLMS,2) ~= 1)
    error('Can only have one reference');
end

% Go to cone contrast         
coneContrast = (comparisonLMS - referenceLMS) ./ referenceLMS;

% And then to opponent contrast
opponentContrast = colorDiffParams.M*coneContrast;

% This shows how to compute CIELAB DE for the same inputs. Very slow
% becaues of the load commands, keep it as false for general use.
COMPARE_LAB = false;
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

   
