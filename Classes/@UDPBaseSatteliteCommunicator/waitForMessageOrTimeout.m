function timedOutFlag = waitForMessageOrTimeout(obj, timeOutSecs)
    tic;
    timedOutFlag = false;
    while (~matlabNUDP('check', obj.udpHandle)) && (~timedOutFlag)
        elapsedTime = toc;
        if (elapsedTime > timeOutSecs)
            timedOutFlag = true;
        end
    end
end