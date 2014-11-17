function GLW_DrawHollowRectangle(xPos, yPos, zPos, width, height, lineThickness, colorRGB)
% Description:
% Renders a CrossHairs cursor.
% 3/20/2013   npc   Wrote it.
%
    global GL;
    % set point size
  	glLineWidth(lineThickness);
    
    % set the polygon color.
    glColor3dv(colorRGB);

    % Enable smooth lines
    glEnable(GL.BLEND);
	glEnable(GL.POLYGON_SMOOTH);
	glEnable(GL.LINE_SMOOTH);
	glEnable(GL.POINT_SMOOTH);
    
    
    glBegin(GL.LINE_STRIP);
    glVertex3f(xPos - width/2, yPos - height/2, zPos);
    glVertex3f(xPos + width/2, yPos - height/2, zPos);
    glVertex3f(xPos + width/2, yPos + height/2, zPos);
    glVertex3f(xPos - width/2, yPos + height/2, zPos);
    glVertex3f(xPos - width/2, yPos - height/2, zPos);
    glEnd();
    
end
