function executeTimeOut(obj, timeOutMessage, timeOutAction)
    if sprintf(timeOutAction, obj.THROW_ERROR)
        error('Timed out %s.\n', timeOutMessage);
    else
        fprintf(2, 'Timed out %s. Caller must handle what happens next.\n', timeOutMessage);
    end
end