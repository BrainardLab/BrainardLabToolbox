function params = mockModulationTrialSequencePupilometry()

    params = initParams();
    
    % setup the trial blocks
    block = struct();
    for i = 1:params.nTrials 
        block(i).data = i;
    end % i
    
    
    fprintf('\n* Creating keyboard listener\n');
    mglListener('init');

    % Initialize UDP
    fprintf('\n* Initializing UPD\n');
    matlabUDP('close');
    matlabUDP('open', params.macHostIP, params.winHostIP, params.udpPort);

    params = trialLoop(params, block);
end


function params = trialLoop(params, block)

   % Send the number of trials to the Winbox
    reply = OLVSGSendNumTrials(params);
    fprintf('Win received number of trials? %s\n',reply);
    
end

function reply = OLVSGSendNumTrials(params)
    % reply = OLVSGSendNumStims(params)
    % Send over the number of trials
    number = params.nTrials;
    matlabUDP('send', sprintf('%f', number));
    reply = OLVSGGetInput;    
end
    
function data = OLVSGGetInput
    while matlabUDP('check') == 0; end
    data = matlabUDP('receive');
end
    
    
function params = initParams()
    params = initParams();
    params.macHostIP = '130.91.72.120';
    params.winHostIP = '130.91.74.15';
    params.udpPort = 2007;

    debug = true;
    if (debug)
        params.winHostIP = '130.91.72.17';  % IoneanPelagos
        params.macHostIP = '130.91.74.10';  % Manta
    end

    params.nTrials = 10;
    params.protocolName = 'UDP_TEST';
    
end

