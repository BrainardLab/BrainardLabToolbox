function timedOutFlag = waitForMessageOrTimeout(obj, timeOutSecs, pauseTimeSecs, timeOutMessage)
    tic;
    timedOutFlag = false;
    noInputs = true;
    nDots = -1;
    while (noInputs) && (~timedOutFlag)
        [noInputs, nDots] = lazyCheck(obj, nDots, pauseTimeSecs);
        elapsedTime = toc;
        if (elapsedTime > timeOutSecs)
            timedOutFlag = true;
            executeTimeOut(timeOutMessage);
        end
    end
end

function executeTimeOut( timeOutMessage)
    fprintf(2,'\n\n-----------------------------------------------------------------------------\n');
    fprintf(2,'<strong>Timed out: %s</strong>.', timeOutMessage);
    fprintf(2,'\n-----------------------------------------------------------------------------\n\n');
    error('Communication failure');
end

function [status, nDots] = lazyCheck(obj, nDots, pauseTimeSecs)
    status = ~(matlabNUDP('check', obj.udpHandle));
    % Add a pause so we are not overheating the machine
    if (pauseTimeSecs > 0)
        pause(pauseTimeSecs);
        dotsNumThresholdForPrinting = 10;
        if (nDots > 600)
            fprintf('\n.')
            nDots = 0;
        else
            if (mod(nDots,dotsNumThresholdForPrinting)==0)
                fprintf('.');
            end
        end
        nDots = nDots+1;
    end
end
