function make

LIBS = '-lftgl';
LIBDIR = '-L/usr/local/lib';
INCDIR = '-I/usr/local/include -I/usr/X11/include/freetype2 -I/usr/X11/include';

compileString = sprintf('mex -v -f ftglopts.sh mglPrivateFTGLText.cpp %s %s %s', INCDIR, LIBDIR, LIBS);
eval(compileString);
