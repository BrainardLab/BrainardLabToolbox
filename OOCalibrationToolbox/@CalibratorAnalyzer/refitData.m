function obj = refitData(obj)

    % Refit accordingly
    refit = GetWithDefault('Refit data [0 -> no,1 -> yes]',0);
    if (refit)
        % Optionally, let the user specify a new type of gamma fit
        obj.cal.describe.gamma.fitType = ...
            GetWithDefault('Enter gamma fit type (see ''help CalibrateFitGamma'')', obj.cal.describe.gamma.fitType);
        
        % Optionally, let the user specify a different number of primary bases
        obj.cal.describe.primaryBasesNum = ...
            GetWithDefault('\nEnter number of primary bases', obj.cal.describe.primaryBasesNum);
        
        % Call the same method that is executed during calibration
        obj.processRawData();
    end
end
