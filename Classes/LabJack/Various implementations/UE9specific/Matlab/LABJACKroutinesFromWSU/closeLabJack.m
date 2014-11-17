function closeLabJack

    global LABJACKstruct
      
    
    if (isempty(whos('global','LABJACKstruct')) == 0)  % LABJACKstruct has been defined
        
        % Check to see if a device is already open

        if (isfield(LABJACKstruct, 'devicePointerIsValid'))


           if (LABJACKstruct.devicePointerIsValid)

                % Ok, close the device before we open it again
                calllib('liblabjackusb', 'LJUSB_CloseDevice', LABJACKstruct.devicePointer);
                disp('Shutting down LabJack');
            end
        end
    
    end
    
    
end

