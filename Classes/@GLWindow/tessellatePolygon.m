function tessVerts = tessellatePolygon(polyVerts)
% tessellatePolygon - Tessellates a 2D polygon.
%
% Syntax:
% tessVerts = GLWindow.tessellatePolygon(polyVerts)
% tessVerts = GLWindow.tessellatePolygon(polyVerts, polyDepth)
%
% Description:
% Takes a 2D convex or concave polygon and tessellates it into a set of
% triangles.  Polygon vertices must be an ordered set of (x,y) pairs.
%
% Input:
% polyVerts (Mx2) - (x,y) vertices for the polygon.
% polyDepth (scalar) - Optional depth component for the tessellate polygon.
%   This value will be the same across all vertices.
%
% Output:
% tessVerts (cell array) - Cell array where each element contains a 3x3
%   matrix defining the 3 (x,y,z) vertices of ones of the tessellation
%   triangles.  Each row is an (x,y,z) triplet.
%
% This function changed in 2011b.
%
% 10/14/11 TYL commented out plot function at the end

% Arg check
narginchk(1, 2);

if nargin == 1
	polyDepth = 0;
end

% Make sure that the input is a Mx2 matrix.
if ndims(polyVerts) ~= 2 || size(polyVerts, 2) ~= 2
	error('"polyVerts" must be a Mx2 matrix.');
end

% Our boundaries lines.  This is defined as the set of vertex pairs that
% make up a boundary line.  This assumes that the passed polygon vertices
% are an ordered set that define a closed polygon.
C = [(1:size(polyVerts,1))' [2:size(polyVerts,1) 1]'];

% Create a Delauny triangle tessellation.
dt = DelaunayTri(polyVerts, C);

% Get a list of the calculated triangles that exist inside the polygon.
i = dt.inOutStatus;

% Get the list of vertices that make up the inside polygons.
triangleList = dt(i,:);
numTriangles = size(triangleList, 1);

% Allocate memory for our tessellated vertices.
tessVerts = cell(1, numTriangles);

for t = 1:numTriangles
	triVerts = zeros(3,3);
	for v = 1:3
		vertexID = triangleList(t, v);
		triVerts(v, 1:2) = dt.X(vertexID, :);
		triVerts(v, 3) = polyDepth;
	end
	
	tessVerts{t} = triVerts;
end

%triplot(dt(dt.inOutStatus,:), dt.X(:,1), dt.X(:,2));
