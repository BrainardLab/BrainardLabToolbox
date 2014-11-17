% Method to prompt the user about leaving the room
function promptUserToLeaveTheRoom(obj, userPrompt)
    
    if (userPrompt)
        % Make sure that GetChar is actually listening for characters before we call it.
        ListenChar(1);
        FlushEvents;

        % Make a local copy of obj.cal so we do not keep calling it and regenerating it
        calStruct = obj.cal;

        if ((calStruct.describe.whichScreen == 1) || ((calStruct.describe.blankOtherScreen == 1)&&(calStruct.describe.whichBlankScreen==1)))
            fprintf('\n\n-----------------------------------------------\n');
            fprintf('Hit any key to proceed past this message and display a box.\n');
            fprintf('Focus radiometer on the displayed box.\n');
            fprintf('Once meter is set up, hit any key - you will get %g seconds\n', obj.cal.describe.leaveRoomTime);
            fprintf('to leave room.\n');
            fprintf('\n-----------------------------------------------\n\n');
            GetChar;
        else
            fprintf('\n\n-----------------------------------------------\n');
            fprintf('Focus radiometer on the displayed box.\n');
            fprintf('Once meter is set up, hit any key - you will get %g seconds\n', obj.cal.describe.leaveRoomTime);
            fprintf('to leave room.');
            fprintf('\n-----------------------------------------------\n\n');
        end
    end
end
