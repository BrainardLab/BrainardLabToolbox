function computeLMSactivationsByRGBprimariesTutorial

    % Load the calibration file
    calFile = 'ViewSonicProbe';
    cal = LoadCalFile(calFile);

    % generate a calStructOBJ to access the calibration data
    calStructOBJ = ObjectToHandleCalOrCalStruct(cal);
    clear 'cal'

    % Retrieve the display primaries SPD data from the calibration
    S_primaries = calStructOBJ.get('S');
    wavelengthSamplingPrimaries = SToWls(S_primaries);
    SPDs = calStructOBJ.get('P_device');
    
    % Load cone spectra and interpolate to desired wavelength sampling
    load('T_cones_ss2.mat');  % this loads S_cones_ss2 and T_cones_ss2
    S_coneFundamentals = S_cones_ss2;
    coneFundamentals   = T_cones_ss2;
    wavelengthSamplingCones = SToWls(S_coneFundamentals);
    
    
    % Match wavelength sampling of primariesSPD to that of cones fundamentals
    upsampledSPDs = SplineSpd(S_primaries, SPDs, S_coneFundamentals);
   
    % or match wavelength sampling of cones to that of the measured SPDs;
    downsampledConeFundamentals = SplineCmf(S_coneFundamentals, coneFundamentals, S_primaries);
    
    % Compute excitations for upsampled and downsampled versions
    for primaryIndex = 1:3
        for coneIndex = 1:3
            coneExcitation1(coneIndex, primaryIndex) = dot(upsampledSPDs(:,primaryIndex), coneFundamentals(coneIndex,:));
            coneExcitation2(coneIndex, primaryIndex) = dot(SPDs(:,primaryIndex), downsampledConeFundamentals(coneIndex,:));
        end
    end
    
    
    % Plotting
    normSPDs = SPDs/max(SPDs(:));
    hFig = figure(1); clf; set(hFig, 'Position', [10 10 1420 600]); hold on;
    plot(wavelengthSamplingCones, squeeze(coneFundamentals(1,:)), 's-', 'MarkerSize', 10, 'MarkerFaceColor', [0.9 0.5 0.7], 'MarkerEdgeColor', [1 0 0], 'Color', [0.9 0.5 0.7], 'LineWidth', 1.0);
    plot(wavelengthSamplingCones, squeeze(coneFundamentals(2,:)), 's-', 'MarkerSize', 10, 'MarkerFaceColor', [0.4 0.9 0.7], 'MarkerEdgeColor', [0 1 0], 'Color', [0.2 0.9 0.7], 'LineWidth', 1.0);
    plot(wavelengthSamplingCones, squeeze(coneFundamentals(3,:)), 's-', 'MarkerSize', 10, 'MarkerFaceColor', [0.8 0.6 0.9], 'MarkerEdgeColor', [0 0 1], 'Color', [0.8 0.6 0.9], 'LineWidth', 1.0);
    plot(wavelengthSamplingPrimaries, squeeze(normSPDs(:,1)), 'kd-', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    plot(wavelengthSamplingPrimaries, squeeze(normSPDs(:,2)), 'kd-', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
    plot(wavelengthSamplingPrimaries, squeeze(normSPDs(:,3)), 'kd-', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
    box on; grid on
    set(gca, 'XLim', [380 830], 'XTick', [0:50:1000], 'YTick', [0:0.1:1.0]);
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    xlabel('wavelength (nm)', 'FontWeight', 'b');
    ylabel('sensitivity', 'FontWeight', 'b');
    hlegend = legend('Lcone', 'Mcone', 'Scone', 'Rprimary', 'Gprimary', 'Bprimary');
    set(hlegend, 'FontName', 'Helvetica', 'FontSize', 16);
    NicePlot.exportFigToPDF('RawData',hFig,300);
    
    
    
    % Plot original and upsampled red primary 
    hFig = figure(2); set(hFig, 'Position', [10 100 1420 600]);clf;
    subplot(2,1,1);
    hold on;
    stem(wavelengthSamplingPrimaries, SPDs(:,1), 'ks-', 'MarkerSize', 12, 'MarkerFaceColor', [0.8 0.8 0.8]);
    plot(wavelengthSamplingCones, upsampledSPDs(:,1), 'r.', 'MarkerSize', 6, 'MarkerFaceColor', [1 0 0]);
    box on; grid on
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    set(gca, 'XLim', [380 830], 'XTick', [0:50:1000]);
    xlabel('wavelength (nm)', 'FontWeight', 'b');
    ylabel('energy', 'FontWeight', 'b');
    hlegend = legend('raw primary SPD', 'up-sampled primary SPD');
    set(hlegend, 'FontName', 'Helvetica', 'FontSize', 16);
    title('SplineSpd', 'FontName', 'Helvetica', 'FontSize', 16);

    subplot(2,1,2);
    hold on;
    stem(wavelengthSamplingPrimaries, downsampledConeFundamentals(1,:), 'ks-', 'MarkerSize', 12, 'MarkerFaceColor', [0.8 0.8 0.8]);
    plot(wavelengthSamplingCones, coneFundamentals(1,:), 'r.', 'MarkerSize', 6, 'MarkerFaceColor', [1 0 0]); 
    box on; grid on
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    set(gca, 'XLim', [380 830], 'XTick', [0:50:1000]);
    xlabel('wavelength (nm)', 'FontWeight', 'b');
    ylabel('sensitivity', 'FontWeight', 'b');
    hlegend = legend('down-sampled fundamental', 'raw fundamental');
    set(hlegend, 'FontName', 'Helvetica', 'FontSize', 16);
    title('SplineCmf', 'FontName', 'Helvetica', 'FontSize', 16);
    
    NicePlot.exportFigToPDF('UpDownSampling',hFig,300);
    
    
    
    hFig = figure(3); set(hFig, 'Position', [10 10 1040 615]); clf;
    coneTypes = {'L', 'M', 'S'};
    primaries = {'Red', 'Green', 'Blue'};
    LMScolors = hsv(3);
    

    for primaryIndex = 1:numel(primaries)
        subplot(2,3, primaryIndex);
        hold on
        bar(1, coneExcitation1(1, primaryIndex), 'facecolor', [0.9 0.5 0.7]); 
        bar(2, coneExcitation1(2, primaryIndex),  'facecolor', [0.4 0.9 0.7]); 
        bar(3, coneExcitation1(3, primaryIndex), 'facecolor', [0.8 0.6 0.9]);
         box on; grid on
        xlabel('cone type'); ylabel('cone excitation');
        set(gca, 'XTick', [1 2 3], 'XTickLabel', coneTypes);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
        title(sprintf('%s primary', primaries{primaryIndex}));
       
        
        subplot(2,3, 3+primaryIndex);
        hold on;
        bar(1, 100*abs(coneExcitation1(1, primaryIndex)-coneExcitation2(1, primaryIndex))/coneExcitation1(1, primaryIndex), 'facecolor', [0.9 0.5 0.7]); 
        bar(2, 100*abs(coneExcitation1(2, primaryIndex)-coneExcitation2(2, primaryIndex))/coneExcitation1(2, primaryIndex),  'facecolor', [0.4 0.9 0.7]); 
        bar(3, 100*abs(coneExcitation1(3, primaryIndex)-coneExcitation2(3, primaryIndex))/coneExcitation1(3, primaryIndex), 'facecolor', [0.8 0.6 0.9]); 
        box on; grid on
        xlabel('cone type'); ylabel('percent error');
        set(gca, 'XTick', [1 2 3], 'XTickLabel', coneTypes);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
        title(sprintf('%s primary', primaries{primaryIndex}));
    end
       
    NicePlot.exportFigToPDF('Excitations',hFig,300);
    
end
