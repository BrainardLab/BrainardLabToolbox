% Method that puts up a plot of the essential data
function plotBasicMeasurements(obj)
    cal = obj.cal;
    
    close all
    
    figure(1); clf;
    hold on
    plot(SToWls(cal.rawData.S), cal.processedData.P_device(:,1), 'r-');
    plot(SToWls(cal.rawData.S), cal.processedData.P_device(:,2), 'g-');
    plot(SToWls(cal.rawData.S), cal.processedData.P_device(:,3), 'b-');
    xlabel('Wavelength (nm)', 'Fontweight', 'bold');
    ylabel('Power', 'Fontweight', 'bold');
    title('Phosphor spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380, 780, -Inf, Inf]);
    drawnow;

    figure(2); clf;
    hold on
    plot(cal.rawData.gammaInput, cal.rawData.gammaTable(:,1), 'r+');
    plot(cal.rawData.gammaInput, cal.rawData.gammaTable(:,2), 'g+');
    plot(cal.rawData.gammaInput, cal.rawData.gammaTable(:,3), 'b+');
    xlabel('Input value', 'Fontweight', 'bold');
    ylabel('Normalized output', 'Fontweight', 'bold');
    title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    plot(cal.processedData.gammaInput, cal.processedData.gammaTable(:,1), 'r-');
    plot(cal.processedData.gammaInput, cal.processedData.gammaTable(:,2), 'g-');
    plot(cal.processedData.gammaInput, cal.processedData.gammaTable(:,3), 'b-');
    
    hold off
    drawnow;
end
