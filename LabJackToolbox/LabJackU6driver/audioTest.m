function audioTest

    frequencyHz = 100;
    samplingFrequencyHz = 50000;
    dt = 1/samplingFrequencyHz;
    duration = 5.0;
    t = 0:dt:duration;
    y = 1/2*sin(2*pi*frequencyHz*t);
    audiowrite('100Hz.wav',y, samplingFrequencyHz);
end

