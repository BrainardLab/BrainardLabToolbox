function params = mockModulationTrialSequencePupilometry()

    fprintf('Make sure the windows program is running, then hit enter to continue\n');
    pause;
    
    params = initParams();
    
    % setup the trial blocks
    block = struct();
    for i = 1:params.nTrials 
        block(i).data = i;
    end % i
    
    
    fprintf('\n* Creating keyboard listener\n');
    mglListener('init');

    % Instantiate a UDPcommunictor object
    UDPobj = UDPcommunicator( ...
          'localIP', params.macHostIP, ...
         'remoteIP', params.winHostIP, ...
          'udpPort', params.udpPort, ...      % optional with default 2007
        'verbosity', 'normal' ...             % optional with possible values {'min', 'normal', 'max'}, and default 'normal'
        );

    params = trialLoop(params, block, UDPobj);
    
    fprintf('\nBye bye from the mac.');
end


function params = trialLoop(params, block, UDPobj)

    fprintf('\nMac computer is sending number of trials (%d) message\n', params.nTrials);
    status = UDPobj.sendMessage(...
            'NUMBER_OF_TRIALS', 'withValue', params.nTrials, ...
            'timeOutSecs', 2, 'maxAttemptsNum', 1);
    status
    if (~strcmp(status, 'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE'))
        error('Aborting here');
    end
   
    
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
    params.macHostIP = '130.91.72.120';
    params.winHostIP = '130.91.74.15';
    params.udpPort = 2007;

    debug = true;
    if (debug)
        params.winHostIP = '130.91.72.17';  % IoneanPelagos
        params.macHostIP = '130.91.74.10';  % Manta
    end

    params.nTrials = 13;
    
end

