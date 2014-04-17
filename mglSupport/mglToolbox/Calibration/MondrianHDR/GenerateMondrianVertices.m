function verts = GenerateMondrianVertices(edgeSize)
% verts = GenerateMondrianVertices(edgeSize)
%
% Description:
% Generates a set of vertices for a 5x5 Mondrian with a total width of
% "edgeSize".
%
% Input:
% edgeSize (scalar) - The width and height of the Mondrian.
%
% Output:
% verts (5x5x4x2 double) - Vertices of the 4 corners of every square of the
%   Mondrian.

% 7/12/2010 cgb     Pulled it out from HDRAnaDriver, that is HDRCompare. 

if nargin ~= 1
	error('Usage: verts = GenerateMondrianVertices(edgeSize)');
end

leftEdge = -edgeSize/2;
topEdge = edgeSize/2;
squareWidth = edgeSize/5;
squareHeight = edgeSize/5;
verts = zeros([5 5 4 2]);
for i = 1:5
	for j = 1:5
		% upper left
		verts(i, j, 1, 1) = (j-1)*squareWidth + leftEdge;
		verts(i, j, 1, 2) = topEdge - (i-1)*squareHeight;
		
		% upper right
		verts(i, j, 2, 1) = verts(i, j, 1, 1) + squareWidth;
		verts(i, j, 2, 2) = verts(i, j, 1, 2);
		
		% lower right
		verts(i, j, 3, 1) = verts(i, j, 2, 1);
		verts(i, j, 3, 2) = verts(i, j, 2, 2) - squareHeight;
		
		% lower left
		verts(i, j, 4, 1) = verts(i, j, 1, 1);
		verts(i, j, 4, 2) = verts(i, j, 3, 2);
	end
end
