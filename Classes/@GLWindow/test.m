function test

warpFile.left = 'StereoWarp-NoRadiance-left';
warpFile.right = 'StereoWarp-NoRadiance-right';

w = GLWindow('SceneDimensions', [40 30, 76.4], 'BackgroundColor', zeros(2,3), ...
	'InterocularDistance', 6, 'DisplayType', 'Stereo', 'WarpFile', warpFile);

try
	c.left = rand(5,5,3);
	c.right = c.left;
	w.addMondrian(5, 5, [10 10], c, 'Name', 'mon', ...
		'Rotation', [0 0 0 0], 'Center', [0 0 0]);
	
	w.setMondrianPatchDepth('mon', 3, 3, 5);
	
% 	for i = 1:5
% 		for j = 1:5
% 			w.setMondrianPatchDepth('mon', i, j, rand*5);
% 		end
% 	end

%	w.addRectangle([0 0 30], [5 5], [1 0 0;1 0 0], 'Name', 'sq1', 'Rotation', [0 0 1 0]);
	
	w.open;
	w.draw;
	
	mglGetKeyEvent;
	
	keepLooping = true;
	while keepLooping
		key = mglGetKeyEvent;
		if ~isempty(key)
			switch key.charCode
				case 'q'
					keepLooping = false;
					
				case 'r'
					patchID = GetInput('Which Patch', 'number', 2);
					depth = GetInput('Depth', 'number', 1);
					
					w.setMondrianPatchDepth('mon', patchID(1), patchID(2), depth);
					
					% Clear the keyboard buffer.
					mglGetKeyEvent;
			end
		end
		
		w.draw;
	end
	
	w.close;
catch e
	w.close;
	rethrow(e);
end