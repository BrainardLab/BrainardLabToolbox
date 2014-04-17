function [M,m0,theError,predictedXYZ] = FindTransToMinimizeDeltaE(whiteXYZ, targetXYZ, sourceTristim, MINIMIZEINXYZ, AFFINE)
% [M,m0,theError,predictedXYZ] = FindTransToMinimizeDeltaE(whiteXYZ, targetXYZ, sourceTristim, [MINIMIZEINXYZ], [AFFINE])
%
% Input
%   whiteXYZ      - XYZ of white point for Lab transformation
%   targetXYZ     - XYZ of target color coordinates
%   sourceTristim - Tristimulus coordinates (wrt any CMFs, e.g. can be XYZ, RGB, etc.)
%   MINIMIZEINXYZ - Minimize in XYZ rather than Lab (default = 0)
%   AFFINE        - Generate an affine transformation rather than lines
%
% Finds M and m0 such that M*sourceTristim + m0 approximates targetXYZ.
%   By default, m0 is 0; set AFFINE to 1 to find it.
%   By default, error is minimum vector length of error (mean DE) in Lab.  Set MINIMIZEINXYZ to 1 to
%     minimize mean vector length error in XYZ instead.
%
% 05/03/10   ek      Wrote.
% 05/13/10   ek      Change to make possible to check each color's deltaE.
% 05/15/10   dhb     Make vlb, vub matrices.  Some cosmetic changes.
% 05/18/10   dhb, ek Add option to minimize in XYZ.
%            dhb     Generic variable names.  Different intialization.
% 8/13/10    dhb     Even more generic, changed function name.
%            dhb     Make sure MINIMIZEINXYZ is passed everywhere.
% 12/6/10    dhb     Bounds adapt to entry size in initial matrix.
% 5/23/13    dhb     Don't crash if IsCluster is not on path.

%% Check optional argument
if (nargin < 4 || isempty(MINIMIZEINXYZ))
    MINIMIZEINXYZ = 0;
end

if (nargin < 5 || isempty(AFFINE))
    AFFINE = 0;
end

%% Append 1's for AFFINE case
if (AFFINE)
    sourceTristim = [sourceTristim ; ones(1,size(sourceTristim,2))];
end

%% Initial CameraRGB to XYZ transform matrix
initialMatrix = ((sourceTristim')\(targetXYZ)')';

%% Initial Error
[initialError] = GetMatrixErrors(initialMatrix, whiteXYZ, targetXYZ, sourceTristim, MINIMIZEINXYZ);

%% Set reasonable bounds on parameters
maxEntrySize = 10*max(abs(initialMatrix(:)));
vlb = -maxEntrySize*ones(size(initialMatrix));
vub = maxEntrySize*ones(size(initialMatrix));

%% Set search options
if (verLessThan('optim','4.1'))
    error('Your version of the optimization toolbox is too old.  Update it.');
end
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
if (exist('IsCluster','file') && IsCluster && matlabpool('size') > 1)
    options = optimset(options,'UseParallel','always');
end

%% Do the search 
finalMatrix = fmincon(@InlineMinFunction, initialMatrix, [], [], [], [], vlb, vub, [], options);
if (max(abs(finalMatrix(:))) >= maxEntrySize)
    error('Returned matrix is limited by bounds placed during search.  Increase maxEntrySize');
end
[finalError, ~, predictedXYZ] = GetMatrixErrors(finalMatrix, whiteXYZ, targetXYZ, sourceTristim, MINIMIZEINXYZ);

% Split up answer
if (AFFINE)
    M = finalMatrix(1:size(finalMatrix,1),1:size(finalMatrix,1));
    m0 = finalMatrix(:,end);
else
    M = finalMatrix;
    m0 = zeros(size(finalMatrix,1),1);
end
theError = finalError;

%% Diagnostic printout?
CHECK = 0;
if (CHECK)
    initialError      %#ok<NOPRT>
    initialMatrix     %#ok<NOPRT>
    finalError        %#ok<NOPRT>
    finalMatrix       %#ok<NOPRT>
    M                 %#ok<NOPRT>
    m0                %#ok<NOPRT>
end

%% Define Inline function for the search
    function f = InlineMinFunction(x)
        f = GetMatrixErrors(x, whiteXYZ, targetXYZ, sourceTristim, MINIMIZEINXYZ);
    end
end

function [deAverage, deltaE, predictedXYZ] = GetMatrixErrors(Mfull, whiteXYZ, targetXYZ, sourceTristim, MINIMIZEINXYZ)
% [deAverage, deltaE, predictedXYZ] = GetMatrixErrors(Mfull, stdWhiteXYZ, targetXYZ, sourceTristim, [MINIMIZEINXYZ])
%
% Get transformation errors.  This can do either linear or affine depending
% on how the passed sourceTrimstim gets set up above.
%
% 05/06/10   ek      Wrote.
% 05/13/10   ek      Change to make possible to check each color's deltaE.
% 5/18/10    dhb     More genreic variable names.
%            dhb, ek Allow minimization in XYZ or Lab
%            dhb     Return predictions too
% 8/13/10    dhb     Fold this in here, change variable names

%% Check optional argument
if (nargin < 5 || isempty(MINIMIZEINXYZ))
    MINIMIZEINXYZ = 0;
end

%% Calculate color difference between predicted colors and measured colors
predictedXYZ = Mfull * sourceTristim;

% If minimizing in XYZ, computer error there rather than in delta E.
if (MINIMIZEINXYZ)
    deltaE = ComputeDE(targetXYZ,predictedXYZ);
else
    predictedLab = XYZToLab(predictedXYZ, whiteXYZ);
    testLab = XYZToLab(targetXYZ, whiteXYZ);
    deltaE = ComputeDE(testLab, predictedLab);
end

deAverage = mean(deltaE);


end


