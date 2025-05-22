% MeasureSphereOOC.m
%
% Measures spectrum of unisphere source.
%
% 1/5/96	dhb		Re-wrote from JDT original.
% 4/14/99   pbe		New/old meter choice.
% 6/30/00	pbe		Added cd to save to correct folder
% 4/12/02   dhb, kr Update for Penn
% 12/01/05          Fixed data save location to ColorShare instead of LabShare
% 2/19/10   dhb, sm OS/X.
% 3/11/10   dhb     Read serial number from meter and compare.
% 3/11/10   dhb     Initialize meter earlier.
% 8/20/12   dhb, sm PR-670 thread debugged.
% 11/11/15  dhb, jr, si  Modify for our two PR-670s.
% 31/8/16	npc		Use the PR650/670 spectroradiometer objects, made it into a function
% 09/05/17  npc     Code cleanup
% 09/09/17  dhb     Update to use prefs for where data live and go.
% 04/28/25  npc     Update to add CR-250dev

function MeasureSphereOOC()


% Get directory where stuff is
if (~ispref('BrainardLabToolbox','RadiometerChecksDir'))
    error('No ''BrainardLabToolbox:RadiometerChecksDir'' preference set.  Probably you need to update your BrainardLabToolbox local hook file.')
end

radiometerChecksDir = getpref('BrainardLabToolbox','RadiometerChecksDir');
if (~exist(radiometerChecksDir,'dir'))
    error(['Directory ' radiometerChecksDir ' does not exist.  Something is not set up correctly.']);
end
spectroRadiometerOBJ = [];

% Number of measurements
nMeasure = 5;
nominalFL = 30;
actualFL = 0.82*nominalFL;
squareFeetPerMeter = 10.7666;
FL_To_CDFT2 = 0.3183;
actualCDFT2 = FL_To_CDFT2*actualFL;
actualCDM2 = actualCDFT2*squareFeetPerMeter;

% Which radiometer is being tested?
defaultMeter = 1;
fprintf(1,'\nWhich meter is being tested?\n');
fprintf(1,'\tNew UCSB (serial #60990905) enter 1 (default)\n');
fprintf(1,'\tPenn (serial #60020902) enter 2\n');
fprintf(1,'\tPR-670 #1 (serial #67122301), enter 3\n');
fprintf(1,'\tPR-670 #2 (serial #67154302), enter 4\n');
fprintf(1,'\tCR-250 (serial A00927), enter 5\n');

theDataPrompt = sprintf('Enter meter number (default is %g): ',defaultMeter);
meter = input(theDataPrompt);
if (isempty(meter))
    meter = defaultMeter;
end

if IsLinux
    PR650devicePortString = '/dev/ttyUSB0';
else
    PR650devicePortString = [];
end

try
    
    switch (meter)
        case 1
            whichMeter = 'NewUCSB';
            meterType = 1;
            S = [380 5 81];
            spectroRadiometerOBJ  = PR650dev(...
                'verbosity',        1, ...       % 1 -> minimum verbosity
                'devicePortString', [] ...       % empty -> automatic port detection)
                );
            spectroRadiometerOBJ.setOptions('syncMode', 'OFF');
            
        case 2
            whichMeter = 'Penn';
            meterType = 1;
            S = [380 5 81];
            spectroRadiometerOBJ  = PR650dev(...
                'verbosity',        1, ...       % 1 -> minimum verbosity
                'devicePortString', PR650devicePortString ...       % empty -> automatic port detection)
                );
            spectroRadiometerOBJ.setOptions('syncMode', 'OFF');
            
        case 3
            whichMeter = 'PR-670_1';
            meterType = 5;
            S = [380 2 201];
            spectroRadiometerOBJ  = PR670dev(...
                'verbosity',        1, ...       % 1 -> minimum verbosity
                'devicePortString', [] ...       % empty -> automatic port detection)
                );
            
        case 4
            whichMeter = 'PR-670_2';
            meterType = 5;
            S = [380 2 201];
            spectroRadiometerOBJ  = PR670dev(...
                'verbosity',        1, ...       % 1 -> minimum verbosity
                'devicePortString', [] ...       % empty -> automatic port detection)
                );

        case 5
            whichMeter = 'CR-250';
            meterType = 5;
            S = [380 2 201];
            spectroRadiometerOBJ = CR250dev(...
                'verbosity',        1, ...        % 1 -> minimum verbosity
                'devicePortString', [] ...       % empty -> automatic port detection)
                );

    end
    
catch e
    fprintf('Failed with message: ''%s''.\nPlease wait for the spectroradiometer to shut down .... ', e.message);
    if (~isempty(spectroRadiometerOBJ))
        spectroRadiometerOBJ.shutDown();
    end
    rethrow(e);
end
fileName = [whichMeter '_Sphere_' date];

% XYZ color matching function
load T_xyz1931;
T_xyz1931 = SplineCmf(S_xyz1931,683*T_xyz1931,S);

