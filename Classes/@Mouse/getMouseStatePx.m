function [px, py, buttonState] = getMouseStatePx
% [px, py, buttonState] = getPositionPx
%
% Description:
% Gets the pixel position of the mouse and the current state of the mouse
% buttons.
%
% Output:
% px (scalar) - Horizontal position of the mouse cursor in absolute screen
%   coordinates.
% py (scalar) - Vertical position of the mouse cursor in absolute screen
%   coordinates.
% buttonState (scalar) - 0 if no mouse button is pressed, positive integer
%   if a button(s) is pressed.

m = mglGetMouse;

px = m.x;
py = m.y;
buttonState = m.buttons;
