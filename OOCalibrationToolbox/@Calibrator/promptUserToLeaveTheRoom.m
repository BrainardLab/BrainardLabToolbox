% Method to prompt the user about leaving the room
function promptUserToLeaveTheRoom(obj, userPrompt)
    
    if (userPrompt)
        % Make sure that GetChar is actually listening for characters before we call it.
        ListenChar(1);
        FlushEvents;

        if (obj.cal.describe.whichScreen == 1)
            fprintf('Hit any key to proceed past this message and display a box.\n');
            fprintf('Focus radiometer on the displayed box.\n');
            fprintf('Once meter is set up, hit any key - you will get %g seconds\n', obj.cal.describe.leaveRoomTime);
            fprintf('to leave room.\n');
            GetChar;
        else
            fprintf('Focus radiometer on the displayed box.\n');
            fprintf('Once meter is set up, hit any key - you will get %g seconds\n', obj.cal.describe.leaveRoomTime);
            fprintf('to leave room.\n');
        end
    end
end
