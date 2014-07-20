function dumpKeys(obj)
% dumpKeys(obj)

if nargin ~= 1
	error('Usage: dumpKeys(obj)');
end

if obj.top
	for i = 1:obj.top
		fprintf('key %d: %s\n', i, obj.keys{i});
	end
else
	disp('* LRUCache is empty');
end
