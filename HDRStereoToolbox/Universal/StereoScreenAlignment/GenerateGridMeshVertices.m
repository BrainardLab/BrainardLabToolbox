% Method to generate the vertices that define the mesh of quadrilaterals given arrays of  x- and y-coords of the grid nodes
% 
function gridVertexArray = GenerateGridMeshVertices(screenWidthInPixels, screenHeightInPixels, X, Y, invertYaxis)   
    yGridNodesNum = size(X, 1);
    xGridNodesNum = size(X, 2);
    
    verticesNum = (yGridNodesNum-1) * (xGridNodesNum-1) * 4;
    xVertices = zeros(1, verticesNum);
    yVertices = zeros(1, verticesNum);
    
    index = 0;
    for iy = 1:yGridNodesNum-1
        for ix = 1:xGridNodesNum-1
           % (x,y) coord of lower-left vertex
           index = index + 1;
           xVertices(index) = X(iy,ix);
           yVertices(index) = Y(iy,ix);
           
           % (x,y) coord of lower-right vertex
           index = index + 1;
           xVertices(index) = X(iy, ix+1);
           yVertices(index) = Y(iy, ix+1);
           
           % (x,y) coord of upper-right vertex
           index = index + 1;
           xVertices(index) = X(iy+1, ix+1);
           yVertices(index) = Y(iy+1, ix+1);
           
           % (x,y) coord of upper-left vertex
           index = index + 1;
           xVertices(index) = X(iy+1, ix);
           yVertices(index) = Y(iy+1, ix); 
        end
    end
    
    if (invertYaxis)
        yVertices = screenHeightInPixels - yVertices;
    end
   
    % Package computed vertices
    gridVertexArray = zeros(1, 2*numel(xVertices));
    gridVertexArray(1:2:end) = xVertices;
    gridVertexArray(2:2:end) = yVertices;      
end
