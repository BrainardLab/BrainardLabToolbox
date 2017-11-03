function timedOutFlag = waitForMessageOrTimeout(obj, timeOutSecs)
    tic;
    timedOutFlag = false;
    while (~lazyCheck(obj)) && (~timedOutFlag)
        elapsedTime = toc;
        if (elapsedTime > timeOutSecs)
            timedOutFlag = true;
            fprintf('>>>Here timeout: %f secs\n', timeOutSecs);
        end
    end
end

function status = lazyCheck(obj)
    status = matlabNUDP('check', obj.udpHandle);
    % Add a pause so we are not overheating the machine
    pause(0.01);
    fprintf('[%s] Waiting for input %s\n',datestr(now)); 
end
