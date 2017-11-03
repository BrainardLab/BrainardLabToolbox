function timedOutFlag = waitForMessageOrTimeout(obj, timeOutSecs)
    tic;
    fprintf('\n');
    timedOutFlag = false;
    while (~lazyCheck(obj)) && (~timedOutFlag)
        elapsedTime = toc;
        if (elapsedTime > timeOutSecs)
            timedOutFlag = true;
            fprintf('>>>Here timeout: %f secs\n', timeOutSecs);
        end
    end
    fprintf('\n');
end

function status = lazyCheck(obj)
    status = matlabNUDP('check', obj.udpHandle);
    % Add a pause so we are not overheating the machine
    pause(0.01);
    fprintf('.'); 
end
