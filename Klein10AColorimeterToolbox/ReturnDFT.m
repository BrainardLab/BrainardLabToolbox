function [fftSignal fSignal dc_term] = ReturnDFT(t, s, frequency, hammingFlag)
% fft = ReturnDFT(t, s, frequency)
%
% Return the DFT.
%
% 3/1/2014  ms  Wrote it.

% Set up parameters
timeSignal = t/1000; % Convert to second
NSignal = length(timeSignal);
dtSignal = 1/frequency;
FsSignal = 1/dtSignal;
dfSignal = FsSignal/NSignal;
fSignal = linspace(-FsSignal/2, FsSignal/2-dfSignal, NSignal);

% Do we want to Hamming-window the signal?
if hammingFlag
    theWindow = hamming(NSignal);
    s = s.*theWindow';
end

% FFT the signal
fftSignal = dtSignal * fftshift(fft(ifftshift(s)));
tmp = fft(s);
dc_term = dtSignal*tmp(1);