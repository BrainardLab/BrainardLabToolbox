% mglAnalyzeMonCalSpd
%
% This program reads a standard calibration file and
% reports what is in it.
%
% Assumes exactly three primaries.  There
% may be rare cases where this is not the case, in which case
% you need to look at the calibration data by hand.
%
% This version assumes that the calibration file contains
% measured spectral data.  It needs to be made more generic
% so that it can handle tristimulus and luminance calibrations.
%
% 8/22/97  dhb  Wrote it.
% 2/25/98  dhb  Postpend Spd to the name.
% 8/20/00  dhb  Change name to dump.
% 3/1/02   dhb  Arbitrary file names.
% 5/1/02   dhb  Add DUMPALL flag.
% 9/26/08  dhb, ijk, tyl  Made output easier to read.  Only access named files.
%               Assume three primaries.
% 01/22/10 dhb  Forked off from PTF DumpMonCalSpd.
% 02/15/10 dhb, ar  Add plot of linear model correction to phosphor spectra, if present.
% 02/15/10 dhb  Analyze background effect.
% 03/05/10 dhb  Allow analysis of earlier calibrations
% 03/07/10 dhb  Allow analysis with respect to new linear model or fit type
% 04/22/10  ar  Added additivity check for HDR display
% 04/23/10 dhb, ar, kmo  Generalize additivity check a little.
% 4/23/10  dhb, ar, kmo  Change names of methods to distinguish back from front.
% 5/28/10  dhb, ar Updates for smooth handling of yoked calibration files.
% 6/5/10   dhb  More control of what gets plotted.
% 6/10/10  dhb  Simplify prompt using subroutine.
% 7/08/10   ar  Added and debugged plots for multiple gamma curve measurments that are now taken during the
%               calibration (xyY) for comparison.
% 9/03/10  dhb  The DUMPNAVERAGE code only works right if nAverage > 1.  Added this conditional.
% 10/5/10  dhb  Print min and maximum luminance
%          dhb  Option to save basic figures.
% 11/26/12 dhb  Add conditionals so this will do something reasonable for an XYZ calibration.
% 5/28/13  dhb  Make output figures .png and add date.  This makes them more wiki compatible.
%          dhb  Also format output for easy upload to the wiki.
% 5/08/14  npc  Modifications for accessing calibration data using a @CalStruct object.
%               The first input argument can be either a @CalStruct object (new style), or a cal structure (old style).
%               Passing a @CalStruct object is the preferred way because it results in 
%               (a) less overhead (@CalStruct objects are passed by reference, not by value), and
%               (b) better control over how the calibration data are accessed.


% Initialize
clear; close all;

% Parameters/flags
nDontPlotLowPower = 4;

% Enter load code
fprintf('\n');
[cal,calFilename] = GetCalibrationStructure('Enter calibration filename','HDRFrontYokedMondrianfull',[]);

% Specify @CalStruct object that will handle all access to the calibration data.
[calStructOBJ, inputArgIsACalStructOBJ] = ObjectToHandleCalOrCalStruct(cal);
% Clear cal, so fields are accessed only via get and set methods of calStruct.
clear 'cal'

% Print out some information from the calibration.
DescribeMonCal(calStructOBJ);


S = calStructOBJ.get('S');                          
load T_xyz1931
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);

% Set color space
SetSensorColorSpace(calStructOBJ,T_xyz,S);



% Spectral calibration?
T_device = calStructOBJ.get('T_device');
if (size(T_device,1) > 3)
    ISSPECTRAL = true;
else
    ISSPECTRAL = false;
end

%% What to plot
if (ISSPECTRAL)
    DUMPFULLSPECTRA = GetWithDefault('Plot full phosphor data (0 -> no, 1 -> yes)?',0);
else
    DUMPFULLSPECTRA = false;
end

if (~isempty(calStructOBJ.get('basicmeas.settings')))
    DUMPBASIC = GetWithDefault('Plot basic linearity data (0 -> no, 1 -> yes)?',0);
