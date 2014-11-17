function images = dumpSceneToTiff(GLWObj, tiffFileName)
% images = dumpSceneToTiff(tiffFileName)
%
% Description:
% Dumps the scene in the GLWindow to an uncompressed tif file.
%
% Input:
% tiffFileName (string) - Name of the outputted tif file.
%
% Output:
% images (cell array) - Each cell contains the image from each window.

% This function is pretty slow right now, I'll need to figure out a way to
% make it faster in Matlab or write it in C.

global GL MGL;

if nargin ~= 2
	error('Usage: images = dumpSceneToTiff(tiffFileName)');
end

% Draw the scene again to make sure everything in the framebuffer.
GLWObj.draw;

fprintf('* Dumping scene to TIF...');

for k = 1:GLWObj.NumWindows
	mglSwitchDisplay(GLWObj.WindowInfo(k).WindowID);
	
	% Grab all the pixels.
	if exist('mglFrameGrab', 'file')
		pxData = double(mglFrameGrab);
	else
		pxData = glReadPixels(0, 0, MGL.screenWidth, MGL.screenHeight, GL.RGB, GL.FLOAT);
	end
	
	% Rotate the dumped pixels 90 degrees counter clockwise, otherwise the
	% image will be rotated wrong.
	imData = zeros(size(pxData, 2), size(pxData, 1), 3);
	for i = 1:size(pxData, 2)
		for j = 1:size(pxData, 1)
			imData(MGL.screenHeight-i+1, j, :) = pxData(j, i, :);
		end
	end
	
	if exist('mglFrameGrab', 'file')
		imData = flipdim(imData, 1);
	end
	
	% The first field of the struct images is the front screen image, the
	% second field is the back plane image.
	images{k} = imData ./ 255; %#ok<AGROW>
	
	[p, n] = fileparts(tiffFileName);
	imwrite(imData, fullfile(p, sprintf('%s-%d.tif', n, k)), 'tif', ...
		'Compression', 'none');
end

fprintf('Done\n');
