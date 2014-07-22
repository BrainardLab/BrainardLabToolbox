classdef KeyMaster
% 	properties (SetAccess = private)
% 		KeyMap;
% 	end
	
% 	methods
% 		% Constructor
% 		function KMObj = KeyMaster
% 			keyMap = cell(1, 128);
% 			
% 			for keyCode = 1:128
% 				% Convert the keycode into a regular character.
% 				keyMap(keyCode) = mglKeycodeToChar(keyCode);
% 			end
% 			
% 			KMObj.KeyMap = keyMap;
% 		end
% 	end
	
	methods (Static = true)
		keysFound = inspectKeyPresses(keysOfInterest, keysPressed)
		[keyPressed, detectionTime] = waitForKeyPress(waitDuration)
		[keyPresses, detectionTime] = getKeyPresses
	end
	
	methods (Static = true, Access = private)
		function keyMap = getKeyMap
			persistent p_keyMap
			
			if isempty(p_keyMap)
				p_keyMap = cell(1, 128);
				for keycode = 1:128
					% convert the keycode into a regular character.
					p_keyMap(keycode) = mglKeycodeToChar(keycode);
				end
			end
			
			keyMap = p_keyMap;
		end
	end
end
