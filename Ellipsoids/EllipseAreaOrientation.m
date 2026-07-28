function [area, majorAxisLength, majorAxisAngle, minorAxisLength] = EllipseAreaOrientation(Q)
% EllipseAreaOrientation  Area, major-axis length and orientation of an
% ellipse fit produced by EllipsoidFit.m / EllipsoidMatricesGenerate.m.
%
% Syntax:
%   [area, majorAxisLength, majorAxisAngle, minorAxisLength] = EllipseAreaOrientation(Q)
%
% Description:
%   EllipsoidFit's error function fits Q so that x'*Q*x = 1 for points x
%   on the ellipse (see FitEllipseFunction, which minimizes deviations of
%   diag(x'*Q*x) from 1). So Q is exactly the matrix of that quadratic
%   form, and this routine just does the eigendecomposition of Q to get
%   the ellipse's geometry.
%
%   If Q is 3x3 (e.g. from a fit with isXYEllipse = true, where the z
%   dimension was locked to 0), this uses the top-left 2x2 block, which
%   is the part of Q that actually governs the xy ellipse.
%
% Inputs:
%   Q - 2x2 (or 3x3) matrix from EllipsoidFit/EllipsoidMatricesGenerate,
%       such that x'*Q*x = 1 on the ellipse.
%
% Outputs:
%   area            - Area of the ellipse (pi * semiMajor * semiMinor).
%   majorAxisLength - Full length of the major axis (2 * semiMajor).
%   majorAxisAngle  - Orientation of the major axis, in degrees,
%                      measured counterclockwise from the x-axis, in the
%                      range [0,180).
%   minorAxisLength - Full length of the minor axis (2 * semiMinor).

if (size(Q,1) == 3)
    Q = Q(1:2,1:2);
end

% Eigenvectors of Q give the ellipse's principal axes; for x'*Q*x = 1,
% the semi-axis length along eigenvector i is 1/sqrt(eigenvalue_i).
[V,D] = eig(Q);
d = diag(D);
semiAxes = 1./sqrt(d);

[semiMajor,majorIdx] = max(semiAxes);
semiMinor = min(semiAxes);

majorAxisLength = 2*semiMajor;
minorAxisLength = 2*semiMinor;

majorVec = V(:,majorIdx);
% The commented out quantity should always be 1.
% majorVec'*Q*majorVec*((majorAxisLength/2)^2)

majorAxisAngle = atan2d(majorVec(2), majorVec(1));
majorAxisAngle = mod(majorAxisAngle, 180);
% The commented out quantity should always be 1.
% checkVec = majorAxisLength/2*[cosd(majorAxisAngle) sind(majorAxisAngle)]';
% checkVec'*Q*checkVec

% area = pi*semiMajor*semiMinor, and det(Q) = 1/(semiMajor^2*semiMinor^2)
area = pi / sqrt(det(Q));

end
