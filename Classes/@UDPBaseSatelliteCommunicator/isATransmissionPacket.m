function transmitAction = isATransmissionPacket(direction, hostName)
    transmitAction = false;
    hostEntry = strfind(direction, hostName);
    rightwardArrowEntry = strfind(direction, '->');
    leftwardArrowEntry = strfind(direction, '<-');
    if (~isempty(rightwardArrowEntry))
        if (hostEntry < rightwardArrowEntry)
            transmitAction = true;
        end
    else
        if (isempty(leftwardArrowEntry))
            error('direction field does not contain correct direction information: ''%s''.\n', direction);
        end
        if (hostEntry > leftwardArrowEntry)
            transmitAction = true;
        end
    end
end