function DrawFixationPoint(fpSize, fpLocation, fpColor, sizeType)
% DrawFixationPoint(fpSize, fpLocation, fpColor, [sizeType])
%   Draws a fixation point on the screen using OpenGL
%   through MOGL.  If sizeType is 0 or undefined, the fixation point is
%   drawn as a glPoint with fpSize as its size in pixels.  If sizeType is
%   1, the fixation point is drawn as a gluDisk with fpSize as the radius.

global GL;

if nargin == 3
    sizeType = 0;
end

% If the fixation point location is passed a 2D, make it 3D.
if length(fpLocation) == 2
    fpLocation(3) = 0;
end

glColor3dv(fpColor);

if sizeType
    glPushMatrix;
    glTranslated(fpLocation(1), fpLocation(2), fpLocation(3));
    DrawDisk(0, fpSize, 36, 1, 0, 360);
    glPopMatrix;
else
    glPointSize(fpSize);
    glBegin(GL.POINTS);
    glVertex3dv(fpLocation);
    glEnd;
end
