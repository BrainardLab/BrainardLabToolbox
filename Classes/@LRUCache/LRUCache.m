function obj = LRUCache(cacheLimit)
% obj = LRUCache(cacheLimit)

global g_LRUCacheData;

if nargin < 0 || nargin > 1
	error('Usage: obj = LRUCache([cacheLimit])');
end

if ~exist('cacheLimit', 'var') || isempty(cacheLimit)
	cacheLimit = 10;
end

% Create a cell container to hold up to 'cacheLimit' items.
g_LRUCacheData = cell(1, cacheLimit);

obj.keys = cell(1, cacheLimit);
obj.indices = zeros(1, cacheLimit);
obj.top = 0;
obj.cacheLimit = cacheLimit;
obj.empty = true;

obj = class(obj, 'LRUCache');
