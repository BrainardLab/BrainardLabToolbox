function generateConfigStruct(obj,response)
    % Parse configuration and generate struct
    % Get rid of leading and trailing quotes and trailing CR
    response = response(2:end-2);
    fieldValues = strsplit(response ,',');        
    fieldNames  = {'Status','Lens','AddOn1','AddOn2','AddOn3','Aperture','Units','ExposureMode','ExposureTime','Gain','CyclesAveraged','CIEobserver','DarkMode','SensitivityMode','SyncMode','SyncFrequency'};

    if (str2num(fieldValues{1}) == 0)
        fieldValues{1} = 'OK';
    else
        fieldValues{1} = 'Error';
    end
    
    configStruct = struct();
    for k = 1:numel(fieldValues)
        configStruct.(fieldNames{k}) = fieldValues{k};
    end

    obj.privateCurrentConfiguration = configStruct;
end

