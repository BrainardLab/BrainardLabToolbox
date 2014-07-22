function [obj, data] = search(obj, key)
% [obj, data] = search(obj, key)

global g_LRUCacheData;

if nargin ~= 2
	error('Usage: [obj, data] = search(obj, key)');
end

if nargout ~= 2
	error('search returns 2 arguments that must be set.');
end

% Make sure key is a string.
if ~ischar(key)
	error('key must be a string');
end

% Look for the key in our cache.
i = strmatch(key, obj.keys, 'exact');

if isempty(i)
	% Key not in the cache, so return empty.
	data = [];
else
	% Make sure only 1 match was returned.  Multiple matches implies something
	% wrong with the cache system.
	if length(i) ~= 1
		error('Too many matches, cache is corrupt.');
	end
	
	% Now move the just accessed key to the top of the LRU cache list if
	% not already at the top.
	if i ~= obj.top
		% Make a temporary copy of the key and its data as we will
		% overwrite them in the next step.
		k = obj.keys(i);
		d = obj.indices(i);
		
		% Shift all key/data values above the selected ones down in the LRU list.
		obj.keys(i:obj.top-1) = obj.keys(i+1:obj.top);
		obj.indices(i:obj.top-1) = obj.indices(i+1:obj.top);
		
		% Stick the key at the top of the LRU.
		obj.keys(obj.index) = k;
		obj.indices(obj.top) = d;
	end
	
	% Grab the data cache entry referenced by the top LRU entry.
	data = g_LRUCacheData{obj.indices(obj.top)};
end
