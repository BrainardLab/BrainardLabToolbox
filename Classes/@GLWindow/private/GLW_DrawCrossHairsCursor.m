function GLW_DrawCrossHairsCursor(positionXYZ, diameter, diskDiameter, lineWidth, colorRGB)
% Description:
% Renders a CrossHairs cursor.
% 3/20/2013   npc   Wrote it.
%
    global GL;

    % 3D position of the cursor
    xPos = positionXYZ(1);
    yPos = positionXYZ(2);
    zPos = positionXYZ(3);
   
    % set point size
  	glLineWidth(lineWidth);
    
    % set the polygon color.
    glColor3dv(colorRGB);

    % Enable smooth lines
    glEnable(GL.BLEND);
	glEnable(GL.POLYGON_SMOOTH);
	glEnable(GL.LINE_SMOOTH);
	glEnable(GL.POINT_SMOOTH);
    
    % draw the circle (72 segments, i.e., 5 degree increments)
    radius = diskDiameter/2;
    stepsNum = 72;
    step = 360.0/stepsNum*pi/180.0;
  	glBegin(GL.LINE_STRIP);
  	for i = 0:stepsNum
    	radAngle = i*step;
    	glVertex3f(xPos + radius*cos(radAngle), yPos + radius*sin(radAngle), zPos);
    end
    glEnd();
    
    % draw the cross-hairs
    outerRadius = diameter/2;
    glBegin(GL.LINES);
	glVertex3f(xPos,yPos-outerRadius,  zPos);
    glVertex3f(xPos,yPos-radius,  zPos);
    
    glVertex3f(xPos,yPos+outerRadius,  zPos);
    glVertex3f(xPos,yPos+radius,  zPos);
    
  	glVertex3f(xPos-outerRadius, yPos, zPos);
    glVertex3f(xPos-radius, yPos, zPos);
    
    glVertex3f(xPos+outerRadius, yPos, zPos);
    glVertex3f(xPos+radius, yPos, zPos);
  	glEnd();
end
