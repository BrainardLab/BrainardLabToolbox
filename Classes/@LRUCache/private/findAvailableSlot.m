function slotIndex = findAvailableSlot
% slotIndex = findAvailableSlot
%
% Description:
% Looks for an empty slot in the LRU data cache
%
% Output:
% slotIndex (integer) - Index into the LRU data cache that can be used for
%	storing data.  -1 is returned if all slots are occupied.

global g_LRUCacheData;

slotIndex = -1;

for i = 1:length(g_LRUCacheData)
	if isempty(g_LRUCacheData{i})
		slotIndex = i;
		break;
	end
end
