function isInBox = inBox(mouseBox, mousePos)

left = mouseBox(1);
right = mouseBox(2);
top = mouseBox(3);
bottom = mouseBox(4);

if isstruct(mousePos)
	mousePos = [mousePos.x, mousePos.y];
end

if isempty(mousePos)
	isInBox = false;
elseif mousePos(1) >= left && mousePos(1) <= right && mousePos(2) <= top && mousePos(2) >= bottom
	isInBox = true;
else
	isInBox = false;
end
