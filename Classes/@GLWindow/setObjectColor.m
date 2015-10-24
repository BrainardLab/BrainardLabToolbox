function setObjectColor(GLWObj, objectName, objectColor)
% setObjectColor(GLWObj, objectName, objectColor)
%
% Description:
% Sets a GLWindow object's color.  Multiple objects can be set at once.
% If setting multiple objects at once, 'objectName' and 'objectColor'
% should be cell arrays.
%
% Inputs:
% objectName (string) - Name of object to manipulate.
% objectColor (1x3|struct|cell array) - RGB value(s) in the range [0,1].
%
% Example:
% % Single object color change.
% g = GLWindow; % Create a GLWindow and add a rectangle.
% g. addRectangle([0 0], [5 5], [1 0 0], 'Name', 'rect1');
% g.open; % Open the window.
% g.setObjectColor('rect1', [.5 .3 .8]); % Sets the rectangle to a new color.
% g.draw; % Draw everything.

if nargin ~= 3
	error('Usage: setObjectColor(objectName, objectColor)');
end

% Locate the object in the queue.
queueIndex = GLWObj.findObjectIndex(objectName);

% Verify the color dimensions.  The check is different depending on the
% object type.
switch GLWObj.Objects{queueIndex}.ObjectType
	% Mondrian
	case GLWindow.ObjectTypes.Mondrian
        objectColor = GLW_ValidateMondrianColors(objectColor, GLWObj.DisplayTypeID);
		
	case GLWindow.ObjectTypes.Image
		error('setObjectColor not allowed on image objects.');
		
	case GLWindow.ObjectTypes.Text
		error('setObjectColor not allowed on text objects.');
		
	case GLWindow.ObjectTypes.PolygonSet
		objectColor = GLW_ValidatePolygonSetColors(objectColor, GLWObj.DisplayTypeID);
		
		% All other object types.
	otherwise
		objectColor = GLW_ValidateRGBColor(objectColor, GLWObj.DisplayTypeID);
end

% Set the color if not in Bits++ mode.  The color values never change
% for the object in Bits++ mode, only the values in the gamma.
if any(GLWObj.DisplayTypeID == [GLWindow.DisplayTypes.BitsPP GLWindow.DisplayTypes.StereoBitsPP])
	g = GLWObj.Gamma;
	for ii = 1:GLWObj.NumWindows
		g{ii}(GLWObj.Objects{queueIndex}.BitsPPIndex,:) = objectColor(ii,:);
	end
	GLWObj.Gamma = g;
else
	GLWObj.Objects{queueIndex}.Color = objectColor;
end
