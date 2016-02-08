function object = setRawText(object, inputText)
% Write the config file to disk.

if nargin ~= 2
	error('Usage: setRawText');
end

 object.RawText = {inputText};