% Method to shutdown the device
function obj = shutDown(obj)
    
    % Append a message to the file indicating that the sequence is done
    obj.appendMessageToFile("Done");
end