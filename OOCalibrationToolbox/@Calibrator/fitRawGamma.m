% Method to fit the linear model to measured calibration data.
% Options for field cal.describe.gamma.fitType are:
%    simplePower
%    crtLinear
%    crtPolyLinear
%    crtGamma
%    crtSumPow
%    betacdf
%    sigmoid
%    weibull
function obj = fitRawGamma(obj, nInputLevels)
    
    % Make a local copy of cal so we do not keep calling it and regenerating it
    cal = obj.cal;
    
    if (nargin < 2 || isempty(nInputLevels))
        nInputLevels = 1024;
    end
    
    nPrimaries    = cal.describe.displayPrimariesNum;
    nPrimaryBases = cal.describe.primaryBasesNum;
    
    % Fit gamma functions.
    [mGammaFit1, obj.processedData.gammaInput] = ...
        fitCurve(cal.describe, obj.rawData.gammaInput', obj.rawData.gammaTable, nInputLevels);
    
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
                    obj.rawData.gammaInput', ...
                    obj.rawData.gammaTable(:,nPrimaries+j), ...
                    obj.processedData.gammaInput ...
                    );
            end
        else
            % This is the code we're currently using.  It works for the case where different input levels are specified for
            % the measurments for each primary.
            k = 1;
            for j = 1:nPrimaries*(nPrimaryBases-1)
                if (size(obj.rawData.gammaInput,1) > 1)
                    mGammaFit2(:,j) = interp1(...
                        MakeGammaMonotonic([0 ; obj.rawData.gammaInput(k,:)]), ...
                        [0 ; obj.rawData.gammaTable(:,nDevices+j)],...
                        obj.processedData.gammaInput,...
                        'linear'...
                        );
                else
                    mGammaFit2(:,j) = interp1(...
                        MakeGammaMonotonic([0 ; obj.rawData.gammaInput']),...
                        [0 ; obj.rawData.gammaTable(:,nDevices+j)], ...
                        obj.processedData.gammaInput, ...
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
    obj.processedData.gammaTable  = mGammaFit;
    obj.processedData.gammaFormat = 0;
end


% Method to fit different gamma functions.
function [mGammaFit1, hiResGammaInput] = fitCurve(cal_describe, gammaInput, gammaTable, nInputLevels)
%
    nPrimaries    = cal_describe.displayPrimariesNum;
    
    switch(cal_describe.gamma.fitType)
        case 'crtPolyLinear'
            % For fitting, we set to zero the raw data we
            % believe to be below reliable measurement threshold (contrastThresh).
            % Currently we are fitting both with polynomial and a linear interpolation,
            % using the latter for low measurement values.  The fit break point is
            % given by fitBreakThresh.   This technique was developed
            % through bitter experience and is not theoretically driven.
            if (~isfield(cal_describe.gamma,'contrastThresh'))
                cal_describe.gamma.contrastThresh = 0.001;
            end
            if (~isfield(cal_describe.gamma,'fitBreakThresh'))
                cal_describe.gamma.fitBreakThresh = 0.02;
            end

            mGammaMassaged = gammaTable(:,1:nPrimaries);
            massIndex = find(mGammaMassaged < cal_describe.gamma.contrastThresh);
            mGammaMassaged(massIndex) = zeros(length(massIndex),1);

            for i = 1:nPrimaries
                mGammaMassaged(:,i) = MakeGammaMonotonic(HalfRect(mGammaMassaged(:,i)));
            end

            fitType = 7;
            [mGammaFit1a, hiResGammaInput] = FitDeviceGamma(...
                mGammaMassaged, ...
                gammaInput, ...
                fitType, ...
                nInputLevels...
                );
            
            fitType = 6;
            [mGammaFit1b, hiResGammaInput] = FitDeviceGamma(...
                mGammaMassaged, ...
                gammaInput, ...
                fitType, ...
                nInputLevels...
                );
            
            mGammaFit1 = mGammaFit1a;
            for i = 1:nPrimaries
                indexLin = find(mGammaMassaged(:,i) < cal_describe.gamma.fitBreakThresh);
                if (~isempty(indexLin))
                    breakIndex = max(indexLin);
                    breakInput = gammaInput(breakIndex);
                    inputIndex = find(hiResGammaInput <= breakInput);
                    if (~isempty(inputIndex))
                        mGammaFit1(inputIndex,i) = mGammaFit1b(inputIndex,i);
                    end
                end
            end
        
        otherwise
            error('Unsupported gamma fit string passed');
    end % switch
    
    
    
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
