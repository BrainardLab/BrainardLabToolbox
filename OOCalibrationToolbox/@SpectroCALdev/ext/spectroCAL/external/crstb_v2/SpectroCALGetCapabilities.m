function [Start Stop] = SpectroCALGetCapabilities(port)
% [Start Stop] = SpectroCALGetCapabilities(port)
% 
% Use this function to determine the wavelength range that SpectroCAL makes
% measurements across
%
% e.g. [Start Stop] = SpectroCALGetCapabilities('COM3')
%
% Start     = integer containing start of predefined wavelength range
% Stop      = integer containing end of predefined wavelength range
%
% port      = string containing name of serial port that has been assigned
%             to the device by the host operating system

Start = [];
Stop = [];
Range = [];

VCP = serial(port, 'BaudRate', 921600,'DataBits', 8, 'StopBits', 1, 'FlowControl', 'none', 'Parity', 'none', 'Terminator', 'CR','Timeout', 240, 'InputBufferSize', 16000);

% To construct a serial port object:
fopen(VCP);

% Get the Start
fprintf(VCP,['*PARA:WAVBEG?', char(13)]);

% Find and strip the header
found=false;
while found==false
    letter = fread(VCP, 1);
    if letter == 9
        found=true;
    end
end

% Extract the value
found=false;
WAVBEG=[];
while found==false
    BEGval = fread(VCP, 1);
    WAVBEG = [WAVBEG BEGval];
    if BEGval == 13
        found=true;
    end
end

% Get the Stop
fprintf(VCP,['*PARA:WAVEND?', char(13)]);

% Find and strip the header
found=false;
while found==false
    letter = fread(VCP, 1);
    if letter == 9
        found=true;
    end
end

% Extract the value
found=false;
WAVEND=[];
while found==false
    ENDval = fread(VCP, 1);
    WAVEND = [WAVEND ENDval];
    if ENDval == 13
        found=true;
    end
end

fclose(VCP);

ASCIIWAVBEG = char(WAVBEG);
Start = sscanf(ASCIIWAVBEG, '%g %g');

ASCIIWAVEND = char(WAVEND);
Stop = sscanf(ASCIIWAVEND, '%g %g');

Range = ['Range is:  ','Start nm  ',num2str(Start),'  Stop nm  ',num2str(Stop)];

disp(Range);