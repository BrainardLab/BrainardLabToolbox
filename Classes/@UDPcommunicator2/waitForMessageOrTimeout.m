function timedOutFlag = waitForMessageOrTimeout(obj, timeOutSecs)
    tic;
    timedOutFlag = false;
    while (~matlabUDP('check')) && (~timedOutFlag)
        elapsedTime = toc;
        if (elapsedTime > timeOutSecs)
            timedOutFlag = true;
        end
    end
end