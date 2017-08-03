function theStruct = UpdateStructWithStruct(theStruct, deltaStruct, varargin)
% theStruct = UpdateStructWithStruct(theStruct, deltaStruct, varargin)
%
% Takes as input two structures (theStruct, deltaStruct), and replaces the 
% value of each field in theStruct with the value of the corresponding field of the 
% deltaStruct and returns the result.
% The deltaStruct would just have a subset of the fields in theStruct, and it 
% would be an error for there to be a field in the deltaStruct that wasn?t in theStruct.  
% The deltaStruct could, however, be empty in which case theStruct would be returned unaltered
%
% 8/3/17  NPC  Wrote it.

%% Parse input
p = inputParser;
p.addParameter('assertMatchingFieldClass', false, @islogical);
p.addParameter('assertMatchingFieldLength', false, @islogical);
p.parse(varargin{:});
assertMatchingFieldClass = p.Results.assertMatchingFieldClass;
assertMatchingFieldLength = p.Results.assertMatchingFieldLength;

% Return theStruct unaltered if deltaStruct is empty.
if (isempty(deltaStruct))
    return;
end
    
% Assert that deltaStruct has a subset of the fields in theStruct
theStuctFieldnames = fieldnames(theStruct);
theDeltaStructFieldnames = fieldnames(deltaStruct);
assert(prod(ismember(theDeltaStructFieldnames, theStuctFieldnames))==1, 'The second struct fieldnames is not a subset of the fieldnames found in the first struct.');

% Assert that the matched fields are of the same class
if (assertMatchingFieldClass)
    for fieldIndex = 1:numel(theDeltaStructFieldnames)
        targetFieldname = theDeltaStructFieldnames{fieldIndex};
        class1 = class(theStruct.(targetFieldname));
        class2 = class(deltaStruct.(targetFieldname));
        assert(strcmp(class1,class2), sprintf('The field ''%s'' in the first struct is of class: ''%s'', and of class: ''%s'' in the second struct.', targetFieldname, class1, class2));
    end
end

% Assert that the marched fields have the same numerosities
if (assertMatchingFieldLength)
    for fieldIndex = 1:numel(theDeltaStructFieldnames)
        targetFieldname = theDeltaStructFieldnames{fieldIndex};
        n1 = numel(theStruct.(targetFieldname));
        n2 = numel(deltaStruct.(targetFieldname));
        % Only check numerosities for non-char fields
        if (~strcmp(class(theStruct.(targetFieldname)), 'char'))
            assert(n1 == n2, sprintf('The field ''%s'' in the first struct has %d elements and %d elements in the second struct.', targetFieldname, n1, n2));
        end
    end
end

% Assert that theDeltaStructFieldnames are not structs themselves - otherwise we would need recursion
for fieldIndex = 1:numel(theDeltaStructFieldnames)
    targetFieldname = theDeltaStructFieldnames{fieldIndex};
    assert(~isstruct(theStruct.(targetFieldname)), sprintf('The field ''%s'' in the first struct cannot not be a struct.', targetFieldname));
    assert(~isstruct(deltaStruct.(targetFieldname)), sprintf('The field ''%s'' in the first struct cannot not be a struct.', targetFieldname));
end

% Replace the value of each field in theStruct with the value 
% of the corresponding field of the deltaStruct
for fieldIndex = 1:numel(theDeltaStructFieldnames)
    targetFieldname = theDeltaStructFieldnames{fieldIndex};
    theStruct.(targetFieldname) = deltaStruct.(targetFieldname);
end
end