% A little more meter specific stuff
switch (meter)
    case 1
        if (exist('PR650getserialnumber','file'))
            meterSerialNum = spectroRadiometerOBJ.deviceSerialNum;
            if (~strcmp(meterSerialNum,'60990905'))
                error('Serial number read from meter doesn''t match meter entered.\n');
            end
        end
    case 2
        if (exist('PR650getserialnumber','file'))
            meterSerialNum = spectroRadiometerOBJ.deviceSerialNum;
            if (~strcmp(meterSerialNum,'60020902'))
                error('Serial number read from meter doesn''t match meter entered.\n');
            end
        end
        
    case 3
        meterSerialNum = spectroRadiometerOBJ.deviceSerialNum;
        if (~strcmp(meterSerialNum,'67122301'))
            error('Serial number read from meter doesn''t match meter entered.\n');
        end
        spectroRadiometerOBJ.setOptions(...
            'syncMode',         'OFF', ...      % choose from 'OFF', 'AUTO', [20 400];
            'cyclesToAverage',  1, ...          % choose any integer in range [1 99]
            'sensitivityMode',  'STANDARD', ... % choose between 'STANDARD' and 'EXTENDED'.  'STANDARD': (exposure range: 6 - 6,000 msec, 'EXTENDED': exposure range: 6 - 30,000 msec
            'exposureTime',     1000, ... % choose between 'ADAPTIVE' (for adaptive exposure), or a value in the range [6 6000] for 'STANDARD' sensitivity mode, or a value in the range [6 30000] for the 'EXTENDED' sensitivity mode
            'apertureSize',     '1 DEG' ...   % choose between '1 DEG', '1/2 DEG', '1/4 DEG', '1/8 DEG'
            );
        
        
    case 4
        meterSerialNum = spectroRadiometerOBJ.deviceSerialNum;
        if (~strcmp(meterSerialNum,'67154302'))
            error('Serial number read from meter doesn''t match meter entered.\n');
        end
        spectroRadiometerOBJ.setOptions(...
            'syncMode',         'OFF', ...      % choose from 'OFF', 'AUTO', [20 400];
            'cyclesToAverage',  1, ...          % choose any integer in range [1 99]
            'sensitivityMode',  'STANDARD', ... % choose between 'STANDARD' and 'EXTENDED'.  'STANDARD': (exposure range: 6 - 6,000 msec, 'EXTENDED': exposure range: 6 - 30,000 msec
            'exposureTime',     1000, ...       % choose between 'ADAPTIVE' (for adaptive exposure), or a value in the range [6 6000] for 'STANDARD' sensitivity mode, or a value in the range [6 30000] for the 'EXTENDED' sensitivity mode
            'apertureSize',     '1 DEG' ...   % choose between '1 DEG', '1/2 DEG', '1/4 DEG', '1/8 DEG'
            );

    case 5
        meterSerialNum = spectroRadiometerOBJ.deviceSerialNum;
        if (~strcmp(meterSerialNum,'A00927'))
            error('Serial number read from meter doesn''t match meter entered.\n');
        end

        if (1==2)
            spectroRadiometerOBJ.exposureMode = 'Fixed';
            spectroRadiometerOBJ.fixedExposureTimeMilliseconds = 1500;
        end
        

        if (1==2)
        spectroRadiometerOBJ.syncMode
        spectroRadiometerOBJ.speedMode
        spectroRadiometerOBJ.exposureMode
        end
        
        if (1==2)
        spectroRadiometerOBJ.setOptions(...
                'syncMode',  'None', ...                  % choose from 'None', 'Manual', 'NTSC', 'PAL', 'CINEMA'
                'speedMode', 'Normal', ...                % choose from 'Slow','Normal','Fast', '2x Fast'
                'exposureMode', 'Auto' ...                % Choose between 'Auto', and 'Fixed'
            );
        end


end

% Instructions
fprintf(1,'Point meter at sphere, set to %g nominal luminance.\n',nominalFL);
fprintf(1,'(Can usually only get sphere to fluctuate between 29/30/31)\n');
fprintf(1,'Standard distance is 1 meter.\n');
fprintf(1,'Hit enter when ready.\n');
pause;
wls = SToWls(S);

figure; clf
hold off
theSpectra = {};
fprintf(1,['\n\nSPHERE MEASUREMENTS - ' whichMeter '\n']);
for i = 1:nMeasure
    % Measure
    fprintf(1, 'Measuring %g...',i);
    spectrum = spectroRadiometerOBJ.measure('userS', S);
    fprintf(1,'done\n');
    theSpectra{i} = spectrum;
    measureXYZ = T_xyz1931*spectrum;
    measureCDM2(i) = measureXYZ(2);
    fprintf(1,'\tNominal luminance, %g cd/m2, actual %g cd/m2\n',actualCDM2,measureCDM2(i));
    
    % Plot
    plot(wls,spectrum,'r');
    
    hold on
end
str = LiteralUnderscore(sprintf([fileName ', %0.2f cd/m2'],mean(measureCDM2(i))));
title(str, 'Fontsize', 12, 'Fontname', 'helvetica', 'Fontweight', 'bold');
%axis([350 800 0 0.25]);
hold off;
drawnow;

% Save to right folder
curDir = pwd;
switch (whichMeter)
    case 'NewUCSB'
        cd(fullfile(radiometerChecksDir,'xNewMeter'));
    case 'Penn'
        cd(fullfile(radiometerChecksDir,'xPennMeter'));
    case 'PR-670_1'
        cd(fullfile(radiometerChecksDir,'xPR-670_1'));
    case 'PR-670_2'
        cd(fullfile(radiometerChecksDir,'xPR-670_2'));
    case 'CR-250'
        cd(fullfile(radiometerChecksDir,'xCR-250'));
end
eval(['save(''' fileName ''');']);
saveas(gcf,[fileName '.pdf'],'pdf');
cd(curDir);

% Shutdown spectroradiometer
if (~isempty(spectroRadiometerOBJ))
    spectroRadiometerOBJ.shutDown();
end

end

