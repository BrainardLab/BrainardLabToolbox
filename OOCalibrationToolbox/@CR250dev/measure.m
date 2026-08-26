% Method to conduct a single native measurent. For the CR-250 this is an SPD measurement.
%
function result = measure(obj, varargin)
    % initialize to empty result
    result = [];

    
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