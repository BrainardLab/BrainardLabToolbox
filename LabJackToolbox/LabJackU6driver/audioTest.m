function audioTest

    frequencyHz = 30;
    samplingFrequencyHz = 50000;
    dt = 1/samplingFrequencyHz;
    duration = 5.0;
    t = 0:dt:duration;
    tt = t-mean(t);
    sigma = mean(t)/6;
    envelope = (exp(-0.5*(tt/sigma).^2)).^0.25;
    y = 1/2*sin(2*pi*frequencyHz*tt) .* envelope;
    figure(1); clf;
    plot(t,y);
    drawnow;
    audiowrite('30Hz.wav',y, samplingFrequencyHz);
end

