function expandedResponseStruct = ExpandResponseStruct(responseStruct, newLength)
% expandedResponseStruct = ExpandResponseStruct(responseStruct, newLength)
%
% Descriptions:
% Takes a responseStruct and expands its number of columns to "newLength",
% filling in NaNs were there is no defined data.

% Get the size of the original struct.
oDims = size(responseStruct);

% Get the fieldnames.
fNames = fieldnames(responseStruct);

for i = 1:length(fNames)
	expandedResponseStruct.(fNames{i}) = NaN;
end

% Repmat the struct into the new size.
expandedResponseStruct = repmat(expandedResponseStruct, oDims(1), newLength);

% Stick the old values into the new struct array.
for i = 1:oDims(1)
	% Sort the values into their original array order.
	[s, si] = sort([responseStruct(i,:).colorIndex]);
	
	% Stick the sorted struct array for this block into the new embiggened
	% struct array.
	expandedResponseStruct(i, s) = responseStruct(i, si);
end
