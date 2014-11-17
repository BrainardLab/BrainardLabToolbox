function [x, y] = FitEllipse2Rect(rect, angleStep)
% [x, y] = FitEllipse2Rect(rect, [angleStep])
%	Generates the (x, y) points needed to fit an ellipse to a rectangle
%	specified by 'rect'.  The points are calculated using the parametric
%	equations x = h + a*cos(t) and y = k + b*sin(t) where -pi <= t <= pi.
%
%	'rect' is defined as [leftX, rightX, bottomY, topY].  For example a
%	rectangle 1 unit wide and 4 units tall centered around (0, 0) would be
%	defined as [-.5, .5, -2, 2]);
%
%	'angleStep' defines the increment that 't' steps and should be
%	specified in degrees.  By default, it is set to 1 degree.

if nargin < 1 || nargin > 2
	error('Usage: [x, y] = FitEllipse2Rect(rect, [angleStep])');
end

if nargin == 1
	angleStep = 1;
end

a = (rect(2) - rect(1)) / 2;
b = (rect(4) - rect(3)) / 2;

h = (rect(1) + rect(2)) / 2;
k = (rect(3) + rect(4)) / 2;

incr = angleStep / 180 * pi;
t = -pi:incr:pi;
x = h + a * cos(t);
y = k + b * sin(t);

% % Debug
% figure;
% plot(x, y);
% z = max(abs(rect));
% hold on;
% plot(rect(1), k, 'rx');
% plot(rect(2), k, 'rx');
% plot(h, rect(3), 'rx');
% plot(h, rect(4), 'rx');
% axis([-z z -z z]);
% hold off;
