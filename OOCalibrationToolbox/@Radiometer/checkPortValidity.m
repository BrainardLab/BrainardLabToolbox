% Method to check the validity of the selected port
 function invalidPort = checkPortValidity(obj, invalidPortStrings)    
    invalidPort = false;
    for invalidPortStringIndex = 1:length(invalidPortStrings)
        if (~isempty(strfind(obj.portString, char(invalidPortStrings(invalidPortStringIndex)))))
            invalidPort = true;
        end
    end
end