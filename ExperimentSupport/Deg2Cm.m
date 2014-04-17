function cm = Deg2Cm(viewDist, degs)
% cm = Deg2Cm(viewDist, degs)
%	Converts an angle 'degs' into centimeters based on 'viewDist', which
%	specifies the distant from the target in centimeters.

cm = viewDist * tan(degs / 180 * pi);
