function timedOutFlag = waitForMessageOrTimeout(obj, timeOutSecs)
    tic;
    timedOutFlag = false;
    noInputs = true;
    nDots = -1;
    while (noInputs) && (~timedOutFlag)
        [noInputs, nDots] = lazyCheck(obj, nDots);
        elapsedTime = toc;
        if (elapsedTime > timeOutSecs)
            timedOutFlag = true;
            fprintf('>>>Here timeout: %f secs\n', timeOutSecs);
        end
    end
end

function [status, nDots] = lazyCheck(obj, nDots)
    status = ~(matlabNUDP('check', obj.udpHandle));
    % Add a pause so we are not overheating the machine
    pause(0.01);
    if (1==2)
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
