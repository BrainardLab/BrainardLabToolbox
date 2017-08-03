function UpdateStructWithStructTests()
% UpdateStructWithStructTests
%
% Some basic unit tests for UpdateStructWithStruct
%
% 8/3/17  NPC  Wrote it.

%% TEST 1
testName = 'test1-pass';
fprintf('\n%s\n', testName);
spatialFilter1 = struct(...
        'name', 'cos', ...
        'center', 0.0, ...
        'sigma', 0.2, ...
        'phase', pi/2 ...
    );

deltaFilter = struct(...
        'name', 'sin', ...
        'phase', pi ...
    );

try
    spatialFilter2 = UpdateStructWithStruct(spatialFilter1,deltaFilter, 'assertMatchingFieldClass', true);
catch err
    fprintf('\tCaught the following error: %s\n', err.message);
end


%% TEST 2
testName = 'test2-fields of different class types - pass because flag is not set';
fprintf('\n%s\n', testName);
deltaFilter = struct(...
        'name', 'gabor2', ...
        'phase', 'pi' ...
    );
try
    spatialFilter2 = UpdateStructWithStruct(spatialFilter1,deltaFilter, 'assertMatchingFieldClass', false);
catch err
    fprintf('\tCaught the following error: %s\n', err.message);
end


%% TEST 3
testName = 'test3-fields of different class types - fail because flag is set';
fprintf('\n%s\n', testName);
try
    spatialFilter2 = UpdateStructWithStruct(spatialFilter1,deltaFilter, 'assertMatchingFieldClass', true);
catch err
    fprintf('\tCaught the following error: %s\n', err.message);
end


%% TEST 4
testName = 'test4-fields of different numerosities - fail because flag is  set';
fprintf('\n%s\n', testName);
deltaFilter = struct(...
        'name', 'gabor2', ...
        'phase', [pi pi/2] ...
    );
try
    spatialFilter2 = UpdateStructWithStruct(spatialFilter1,deltaFilter, ...
        'assertMatchingFieldClass', true, ...
        'assertMatchingFieldLength', true ...
        );
catch err
    fprintf('\tCaught the following error: %s\n', err.message);
end

%% TEST 5
testName = 'test5- matching fields are structs - pass because allowStructFields flag is set';
fprintf('\n%s\n', testName);
deltaFilter = struct(...
        'name', 'gabor2', ...
        'phase', struct('value', pi) ...
    );
spatialFilter = spatialFilter1;
spatialFilter.phase = deltaFilter.phase;
try
    spatialFilter2 = UpdateStructWithStruct(spatialFilter,deltaFilter, ...
        'assertMatchingFieldClass', true, ...
        'assertMatchingFieldLength', true, ...
        'allowStructFields', true ...
        );
catch err
    fprintf('\tCaught the following error: %s\n', err.message);
end

%% TEST 6
testName = 'test6- matching fields are structs - fail because allowStructFields flag is not set';
fprintf('\n%s\n', testName);
try
    spatialFilter2 = UpdateStructWithStruct(spatialFilter1,deltaFilter, ...
        'assertMatchingFieldClass', true, ...
        'assertMatchingFieldLength', true ...
        );
catch err
    fprintf('\tCaught the following error: %s\n', err.message);
end


%% TEST 7
testName = 'test7-field not found in first struct - fail';
fprintf('\n%s\n', testName);

deltaFilter = struct(...
        'name', 'gabor2', ...
        'phase', pi, ...
        'exp', 2.4 ...
    );
try
    spatialFilter2 = UpdateStructWithStruct(spatialFilter,deltaFilter, 'assertMatchingFieldClass', true);
catch err
    fprintf('\tCaught the following error: %s\n', err.message);
end

end


