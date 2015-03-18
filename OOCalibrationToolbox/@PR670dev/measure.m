% Method to conduct a single native measurent. For the PR-670 this is an SPD measurement.
function result = measure(obj, varargin) 

    if (obj.verbosity > 9)
        fprintf('In PR670.measure\n');
    end

    % initialize to empty result
    result = [];
    
    % configure syncMode
    if (strcmp(obj.syncMode, 'AUTO'))
        % See if we can sync to the source and set sync mode appropriately.
        sourceFreq = obj.measureSourceFrequency();
        
        if (~isempty(sourceFreq))
            obj.setOptions('syncMode', 'AUTO');
        else
            obj.setOptions('syncMode', 'OFF');
        end
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
