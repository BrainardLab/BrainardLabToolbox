function DrawGrating(window, origin, meshSize, textureOffset, destSize, texture, orientation)
glPushMatrix;

% Move the texture to the origin.
glTranslated(origin(1) - destSize/2, origin(2) - destSize/2, 0);
Screen('EndOpenGL', window);

% Define shifted srcRect that cuts out the properly shifted rectangular
% area from the texture:
srcRect = [-textureOffset, 0, meshSize - textureOffset, meshSize];

% Draw grating texture: Only show subarea 'srcRect'.
Screen('DrawTexture', window, texture, srcRect, [0, 0, destSize, destSize], ...
    orientation);

Screen('BeginOpenGL', window, 1);
glPopMatrix;
