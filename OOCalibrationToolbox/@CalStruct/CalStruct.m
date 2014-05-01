classdef CalStruct < handle

    % Read-write properties.
    properties 
	
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

        % Dictionary for mapping fields of the inputCal format 
        % to field names of the old-style format.
        oldFormatFieldMap;
        
        % Dictionary holding the struct paths (within the inputCal) 
        % of the different old-style format field names.
        calStructPathMap;
    end
    
    % Public methods
    methods
        % Constructor
        function obj = CalStruct(cal)
            obj.inputCal  = cal;
            obj.determineInputCalFormat();
            obj.determineInputCalValidity();
            obj.setFieldMapping();
        end
        
        % Getter method for cal
        function cal = get.cal(obj)
            cal = obj.generateUpdatedCal;
        end
        
        % Getter method for a passed fieldName
        function fieldValue = get(obj, oldFormatFieldName)
            if (obj.fieldNameToGetIsValid(oldFormatFieldName))
                fieldValue = obj.oldFormatFieldMap(oldFormatFieldName);
            else
                fprintf(2, 'Returning an empty value.\n');
                fieldValue = [];
                obj.printMappedFieldNames(); 
            end
        end 
        
        % Setter method for a passed fieldName
        function set(obj, oldFormatFieldName, fieldValue)
            if (obj.fieldNameToGetIsValid(oldFormatFieldName))
                obj.oldFormatFieldMap(oldFormatFieldName) = fieldValue;
            else
                fprintf(2, 'Field name ''%s'' does not exist. Cannot set its value.\n', oldFormatFieldName);
                obj.printMappedFieldNames(); 
            end
        end     
        
    end
   
    % Private methods
    methods (Access = private)
        % Method to determine whether the inputCal has new-style format.
        determineInputCalFormat(obj);
        
        % Method to determine whether the inputCal has the expected basic
        % fields.
        determineInputCalValidity(obj);
        
        % Method to check for the existence of and retrieve the a field's 
        % value and path in cal.
        [fieldValue, fieldPath] = retrieveFieldFromStruct(obj, structure, fieldName);
        
        % Method to check the validity of the requested field name.
        isValid = fieldNameToGetIsValid(obj, oldFormatFieldName);
        
        % Method to print the field names contained in the FieldMap
        printMappedFieldNames(obj);
        
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
    end
    
end