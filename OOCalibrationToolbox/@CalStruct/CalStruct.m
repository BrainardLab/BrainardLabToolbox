classdef CalStruct < handle

    % Read-write properties.
    properties 
        verbosity = 1;
    end % Public properties
    
    % Read-only properties
    properties (SetAccess = private) 
        % copy of the modified private property inputCal
        cal;
    end
    
    % invisible - to the user properties
    properties (Access = private)
        % The cal struct that we got during instantiation. 
        % This will be modified via calls to calStruct.set(fieldName, fieldValue);
        inputCal;
        
        % Flag indicating whether the inputCal has new-style format.
        inputCalHasNewStyleFormat;

        % Dictionary for mapping unified field names
        fieldMap;
        
        % properties holding all the cal fields that can be addressed by a unified field name
        % General info
        describe___computerInfo;
        describe___svnInfo;
        describe___matlabInfo;
        
        backgroundDependenceSetup___bgSettings;
    end
    
    
    % Public methods
    methods
        % Constructor
        function obj = CalStruct(cal)
            obj.setFieldMapping();
            obj.parseInputCal(cal);
        end
        
        % Getter method for cal
        function cal = get.cal(obj)
            cal = obj.generateUpdatedCal;
        end
        
        
        % Getter method for a passed fieldName
        function fieldValue = get(obj, unifiedFieldName)

            if (obj.fieldNameIsValid(unifiedFieldName))
                % Find the corresponding property name
                propertyName = obj.fieldMap(unifiedFieldName).propertyName;

                % Call the getter for that property
                fieldValue = eval(sprintf('obj.%s;',propertyName));
            else
                fprintf(2, 'Unknown unified field name (''%s''). Cannot get its value.\n', unifiedFieldName);
                obj.printMappedFieldNames(); 
            end     
        end 
        
        % Setter method for a passed fieldName
        function set(obj, unifiedFieldName, fieldValue)
            
            if (obj.fieldNameIsValid(unifiedFieldName))
                % Find the corresponding property name
                propertyName = obj.fieldMap(unifiedFieldName).propertyName;

                % Call the setter for that property
                size(eval(sprintf('obj.%s',propertyName)))
                eval(sprintf('obj.%s = fieldValue;',propertyName));     
            else
                fprintf(2, 'Unknown unified field name (''%s''). Cannot set its value.\n', unifiedFieldName);
                obj.printMappedFieldNames(); 
            end
        end     
        
    end
   
    % Private methods
    methods (Access = private)

        % Method to parse the input cal struct
        function parseInputCal(obj, cal)
            % make a private copy
            obj.inputCal = cal;
            % detemine input cal format
            obj.determineInputCalFormat();
            % load all known fields
            unifiedFieldNames = keys(obj.fieldMap);
            for k = 1:numel(unifiedFieldNames)
                % retrieve path in input cal
                if (obj.inputCalHasNewStyleFormat)
                    calPath = obj.fieldMap(unifiedFieldNames{k}).newCalPath;
                else
                    calPath = obj.fieldMap(unifiedFieldNames{k}).oldCalPath;
                end
                % set the corresponding private property
                propertyName = obj.fieldMap(unifiedFieldNames{k}).propertyName;
                propertyValue = eval(sprintf('cal.%s;',calPath));
                eval(sprintf('obj.%s = propertyValue;',propertyName));
                % Check if we need to convert the property to old-style format
                if isfield(obj.fieldMap(unifiedFieldNames{k}), 'newToOldConversionFname') && (obj.inputCalHasNewStyleFormat)
                    conversionFunctionHandle = obj.fieldMap(unifiedFieldNames{k}).newToOldConversionFname;
                    fprintf('Will convert the value of cal.%s to old-style format. \n', calPath);
                    propertyValue = conversionFunctionHandle(propertyValue); 
                end
                fprintf('%d. Loading %-40s <- cal.%s \n', k, propertyName, calPath);
                eval(sprintf('obj.%s = propertyValue;',propertyName));
            end
            fprintf('Finished parsing input cal.\n');
        end
        
        % Method to determine whether the inputCal has new-style format.
        determineInputCalFormat(obj);
        
        % Method to determine whether the inputCal has the expected basic
        % fields.
        determineInputCalValidity(obj);
        
        % Method to check the validity of the requested unified field name.
        isValid = fieldNameIsValid(obj, unifiedFieldName);
        
        % Method to print the field names contained in the FieldMap
        printMappedFieldNames(obj);
        
        % Method to check for the existence of and retrieve the a field's 
        % value and path in cal.
        [fieldValue, fieldPath] = retrieveFieldFromStruct(obj, structure, fieldName);
        
     
        

        
        % Method to combine svnInfo and matlabInfo into a single struct
        % as was done in the old-style format
        [svnInfo, path] = makeOldStyleSVNInfo(obj);
        
        % Method to make old-style meter type. In OOC calibration we store
        % the meter model as a string.
        [meterType, path] = makeOldStyleMeterType(obj);
        
        % Methods to pack the raw data in the old-style way.
        [monIndex, path]    = makeOldStyleMonIndex(obj);
        [monSpd, path]      = makeOldStyleMonSpd(obj);
        [mon, path]         = makeOldStyleMon(obj);
        [spectra, path]     = makeBgMeasSpectra(obj);
        [gammaInput, path]  = makeOldStyleRawGammaInput(obj);
        
        cal = generateUpdatedCal(obj);

        function svn = SVNconversion(obj, propertyValue)
           svn.svnInfo    = obj.describe___svnInfo;
           svn.matlabInfo = obj.describe___matlabInfo;
        end
        
         
    end

end