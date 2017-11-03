function timedOutFlag = waitForMessageOrTimeout(obj, timeOutSecs)
    tic;
    fprintf('\n');
    timedOutFlag = false;
    noInputs = true;
    nDots = 0;
    while (noInputs) && (~timedOutFlag)
        [noInputs, nDots] = lazyCheck(obj, nDots);
        elapsedTime = toc;
        if (elapsedTime > timeOutSecs)
            timedOutFlag = true;
            fprintf('>>>Here timeout: %f secs\n', timeOutSecs);
        end
    end
    fprintf('\n');
end

function [status, nDots] = lazyCheck(obj, nDots)
    status = ~(matlabNUDP('check', obj.udpHandle));
    % Add a pause so we are not overheating the machine
    pause(0.01);
    nDots = nDots+1;
    if (nDots > 60)
        fprintf('\n.')
        nDots = 0;
    else        
        fprintf('.');
    end
    
end
