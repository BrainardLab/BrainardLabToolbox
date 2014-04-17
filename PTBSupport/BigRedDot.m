function BigRedDot(radius, viewDist, screenDims)

if nargin ~= 3
	error('Usage: BigRedDot(radius, viewDist, screenDims)');
end

% Turn off annoying warning messages.
Screen('Preference', 'SuppressAllWarnings', 1);

% Required for using MOGL.
InitializeMatlabOpenGL;

% Create the display.
params.screenNumber = max(Screen('Screens'));
[params.window, params.rect] = Screen('OpenWindow', params.screenNumber);

params.radius = tan(radius/180*pi)*viewDist;
params.viewDist = viewDist;
params.screenDims = screenDims;

Screen('BeginOpenGL', params.window, 1);

% Initialize the OpenGL workspace.
InitOpenGL(params);

glClear;
glColor3dv([1 0 0]);
DrawDisk(params.radius-0.1, params.radius, 100, 2, 0, 360);

Screen('EndOpenGL', params.window);

Screen('Flip', params.window);

ListenChar(2);
FlushEvents;
GetChar;
ListenChar(1);

Screen('CloseAll');



% --- Initializes the OpenGL workspace.
function InitOpenGL(params)
global GL;

% This makes the fixation point a circle instead of a square.
glEnable(GL.POINT_SMOOTH);
glEnable(GL.BLEND);
glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

glShadeModel(GL.FLAT);
glClearColor(1, 1, 1, 0);

glMatrixMode(GL.PROJECTION);
glLoadIdentity;
glOrtho(-params.screenDims(1)/2, params.screenDims(1)/2, -params.screenDims(2)/2, params.screenDims(2)/2, 0, 1);

