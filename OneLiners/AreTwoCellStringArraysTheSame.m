function areSame = AreTwoCellStringArraysTheSame(array1,array2)
% areSame = AreTwoCellStringArraysTheSame(array1,array2)
%
% Checks whether two cell string arrays have the same number
% of entries and contain entry-wise matching strings.
%
% 7/21/13  dhb  Wrote it.  Probably there is a slicker way.

areSame = true;
if (length(array1) ~= length(array2))
    areSame = false;
    return;
end
for i = 1:length(array1)
    if (~strcmp(array1{i},array2{i}))
        areSame = false;
        return;
    end
end