end
if (~isempty(calStructOBJ.get('bgmeas.settings')))
    DUMPBG = GetWithDefault('Plot background effect data (0 -> no, 1 -> yes)?',0);
end
if (~isempty(calStructOBJ.get('monSpd')))
    DUMPNAVERAGE = GetWithDefault('Plot all sets of measures (0 -> no, 1 -> yes)?',0);
end

%% Save basic figures?
SAVEBASICFIGS = GetWithDefault('Save basic figures in cal plot directory (0 -> no, 1 -> yes)?',0);
if (SAVEBASICFIGS)
    calFolder = CalDataFolder([],calFilename);
    calPlotFolder = fullfile(calFolder,'Plots');
    if (~exist(calPlotFolder,'dir'))
        unix(['mkdir ' calPlotFolder]);
    end
    calFilePlotFolder = fullfile(calPlotFolder,calFilename);
    if (~exist(calFilePlotFolder,'dir'))
        unix(['mkdir ' calFilePlotFolder]);
    end
    calDate = calStructOBJ.get('date');
    thePlotFolder = fullfile(calFilePlotFolder,calDate(1:11));
    if (~exist(thePlotFolder,'dir'))
        unix(['mkdir ' thePlotFolder]);
    end
end

% Refit accordingly
REFIT = GetWithDefault('Refit data [0 -> no,1 -> yes]',0);
if (REFIT)
    newFitType = GetWithDefault('Enter gamma fit type (see ''help CalibrateFitGamma'')', calStructOBJ.get('gamma.fitType'));
    calStructOBJ.set('gamma.fitType', newFitType);
    if (ISSPECTRAL)
        % Get new number of primary bases
        new_nPrimaryBases = GetWithDefault('\nEnter number of primary bases',calStructOBJ.get('nPrimaryBases'));
        calStructOBJ.set('nPrimaryBases', new_nPrimaryBases);
        
        % and fit a linear model to the data
        CalibrateFitLinMod(calStructOBJ);

        % fit yoked
        CalibrateFitYoked(calStructOBJ);        
    end
end

S = calStructOBJ.get('S');   

%% Color matching functions
load T_xyz1931
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);

% Set color space
SetSensorColorSpace(calStructOBJ,T_xyz,S);

