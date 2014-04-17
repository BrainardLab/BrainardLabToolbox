function testCal
     clear all
    load('cal.mat');
    
    disp('cal structure')
    cal
    
    disp('cal.describe')
    cal.describe
    
    disp('cal.basicLinearitySetup')
    cal.basicLinearitySetup
    
    disp('cal.backgroundDependenceSetup')
    cal.backgroundDependenceSetup
    
    disp('cal.rawData')
    cal.rawData
    size(cal.rawData.gammaCurveSpectra)
    
     
    
   figure(99)
   clf;
   hold on;
   plot(squeeze(cal.rawData.gammaCurveMeanSpectra(1,7,:)), 'r-');
   plot(squeeze(cal.rawData.gammaCurveMeanSpectra(2,7,:)), 'g-');
   plot(squeeze(cal.rawData.gammaCurveMeanSpectra(3,7,:)), 'b-');
   pause;
   
   cal = FitLinearModel(cal)
   
   cal.rawData
   
   cal = FitRawGamma(cal)
   cal.rawData
   
   disp('cal.processedData')
    cal.processedData
    
    % Put up a plot of the essential data
    figure(123); clf;

    hold on
    plot(SToWls(cal.processedData.S_device), cal.processedData.P_device(:,1), 'r-');
    plot(SToWls(cal.processedData.S_device), cal.processedData.P_device(:,2), 'g-');
    plot(SToWls(cal.processedData.S_device), cal.processedData.P_device(:,3), 'b-');
    xlabel('Wavelength (nm)', 'Fontweight', 'bold');
    ylabel('Power', 'Fontweight', 'bold');
    title('Phosphor spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380, 780, -Inf, Inf]);

    figure(2); clf;
    hold on
    plot(cal.rawData.gammaInput, cal.rawData.gammaTable(:,1), 'r+');
    plot(cal.rawData.gammaInput, cal.rawData.gammaTable(:,2), 'g+');
    plot(cal.rawData.gammaInput, cal.rawData.gammaTable(:,3), 'b+');
    xlabel('Input value', 'Fontweight', 'bold');
    ylabel('Normalized output', 'Fontweight', 'bold');
    title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    plot(cal.processedData.gammaInput, cal.processedData.gammaTable(:,1), 'r-');
    plot(cal.processedData.gammaInput, cal.processedData.gammaTable(:,2), 'g-');
    plot(cal.processedData.gammaInput, cal.processedData.gammaTable(:,3), 'b-');
    
    hold off
    figure(gcf);
    drawnow;
    
end


% The following functions should be part of a different object perhaps
% but now include them here
function cal = FitRawGamma(cal, nInputLevels)
% cal = CalibrateFitGamma(cal,[nInputLevels])
%
% Fit the gamma function to the calibration measurements.  Options for field
% cal.describe.gamma.fitType are:
%    simplePower
%    crtLinear
%    crtPolyLinear
%    crtGamma
%    crtSumPow
%    betacdf
%    sigmoid
%    weibull

    if (nargin < 2 || isempty(nInputLevels))
        nInputLevels = 1024;
    end
    
    nPrimaries    = cal.describe.displayPrimariesNum;
    nPrimaryBases = cal.describe.primaryBasesNum;
    
    % Fit gamma functions.
    switch(cal.describe.gamma.fitType)
        case 'crtPolyLinear'
            % For fitting, we set to zero the raw data we
            % believe to be below reliable measurement threshold (contrastThresh).
            % Currently we are fitting both with polynomial and a linear interpolation,
            % using the latter for low measurement values.  The fit break point is
            % given by fitBreakThresh.   This technique was developed
            % through bitter experience and is not theoretically driven.
            if (~isfield(cal.describe.gamma,'contrastThresh'))
                cal.describe.gamma.contrastThresh = 0.001;
            end
            if (~isfield(cal.describe.gamma,'fitBreakThresh'))
                cal.describe.gamma.fitBreakThresh = 0.02;
            end

            mGammaMassaged = cal.rawData.gammaTable(:,1:nPrimaries);
            massIndex = find(mGammaMassaged < cal.describe.gamma.contrastThresh);
            mGammaMassaged(massIndex) = zeros(length(massIndex),1);

            for i = 1:nPrimaries
                mGammaMassaged(:,i) = MakeGammaMonotonic(HalfRect(mGammaMassaged(:,i)));
            end

            fitType = 7;
            [mGammaFit1a, cal.processedData.gammaInput] = FitDeviceGamma(...
                mGammaMassaged, ...
                cal.rawData.gammaInput, ...
                fitType, ...
                nInputLevels...
                );
            
            fitType = 6;
            [mGammaFit1b, cal.processedData.gammaInput] = FitDeviceGamma(...
                mGammaMassaged, ...
                cal.rawData.gammaInput, ...
                fitType, ...
                nInputLevels...
                );
            
            mGammaFit1 = mGammaFit1a;
            for i = 1:nPrimaries
                indexLin = find(mGammaMassaged(:,i) < cal.describe.gamma.fitBreakThresh);
                if (~isempty(indexLin))
                    breakIndex = max(indexLin);
                    breakInput = cal.rawData.gammaInput(breakIndex);
                    inputIndex = find(cal.processedData.gammaInput <= breakInput);
                    if (~isempty(inputIndex))
                        mGammaFit1(inputIndex,i) = mGammaFit1b(inputIndex,i);
                    end
                end
            end
        
        otherwise
            error('Unsupported gamma fit string passed');
    end % switch
    
    
    % Fix contingous zeros at start problem
    mGammaFit1 = FixZerosAtStart(mGammaFit1);
    for j = 1:size(mGammaFit1,2)
        mGammaFit1(:,j) = MakeGammaMonotonic(mGammaFit1(:,j));
    end

    % Handle higher order terms, which are just fit with a polynomial
    if (nPrimaryBases > 1)
        m = size(mGammaFit1,1);
        mGammaFit2 = zeros(m,nDevices*(nPrimaryBases-1));
    
        % OLDFIT path does not contain option of handling data with independent input values
        % for measurements for each device primary.
        OLDFIT = 0;
        if (OLDFIT)
            for j = 1:nPrimaries*(nPrimaryBases-1)
                mGammaFit2(:,j) = FitGammaPolyR( ...
                    cal.rawData.gammaInput, ...
                    cal.rawData.gammaTable(:,nDevices+j), ...
                    cal.processedData.gammaInput ...
                    );
            end
        else
            % This is the code we're currently using.  It works for the case where different input levels are specified for
            % the measurments for each primary.
            k = 1;
            for j = 1:nPrimaries*(nPrimaryBases-1)
                if (size(cal.rawData.gammaInput,2) > 1)
                    mGammaFit2(:,j) = interp1(...
                        MakeGammaMonotonic([0 ; cal.rawData.gammaInput(:,k)]), ...
                        [0 ; cal.rawData.gammaTable(:,nDevices+j)],...
                        cal.processedData.gammaInput,...
                        'linear'...
                        );
                else
                    mGammaFit2(:,j) = interp1(...
                        MakeGammaMonotonic([0 ; cal.rawData.gammaInput]),...
                        [0 ; cal.rawData.gammaTable(:,nDevices+j)], ...
                        cal.processedData.gammaInput, ...
                        'linear'...
                        );
                end
                k = k+1;
                if (k == nPrimaries+1)
                    k = 1;
                end
            end
        end
        mGammaFit = [mGammaFit1 , mGammaFit2];
    else
        mGammaFit = mGammaFit1;
    end

    % Update calibration structure
    cal.processedData.gammaFormat = 0;
    cal.processedData.gammaTable = mGammaFit;
end


function cal = FitLinearModel(cal)
% Fit the linear model to spectral calibration data.
%
    spectralSamples = size(cal.rawData.gammaCurveSpectra,4);
    nPrimaries    = cal.describe.displayPrimariesNum;
    nPrimaryBases = cal.describe.primaryBasesNum;
    nMeas         = cal.describe.nMeas;

    Pmon      = zeros(spectralSamples, nPrimaries*nPrimaryBases);
    mGammaRaw = zeros(nMeas, nPrimaries*nPrimaryBases);
    monSVs    = zeros(min([nMeas spectralSamples]),nPrimaries);

    for i = 1:nPrimaries
        tempMon = (squeeze(cal.rawData.gammaCurveMeanSpectra(i,:,:)))';
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
                for j = 1: nPrimaryBases-1
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
    cal.rawData.gammaTable     = mGammaRaw;
    cal.processedData.S_device = cal.rawData.S;
    cal.processedData.P_device = Pmon;
    cal.processedData.T_device = WlsToT(cal.rawData.S);
    cal.processedData.monSVs   = monSVs;
end



function cal = FitRawGammaORIGINAL(cal, nInputLevels)
% cal = CalibrateFitGamma(cal,[nInputLevels])
%
% Fit the gamma function to the calibration measurements.  Options for field
% cal.describe.gamma.fitType are:
%    simplePower
%    crtLinear
%    crtPolyLinear
%    crtGamma
%    crtSumPow
%    betacdf
%    sigmoid
%    weibull

    if (nargin < 2 || isempty(nInputLevels))
        nInputLevels = 1024;
    end
    
    nPrimaries    = cal.describe.displayPrimariesNum;
    nPrimaryBases = cal.describe.primaryBasesNum;
    nMeas         = cal.describe.nMeas;
    
    % Fit gamma functions.
    switch(cal.describe.gamma.fitType)
        case 'crtPolyLinear'
            % For fitting, we set to zero the raw data we
            % believe to be below reliable measurement threshold (contrastThresh).
            % Currently we are fitting both with polynomial and a linear interpolation,
            % using the latter for low measurement values.  The fit break point is
            % given by fitBreakThresh.   This technique was developed
            % through bitter experience and is not theoretically driven.
            if (~isfield(cal.describe.gamma,'contrastThresh'))
                cal.describe.gamma.contrastThresh = 0.001;
            end
            if (~isfield(cal.describe.gamma,'fitBreakThresh'))
                cal.describe.gamma.fitBreakThresh = 0.02;
            end

            % cal.rawdata.rawGammaTable is constructed in FitLinearModel
            mGammaMassaged = cal.rawData.rawGammaTable(:,1:nPrimaries);
            massIndex = find(mGammaMassaged < cal.describe.gamma.contrastThresh);
            mGammaMassaged(massIndex) = zeros(length(massIndex),1);

            for i = 1:nPrimaries
                mGammaMassaged(:,i) = MakeGammaMonotonic(HalfRect(mGammaMassaged(:,i)));
            end

            fitType = 7;
            [mGammaFit1a, cal.rawData.gammaInput] = FitDeviceGamma(...
                mGammaMassaged,cal.rawData.rawGammaInput,fitType,nInputLevels);
            fitType = 6;
            [mGammaFit1b,cal.rawData.gammaInput] = FitDeviceGamma(...
                mGammaMassaged,cal.rawData.rawGammaInput,fitType,nInputLevels);
            mGammaFit1 = mGammaFit1a;
            for i = 1:nPrimaries
                indexLin = find(mGammaMassaged(:,i) < cal.describe.gamma.fitBreakThresh);
                if (~isempty(indexLin))
                    breakIndex = max(indexLin);
                    breakInput = cal.rawData.rawGammaInput(breakIndex);
                    inputIndex = find(cal.rawData.gammaInput <= breakInput);
                    if (~isempty(inputIndex))
                        mGammaFit1(inputIndex,i) = mGammaFit1b(inputIndex,i);
                    end
                end
            end
        
        otherwise
            error('Unsupported gamma fit string passed');
    end % switch
    
    
    % Fix contingous zeros at start problem
    mGammaFit1 = FixZerosAtStart(mGammaFit1);
    for j = 1:size(mGammaFit1,2)
        mGammaFit1(:,j) = MakeGammaMonotonic(mGammaFit1(:,j));
    end

    % Handle higher order terms, which are just fit with a polynomial
    if (nPrimaryBases > 1)
        m = size(mGammaFit1,1);
        mGammaFit2 = zeros(m,nDevices*(nPrimaryBases-1));
    
        % OLDFIT path does not contain option of handling data with independent input values
        % for measurements for each device primary.
        OLDFIT = 0;
        if (OLDFIT)
            for j = 1:nPrimaries*(nPrimaryBases-1)
                mGammaFit2(:,j) = ...
                    FitGammaPolyR(cal.rawData.rawGammaInput,cal.rawData.rawGammaTable(:,nDevices+j), ...
                    cal.rawData.gammaInput);
            end

        % This is the code we're currently using.  It works for the case where different input levels are specified for
        % the measurments for each primary.
        else
            k = 1;
            for j = 1:nPrimaries*(nPrimaryBases-1)
                if (size(cal.rawData.rawGammaInput,2) > 1)
                    mGammaFit2(:,j) = interp1(MakeGammaMonotonic([0 ; cal.rawData.rawGammaInput(:,k)]),[0 ; cal.rawData.rawGammaTable(:,nDevices+j)],cal.rawData.gammaInput,'linear');
                else
                    mGammaFit2(:,j) = interp1(MakeGammaMonotonic([0 ; cal.rawData.rawGammaInput]),[0 ; cal.rawData.rawGammaTable(:,nDevices+j)],cal.rawData.gammaInput,'linear');
                end
                k = k+1;
                if (k == nPrimaries+1)
                    k = 1;
                end
            end
        end

        mGammaFit = [mGammaFit1 , mGammaFit2];
    else
        mGammaFit = mGammaFit1;
    end

    % Save information in form for calibration routines.
    cal.rawData.gammaFormat = 0;
    cal.rawData.gammaTable = mGammaFit;

end

function cal = FitLinearModelORIGINAL(cal)
% Fit the linear model to spectral calibration data.
%

    spectralSamples = size(cal.rawData.gammaCurveSpectra,4);
    nPrimaries    = cal.describe.displayPrimariesNum;
    nPrimaryBases = cal.describe.primaryBasesNum;
    nMeas         = cal.describe.nMeas;

    Pmon      = zeros(spectralSamples, nPrimaries*nPrimaryBases);
    mGammaRaw = zeros(nMeas, nPrimaries*nPrimaryBases);
    monSVs    = zeros(min([nMeas spectralSamples]),nPrimaries);



    for i = 1:nPrimaries
        
        tempMon = (squeeze(cal.rawData.gammaCurveMeanSpectra(i,:,:)))';
        size(tempMon)
        pause;
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
                for j = 1: nPrimaryBases-1
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
    cal.S_device = cal.rawData.S;
    cal.P_device = Pmon;
    cal.T_device = WlsToT(cal.rawData.S);
    cal.rawData.rawGammaTable = mGammaRaw;
    cal.rawData.monSVs = monSVs;
end


% output = FixZerosAtStart(input)
%
% The OS/X routines need the fit gamma function to be monotonically
% increasing.  One way that sometimes fails is when a whole bunch of
% entries at the start are zero.  This routine fixes that up.
function output = FixZerosAtStart(input)

    output = input;
    for j = 1:size(input,2)
        for i = 1:size(input,1)
            if (input(i,j) > 0)
                break;
            end
        end
        if (i == size(input,1))
            error('Entire passed gamma function is zero');
        end
        output(1:i,j) = linspace(0,min([0.0001 input(i+1,j)/2]),i)';
    end

end
