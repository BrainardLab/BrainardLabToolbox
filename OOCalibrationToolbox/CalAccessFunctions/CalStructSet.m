function destinationCalStruct = CalStructSet(sourceCalStruct, targetFieldName, fieldValue)
% Function to set values of calStruct fields that follow either the old
% format or the new format (implemented in the @Calibrator class). The
% input fieldname corresponds to the one that appeared in old-format
% calStructs. This function is to be used by PTB-3 functions so that they
% remain agnostic as to the format (new or old) of the calStruct.
% 
% 4/21/2014   npc   Wrote it.
%
% Usage examples:
% -------------------------------------------------------------------------
% % Set the gamma mode (a run-time propery of calStruct) to a desired value
% cal = CalStructSet(cal, 'gammaMode', desiredGammaModeVal);
%
% % Set the inverse gamma table (a run-time propery of calStruct) to a desired value
% cal = CalStructSet(cal, 'iGammaTable', desiredIGammaTable);
% 
% % Set the number of primary bases
% cal = CalStructSet(cal, 'nPrimaryBases', desiredPrimaryBasesNum);
%
% % Other examples.
% cal = CalStructSet(cal, 'S_device', desired_Sdevice);                  
% cal = CalStructSet(cal, 'P_device', desired_Pmon);                    
% cal = CalStructSet(cal, 'T_device', desired_Tdevice);                  
% cal = CalStructSet(cal, 'rawGammaTable', desiredRawGammaTable);        
% cal = CalStructSet(cal, 'monSVs', desired_monSVs); 
%
% 'doc CalStructSet' for more information on the accessible fieldnames.
% -------------------------------------------------------------------------

%   Generate a replica of the source CalStruct
    destinationCalStruct = sourceCalStruct;
    
    % Find the path (within the calStruct) of the targetFieldName
    if (CalStructHasNewStyleFormat(sourceCalStruct))    
        % OldFieldName, newCalStruct.
        % Translate targetFieldName (in oldStruct) to its newStruct name
        [translatedFieldName, ~] = ...
            PathOrValueOfOldFieldNameFromNewCalStruct(sourceCalStruct, targetFieldName);
        if isempty(translatedFieldName)
            error('CalStructSet() could not find the corresponding name of ''%s'' in the newStruct.', targetFieldName);
        elseif (~isempty(strfind(translatedFieldName, 'raw')))
            % if there is raw in the name do not strip the '.'
            fieldNameStructPath = translatedFieldName;
        else
            % strip everything before the last '.'
            indices = strfind(translatedFieldName, '.');
            translatedFieldName = translatedFieldName(indices(end)+1:end);
            fieldNameStructPath  = FieldPathInNewCalStruct(sourceCalStruct, translatedFieldName, '');
        end
    else
        % OldFieldName, oldStruct. No translation needed.
        fieldNameStructPath = FieldPathInOldCalStruct(sourceCalStruct, targetFieldName, '');
    end
    
    % Update targetFieldName
    if isempty(fieldNameStructPath)
        % targetFieldName was not found in calStruct, so add it as a new field
        fprintf('<strong> >> CalStructSet:: Did not find field ''%s'' in CalStruct, so will add it at the root. </strong>\n', targetFieldName);
        eval(sprintf('destinationCalStruct.%s = fieldValue;', targetFieldName));
    else
        fprintf('<strong> >> CalStructSet:: Setting value of destinationCalStruct.%s </strong>\n', fieldNameStructPath);
        % targetFieldName was found in calStruct, so update its value
        eval(sprintf('destinationCalStruct.%s = fieldValue;', fieldNameStructPath));
    end    
end

