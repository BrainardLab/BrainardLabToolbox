% mglAnalyzeYokedCalibration
%
% Test that the yoked calibration properly predicts the measuements it was derived from.
%
% 6/4/10  dhb, ar  Wrote it.
% 6/10/10 dhb      Prompt for which file.  
%         dhb      Open circles plot results for low input values
%         dhb      Reduce number of plots.  Additional options can be turned back on if you want.
%         dhb      Add direct comparison to what is in the raw gamma measurements.
% 7/15/10  ar      Determine the highest luminance to be used for plots. 
%% Clear
clear; close all;

%% Load the calibration file we want to check
cal = GetCalibrationStructure('Enter calibration file to analyze','HDRBackYokedMondrianwhite',[]);

%% Sensor color space
S = [380 4 101];
load T_xyz1931
T_xyz=683*SplineCmf(S_xyz1931, T_xyz1931, S);
cal = SetSensorColorSpace(cal,T_xyz,S);
cal = SetGammaMethod(cal,0);

%% Predict the yoked measurements from the yoked calibration file
for i = 1:size(cal.yoked.settings,2)
    [predictedYokedXYZ(:,i)] = SettingsToSensorAcc(cal,cal.yoked.settings(:,i));
end
predictedYokedxyY = XYZToxyY(predictedYokedXYZ);

%% Make sure that the yoked settings match what is in cal.rawdata.rawGammaInput
% If not, we didn't build the yoked calibration file the way we thought we did.
check = cal.yoked.settings-cal.rawdata.rawGammaInput';
if (max(abs(check)) > 1e-8)
    error('Goof in relation between yoked and raw gamma settings');
end

%% Get the yoked measurements in xyY.  For a fair comparison,
% we need to add the ambient light in to the measured XYZ 
% coordinates, since that is what we are predicting.
measuredYokedXYZ = T_xyz*cal.yoked.spectra;
measuredAmbientXYZ = T_xyz*cal.P_ambient;
measuredYokedxyY = XYZToxyY(measuredYokedXYZ+repmat(measuredAmbientXYZ,1,size(measuredYokedXYZ,2)));

