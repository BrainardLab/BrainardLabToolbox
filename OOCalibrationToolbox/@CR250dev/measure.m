% Method to conduct a single native measurent. For the CR-250 this is an SPD measurement.
%
function result = measure(obj, varargin)
    % initialize to empty result
    result = [];

    % NEED TO IMPLEMENT 
    if (1==2)
        % Configure syncMode
        if (strcmp(obj.syncMode, 'ON'))
            if (obj.verbosity > 5)
                disp('Measure with synMode ON');
            end
            syncFreq = obj.measureSyncFreq();
            if (~isempty(syncFreq))
                obj.setSyncFreq(1);
            else
                obj.setSyncFreq(0);
            end
        else
            if (obj.verbosity > 5)
                disp('Measure with synMode OFF');
            end
            obj.setSyncFreq(0);
        end
    else
        fprintf(2,'CR250.measure(): Ignoring sync mode\n');
    end

    
     % Do the measurement (set the obj.nativeMeasurement). 
    obj.measureSPD();

    % By default, the measurement is the native measurement
    obj.measurement = obj.nativeMeasurement;
    
    % Adjust measurement, if we have additional argsin
    if (~isempty(varargin))
        obj.measurement = obj.adjustMeasurement(varargin);
    end
    
    % return the measurement
    if (isfield(obj.measurement, 'energy'))
        result = obj.measurement.energy;
    else
        result = obj.measurement;
    end
end