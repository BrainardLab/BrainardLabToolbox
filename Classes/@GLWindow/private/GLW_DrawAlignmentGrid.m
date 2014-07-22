function GLW_DrawAlignmentGrid(nodePositions, lineWidth, colorRGB)
% Description:
% Renders an alignment grid.
% 3/20/2013   npc   Wrote it.
%
    global GL;

    % set point size
  	glLineWidth(lineWidth);
    
    % set the polygon color.
    glColor3dv(colorRGB);

    % Enable smooth lines
    glEnable(GL.BLEND);
	glEnable(GL.POLYGON_SMOOTH);
	glEnable(GL.LINE_SMOOTH);
	glEnable(GL.POINT_SMOOTH);

    % Draw segments between nodes
    glBegin(GL.LINES);
    rowsNum = size(nodePositions, 1);
    colsNum = size(nodePositions, 2);
    
    % horizontal segments
    for row = 1:rowsNum
        for col = 1:colsNum-1
            x1 = nodePositions(row,col,1);
            y1 = nodePositions(row,col,2);
            x2 = nodePositions(row,col+1,1);
            y2 = nodePositions(row,col+1,2);
            glVertex3f(x1, y1, 0);
            glVertex3f(x2, y2, 0);
        end
    end
    
    % vertical segments
    for col = 1:colsNum
        for row = 1:rowsNum-1
            x1 = nodePositions(row,col,1);
            y1 = nodePositions(row,col,2);
            x2 = nodePositions(row+1,col,1);
            y2 = nodePositions(row+1,col,2);
            glVertex3f(x1, y1, 0);
            glVertex3f(x2, y2, 0);
        end
    end
  	glEnd();
end