function executeTimeOut(obj, timeOutMessage, timeOutAction)
    if strcmp(timeOutAction, obj.THROW_ERROR)
        error('\nTimed out: %s. Check remote host.\n', timeOutMessage);
    else
        fprintf(2, '\nTimed out %s.\n', timeOutMessage);
    end
end