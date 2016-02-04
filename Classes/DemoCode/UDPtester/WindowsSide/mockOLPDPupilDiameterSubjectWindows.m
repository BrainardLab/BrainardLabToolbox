function mockOLPDPupilDiameterSubjectWindows

    params = initParams();

    % Open ip the UDP communication
    matlabUDP('close');
    matlabUDP('open',params.winHostIP,params.macHostIP,params.udpPort);

    fprintf('Waiting for Mac to tell us to go\n');
    numStims = VSGOLGetNumberStims;

end

function numStims = VSGOLGetNumberStims
    % numStims = VSGOLGetNumberStims
    % Get the number of trials from the Mac
    temp = VSGOLGetInput;
    fprintf('Number of stims (%s) received!',temp);
    numStims = str2num(temp);
    matlabUDP('send',sprintf('Number of stimuli: %f received!!!',numStims));
end

function data = VSGOLGetInput
    % data = VSGOLGetInput Continuously checks for input from the Mac machine
    % until data is actually available.
    while matlabUDP('check') == 0; end
    data = matlabUDP('receive');
end

function params = initParams()
    params.macHostIP = '130.91.72.120';
    params.winHostIP = '130.91.74.15';
    params.udpPort = 2007;
    
    debug = true;
    if (debug)
        params.winHostIP = '130.91.72.17';  % IoneanPelagos
        params.macHostIP = '130.91.74.10';  % Manta
    end
    
end

