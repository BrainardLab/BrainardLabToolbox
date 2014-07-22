function checksum8 = calculateChecksum8(buffer)
    
    uint16buffer = uint16(buffer);
    
    checksum8   = sum(uint16buffer(2:6));


    temp        = bitshift(checksum8,-8);
  
    checksum8   = (checksum8 - 256 * temp ) + temp;
    temp        = uint16(bitshift(checksum8,-8));
    
    checksum8   = uint8( (checksum8 - 256 * temp) + temp );
    

end