function timedOutFlag = waitForMessageOrTimeout(obj, timeOutSecs)
    tic;
    timedOutFlag = false;
    while (~matlabNUDP('check', obj.udpHandle)) && (~timedOutFlag)
        elapsedTime = toc;
        if (elapsedTime > timeOutSecs)
            timedOutFlag = true;
            fprintf('>>>Here timeout: %f secs\n', timeOutSecs);
        end
    end
end