function OOC_compareCals

    % Load a calibration files
    [cal1, calFilename] = GetCalibrationStructure('Enter calibration filename','ViewSonicProbe',[]);
    [cal2, calFilename] = GetCalibrationStructure('Enter another calibration filename','ViewSonicProbe',[]);
    
    
    % Generate CalStructOBJ to handle the cal struct
    [cal1StructOBJ, ~] = ObjectToHandleCalOrCalStruct(cal1);
    [cal2StructOBJ, ~] = ObjectToHandleCalOrCalStruct(cal2);
    
    backgroundSpectra1 = cal1StructOBJ.get('bgmeas.spectra');
    backgroundSpectra2 = cal2StructOBJ.get('bgmeas.spectra');
    backgroundSpectra1 = backgroundSpectra1(:);
    backgroundSpectra2 = backgroundSpectra2(:);
    
    bg1 = [];
    bg2 = [];
    for k = 1:numel(backgroundSpectra1)
        a = backgroundSpectra1{k};
        bg1 = [bg1 a(:)];
        b = backgroundSpectra2{k};
        bg2 = [bg2 b(:)];
    end
    
    basicSpectra1 = 0.5*(cal1StructOBJ.get('basicmeas.spectra1') + cal1StructOBJ.get('basicmeas.spectra2'));
    basicSpectra2 = 0.5*(cal2StructOBJ.get('basicmeas.spectra1') + cal2StructOBJ.get('basicmeas.spectra2'));
    
    basicSpectra1 = basicSpectra1(:);
    basicSpectra2 = basicSpectra2(:);
    
    minAll = min([min(basicSpectra1) min(basicSpectra2)]);
    maxAll = max([max(basicSpectra1) max(basicSpectra2)]);
    
    figure(1);
    clf;
    subplot('Position', [0.07 0.55 0.9 0.40]);
    plot([minAll maxAll], [minAll maxAll], 'k-', 'LineWidth', 2);
    hold on
    plot(basicSpectra1(:), basicSpectra2(:), 'ro');
    hold off;
    axis 'square'
    set(gca, 'XScale', 'log', 'YScale', 'log');
    xlabel(cal1.describe.graphicsEngine, 'FontName', 'Helvetica', 'FontSize', 14);
    ylabel(cal2.describe.graphicsEngine, 'FontName', 'Helvetica', 'FontSize', 14);
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    title('basic measurements');
    drawnow;
    

    minAll = min([min(bg1) min(bg2)]);
    maxAll = max([max(bg1) max(bg2)]);
    
    subplot('Position', [0.07 0.06 0.9 0.40]);
    plot([minAll maxAll], [minAll maxAll], 'k-', 'LineWidth', 2);
    hold on
    plot(bg1(:), bg2(:), 'ro');
    hold off;
    axis 'square'
    set(gca, 'XScale', 'log', 'YScale', 'log');
    xlabel(cal1.describe.graphicsEngine, 'FontName', 'Helvetica', 'FontSize', 14);
    ylabel(cal2.describe.graphicsEngine, 'FontName', 'Helvetica', 'FontSize', 14);
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    title('background measurements');
    drawnow;
    
    
end
