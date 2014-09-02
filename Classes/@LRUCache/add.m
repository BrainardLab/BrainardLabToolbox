function obj = add(obj, key, value)
% obj = add(obj, key, value)
%
% Description:
% Adds a key/value pair to the LRU cache.
%
% Input:
% obj (LRUCache) - LRUCache object.
% key (string) - String which identifies the data to cache.  Must be unique
%	in the cache.  Always search for the key before adding it.
% value - Can be any data type, structure, etc.  Will always be associated
%	with 'key'.
%
% Output:
% obj (LRUCache) - Updated LRUCache object.

global g_LRUCacheData;

if nargin ~= 3
	error('Usage: obj = add(obj, key, value)');
end

if ~ischar(key)
	error('key must be a string.');
end

% Look to see if the key was already added.
if ~obj.empty && ~isempty(strmatch(key, obj.keys, 'exact'))
	error('LRUCache/add: key "%s" already added, duplicates not allowed.', key);
end

% If we've moved past the cache limit, toss the key at the bottom of the list.
if obj.top == obj.cacheLimit
	obj.top = obj.cacheLimit;
	
	openSlot = obj.indices{1};

	% Toss the bottom key, index, and the corresponding data cache entry.
	obj.keys(1:obj.cacheLimit-1) = obj.keys(2:obj.cacheLimit);
	obj.indices(1:obj.cacheLimit-1) = obj.indices(2:obj.cacheLimit);
	g_LRUCacheData{openSlot} = [];
else
	% Look for an available data cache slot.
	openSlot = findAvailableSlot;
	if openSlot == -1
		error('No open cache slots available.');
	end
	
	obj.top = obj.top + 1;
end

% Flag the cache as being non empty.
obj.empty = false;

% Stick the key and cache index on top of the LRU cache.
obj.keys{obj.top} = key;
obj.indices(obj.top) = openSlot;

% Add the actual data to the global cache.
g_LRUCacheData{openSlot} = value;
