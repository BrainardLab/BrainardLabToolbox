function obj = fitLinearModel(obj)
% Fit the linear model to measured calibration data.
%
    % Make a local copy of cal so we do not keep calling it and regenerating it
    cal = obj.cal;
    
    nPrimaries      = cal.describe.displayPrimariesNum;
    nPrimaryBases   = cal.describe.primaryBasesNum;
    nMeas           = cal.describe.nMeas;

    Pmon      = zeros(obj.measurementChannelsNum, nPrimaries*nPrimaryBases);
    mGammaRaw = zeros(nMeas, nPrimaries*nPrimaryBases);
    monSVs    = zeros(min([nMeas obj.measurementChannelsNum]),nPrimaries);

    for i = 1:nPrimaries
        tempMon = (squeeze(obj.rawData.gammaCurveMeanMeasurements(i,:,:)))';
        monSVs(:,i) = svd(tempMon);

        % Build a linear model
        if (nPrimaryBases > 0)
            % Get full linear model
            [monB,monW] = FindLinMod(tempMon,nPrimaryBases);

            % Express max measurement within the full linear model.
            % This is the first basis function.
            tempB = monB*monW(:, nMeas);
            maxPow = max(abs(tempB));

            % Get residuals with respect to first component
            residMon = tempMon-tempB*(tempB\tempMon);

            % If linear model dimension is greater than 1,
            % fit linear model of dimension-1 to the residuals.
            % Take this as the higher order terms of the linear model.
            %
            % Also normalize each basis vector to max power of first
            % component, and make sure convention is that this max
            % is positive.
            if ( nPrimaryBases > 1)
                residB = FindLinMod(residMon, nPrimaryBases-1);
                for j = 1:nPrimaryBases-1
                    residB(:,j) = maxPow*residB(:,j)/max(abs(residB(:,j)));
                    [~,index] = max(abs(residB(:,j)));
                    if (residB(index,j) < 0)
                        residB(:,j) = -residB(:,j);
                    end
                end
                monB = [tempB residB];
            else
                monB = tempB;
            end

            % Zero means build one dimensional linear model just taking max measurement
            % as the spectrum.
        else
            cal.describe.primaryBasesNum = 1;
            monB = tempMon(:, nMeas);
        end

        % Find weights with respect to adjusted linear model and
        % store
        monW = FindModelWeights(tempMon,monB);
        for j = 1: nPrimaryBases
            mGammaRaw(:,i+(j-1)*nPrimaries) = (monW(j,:))';
            Pmon(:,i+(j-1)*nPrimaries) = monB(:,j);
        end
    end

    % Update calibration structure.
    obj.rawData.gammaTable     = mGammaRaw;
    obj.processedData.S_device = obj.rawData.S;
    obj.processedData.P_device = Pmon;
    obj.processedData.T_device = WlsToT(obj.rawData.S);
    obj.processedData.monSVs   = monSVs;

end