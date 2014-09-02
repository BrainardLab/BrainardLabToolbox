function GLW_DrawSimple3DCursor(positionXYZ, diameter, lineThickness, colorRGB)
% Description:
% Renders a simple cursor (filled polygon or arbitrary shape).
% 3/20/2013   npc   Wrote it.
%
    global GL;

    % 3D position of the cursor
    xPos = positionXYZ(1);
    yPos = positionXYZ(2);
    zPos = positionXYZ(3);
   
    % set point size
  	glLineWidth(lineThickness);
    
    % set the polygon color.
    glColor3dv(colorRGB);

    % Enable smooth lines
    glEnable(GL.BLEND);
	glEnable(GL.POLYGON_SMOOTH);
	glEnable(GL.LINE_SMOOTH);
	glEnable(GL.POINT_SMOOTH);
    
    % fill the polygon
    glPolygonMode(GL.FRONT_AND_BACK, GL.FILL);

    % enter the polygon vertices (72 segments, i.e., 5 degree increments)
    radius = diameter/2;
    stepsNum = 72;
    step = 360.0/stepsNum*pi/180.0;
  	glBegin(GL.POLYGON);
  	for i = 0:stepsNum
    	radAngle = i*step;
    	glVertex3f(xPos + radius*cos(radAngle), yPos + radius*sin(radAngle), zPos);
    end
    glEnd();
     
    
end
