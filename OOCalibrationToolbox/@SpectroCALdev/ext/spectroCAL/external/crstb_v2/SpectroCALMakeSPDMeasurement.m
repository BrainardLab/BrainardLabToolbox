function [CIEXY, CIEUV, Luminance, Lambda, Radiance, errorString] = SpectroCALMakeSPDMeasurement(port,start, stop, step)
% [CIEXY CIEUV Luminance Lambda Radiance] = SpectroCALMakeSPDMeasurement(port,start, stop, resolution)
% 
% e.g. [CIEXY CIEUV Luminance Lambda Radiance] = SpectroCALMakeSPDMeasurement('COM3',380, 780, 1)
%
% CIEXY     = column vector contains CIE xy chromaticity coordinates
% CIEUV     = column vector contains CIE u'v' chromaticity coordinates
% Luminance = scalar containing Photopic Luminance in cd.^m-2
% Lambda    = row vector containing wavelengths that were measured in nm
% Radiance  = row vector containing spectral radiance in watts per
%             steradian per square meter for each measured wavelength
%
% port      = string containing name of serial port that has been assigned
%             to the device by the host operating system
% start     = integer containing start of wavelength sample
% stop      = integer containing end of wavelength sample
% step      = integer containing sample step size in nm (can be 1 or 5nm)

% 11/2017 Updated error handling

CIEXY = [];
CIEUV = [];
Luminance = [];
Lambda = [];
Radiance = [];

SpectroCALLaserOff(port);

VCP = serial(port, 'BaudRate', 921600,'DataBits', 8, 'StopBits', 1, 'FlowControl', 'none', 'Parity', 'none', 'Terminator', 'CR','Timeout', 240, 'InputBufferSize', 16000);

disp('Initialising SpectroCAL');

% To construct a serial port object:
fopen(VCP);

% Set automatic adaption to exposure
fprintf(VCP,['*CONF:EXPO 1', char(13)]);
errorString = checkACK(VCP,'setting exposure'); % check if command was acknowleged
if ~isempty(errorString), fclose(VCP); return; end

% Radiometric spectra in nm / value 
fprintf(VCP,['*CONF:FUNC 6', char(13)]);
errorString = checkACK(VCP,'reference spectrum'); % check if command was acknowleged
if ~isempty(errorString), fclose(VCP); return; end

% Set wavelength range and resolution
fprintf(VCP,['*CONF:WRAN ',num2str(start),' ',num2str(stop),' ',num2str(step), char(13)]);
errorString = checkACK(VCP,'setting wavelength range'); % check if command was acknowleged
if ~isempty(errorString), fclose(VCP); return; end
 
% Initiazise the measurement
fprintf(VCP,['*INIT', char(13)]);
errorString = checkACK(VCP,'initialising measurement'); % check if command was acknowleged
if ~isempty(errorString), fclose(VCP); return; end

disp('Measuring Spectral Power Distribution');
disp('Please Wait - set to timeout after 240s if insufficient signal');

% wait for measurement to finish (SpectroCAL returns 7)
tic;
while 1
    if VCP.BytesAvailable>0
        sReturn = fread(VCP,VCP.BytesAvailable)';
        if sReturn(1)~=7 % if the return is not 7
            warning(['SpectroCAL: returned error code ',num2str(sReturn(1))]);
            errorString = {['SpectroCAL: returned error code ',num2str(sReturn(1))],'Check for overexposure.'};
            fclose(VCP);
            return % abort the measurement and exit the function
        else
            break; % measurement succesfully completed
        end

    end
    if toc>240
        warning('SpectroCAL: timeout. No response received within 240 seconds.');
        errorString = 'SpectroCAL: timeout. No response received within 240 seconds.';
        fclose(VCP);
        return % abort the measurement and exit the function
    end
    pause(0.01);
end  
    
MeasurementValues = ['Values used in this measurement:  ','Start nm  ',num2str(start),'  Stop nm  ',num2str(stop),'  Step size nm  ',num2str(step)];

disp(MeasurementValues);

