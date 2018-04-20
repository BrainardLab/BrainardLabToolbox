function [c,ceq] = FitColorMaterialModelMLDSConstraint(x,params)
% [c,ceq] = FitColorMaterialModelMLDSConstraint(x,params)
%
% Implement constraint function.  This prevents elements of the solution
% from being too close to each other.  We use it when the parameters are
% describing a smooth parametric form for the positions, in which case we
% can't just impose a linear inequality constraint to acheive this.

% History
%   02/16/18  dhb, ar  Add parameter bound constraint.

% Sanity check - is the solution to any of our parameters NaN
if (any(isnan(x)))
    error('Entry of x is NaN');
end

% We need to convert X to params here
[materialMatchColorCoords,colorMatchMaterialCoords,w,sigma] = ColorMaterialModelXToParams(x, params); 

% This constraint forces the solution to be monotonic
cVec1 = diff(materialMatchColorCoords);
cVec2 = diff(colorMatchMaterialCoords);
c1 = -[cVec1 cVec2]' + sigma/params.sigmaFactor;

% This constraint forces the values to be within range
c1Vec = abs(materialMatchColorCoords) - params.maxPositionValue;
c2Vec = abs(colorMatchMaterialCoords) - params.maxPositionValue;
c2 = [c1Vec(:) ; c2Vec(:)];

% This is the whole constraint
c = [c1(:) ; c2(:)];

% Set equality constraint so that it isn't violated
ceq = 0;

end