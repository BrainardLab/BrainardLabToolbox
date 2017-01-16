function [c,ceq] = FitColorMaterialScalingConst(x,params)
% [c,ceq] = FitColorMaterialScalingConst(x,params)
%
% Implement constraint function.  This prevents elements of the solution
% from being too close to each other.  We use it when the parameters are
% describing a smooth parametric form for the positions, in which case we
% can't just impose a linear inequality constraint to acheive this.

% Sanity check - is the solution to any of our parameters NaN
if (any(isnan(x)))
    error('Entry of x is NaN');
end

% We need to convert X to params here
[materialMatchColorCoords,colorMatchMaterialCoords,w,sigma] = ColorMaterialModelXToParams(x,params); 
           
cVec1 = diff(materialMatchColorCoords);
cVec2 = diff(colorMatchMaterialCoords);
c = -[cVec1 cVec2]' + params.sigma/params.sigmaFactor;
ceq = 0;

end