function write(object)
% Write the config file to disk.

if nargin ~= 1
	error('Usage: write');
end

% Open the config file for writing.
fid = fopen(object.FileName, 'w');
if fid == -1
	error('Could not open %s', fileName);
end

for i = 1:length(object.RawText)
	fprintf(fid, '%s\n', object.RawText{i});
end

for i = 1:length(object.Params)
   fprintf(fid, '%s:%s:%s:%s\n', object.Params(i).paramName, object.Params(i).paramType, ...
       object.Params(i).paramValRaw, object.Params(i).paramDescription); 
end

fclose(fid);