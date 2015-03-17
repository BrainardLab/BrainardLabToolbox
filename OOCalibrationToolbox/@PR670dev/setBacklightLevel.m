% Method to set the backlight level
function setBacklightLevel(obj, level)

    level = round(level);
    
    if (level < 0)
        level = 0;
    end
    if (level > 99)
        level = 99;
    end
    
    obj.writeSerialPortCommand('commandString', sprintf('B%2d',level));
end

