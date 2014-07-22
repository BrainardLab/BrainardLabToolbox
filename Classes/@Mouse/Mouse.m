classdef Mouse
	properties (SetAccess = private)
		% Horizontal and vertical cursor positions in pixels.  These are
		% absolute screen coordinates.
		HorizontalPosPx;
		VerticalPosPx;
		MouseStatePx;
		
		% Current state of the mouse button.
		ButtonState;
		
		% Display info from mglDescribeDisplays.
		DisplayInfo;
	end
	
	properties (Access = private)
		% Largest screen height of any screen attached to the computer in
		% pixels.
		MaxDisplayHeight;
	end
	
	methods
		function obj = Mouse(displayInfo)
			if nargin > 1
				error('Usage obj = Mouse([mglDisplayInfo])');
			end
			
			if nargin == 0
				obj.DisplayInfo = mglDescribeDisplays;
			else
				obj.DisplayInfo = displayInfo;
			end
			
			% Find the greatest display height in pixels.
			for i = 1:length(obj.DisplayInfo)
				heightList(i) = obj.DisplayInfo(i).screenSizePixel(2); %#ok<AGROW>
			end
			obj.MaxDisplayHeight = max(heightList);
		end
		
		% Converts the pixel coordinates of the mouse position into
		% centimeters.
		cmCoords = px2cm(obj, targetScreen, screenDimsCm)
	end
	
	methods (Static = true)
		[x, y, b] = getMouseStatePx
		
		isInBox = inBox(mouseBox, mousePos)
	end
	
	% Property access overrides.
	methods
		function mouseState = get.MouseStatePx(obj) %#ok<MANU>
			[mouseState.x, mouseState.y, mouseState.buttonState] = Mouse.getMouseStatePx;
		end
		
		function pos = get.HorizontalPosPx(obj)
			pos = obj.MouseStatePx.x;
		end
		
		function pos = get.VerticalPosPx(obj)
			pos = obj.MouseStatePx.y;
		end
		
		function bState = get.ButtonState(obj)
			bState = obj.MouseStatePx.buttonState;
		end
	end
end
