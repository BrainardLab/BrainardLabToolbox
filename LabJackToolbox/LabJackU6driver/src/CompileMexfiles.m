function CompileMexfiles

	compileMexFile = true;
    if (compileMexFile)
        [dirName, ~] = fileparts(which(mfilename()));
        cd(dirName);
        % Compile the U3 mexfile
        mex -v -output LJU6 LDFLAGS="\$LDFLAGS -weak_library /usr/local/Cellar/exodriver/2.5.3/lib/liblabjackusb.dylib -weak_library /usr/local/Cellar/libusb/1.0.21/lib/libusb-1.0.dylib" CFLAGS="\$CFLAGS -Wall -g" -I/usr/include -I/usr/local/Cellar/exodriver/2.5.3/include -I/usr/local/Cellar/libusb/1.0.21/include/libusb-1.0 "u6.c"
     end

    return;
    
end

