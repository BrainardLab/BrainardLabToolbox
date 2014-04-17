function DrawQuad(width, height, origin)
global GL;

if nargin ~= 3
    error('Invalid number of inputs');
end

glBegin(GL.QUADS);
    glVertex3d(-width/2 + origin(1), -height/2 + origin(2), origin(3));
    glVertex3d(-width/2 + origin(1), height/2 + origin(2), origin(3));
    glVertex3d(width/2 + origin(1), height/2 + origin(2), origin(3));
    glVertex3d(width/2 + origin(1), -height/2 + origin(2), origin(3));
glEnd;
