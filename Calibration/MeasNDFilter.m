% MeasNDFilter
%
% Measure the transmissivity of an ND filter.
%
% This is set up to put date in various places,
% depending on how the measurement will be used.
%
% LEDStim
%   Here this is the filter we use to put the LED
%   output into the range that the photo diode
%   works over.  We then have to back that out
%   of the overall calibration measurements elsewhere.
%
% OneLight
%   ND filters for the OneLight project.
%
% This is set up for the PR-670, which we put into
% extended mode by hand.  Eventually, we'll have a
% way of doing this programmatically, in which case
% we would simply do it from the code.
%
% 08/30/12  dhb, ks  Write it
% 07/03/13  dhb      Generalize i/o location, and add project types.
% 2/01/16   npc      Adapted to use the PR670dev object

% Setup
clear; close all;

% Analyze only?
ANALYZEONLY = 0;

% Change so that we're running where this lives.
defaultProject = 'OneLight'
fprintf('Projects:\n');
fprintf('\tOneLight\n');
fprintf('\tLEDStim\n');
whichProj = GetWithDefault('Enter project name',defaultProject);
switch (whichProj)
    case 'OneLight'
        myDir = '/Users/Shared/Matlab/Toolboxes/PsychCalLocalData/OneLight';
        subDir = 'xNDFilters';
    case 'LEDStim'
        myDir = '/Users/Shared/Matlab/Toolboxes/LEDToolbox';
        subDir = 'xCalibrationData';
    otherwise
        error('Unknown project specified');
end
curDir = pwd;
targetDir = fullfile(myDir,subDir,'');
if (~exist(targetDir,'dir'))
    mkdir(targetDir);
end

% Parameters.  One of the plots below will break if you
% make nAverageUnatten and nAverageAtten different from
% each other.
nAverage = 15;
nAverageUnatten = nAverage;
nAverageAtten = nAverage;
waitTime = 10;
filterName = GetWithDefault('Enter filter name','ND3');
dateName = GetWithDefault('Enter date name','022713');
S = [380 2 201];


% Allow computation of luminance
load T_xyz1931
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);

if (~ANALYZEONLY)
    
    % init spectroRadiometerOBJ to empty
    spectroRadiometerOBJ = [];
    
    try
        % Instantiate a PR670 object
        spectroRadiometerOBJ  = PR670dev(...
            'verbosity',        1, ...       % 1 -> minimum verbosity
            'devicePortString', [] ...       % empty -> automatic port detection)
        );
        spectroRadiometerOBJ.setOptions('syncMode', 'OFF');
            
        % Measure unattenuated light
        input('Set up unattenuated light and hit enter'); pause(waitTime);
        Snd('Play',sin(0:10000));
        for i = 1:nAverageUnatten
            fprintf('\tUnatenuated measurement %d\n',i);
            unattenSpd(:,i) = spectroRadiometerOBJ.measure('userS', S);
        end
    
        % Signal to user that it's time to insert the filter
        fprintf('Hit a character\n');
        ListenChar(2);
        while (1)
            Snd('Play',sin(0:10000));
            pause(1);
            if (CharAvail)
                break;
            end
        end
        GetChar;
        ListenChar(0);
    
        input('Set up attenuated light and hit enter'); pause(waitTime);
        Snd('Play',sin(0:10000));
        for i = 1:nAverageAtten
            fprintf('\tAtenuated measurement %d\n',i);
            attenSpd(:,i) = spectroRadiometerOBJ.measure('userS', S);
        end
    
        % Let user know we're all done measuring
        fprintf('Hit a character\n');
        ListenChar(2);
        while (1)
            Snd('Play',sin(0:10000));
            pause(1);
            if (CharAvail)
                break;
            end
        end
        GetChar;
        ListenChar(0);
        
        % Gracefully shutdown the spectroradiometer
        spectroRadiometerOBJ.shutDown();
    
    catch err
        % cleanup related to the spectroRadiometerOBJ
        if (exist('spectroRadiometerOBJ', 'var'))
            if (isempty(spectroRadiometerOBJ))
                fprintf(2,'\nClosing all IO ports due to encountered error.\n');
                IOPort('closeall');
            else
                % Shutdown spectroRadiometerOBJ object and close the associated device
                fprintf(2,'\nShutting down spectroRadiometerOBJ due to encountered error. \n');
                spectroRadiometerOBJ.shutDown();
            end
        end
    
        rethrow(err);
    end
    
else
    cd(targetDir);
    eval(['load srf_filter_' filterName '_' dateName]);
    cd(curDir);  
end

unattenLum = T_xyz(2,:)*unattenSpd;
attenLum = T_xyz(2,:)*attenSpd;
nonzeroMeasIndex = find(attenLum ~= 0);
fprintf('%d of %d measurements above meter low-level limit\n',length(nonzeroMeasIndex),length(attenLum));
fprintf('Only averaging across pairs of measurements where atten measurement was OK\n');
fprintf('Mean unatten lum (cd/m2): %0.g\n',mean(unattenLum(nonzeroMeasIndex)));
fprintf('Mean atten lum (cd/m2): %0.4g\n',mean(attenLum(nonzeroMeasIndex)));

% Compute averages and estimate filter
nonzeroMeasIndex = find(attenLum ~= 0);
avgUnatten = mean(unattenSpd(:,nonzeroMeasIndex),2);
avgAtten = mean(attenSpd(:,nonzeroMeasIndex),2);
filter = avgAtten./avgUnatten;

% Print mean attenuation
fprintf('Mean attenuation = %0.4g\n',mean(filter));

% Save
cd(targetDir);
eval(['srf_filter_' filterName '= filter;']);
eval(['S_filter_' filterName ' = S;']);
eval(['save srf_filter_' filterName '_' dateName ' S_filter_' filterName ' srf_filter_' filterName ' unattenSpd attenSpd']);
cd(curDir);

% Plot
figure; clf;
subplot(1,2,1); hold on
plot(unattenLum,'ro','MarkerSize',8,'MarkerFaceColor','r');
ylim([0 1.1*max(unattenLum)]);
xlabel('Measurement #');
ylabel('Luminance (cd/m2');
title('Unattenuated');
subplot(1,2,2); hold on
plot(SToWls(S),unattenSpd);
xlabel('Wavelength (nm');
ylabel('Power');

% Plot
figure; clf;
subplot(1,2,1); hold on
plot(attenLum,'ro','MarkerSize',8,'MarkerFaceColor','r');
ylim([0 1.1*max(attenLum)]);
xlabel('Measurement #');
ylabel('Luminance (cd/m2');
title('Attenuated');
subplot(1,2,2); hold on
plot(SToWls(S),attenSpd);
xlabel('Wavelength (nm');
ylabel('Power');

% Plot
figure; clf; hold on
for i = 1:size(attenSpd,2)
    plot(SToWls(S),attenSpd(:,i)./unattenSpd(:,i),'r');
end
plot(SToWls(S),filter,'k','LineWidth',2);
xlabel('Wavelength (nm)');
ylabel('Tranmission');
%ylim([0 0.04]);
pbaspect([1 1 1]);
title('Filter');
cd(targetDir);
set(gcf, 'PaperPosition', [0 0 8 8]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [8 8]); %Set the paper to have width 5 and height 5.
saveas(gcf,['filterData_' filterName '_' dateName '.png'],'png');
cd(curDir);