%% Get prediction directly from the rawGammaTable.  Also need to add ambient for
% these.  This prediction takes the quality of the fit to the gamma data out of
% the predictions, and lets us see how well we do based on the linear model approximation
% and measured gamma values.
%
% The plots for these are currently only added to the plots against nominal input
rawPredictedXYZ = T_xyz*(cal.P_device*cal.rawdata.rawGammaTable');
rawPredictedYokedxyY = XYZToxyY(rawPredictedXYZ+repmat(measuredAmbientXYZ,1,size(measuredYokedXYZ,2)));

% Determine the highest coordinate for maxLum
if predictedYokedxyY(3,end) >= measuredYokedxyY(3,end)
    maxLum=1.1*predictedYokedxyY(3,end); 
else
    maxLum=1.1*measuredYokedxyY(3,end); 
end
%% Plots against luminance
if (0)
    [lumPlot,f] = StartFigure('standard');
    f.xrange = [0 maxLum]; f.nxticks = 6;
    f.yrange = [0 maxLum]; f.nyticks = 5;
    f.xtickformat = '%0.1f'; f.ytickformat = '%0.1f ';
    for i = 1:size(cal.yoked.settings,2)
        if (any(cal.yoked.settings(:,i) < 1e-3))
            plot(measuredYokedxyY(3,i)', measuredYokedxyY(3,i)','ro','MarkerSize',f.basicmarkersize);
            plot(measuredYokedxyY(3,i)', predictedYokedxyY(3,i)','go','MarkerSize',f.basicmarkersize);
        else
            plot(measuredYokedxyY(3,i)', measuredYokedxyY(3,i)','ro','MarkerSize',f.basicmarkersize,'MarkerFaceColor','r');
            plot(measuredYokedxyY(3,i)', predictedYokedxyY(3,i)','go','MarkerSize',f.basicmarkersize,'MarkerFaceColor','g');
        end
    end
    xlabel('Predicted Luminance (cd/m2)','FontName',f.fontname,'FontSize',f.labelfontsize);
    ylabel('Predicted Luminance (cd/m2)','FontName',f.fontname,'FontSize',f.labelfontsize);
    FinishFigure(lumPlot,f);
    
    % Plot x chromaticity as a function of luminance
    [xPlot,f] = StartFigure('standard');
    f.xrange = [0 maxLum]; f.nxticks = 6;
    f.yrange = [0.2 0.6]; f.nyticks = 5;
    f.xtickformat = '%d'; f.ytickformat = '%0.2f ';
    for i = 1:size(cal.yoked.settings,2)
        if (any(cal.yoked.settings(:,i) < 1e-3))
            plot(measuredYokedxyY(3,i)', measuredYokedxyY(1,i)','ro','MarkerSize',f.basicmarkersize);
            plot(measuredYokedxyY(3,i)', predictedYokedxyY(1,i)','go','MarkerSize',f.basicmarkersize);
        else
            plot(measuredYokedxyY(3,i)', measuredYokedxyY(1,i)','ro','MarkerSize',f.basicmarkersize,'MarkerFaceColor','r');
            plot(measuredYokedxyY(3,i)', predictedYokedxyY(1,i)','go','MarkerSize',f.basicmarkersize,'MarkerFaceColor','g');
        end
    end
    xlabel('Predicted Luminance (cd/m2)','FontName',f.fontname,'FontSize',f.labelfontsize);
    ylabel('x chromaticity','FontName',f.fontname,'FontSize',f.labelfontsize);
    FinishFigure(xPlot,f);
    
    % Plot y chromaticity as a function of luminance
    [yPlot,f] = StartFigure('standard');
    f.xrange = [0 maxLum]; f.nxticks = 6;
    f.yrange = [0.2 0.6]; f.nyticks = 5;
    f.xtickformat = '%0.1f'; f.ytickformat = '%0.2f ';
    for i = 1:size(cal.yoked.settings,2)
        if (any(cal.yoked.settings(:,i) < 1e-3))
            plot(measuredYokedxyY(3,i)', measuredYokedxyY(2,i)','ro','MarkerSize',f.basicmarkersize);
            plot(measuredYokedxyY(3,i)', predictedYokedxyY(2,i)','go','MarkerSize',f.basicmarkersize);
        else
            plot(measuredYokedxyY(3,i)', measuredYokedxyY(2,i)','ro','MarkerSize',f.basicmarkersize,'MarkerFaceColor','r');
            plot(measuredYokedxyY(3,i)', predictedYokedxyY(2,i)','go','MarkerSize',f.basicmarkersize,'MarkerFaceColor','g');
        end
    end
    xlabel('Luminance (cd/m2)','FontName',f.fontname,'FontSize',f.labelfontsize);
    ylabel('y chromaticity','FontName',f.fontname,'FontSize',f.labelfontsize);
    FinishFigure(yPlot,f);
end

%% Plots against nominal
if (1)
    % luminance
    [lumPlot,f] = StartFigure('standard');
    f.xrange = [0 size(cal.yoked.settings, 2)]; f.nxticks = 6;
    f.yrange = [0 maxLum]; f.nyticks = 5;
    f.xtickformat = '%0.0f'; f.ytickformat = '%0.2f ';
    for i = 1:size(cal.yoked.settings,2)
        if (any(cal.yoked.settings(:,i) < 1e-3))
            plot(i,measuredYokedxyY(3,i)','ro','MarkerSize',f.basicmarkersize+2);
            plot(i,predictedYokedxyY(3,i)','go','MarkerSize',f.basicmarkersize);
            plot(i,rawPredictedYokedxyY(3,i)','bo','MarkerSize',f.basicmarkersize-2);
        else
            plot(i,measuredYokedxyY(3,i)','ro','MarkerSize',f.basicmarkersize+2,'MarkerFaceColor','r');
            plot(i,predictedYokedxyY(3,i)','go','MarkerSize',f.basicmarkersize,'MarkerFaceColor','g');
            plot(i,rawPredictedYokedxyY(3,i)','bo','MarkerSize',f.basicmarkersize-2,'MarkerFaceColor','b');
        end
    end
    xlabel('Test #','FontName',f.fontname,'FontSize',f.labelfontsize);
    ylabel('Luminance (cd/m2)','FontName',f.fontname,'FontSize',f.labelfontsize);
    FinishFigure(lumPlot,f);
    
    
    % x chromaticity obtained
    [xPlot,f] = StartFigure('standard');
    f.xrange = [0 size(cal.yoked.settings, 2)]; f.nxticks = 6;
    f.yrange = [0.2 0.6]; f.nyticks = 5;
    f.xtickformat = '%0.0f'; f.ytickformat = '%0.2f ';
   for i = 1:size(cal.yoked.settings,2)
        if (any(cal.yoked.settings(:,i) < 1e-3))
            plot(i,measuredYokedxyY(1,i)','ro','MarkerSize',f.basicmarkersize+2);
            plot(i,predictedYokedxyY(1,i)','go','MarkerSize',f.basicmarkersize);
            plot(i,rawPredictedYokedxyY(1,i)','bo','MarkerSize',f.basicmarkersize-2);
        else
            plot(i,measuredYokedxyY(1,i)','ro','MarkerSize',f.basicmarkersize+2,'MarkerFaceColor','r');
            plot(i,predictedYokedxyY(1,i)','go','MarkerSize',f.basicmarkersize,'MarkerFaceColor','g');
            plot(i,rawPredictedYokedxyY(1,i)','bo','MarkerSize',f.basicmarkersize-2,'MarkerFaceColor','b');
        end
    end
    xlabel('Test #','FontName',f.fontname,'FontSize',f.labelfontsize);
    ylabel('x chromaticity','FontName',f.fontname,'FontSize',f.labelfontsize);
    FinishFigure(xPlot,f);
    
    % y chromaticity
    [yPlot,f] = StartFigure('standard');
    f.xrange = [0 size(cal.yoked.settings, 2)]; f.nxticks = 6;
    f.yrange = [0.2 0.6]; f.nyticks = 5;
    f.xtickformat = '%0.0f'; f.ytickformat = '%0.2f ';
    for i = 1:size(cal.yoked.settings,2)
        if (any(cal.yoked.settings(:,i) < 1e-3))
            plot(i,measuredYokedxyY(2,i)','ro','MarkerSize',f.basicmarkersize+2);
            plot(i,predictedYokedxyY(2,i)','go','MarkerSize',f.basicmarkersize);
            plot(i,rawPredictedYokedxyY(2,i)','bo','MarkerSize',f.basicmarkersize-2);
        else
            plot(i,measuredYokedxyY(2,i)','ro','MarkerSize',f.basicmarkersize+2,'MarkerFaceColor','r');
            plot(i,predictedYokedxyY(2,i)','go','MarkerSize',f.basicmarkersize,'MarkerFaceColor','g');
            plot(i,rawPredictedYokedxyY(2,i)','bo','MarkerSize',f.basicmarkersize-2,'MarkerFaceColor','b');
        end
    end
    xlabel('Test #','FontName',f.fontname,'FontSize',f.labelfontsize);
    ylabel('y chromaticity','FontName',f.fontname,'FontSize',f.labelfontsize);
    FinishFigure(yPlot,f);
end


%% Compute and plot differences
% Open circle plotting for low input not implemented here.
if (0)
    for i=1:size(cal.yoked.settings, 2)
        diffYokedLum(i)=(measuredYokedxyY(3,i))'- (predictedYokedxyY(3,i))';
    end
    for i=1:size(cal.yoked.settings, 2)
        diffYokedx(i)=(measuredYokedxyY(1,i))'- (predictedYokedxyY(1,i))';
    end
    for i=1:size(cal.yoked.settings, 2)
        diffYokedy(i)=(measuredYokedxyY(2,i))'- (predictedYokedxyY(2,i))';
    end
    
    [LumdifferencePlot,f] = StartFigure('standard');
    f.xrange = [0 size(cal.yoked.settings,2)]; f.nxticks = 6;
    f.yrange = [-30 10]; f.nyticks = 5;
    f.xtickformat = '%0.0f'; f.ytickformat = '%0.2f ';
    plot(diffYokedLum','ro','MarkerSize',f.basicmarkersize,'MarkerFaceColor','r');
    xlabel('Test #','FontName',f.fontname,'FontSize',f.labelfontsize);
    ylabel('Luminance diff','FontName',f.fontname,'FontSize',f.labelfontsize);
    FinishFigure(LumdifferencePlot,f);
    
    [XdifferencePlot,f] = StartFigure('standard');
    f.xrange = [0 size(cal.yoked.settings,2)]; f.nxticks = 6;
    f.yrange = [-0.1 0.1]; f.nyticks = 5;
    f.xtickformat = '%0.0f'; f.ytickformat = '%0.2f ';
    plot(diffYokedx','ro','MarkerSize',f.basicmarkersize,'MarkerFaceColor','r');
    xlabel('Test #','FontName',f.fontname,'FontSize',f.labelfontsize);
    ylabel('x chromaticity diff','FontName',f.fontname,'FontSize',f.labelfontsize);
    FinishFigure(XdifferencePlot,f);
    
    [YdifferencePlot,f] = StartFigure('standard');
    f.xrange = [0 size(cal.yoked.settings,2)]; f.nxticks = 6;
    f.yrange = [-0.1 0.1]; f.nyticks = 5;
    f.xtickformat = '%0.0f'; f.ytickformat = '%0.2f ';
    plot(diffYokedy','ro','MarkerSize',f.basicmarkersize,'MarkerFaceColor','r');
    xlabel('Test #','FontName',f.fontname,'FontSize',f.labelfontsize);
    ylabel('y chromaticity','FontName',f.fontname,'FontSize',f.labelfontsize);
    FinishFigure(YdifferencePlot,f);
end




