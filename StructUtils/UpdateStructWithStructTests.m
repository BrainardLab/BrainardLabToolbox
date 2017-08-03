function UpdateStructWithStructTests()
% UpdateStructWithStructTests
%
% Some basic unit tests for UpdateStructWithStruct
%
% 8/3/17  NPC  Wrote it.

%% TEST 1
testName = 'test1-pass';
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
    fprintf('Caught the following error: %s\n', err.message);
end


%% TEST 2
testName = 'test2-fields of different class types - pass because flag is not set';
deltaFilter = struct(...
        'name', 'gabor2', ...
        'phase', 'pi' ...
    );
try
    spatialFilter3 = UpdateStructWithStruct(spatialFilter1,deltaFilter, 'assertMatchingFieldClass', false);
catch err
    fprintf('Caught the following error: %s\n', err.message);
end


%% TEST 3
testName = 'test3-fields of different class types - fail because flag is set';
try
    spatialFilter4 = UpdateStructWithStruct(spatialFilter1,deltaFilter, 'assertMatchingFieldClass', true);
catch err
    fprintf('Caught the following error: %s\n', err.message);
end


%% TEST 4
testName = 'test4-fields of different numerosities - fail because flag is  set';
deltaFilter = struct(...
        'name', 'gabor2', ...
        'phase', [pi pi/2] ...
    );
try
    spatialFilter5 = UpdateStructWithStruct(spatialFilter1,deltaFilter, ...
        'assertMatchingFieldClass', true, ...
        'assertMatchingFieldLength', true ...
        );
catch err
    fprintf('Caught the following error: %s\n', err.message);
end

%% TEST 5
testName = 'test5-field not found in first struct - Fail';
deltaFilter = struct(...
        'name', 'gabor2', ...
        'phase', pi, ...
        'exp', 2.4 ...
    );
try
    spatialFilter5 = UpdateStructWithStruct(spatialFilter1,deltaFilter, 'assertMatchingFieldClass', true);
catch err
    fprintf('Caught the following error: %s\n', err.message);
end

end