% Comptue min/max luminance
maxXYZ = PrimaryToSensor(calStructOBJ,[1 1 1]');
minXYZ = PrimaryToSensor(calStructOBJ,[0 0 0]');
fprintf('  * Minimum luminance %0.3f cd/m2; maximum luminance %0.2f cd/m2\n',minXYZ(2),maxXYZ(2));

% Provide information about gamma measurements
% This is probably not method-independent.
fprintf('  * Gamma measurements were made at %g levels\n',...
    size(calStructOBJ.get('rawGammaInput'),1));
fprintf('  * Gamma table available at %g levels\n',...
    size(calStructOBJ.get('gammaInput'),1));

%% Check
if (calStructOBJ.get('nDevices') ~= 3)
    error('This program is hard coded on assumption of three device primaries.');
end

%% Put up a plot of the essential data.  Optional save.
% Need to figure out from dimensions whether this is a
% spectral or tristimulus calibration.

% Spectral plot
if (ISSPECTRAL)
    CalibratePlotSpectra(calStructOBJ,figure(1));
end

% Gamma plot
CalibratePlotGamma(calStructOBJ,figure(2));

% Ambient plot for spectral measurements
if (ISSPECTRAL)
    CalibratePlotAmbient(calStructOBJ,figure(3));
end

% Chromaticity plot
if (ISSPECTRAL)
    xyYMon = XYZToxyY(T_xyz*calStructOBJ.get('P_device'));
    xyYAmb = XYZToxyY(T_xyz*calStructOBJ.get('P_ambient'));
else
    % Plot chromaticities of three channels
    % We assume that the data are XYZ in this
    % case, which is a good guess.  Also assume
    % that there are just three channels.
    if (size(calStructOBJ.get('P_device'),2) ~= 3)
        error('Plotting code assumes just three channels in device');
    end
    xyYMon = XYZToxyY(calStructOBJ.get('P_device'));
    xyYAmb = XYZToxyY(calStructOBJ.get('P_ambient'));
end
figure(4); hold on
xyYLocus = XYZToxyY(T_xyz);
plot(xyYMon(1,1)',xyYMon(2,1)','ro','MarkerSize',8,'MarkerFaceColor','r');
plot(xyYMon(1,2)',xyYMon(2,2)','go','MarkerSize',8,'MarkerFaceColor','g');
plot(xyYMon(1,3)',xyYMon(2,3)','bo','MarkerSize',8,'MarkerFaceColor','b');
plot(xyYLocus(1,:)',xyYLocus(2,:)','k');
axis([0 1 0 1]); axis('square');
xlabel('x chromaticity');
ylabel('y chromaticity');
title(sprintf('RGB channel chromaticities',nDontPlotLowPower));

if (SAVEBASICFIGS)
    calDate = calStructOBJ.get('date');
    
    if (ISSPECTRAL)
        figure(1);
        savefig(fullfile(thePlotFolder,['Spectra_' calDate(1:11)]),gcf,'png');
    end
       
    figure(2);
    savefig(fullfile(thePlotFolder,['Gamma_' calDate(1:11)]),gcf,'png');
    if (ISSPECTRAL)
        figure(3);
        savefig(fullfile(thePlotFolder,['Ambient_' calDate(1:11)]),gcf,'png');
    end
    figure(4);
    savefig(fullfile(thePlotFolder,['Chromaticities_' calDate(1:11)]),gcf,'png');
end
    
% Plot full spectral data for each phosphor
if (DUMPFULLSPECTRA)
    
    S        = calStructOBJ.get('S');
    S_device = calStructOBJ.get('S_device');
    nMeas    = calStructOBJ.get('nMeas');
    nDevices = calStructOBJ.get('nDevices');
    mon      = calStructOBJ.get('mon');
    
    figure(4+nDevices+1); clf; hold on;
    
    for j = 1:nDevices    
        % Get channel measurements into columns of a matrix from raw data in calibration file.
        tempMon = reshape( mon(:,j), S(3), nMeas);
        
        % Scale each measurement to the maximum spectrum to allow us to compare shapes visually.
        maxSpectrum = tempMon(:,end);
        scaledMon = tempMon;
        for i = 1: nMeas
            scaledMon(:,i) = scaledMon(:,i)*(scaledMon(:,i)\maxSpectrum);
        end
        
        % Compute phosphor chromaticities
        xyYMon = XYZToxyY(T_xyz*tempMon);
        
        % Plot raw spectra
        figure(4+j); clf
        subplot(1,2,1);
        plot(SToWls(S_device),tempMon);
        xlabel('Wavelength (nm)', 'Fontweight', 'bold');
        ylabel('Power', 'Fontweight', 'bold');
        axis([380,780,-Inf,Inf]);
        
        % Plot scaled spectra
        subplot(1,2,2);
        plot(SToWls(S_device),scaledMon(:,nDontPlotLowPower+1:end));
        xlabel('Wavelength (nm)', 'Fontweight', 'bold');
        ylabel('Normalized Power', 'Fontweight', 'bold');
        axis([380,780,-Inf,Inf]);
        drawnow;
        
        % Keep singular values
        monSVs(:,i) = svd(tempMon);
        
        % Plot chromaticities
        figure(4+nDevices+1); hold on
        plot(xyYMon(1,1:end)',xyYMon(2,1:end)','k+');
        plot(xyYMon(1,nDontPlotLowPower+1:end)',xyYMon(2,nDontPlotLowPower+1:end)','r+');
        axis([0 1 0 1]); axis('square');
        xlabel('x chromaticity');
        ylabel('y chromaticity');
        title(sprintf('Lower %d luminances in black',nDontPlotLowPower));
        if (SAVEBASICFIGS)
            savefig(fullfile(thePlotFolder,['PhosphorConstancy_' calDate(1:11)]),gcf,'png');
        end
    end
end


% Analyze basic measurements (these are in essence a linearity check)
if (~isempty(calStructOBJ.get('basicmeas.settings')))
    if (DUMPBASIC)
        
        % Handle wacky world of how we drive the HDR back projector
        HDRprojector = calStructOBJ.get('HDRProjector');
        settings     = calStructOBJ.get('basicmeas.settings');
        
        if (HDRprojector  == 1)
            newSettings = [zeros(size(settings(2,:))) ; settings(2,:) ; zeros(size(settings(2,:)))];
            calStructOBJ.set('basicmeas.settings', newSettings);
        end
        
        spectra1 = calStructOBJ.get('basicmeas.spectra1');
        spectra2 = calStructOBJ.get('basicmeas.spectra2');
        basicxyY1 = XYZToxyY(T_xyz*spectra1);
        basicxyY2 = XYZToxyY(T_xyz*spectra2);
        nominalxyY = XYZToxyY(SettingsToSensorAcc(calStructOBJ, settings));
        
        % Scatter plot
        figure; clf;
        subplot(1,3,1); hold on
        plot(nominalxyY(1,:),basicxyY1(1,:),'r+');
        plot(nominalxyY(1,:),basicxyY2(1,:),'b+');
        plot([0.1 0.7],[0.1 0.7],'k');
        axis([0.1 0.7 0.1 0.7]);
        xlabel('Nominal x');
        ylabel('Measured x');
        axis('square');
        
        subplot(1,3,2); hold on
        plot(nominalxyY(2,:),basicxyY1(2,:),'r+');
        plot(nominalxyY(2,:),basicxyY2(2,:),'b+');
        plot([0.1 0.7],[0.1 0.7],'k');
        axis([0.1 0.7 0.1 0.7]);
        xlabel('Nominal y');
        ylabel('Measured y');
        axis('square');
        
        subplot(1,3,3); hold on
        plot(nominalxyY(3,:),basicxyY1(3,:),'r+');
        plot(nominalxyY(3,:),basicxyY2(3,:),'b+');
        minVal = min([nominalxyY(3,:),basicxyY1(3,:)])-1;
        maxVal = max([nominalxyY(3,:),basicxyY1(3,:)])+1;
        plot([minVal maxVal],[minVal maxVal],'k');
        axis([minVal maxVal minVal maxVal]);
        xlabel('Nominal Y (cd/m2)');
        ylabel('Measured Y (cd/m2)');
        axis('square');
        if (SAVEBASICFIGS)
            savefig(fullfile(thePlotFolder,['Linearity_' calDate(1:11)]),gcf,'png');
        end
        
        % Deviation plot
        figure; clf;
        set(gcf,'Position',[680 820 1000 300]);
        deviationsxyY1 = basicxyY1-nominalxyY;
        deviationsxyY2 = basicxyY2-nominalxyY;

        subplot(1,3,1); hold on
        plot(nominalxyY(3,:),deviationsxyY1(1,:),'r+');
        plot(nominalxyY(3,:),deviationsxyY2(1,:),'b+');
        xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-0.2 0.2]);
        xlabel('Nominal Y');
        ylabel('x meas-nominal');
        title(sprintf('Max abs deviation %0.4f\n',max(abs([deviationsxyY1(1,:) deviationsxyY2(1,:)]))));
        
        subplot(1,3,2); hold on
        plot(nominalxyY(3,:),deviationsxyY1(2,:),'r+');
        plot(nominalxyY(3,:),deviationsxyY2(2,:),'b+');
        xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-0.2 0.2]);
        xlabel('Nominal Y');
        ylabel('y meas-nominal');
        title(sprintf('Max abs deviation %0.4f\n',max(abs([deviationsxyY1(2,:) deviationsxyY2(2,:)]))));

        
        subplot(1,3,3); hold on
        plot(nominalxyY(3,:),deviationsxyY1(3,:),'r+');
        plot(nominalxyY(3,:),deviationsxyY2(3,:),'b+');
        xlim([min(nominalxyY(3,:))-1 max(nominalxyY(3,:))+1]); ylim([-5 5]);
        xlabel('Nominal Y');
        ylabel('Y meas-nominal');
        title(sprintf('Max abs deviation %0.2f\n',max(abs([deviationsxyY1(3,:) deviationsxyY2(3,:)]))));

        if (SAVEBASICFIGS)
            calDate = calStructOBJ.get('date');
            savefig(fullfile(thePlotFolder,['LinearityDeviations_' calDate(1:11)]),gcf,'png');
        end
        
        % Print out some statistics
        deviationsStd1 = std(deviationsxyY1,[],2);
        deviationsStd2 = std(deviationsxyY2,[],2);
        fprintf('  * xyY deviations from linearity (standard deviation), run 1: %0.3f, %0.3f, %0.2f\n',...
            deviationsStd1(1),deviationsStd1(2),deviationsStd1(3));
        fprintf('  * xyY deviations from linearity (standard deviation), run 2: %0.3f, %0.3f, %0.2f\n',...
            deviationsStd2(1),deviationsStd2(2),deviationsStd2(3));
        
        % These show individual spectral overlaid on linearity predictions
        ambSpd = calStructOBJ.get('P_ambient');
        figure; clf;
        k=1;
        plot((spectra1(:,k)-ambSpd),'r-')
        hold on
        plot(((spectra1(:,k+1)-ambSpd)+(spectra1(:,k+2)-ambSpd)+...
            (spectra1(:,k+3)-ambSpd)),'b-')
        title(sprintf('Additivity check (%0.2f,%0.2f, %0.2f)',settings(1,k),settings(2,k),settings(3,k)));
        
        figure; clf;
        k=5;
        plot((spectra1(:,k)-ambSpd),'r-')
        hold on
        plot(((spectra1(:,k+1)-ambSpd)+(spectra1(:,k+2)-ambSpd)+...
            (spectra1(:,k+3)-ambSpd)),'b-')
        title(sprintf('Additivity check (%0.2f,%0.2f, %0.2f)',settings(1,k),settings(2,k),settings(3,k)));
        
        figure; clf;
        k=9;
        plot((spectra1(:,k)-ambSpd),'r-')
        hold on
        plot(((spectra1(:,k+1)-ambSpd)+(spectra1(:,k+2)-ambSpd)+...
            (spectra1(:,k+3)-ambSpd)),'b-')
        title(sprintf('Additivity check (%0.2f,%0.2f, %0.2f)',settings(1,k),settings(2,k),settings(3,k)));
        
        figure; clf;
        k=13;
        plot((spectra1(:,k)-ambSpd),'r-')
        hold on
        plot(((spectra1(:,k+1)-ambSpd)+(spectra1(:,k+2)-ambSpd)+...
            (spectra1(:,k+3)-ambSpd)),'b-')
        title(sprintf('Additivity check (%0.2f,%0.2f, %0.2f)',settings(1,k),settings(2,k),settings(3,k)));
        xlabel('Wavelength (nm)'); ylabel('Power');
    end
