function checksum16 = calculateChecksum16(buffer, n)


    uint16buffer = uint16(buffer);
    checksum16   = sum(uint16buffer(7:n));
    
end
    
    
