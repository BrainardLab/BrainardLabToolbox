function transmitStructPackages

    %tbUse({'BrainardLabToolbox', 'UnitTestToolbox'});
    
    % Open UDP channel
    localHost = '128.91.12.90';
    remoteHost = '128.91.12.144';
    matlabUDP('open', localHost, remoteHost, 2007);
   
    % The data to be transmitted
    RFpair = struct();
    RFpair.index = 0;
    RFpair.center = [-2.3 4.034];
    RFpair.isUnitVolumeNormalized = false;
    RFpair.phases = {'even', 'odd'};
    RFpair.frequency = 20.0;
    RFpair.sigma = 0.23;
    RFpair.orientation = pi;
    RFpair.spatialSupport = [-1,1 16];
    RFpair.image = rand(16,16);
    
    % Display it nicely
    disp(UnitTest.displayNicelyFormattedStruct(RFpair, 'RFpair', '', 50));
    for i = 1:10
    
        % Wait for a little bit
        pause(0.1); tic
        
        % Send the struct_transmit_initiate token
        matlabUDP('send', 'struct_transmit_initiate');
    
        % Change some fields
        RFpair.index = RFpair.index + 1;
        RFpair.image = rand(16,16);
        
        % Keep a copy of the random image for later visualization
        theImages{i} = RFpair.image;
        
        % Serialize data
        serializedRFpair = getByteStreamFromArray(RFpair);
    
        % Send number of bytes to read
        matlabUDP('send', sprintf('%d', numel(serializedRFpair)));
        
        % Send each byte separately
        for k = 1:numel(serializedRFpair)
            matlabUDP('send',sprintf('%03d', serializedRFpair(k)))
        end
    
         % Send the struct_transmit_terminate token
        matlabUDP('send', 'struct_transmit_terminate');
    
        fprintf('Data packet sent in %2.5f seconds\n', toc);
    end  % for i
    
    % Close UDP channel
    matlabUDP('close');

    % Display images transmitted
    figure(1); clf;
    for k = 1:numel(theImages)
        subplot(2,5,k);
        imagesc(theImages{k});
        colormap(gray)
        axis 'image'
    end
end

    