end


%% Repeat measurements
%
% This is added to plot the measurments for gamma curves that are now taken
% twice during the calibration.
nMeas    = calStructOBJ.get('nMeas');
nAverage = calStructOBJ.get('nAverage');
nDevices = calStructOBJ.get('nDevices');
monSpd   = calStructOBJ.get('monSpd');
S        = calStructOBJ.get('S');

if (nAverage > 1 && (~isempty(monSpd)))
    if (DUMPNAVERAGE)
        % First convert the set of measurments to xyY; then plot it
        for a=1:nAverage
            for i=1:nDevices
                tempMonSpd{a,i} = reshape(monSpd{a,i}, S(3), nMeas);
            end
        end
        
        calStructOBJ.set('monSpd', tempMonSpd);
        monSpd   = calStructOBJ.get('monSpd');
        
        for a = 1:nAverage
            for i = 1:nDevices
                monxyY{a,i}=XYZToxyY(T_xyz*monSpd{a,i});
            end
        end
        
        % Plot Y for all the measures and all the guns
        figure; clf;
        subplot(1,3,1); hold on
        for a=1:nAverage
            plot(monxyY{a,1}(3,:),'r-');
            plot(monxyY{a,2}(3,:),'g-');
            plot(monxyY{a,3}(3,:),'b-');
        end
        axis([1 nMeas 0 450]);
        xlabel('Measures');
        ylabel('Measured Luminance in cd/m2');
        % Plot y for all the measures and all the guns
        subplot(1,3,2); hold on
        for a=1:nAverage
            plot(monxyY{a,1}(1,:),'r-');
            plot(monxyY{a,2}(1,:),'g-');
            plot(monxyY{a,3}(1,:),'b-');
        end
        axis([1 length(monxyY{a,1}(:,3)) 0 300]);
        xlabel('Measures');
        ylabel('Measured x-chromaticity');
        axis([1 nMeas 0 1]);
        % Plot x for all the measures and all the guns
        subplot(1,3,3); hold on
        for a=1:nAverage
            plot(monxyY{a,1}(2,:),'r-');
            plot(monxyY{a,2}(2,:),'g-');
            plot(monxyY{a,3}(2,:),'b-');
        end
        axis([1 nMeas 0 1]);
        xlabel('Measures');
        ylabel('Measured y-chromaticity');
        %axis('square');
    end
