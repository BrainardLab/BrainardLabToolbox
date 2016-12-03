function [c,ceq] = FitColorMaterialScalingConst(x,params)
% [c,ceq] = FitColorMaterialScalingConst(x,params)
%
% Implement constraint function

% Sanity check - is the solution to any of our parameters NaN
if (any(isnan(x)))
    error('Entry of x is NaN');
end

% We need to convert X to params here
[materialMatchColorCoords,colorMatchMaterialCoords,w,sigma] = ColorMaterialModelXToParams(x,params); 
           
cVec1 = diff(materialMatchColorCoords);
cVec2 = diff(colorMatchMaterialCoords);
c = -[cVec1 cVec2]' + 1/params.sigmaFactor;
ceq = 0;

end