function DisplayHierarchicalViewOfObjectProperties(objectVar, objectName)
% Method  to display a hierarchical view of an object's properties and
% their values.
%
% @b Description: 
%
% This method is used to display a hierarchical view of an object's
% properties and their values. At the moment this method can dig
% down to four levels deep in the  hierarchy.  Property names are shown in bold, 
% and properties that are structures are labeled in red. 
%
% The following code snippet
%
% @code
% glWindow = GLWindow('SceneDimensions', [1600 1200])
% CodeDevHelper.DisplayHierarchicalViewOfObjectProperties(glWindow, 'win');
% @endcode
%
% produces the following output in Matlab's command window.
% @code
% win : Object of class GLWindow with the following properties:
% |@ DisplayInfo                            : STRUCT array (2 elements, displaying el.#1 only)
% |  |--- isMain                            : 1
% |  |--- modelNumber                       : 45061
% |  |--- screenSizeMM                      : 596.5504,   335.5596
% |  |--- screenSizePixel                   : 2560,       1440
% |  |--- serialNumber                      : 0
% |  |--- vendorNumber                      : 1552
% |  |--- refreshRate                       : 60
% |  |--- openGLacceleration                : 1
% |  |--- unitNumber                        : 0
% |  |--- isStereo                          : 0
% |  |--- bitsPerPixel                      : 32
% |  |--- bitsPerSample                     : 8
% |  |--- samplesPerPixel                   : 3
% |  |--- isCaptured                        : 0
% |  |--- gammaTableWidth                   : empty
% |  |--- gammaTableLength                  : 256
% |  |--- displayBounds                     : 0,          0,       2560,       1440
% |  
% |
% |@ FullScreen                             : 1         
% |@ HideCursor                             : 0         
% |@ Multisampling                          : 1         
% |@ NoWarp                                 : 0         
% |@ NumWindows                             : 1         
% |@ OpenGLDebugLevel                       : 1         
% |@ WindowSize                             : 350       ,        350
% |@ PostProcessingShader                   : empty     
% |@ DiagnosticMode                         : 0         
% |@ SceneDimensions                        : 1600      ,       1200
% |@ Scale                                  : 1         ,          1,          1
% |@ BackgroundColor                        : 0         ,          0,          0,          0
% |@ Gamma                                  : 0         ,  0.0039216,  0.0078431,   0.011765,   0.015686,   0.019608,   0.023529,   0.027451,   0.031373 ... (remaining 246 values not shown)
% |@ InterocularDistance                    : 0         
% |@ Cursor3Dposition                       : STRUCT
% |  |--- virtualXYZposition                : 0,          0,          1
% |  |--- displayXYZposition                : 0,          0,          1
% |  
% |
% |@ DisplayType                            : Normal    
% |@ Is3D                                   : 0         
% |@ WarpFile                               : empty     
% |@ WindowID                               : 2         
% |@ WindowPosition                         : 0         ,          0
% |@ DisplayTypes                           : STRUCT
% |  |--- Normal                            : 1
% |  |--- BitsPP                            : 2
% |  |--- HDR                               : 3
% |  |--- Stereo                            : 4
% |  |--- StereoBitsPP                      : 5
% |  |--- StereoHDR                         : 6
% |  
% |
% |@ ObjectTypes                            : STRUCT
% |  |--- Rect                              : 1
% |  |--- Oval                              : 2
% |  |--- Mondrian                          : 3
% |  |--- Image                             : 4
% |  |--- Text                              : 5
% |  |--- Noise                             : 6
% |  |--- DotSet                            : 7
% |  |--- Cross                             : 8
% |  |--- Triangle                          : 9
% |  |--- Grating                           : 10
% |  |--- Line                              : 11
% |  |--- PolygonSet                        : 12
% |  |--- Wedge                             : 13
% |  |--- MultiChromaDotSet                 : 14
% |  |--- Cursor3D                          : 15
% |  |--- AlignmentGrid                     : 16
% |  
% |
% |@ RenderMethods                          : STRUCT
% |  |--- Normal                            : 1
% |  |--- Texture                           : 2
% |  
% |
% |@ MondrianTypes                          : STRUCT
% |  |--- Normal                            : 1
% |  |--- HorizontalAdelson                 : 2
% |  |--- VerticalAdelson                   : 3
% |  |--- SmoothWall                        : 4
% |  |--- JaggedWall                        : 5
% |  
% |
% |@ DisplayFields                          : STRUCT
% |  |--- StereoHDR                         : left_front
% |  |--- HDR                               : front
% |  |--- Stereo                            : left
% |  
% |
% @endcode
%
% Parameters:
%  objectVar:   -- The object whose properties are to be displayed.
%  objectName:  -- The name of the object.
%
% History:
% @code
% 3/17/2013   npc   Wrote it
% 6/29/2013   npc   Made it work with structs (in addition to objects)
% @endcode
%
        
    if (isobject(objectVar))
        fprintf('\n\n<strong>%s </strong>: Object of class %s with the following properties:\n|\n', objectName, class(objectVar));
        objPropertyNames = properties(objectVar);
    elseif (isstruct(objectVar))
        fprintf('\n\n<strong>%s </strong>: Struct with the following fields:\n|\n', objectName);
        objPropertyNames = fieldnames(objectVar);
    else
        fprintf('%s is not an object or a struct. Displaying nothing.\n', objectName);
        return;
    end


    for objIndex = 1:length(objPropertyNames)
        
       propertyValue = eval(sprintf('objectVar.%s',  objPropertyNames{objIndex}));
       propertyName  = objPropertyNames{objIndex};
       
       if (~isstruct(propertyValue)) 
           isProprety = true;
           spaces = 0;
           DisplayFieldValues(isProprety, propertyName, propertyValue, spaces, objIndex, length(objPropertyNames));
       else
           
           fprintf('|@ <strong>%-38s </strong>:', propertyName); 
           if (length(propertyValue) == 1)
               fprintf(' STRUCT\n');
           else
               fprintf(' STRUCT array (%d elements, displaying el.#1 only)\n', length(propertyValue));
           end
            
           structFieldNames = fieldnames(propertyValue);
                
           for fieldIndex = 1:length(structFieldNames)
               fieldName  = structFieldNames{fieldIndex};
               fieldValue = eval(sprintf('propertyValue.%s', fieldName));
                    
               if (~isstruct(fieldValue))
                   isProprety = false;
                    spaces = 2;
                    DisplayFieldValues(isProprety, fieldName, fieldValue, spaces, fieldIndex, length(structFieldNames));
               else
                    fprintf('|  |\n');
                    fprintf('|  '); fprintf(2,'+>>> % -33s :', fieldName); 
                    if (length(fieldValue) == 1)
                        fprintf(' STRUCT\n');
                    else
                        fprintf(' STRUCT array (%d elements, displaying el.#1 only)\n', length(fieldValue));
                    end
                    
                    substructFieldNames = fieldnames(fieldValue);
                    for subFieldIndex = 1:length(substructFieldNames)
                        
                        subFieldName  = substructFieldNames{subFieldIndex};
                        subFieldValue = eval(sprintf('propertyValue.%s.%s', fieldName, subFieldName));
                        
                        if (~isstruct(subFieldValue)) 
                            isProprety = false;
                            spaces = 4;
                            DisplayFieldValues(isProprety, subFieldName, subFieldValue, spaces, subFieldIndex, length(substructFieldNames));
                        else
                            fprintf('|  |    |\n');
                            fprintf('|  |    '); fprintf(2,'+>>> % -28s :', subFieldName); 
                            if (length(subFieldValue) == 1)
                                fprintf(' STRUCT\n');
                            else
                                fprintf(' STRUCT array (%d elements, displaying el.#1 only)\n', length(subFieldValue));
                            end
                            
                            subsubstructFieldNames = fieldnames(subFieldValue);
                            for subsubFieldIndex = 1:length(subsubstructFieldNames)
                                
                                subsubFieldName  = subsubstructFieldNames{subsubFieldIndex};
                                subsubFieldValue = eval(sprintf('propertyValue.%s.%s.%s', fieldName, subFieldName, subsubFieldName));
                                    
                                if (~isstruct(subsubFieldValue)) 
                                    isProprety = false;
                                    spaces = 6;
                                    DisplayFieldValues(isProprety, subsubFieldName, subsubFieldValue, spaces, subsubFieldIndex, length(subsubstructFieldNames));
                                else
                                    fprintf('|  |    |    |\n');
                                    fprintf('|  |    |    '); fprintf(2,'+>>> % -23s :', subsubFieldName);
                                    if (length(subFieldValue) == 1)
                                        fprintf(' STRUCT\n');
                                    else
                                        fprintf(' STRUCT array (%d elements, displaying el.#1 only)\n', length(subsubFieldValue));
                                    end
                                    
                                    subsubsubstructFieldNames = fieldnames(subsubFieldValue);
                                    for subsubsubFieldIndex = 1:length(subsubsubstructFieldNames)
                                        subsubsubFieldName  = subsubsubstructFieldNames{subsubsubFieldIndex};
                                        subsubsubFieldValue = eval(sprintf('propertyValue.%s.%s.%s.%s', fieldName, subFieldName, subsubFieldName, subsubsubFieldName));
                                        
                                        if (isstruct(subsubsubFieldValue)) 
                                            if (length(subsubsubFieldValue) == 1)
                                                subsubsubFieldValue = sprintf(' STRUCT (fields not displayed)');
                                            else
                                                subsubsubFieldValue = sprintf(' STRUCT array (%d elements) (fields not displayed)', length(subsubsubFieldValue));
                                            end
                                        end
                                        isProprety = false;
                                        spaces = 8;
                                        DisplayFieldValues(isProprety, subsubsubFieldName, subsubsubFieldValue, spaces, subsubsubFieldIndex, length(subsubsubstructFieldNames));
                                            
                                    end
                                end
                            end               
                        end
                    end
                end
           end   % for fieldIndex
           
           fprintf('|\n');
       end 
    end  % objIndex
    
    fprintf('\n\n');

end




function DisplayFieldValues(isProperty, fieldName, fieldValue, blanks, fieldIndex, totalFields)

    if (blanks == 0)
        spaceString = '';
    elseif (blanks == 2)
        spaceString = '|  |---';
    elseif (blanks == 4)
        spaceString = '|  |    |---';
    elseif (blanks == 6)
        spaceString = '|  |    |    |---';
    elseif (blanks >=8)
        spaceString = '|  |    |    |    |---';
    end
        
    countLimit = 10;
    
    if (isempty(fieldValue))
        printString(isProperty, blanks, spaceString, fieldName, 'empty');
        fprintf('\n');
        return;
    end
    
    
    if (ndims(fieldValue) > 1)
         % multi-dimensional, reshape into a 1-D array
         if (iscell(fieldValue))
            fieldValue = fieldValue{:};
         else
            fieldValue = fieldValue(:);
         end
    end
        
    if (iscell(fieldValue))
        % First element
        
        if (length(fieldValue) == 0)
            printString(isProperty, blanks, spaceString, fieldName, '[]');
        else
            printString(isProperty, blanks, spaceString, fieldName, num2str(fieldValue{1}));
            % Remaining elements up to countLimit
            for k = 2:length(fieldValue)
                if (k < countLimit)
                    fprintf(', %10s', num2str(fieldValue{k}));
                elseif (k == countLimit)
                    fprintf(2,' ... (remaining %d values not shown)', length(fieldValue)-countLimit);
                end
            end
        end
    else
        if (ischar(fieldValue))
            printString(isProperty, blanks, spaceString, fieldName, fieldValue);
        else
            % First element
            if (length(fieldValue) == 0)
                printString(isProperty, blanks, spaceString, fieldName, '[]');
            else
                
                if ((isnumeric(fieldValue)) || (islogical(fieldValue)))
                    printString(isProperty, blanks, spaceString, fieldName, num2str(fieldValue(1)));
                    % Remaining elements up to countLimit
                    for k = 2:length(fieldValue)
                        if (k < countLimit)
                            fprintf(', %10s', num2str(fieldValue(k)));
                        elseif (k == countLimit)
                            fprintf(2,' ... (remaining %d values not shown)', length(fieldValue)-countLimit);
                        end
                    end
                
                elseif (isobject(fieldValue))
                    printString(isProperty, blanks, spaceString, fieldName, sprintf('object of class %s', class(fieldValue)));
                end
                
            end
        end
    end
    fprintf('\n');

    
    if (fieldIndex == totalFields)
        if (blanks == 2)
            fprintf('|  \n');
        elseif (blanks == 4)
            fprintf('|  | \n');
        elseif (blanks == 6)
        	fprintf('|  |    | \n');
        elseif (blanks >=8)
        	fprintf('|  |    |    | \n');
        end
    end
    
end



function  printString(isProperty, blanks, spaceString, fieldName, stringText)
   
    if (isProperty)
        fprintf('|@ <strong>%-38s </strong>: %-10s', fieldName, stringText); 
    else
        if (blanks == 0)
            fprintf('%s % -33s : %s', spaceString, fieldName, stringText);
        elseif (blanks == 2)
            fprintf('%s % -33s : %s', spaceString, fieldName, stringText);
        elseif (blanks == 4)
            fprintf('%s % -28s : %s', spaceString, fieldName, stringText);
        elseif (blanks == 6)
            fprintf('%s % -23s : %s', spaceString, fieldName, stringText);
        elseif (blanks >= 8)
            fprintf('%s % -18s : %s', spaceString, fieldName, stringText);
        else
            fprintf('unknown size of blanks');
        end
    end
end