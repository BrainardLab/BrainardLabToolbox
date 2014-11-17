function GenerateAndSaveUnwarpCalibrationStructure(screenWidthInPixels, screenHeightInPixels, Xnominal, Ynominal, Xdistorted, Ydistorted, calFileName)

    invertYaxis = true;   % calibration grid must have reversed y-axis
    calibrationGridVertexArray = GenerateGridMeshVertices(screenWidthInPixels, screenHeightInPixels, Xnominal, Ynominal, invertYaxis);
   
    invertYaxis = false;   % distortion grid must have upright y-axis
    distortedGridVertexArray = GenerateGridMeshVertices(screenWidthInPixels, screenHeightInPixels, Xdistorted, Ydistorted, invertYaxis);
        
    % Generate warp struct
    warpStruct = struct(...
        'warpType', 'ArbitraryDeformation',...
        'calibrationGridVertexArray',   calibrationGridVertexArray, ...
        'distortedGridVertexArray',     distortedGridVertexArray, ...
        'screenWidthInPixels',          screenWidthInPixels, ...
        'screenHeightInPixels',         screenHeightInPixels ... 
        );
    
    % Generate describe struct
    describeStruct = struct('date', datestr(now));
    
    % Assemble into one struct for exporting
    cal = struct('describe',   describeStruct, ...
                 'warpParams', warpStruct ...
                );
                 
    SaveCalFile(cal, calFileName);
    fprintf('\n\nUnwarp calibration struct saved to ''%s''.\n', calFileName);
end