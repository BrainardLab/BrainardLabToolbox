function status = transmitWordToBionics(word)

    global Stimulator
    
    
    status = setDIOword(Stimulator.Bionics.Constants.WordSeparator);
    if (status ~= 0) return;  end
    
    status = setDIOword(word);
    if (status ~= 0) return;  end
    
    
end