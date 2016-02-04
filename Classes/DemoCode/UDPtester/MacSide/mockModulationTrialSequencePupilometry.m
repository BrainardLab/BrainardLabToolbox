function params = mockModulationTrialSequencePupilometry()

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
end


function params = trialLoop(params, block, UDPobj)

   % Send the number of trials to the Winbox
   UDPobj.send('numTrials', params.nTrials);
   
   % reply = OLVSGSendNumTrials(params);
   % fprintf('Win received number of trials? %s\n',reply);
    
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

    params.nTrials = 10;
    
end

