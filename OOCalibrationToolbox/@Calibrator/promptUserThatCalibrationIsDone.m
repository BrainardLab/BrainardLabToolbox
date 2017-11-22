% Method to prompt the user that the calibration is done
function promptUserThatCalibrationIsDone(obj,beepWhenDone)

    FlushEvents;
    if (beepWhenDone == 1)
        fprintf('Calibration finished.  Hit a character exit.\n');
        ListenChar(2);
        while (1)
            Snd('Play',sin(0:10000));
            pause(2);
            if (CharAvail)
                break;
            end
        end
        GetChar;
        ListenChar(0);
    elseif (beepWhenDone == 2)
        Snd('Play',sin(0:10000));
        pause(0.3);
        Snd('Play',sin(0:10000));
        try
            sendmail(obj.cal.describe.doneNotificationEmail, 'Calibration Complete', 'All done!');
        catch e
            fprintf('\nCouldn''t send completion email, proceeding anyway.\n');
        end
    end
    
end