disp('Retrieving the data from SpectroCAL');
% Get the SPD
fprintf(VCP,['*FETCH:SPRAD 7', char(13)]);

% Find and strip the SPD header
found=false;
header=[];
while found==false
    letter = fread(VCP, 1);
    header = [header letter];
    if letter == 13
        if header(end) == header(end-1)
            found=true;       
        end
    end
end

% Extract the SPD
found=false;
allSPD=[];
while found==false
    SPD = fread(VCP, 1);
    allSPD = [allSPD SPD];
    if SPD == 13
        if allSPD(end) == allSPD(end-1)
            found=true;       
        end
    end
end

% Get the luminance
fprintf(VCP,['*FETCH:PHOTO 7', char(13)]);

% Find and strip the Luminance header
found=false;
while found==false
    letter = fread(VCP, 1);
    if letter == 9
        found=true;
    end
end

% Extract the Luminance
found=false;
LUM=[];
while found==false
    LUMval = fread(VCP, 1);
    LUM = [LUM LUMval];
    if LUMval == 13
        found=true;
    end
end

% Get CIE xy chromaticity coordinates
fprintf(VCP,['*FETCH:CHROMXY 7', char(13)]);

% Find and strip the x header
found=false;
while found==false
    letter = fread(VCP, 1);
    if letter == 9
        found=true;
    end
end

% Extract x
found=false;
CIEx=[];
while found==false
    xval = fread(VCP, 1);
    CIEx = [CIEx xval];
    if xval == 13
        found=true;
    end
end

% Find and strip the y header
found=false;
while found==false
    letter = fread(VCP, 1);
    if letter == 9
        found=true;
    end
end

% Extract y
found=false;
CIEy=[];
while found==false
    yval = fread(VCP, 1);
    CIEy = [CIEy yval];
    if yval == 13
        found=true;
    end
end

% Get CIE u'v' chromaticity coordinates
fprintf(VCP,['*FETCH:CHROMUV 7', char(13)]);

% Find and strip the u' header
found=false;
while found==false
    letter = fread(VCP, 1);
    if letter == 9
        found=true;
    end
end

% Extract u'
found=false;
CIEu=[];
while found==false
    uval = fread(VCP, 1);
    CIEu = [CIEu uval];
    if uval == 13
        found=true;
    end
end

% Find and strip the v' header
found=false;
while found==false
    letter = fread(VCP, 1);
    if letter == 9
        found=true;
    end
end

% Extract v'
found=false;
CIEv=[];
while found==false
    vval = fread(VCP, 1);
    CIEv = [CIEv vval];
    if vval == 13
        found=true;
    end
end

fclose(VCP);

ASCIIspd = char(allSPD);
SPD = sscanf(ASCIIspd, '%g %g', [2 ((stop-start)/step)+1]);
Lambda = SPD(1,:);
Radiance = SPD(2,:);

ASCIILUM = char(LUM);
Luminance = sscanf(ASCIILUM, '%g %g');

ASCIIx = char(CIEx);
ASCIIy = char(CIEy);
CIEXY(1) = sscanf(ASCIIx, '%g %g');
CIEXY(2) = sscanf(ASCIIy, '%g %g');

CIEXY = CIEXY';

ASCIIu = char(CIEu);
ASCIIv = char(CIEv);
CIEUV(1) = sscanf(ASCIIu, '%g %g');
CIEUV(2) = sscanf(ASCIIv, '%g %g');

CIEUV = CIEUV';
disp('Done');

function ErrorString = checkACK(VCP,string)
    tic;
    while 1
        if VCP.BytesAvailable>0
            sReturn = fread(VCP,1)';
            if sReturn(1)~=6 % if the return is not 6
                warning(['error initialising SpectroCAL: returned error code ',num2str(sReturn(1))]);
                ErrorString = ['SpectroCAL: ',string];
                return
            else
                ErrorString = '';
                return; % command acknowledged
            end
            
        end
        if toc>2
            warning('error initialising SpectroCAL: timeout. No response received within 2 seconds.');
            ErrorString = 'SpectroCAL: timeout. No response received within 2 seconds.';
            return
        end
        pause(0.01);
    end  
