function status = connectToLabJack

    
    
    global LABJACKstruct

    status = -1;
    
    if (isempty(whos('global','LABJACKstruct')) == 0)  % LABJACKstruct has been defined
        
        
        if (isfield(LABJACKstruct, 'devicePointerIsValid'))
        % check to see if the pointer to the Device is valid
        
            if (~LABJACKstruct.devicePointerIsValid)  % not valid, try to re-open LabJack
                status = tryToOpenLabJack;
            else  % we have a valid device pointer
                status = 0;
            end
            
        else
            status =  tryToOpenLabJack;
        end
        
        
    else   % LABJACKstruct has NOT been defined, so open LabJack now
         status =  tryToOpenLabJack;
    end
    
    

end
 
function status = tryToOpenLabJack

    
    
    status = openLabJack;

    if (status ~= 0)  % wait for a minute and try again
        pause(2.0);
        status = openLabJack;
    end
    
    
    if (status ~= 0)
        h = msgbox('Cannot Communicate with LABJACK !!!');
        uiwait(h);
    end
    
    
end



    