end


%% Analyze background measurements
if (~isempty(calStructOBJ.get('bgmeas.settings')))
    if (DUMPBG)
        % Handle wacky world of how we drive the HDR back projector
        HDRprojector = calStructOBJ.get('HDRProjector');
        settings     = calStructOBJ.get('bgmeas.settings');
        spectra      = calStructOBJ.get('bgmeas.spectra');
        
        if (~isempty(HDRprojector)) && (HDRprojector == 1)
            newSettings = [zeros(size(settings(2,:))) ; settings(2,:) ; zeros(size(settings(2,:)))];
            calStructOBJ.set('bgmeas.settings', newSettings);
        end
        
        % The calibration code measures a set of spectra for a set of background
        % settings.  For better or for worse, the two sets of settings are the
        % same -- that is, for each background, the target is measured using the
        % set of settings that the background cycles through.
        %
        % For each background setting, the measured spectra are in the corresponding
        % entry of the cell array spectra.
        fprintf('  * Effect of background on ambient\n');
        for j = 1:size(settings,2)
            %fprintf('Target settings %0.2f %0.2f %0.2f\n',settings(1,j),settings(2,j),settings(3,j));
            figure; clf; hold on
            for bg = 1:size(settings,2)
                plot(SToWls(S),spectra{bg}(:,j))
            end
            xlabel('Wavelength (nm)'); ylabel('Power');
            title(sprintf('BG effect on (%0.2f,%0.2f, %0.2f)',settings(1,j),settings(2,j),settings(3,j)));
            if (~any(settings(:,j) ~= 0))
                for bg = 1:size(settings,2)  
                    tempxyY = XYZToxyY(T_xyz*spectra{bg}(:,j));
                    fprintf('    * Background settings = %0.2f %0.2f, %0.2f, ambient xyY = %0.3f, %0.3f, %0.3f cd/m2\n',...
                        settings(1,bg),settings(2,bg),settings(3,bg), ...
                        tempxyY(1),tempxyY(2),tempxyY(3));
                end
            end
        end
    end
end
