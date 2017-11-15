function [error] = SpectroCALLaserOn(port)
% [error] = SpectroCALLaserOn(port) 
% 
% e.g. error = SpectroCALLaserOn('COM3')
%
% COM Port = COM port that has been assigned to SpectroCAL by Windows.
%            Check which one has been assigned to the device using
%            Windows Device Manager

VCP = serial(port, 'BaudRate', 921600,'DataBits', 8, 'StopBits', 1, 'FlowControl', 'none', 'Parity', 'none', 'Terminator', 'CR','Timeout', 5, 'InputBufferSize', 16000);
fopen(VCP);
fprintf(VCP,['*CONTR:LASER 1', char(13)]);
error=fread(VCP,1);
fclose(VCP);