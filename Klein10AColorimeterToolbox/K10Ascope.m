function K10Ascope
% K10Ascope- GUI for measuring luminance time-series using the Klein K10A colorimeter.
%
% Syntax:
% K10Ascope
%
% Description:
% K10Ascope is a tool for acquiring time-series data from the Klein K10A 
% colorimeter. Acquired data (streamed at 256 Hz) are visualized online and 
% saved for further off-line analysis. K10Ascope relies on the K10_device mex
% driver and the FTDIchip USB driver.
%
% ================  Example export file (10 second recording) ================================ 
% 05-Feb-2014 15:51:00                          <---- recording time stamp
%     LockedInRange_1                           <---- sensitivity setting
% 2560                                          <---- number of 256 Hz stream data points (uncorrected Y values)
% Time(s)    YLum (D/A)                         <---- axes labels
% 0.00000      20000                            <---- (t,L) sample #1
% 0.00391      20184                            <---- (t,L) sample #2
% 0.00781      20368                            <---- (t,L) sample #3
% 0.01172      20552                            <---- (t,L) sample #4
%    .           .                                         .
%    .           .                                         .
%    .           .                                         .
% 9.98828      19448                            <---- (t,L) sample #2558
% 9.99219      19632                            <---- (t,L) sample #2559
% 9.99609      19816                            <---- (t,L) sample #2560
% 80                                            <---- number of 8 Hz stream data points (corrected XYZ tristimulus values)
% Time(s)       X        Y        Z             <---- axes labels
% 0.00000   10.00000  10.00000  10.00000        <---- (t,X,Y,Z) sample #1
% 0.12500   13.06147   6.93853  10.00000        <---- (t,X,Y,Z) sample #2
% 0.25000   15.65685   4.34315  10.00000        <---- (t,X,Y,Z) sample #3
%    .          .        .        .                        .
%    .          .        .        .                        .
%    .          .        .        .                        .
% 9.87500   6.93853  13.06147  10.00000         <---- (t,X,Y,Z) sample #80
% =============================================================================================
%
% History:
% 2/4/2014   npc    Wrote it.
% 2/5/2014   npc    Added ability to import and visualize previous recorded data.
%                   Added ability to save sensitivity range.
%                   Added ability to save corrected 8Hz stream of XYZ tri-stimulus values.
%                   Added ability to resize the GUI.
% 2/7/2014   npc    Fixed small temporal misalignment between 256 Hz uncorrected
%                   Y and 8 Hz corrected XYZ streams.
%                   Added ability to also visualize the 8Hz corrected XYZ stream.
% 2/14/2014  npc    Small bug fixes.
%                   Added ability to plot data over different X-axis ranges.

% Clear  environment
    clear all; clear global;

    % Compile Driver
    CompileK10ADriver;
   
    % Generate GUI struct
    global GUI
    GUI = struct;
   
    % Initialize different system
    InitExportSystem();

    % Create the GUI
    CreateGUI;
    
    % Configure K10A
    status = ConfigureK10Adevice;
    
    if (status < 0)
        return;
    end
    
end

function CreateGUI
    global GUI
    
    GUI.figHandle   = figure(1);
    GUI.figureWidth  = 960*1.25;
    GUI.figureHeight = 640*1.25;
    clf;
    
    set(GUI.figHandle, 'CloseRequestFcn',@ExitK10Ascope, ...
        'NumberTitle', 'off','Visible','off',...
        'MenuBar','None', 'Position',[360 500 GUI.figureWidth  GUI.figureHeight]);

    % Disable resizing
    % set(GUI.figHandle, 'ResizeFcn',@FigureResizeCallback);
    
    % Create the menus
    GUI.mainMenu1 = uimenu(GUI.figHandle, 'Label', 'File Ops ...'); 
    GUI.subMenu11 = uimenu(GUI.mainMenu1, 'Label', 'Save as ...');
                    uimenu(GUI.subMenu11, 'Label', 'FileName',              'Callback', {@SaveFileName_Callback});
                    uimenu(GUI.subMenu11, 'Label', 'FileName Index ...',    'Callback', {@SaveFileNameIndex_Callback});
    GUI.subMenu12 = uimenu(GUI.mainMenu1, 'Label', 'Import existing file',  'Callback', {@ImportExistingFile_Callback}, 'Separator', 'on');                
    GUI.subMenu13 = uimenu(GUI.mainMenu1, 'Label', 'Exit',                  'Callback', {@ExitK10Ascope}, 'Separator', 'on');
    
    GUI.mainMenu2 = uimenu(GUI.figHandle, 'Label', 'Settings ...'); 
    GUI.subMenu21 = uimenu(GUI.mainMenu2, 'Label', 'Aiming Lights ...');
                    uimenu(GUI.subMenu21, 'Label', 'Turn ON',           'Callback', {@AimingLightsON_Callback});
                    uimenu(GUI.subMenu21, 'Label', 'Turn OFF',          'Callback', {@AimingLightsOFF_Callback});
    GUI.subMenu22 = uimenu(GUI.mainMenu2, 'Label', 'Sensitivity ...');
                    uimenu(GUI.subMenu22, 'Label', 'Auto-range',            'Callback', {@LuminanceRange_Callback, 0});
                    uimenu(GUI.subMenu22, 'Label', '1 (<     19 Cd/m^2)',   'Callback', {@LuminanceRange_Callback, 1}, 'Separator', 'on');
                    uimenu(GUI.subMenu22, 'Label', '2 (<    116 Cd/m^2)',   'Callback', {@LuminanceRange_Callback, 2});
                    uimenu(GUI.subMenu22, 'Label', '3 (<    850 Cd/m^2)',   'Callback', {@LuminanceRange_Callback, 3});
                    uimenu(GUI.subMenu22, 'Label', '4 (<  6,000 Cd/m^2)',   'Callback', {@LuminanceRange_Callback, 4});
                    uimenu(GUI.subMenu22, 'Label', '5 (< xx,000 Cd/m^2)',   'Callback', {@LuminanceRange_Callback, 5});
                    uimenu(GUI.subMenu22, 'Label', '6 (< zz,000 Cd/m^2)',   'Callback', {@LuminanceRange_Callback, 6});
                    
    GUI.mainMenu3 = uimenu(GUI.figHandle,  'Label', 'Measurements ...');                
    GUI.subMenu31 = uimenu(GUI.mainMenu3,  'Label', 'Take a few corrected XYZ measurements (8Hz) ...');
                    uimenu(GUI.subMenu31,  'Label', '5 consequtive measurements', 'Callback',  {@ConsecutiveCorrectedXYZMeasurements_Callback, 5});
                    uimenu(GUI.subMenu31,  'Label', '10 consequtive measurements', 'Callback', {@ConsecutiveCorrectedXYZMeasurements_Callback, 10});
                    uimenu(GUI.subMenu31,  'Label', '20 consequtive measurements', 'Callback', {@ConsecutiveCorrectedXYZMeasurements_Callback, 20});
                    uimenu(GUI.subMenu31,  'Label', '50 consequtive measurements', 'Callback', {@ConsecutiveCorrectedXYZMeasurements_Callback, 50});
                    uimenu(GUI.subMenu31,  'Label', '100 consequtive measurements', 'Callback', {@ConsecutiveCorrectedXYZMeasurements_Callback, 100});
                    uimenu(GUI.subMenu31,  'Label', '200 consequtive measurements', 'Callback', {@ConsecutiveCorrectedXYZMeasurements_Callback, 200});
                    
    GUI.subMenu32 = uimenu(GUI.mainMenu3,  'Label', 'Stream uncorrected Y measurements (256 Hz) ...','Separator', 'on');
                    uimenu(GUI.subMenu32,  'Label', '2.5 seconds', 'Callback',   {@StreamUncorrectedYMeasurements_Callback, 2.5});
                    uimenu(GUI.subMenu32,  'Label', '5 seconds', 'Callback',   {@StreamUncorrectedYMeasurements_Callback, 5});
                    uimenu(GUI.subMenu32,  'Label', '10 seconds', 'Callback',  {@StreamUncorrectedYMeasurements_Callback, 10});
                    uimenu(GUI.subMenu32,  'Label', '20 seconds', 'Callback',  {@StreamUncorrectedYMeasurements_Callback, 20});
                    uimenu(GUI.subMenu32,  'Label', '30 seconds', 'Callback',  {@StreamUncorrectedYMeasurements_Callback, 30});
                    uimenu(GUI.subMenu32,  'Label', '45 seconds', 'Callback',  {@StreamUncorrectedYMeasurements_Callback, 45});
                    uimenu(GUI.subMenu32,  'Label', '1 minute', 'Callback',    {@StreamUncorrectedYMeasurements_Callback, 60}, 'Separator', 'on');
                    uimenu(GUI.subMenu32,  'Label', '2 minutes', 'Callback',   {@StreamUncorrectedYMeasurements_Callback, 60*2});
                    uimenu(GUI.subMenu32,  'Label', '3 minutes', 'Callback',   {@StreamUncorrectedYMeasurements_Callback, 60*3});
                    uimenu(GUI.subMenu32,  'Label', '4 minutes', 'Callback',   {@StreamUncorrectedYMeasurements_Callback, 60*4});
                    uimenu(GUI.subMenu32,  'Label', '5 minutes', 'Callback',   {@StreamUncorrectedYMeasurements_Callback, 60*5});
                    uimenu(GUI.subMenu32,  'Label', '7 minutes', 'Callback',   {@StreamUncorrectedYMeasurements_Callback, 60*7});
                    uimenu(GUI.subMenu32,  'Label', '10 minutes', 'Callback',  {@StreamUncorrectedYMeasurements_Callback, 60*10});
                    uimenu(GUI.subMenu32,  'Label', '15 minutes', 'Callback',  {@StreamUncorrectedYMeasurements_Callback, 60*15});
                    uimenu(GUI.subMenu32,  'Label', '20 minutes', 'Callback',  {@StreamUncorrectedYMeasurements_Callback, 60*20});
                    uimenu(GUI.subMenu32,  'Label', '30 minutes', 'Callback',  {@StreamUncorrectedYMeasurements_Callback, 60*30});
        
    GUI.mainMenu4 = uimenu(GUI.figHandle,  'Label', 'Data plotting ...');
    GUI.subMenu41 = uimenu(GUI.mainMenu4,  'Label', 'Visualization ...');
                    uimenu(GUI.subMenu41,  'Label', '256 Hz uncorrected Y only',                                    'Callback',   {@DataToVisualize_Callback, 1});
                    uimenu(GUI.subMenu41,  'Label', '256 Hz uncorrected Y + 8 Hz corrected XYZ (separate plot)',    'Callback',   {@DataToVisualize_Callback, 2});
    GUI.subMenu42 = uimenu(GUI.mainMenu4,  'Label', 'X-axis limits ...');
                    uimenu(GUI.subMenu42,  'Label', 'Automatic',            'Callback',     {@XaxisLimits_Callback, 0});
                    uimenu(GUI.subMenu42,  'Label', 'First half',           'Callback',     {@XaxisLimits_Callback, 1});
                    uimenu(GUI.subMenu42,  'Label', 'Second half',          'Callback',     {@XaxisLimits_Callback, 2});
                    uimenu(GUI.subMenu42,  'Label', 'First quarter',        'Callback',     {@XaxisLimits_Callback, 3});
                    uimenu(GUI.subMenu42,  'Label', 'Second quarter',       'Callback',     {@XaxisLimits_Callback, 4});
                    uimenu(GUI.subMenu42,  'Label', 'Third quarter',        'Callback',     {@XaxisLimits_Callback, 5});
                    uimenu(GUI.subMenu42,  'Label', 'Fourth quarter',       'Callback',     {@XaxisLimits_Callback, 6});
                    
    GUI.subMenu43 = uimenu(GUI.mainMenu4,  'Label', 'Y-axis limits ...');
                    uimenu(GUI.subMenu43,  'Label', 'Automatic',             'Callback',   {@YaxisLimits_Callback, 0});
                    uimenu(GUI.subMenu43,  'Label', '[0 0.500]',             'Callback',   {@YaxisLimits_Callback, 1});
                    uimenu(GUI.subMenu43,  'Label', '[0 0.250]',             'Callback',   {@YaxisLimits_Callback, 2});
                    uimenu(GUI.subMenu43,  'Label', '[0 0.125]',             'Callback',   {@YaxisLimits_Callback, 3});
                    uimenu(GUI.subMenu43,  'Label', 'mean + [-0.050 0.050]', 'Callback',   {@YaxisLimits_Callback, 4}, 'Separator', 'on');
                    uimenu(GUI.subMenu43,  'Label', 'mean + [-0.125 0.125]', 'Callback',   {@YaxisLimits_Callback, 5});
                    uimenu(GUI.subMenu43,  'Label', 'mean + [-0.250 0.250]', 'Callback',   {@YaxisLimits_Callback, 6});
                    uimenu(GUI.subMenu43,  'Label', 'mean + [-0.500 0.500]', 'Callback',   {@YaxisLimits_Callback, 7});
    GUI.subMenu44 = uimenu(GUI.mainMenu4,  'Label', 'Number of vertical plots ...');
                    uimenu(GUI.subMenu44,  'Label', '1 plot',               'Callback',   {@VerticalPlotsNum_Callback, 1});
                    uimenu(GUI.subMenu44,  'Label', '2 plots',              'Callback',   {@VerticalPlotsNum_Callback, 2});
                    uimenu(GUI.subMenu44,  'Label', '3 plots',              'Callback',   {@VerticalPlotsNum_Callback, 3});
                    uimenu(GUI.subMenu44,  'Label', '4 plots',              'Callback',   {@VerticalPlotsNum_Callback, 4});
                    uimenu(GUI.subMenu44,  'Label', '5 plots',              'Callback',   {@VerticalPlotsNum_Callback, 5});
                    uimenu(GUI.subMenu44,  'Label', '6 plots',              'Callback',   {@VerticalPlotsNum_Callback, 6});
                    uimenu(GUI.subMenu44,  'Label', '7 plots',              'Callback',   {@VerticalPlotsNum_Callback, 7});
                    uimenu(GUI.subMenu44,  'Label', '8 plots',              'Callback',   {@VerticalPlotsNum_Callback, 8});
                    uimenu(GUI.subMenu44,  'Label', '9 plots',              'Callback',   {@VerticalPlotsNum_Callback, 9});
                    uimenu(GUI.subMenu44,  'Label', '10 plots',             'Callback',   {@VerticalPlotsNum_Callback, 10});
                    
    GUI.statusMenu     = uimenu(GUI.figHandle,  'Label', 'Status ...');
    GUI.statusSubMenu1 = uimenu(GUI.statusMenu, 'Label', 'Sensitivity');
    GUI.statusSubMenu2 = uimenu(GUI.statusMenu, 'Label', 'Export FileName');
    

    % Initialize state
    InitState()
    
    % Initialize image plot
    InitPlottingSystem();
    
    % Make the GUI background white-ish
    set(GUI.figHandle, 'Color', [0.9 0.9 0.9]);

    % Assign the GUI a name which will appear in the window title.
    set(GUI.figHandle, 'Name', sprintf('K10A oscilloscope'));

    % Move the GUI to the center of the screen.
    movegui(GUI.figHandle, 'center');

    % Make the GUI visible.
    set(GUI.figHandle, 'Visible','on');
    
end

function InitState()
    global GUI
    GUI.deviceStatus = -1;
    GUI.luminanceRange = 'Automatic';
end

function InitExportSystem()
    global GUI
    GUI.lastImportLocation = [];
    GUI.exportDirectory     = pwd;
    GUI.recordingFileIndex  = 0;
    GUI.recordingFileName   = 'KleinRecording';
    ComposeRecordingFileName();
end

function InitPlottingSystem()
    global GUI
    
    GUI.visualizedData = 1;  % only 256 Hz data
    
    GUI.YLims = [0 65535];
    GUI.xAxisRange = 0;
    GUI.streamingTime = [0 1];
    GUI.streamingLuminance = GUI.streamingTime*0;
    GUI.streaming8HzTime    = [0 1];
    GUI.correctedXdata8HzStream = GUI.streaming8HzTime*0;
    GUI.correctedYdata8HzStream = GUI.streaming8HzTime*0;
    GUI.correctedZdata8HzStream = GUI.streaming8HzTime*0;
    
    % Create plot axes
    GUI.plotHandle = axes('Units','normalized','Position',[0.035 0.055 0.95 0.91]);
    GUI.lineHandle = plot(GUI.plotHandle, GUI.streamingTime, GUI.streamingLuminance, 'ks-', 'MarkerSize', 4, 'MarkerFaceColor', [0.9 0.7 0.8], 'MarkerEdgeColor', [1.0 0.0 0.0]);
    set(GUI.plotHandle, 'FontName', 'Helvetica', 'FontSize', 12);
    set(GUI.plotHandle, 'XLim', [GUI.streamingTime(1) GUI.streamingTime(end)], 'YLim', GUI.YLims, 'XColor', 'b', 'YColor', 'b');
    set(GUI.plotHandle, 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'Bold');
    box(GUI.plotHandle, 'on');
    xlabel(GUI.plotHandle, 'Time (seconds) ');
    ylabel(GUI.plotHandle, 'Klein Y-filter output (arbitrary units) ');
    
 
end


function  UpdateGUIrangeStatus()
    global GUI
    set(GUI.statusSubMenu1, 'Label', sprintf('Klein sensitivity: %s', GUI.luminanceRange));
end

function DataToVisualize_Callback(varargin)
    global GUI
    GUI.visualizedData = varargin{3}; 
    PlotStreamedData();
end

function VerticalPlotsNum_Callback(varargin)
    disp('Not implemented yet');
end


function XaxisLimits_Callback(varargin)
    global GUI
    GUI.xAxisRange = varargin{3}; 
    PlotStreamedData();
end


function YaxisLimits_Callback(varargin)
    global GUI
    
    if (isempty(GUI.streamingLuminance))
        meanLuminance = 65535*0.5;
    else
        meanLuminance = mean(GUI.streamingLuminance);
    end
    
    yAxisRange = varargin{3}; 
    if (yAxisRange == 0)
       GUI.YLims = [0 65535]; 
    elseif (yAxisRange == 1)
        GUI.YLims = [0 65535]*0.5;
    elseif (yAxisRange == 2)
        GUI.YLims = [0 65535]*0.25;
    elseif (yAxisRange == 3)
        GUI.YLims = [0 65535]*0.125;
    elseif (yAxisRange == 4)
        GUI.YLims = meanLuminance + 65535*0.050*[-1 1];
    elseif (yAxisRange == 5)
        GUI.YLims = meanLuminance + 65535*0.125*[-1 1];
    elseif (yAxisRange == 6)
        GUI.YLims = meanLuminance + 65535*0.25*[-1 1];
    elseif (yAxisRange == 7)
        GUI.YLims = meanLuminance + 65535*0.5*[-1 1];    
    end
    
    PlotStreamedData();
end


function status = StreamUncorrectedYMeasurements_Callback(varargin) 

    % Reset streaming communication params. Make sure that all is OK.
    [status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
    if (status ~= 0)
        return;
    end
   
   streamDurationInSeconds = varargin{3};
   fprintf('\n\nStreaming started!!\n');
   
   % ---- STREAM FOR SPECIFIED DURATION --------------------------
   [status, uncorrectedYdata256HzStream, ...
           correctedXdata8HzStream, ...
           correctedYdata8HzStream, ...
           correctedZdata8HzStream] = ...
                K10A_device('sendCommand', 'Standard Stream', streamDurationInSeconds);
            
  % ----- COMPUTE xy CIE COORDINATES ----------------------------
    meanX = mean(correctedXdata8HzStream);
    meanY = mean(correctedYdata8HzStream);
    meanZ = mean(correctedZdata8HzStream);
    meanCIExChroma = meanX / (meanX + meanY + meanZ);
    meanCIEyChroma = meanY / (meanX + meanY + meanZ);
    
  % ---- COMPUTE RESPONSE ------------------------------------------
    global GUI
    GUI.streamingTime = [0:1:length(uncorrectedYdata256HzStream)-1]/256.0;
    GUI.streaming8HzTime = GUI.streamingTime(33:32:end)-24.0/256.0; 
    GUI.streamingLuminance = uncorrectedYdata256HzStream;
    GUI.correctedXdata8HzStream = correctedXdata8HzStream(2:end);
    GUI.correctedYdata8HzStream = correctedYdata8HzStream(2:end);
    GUI.correctedZdata8HzStream = correctedZdata8HzStream(2:end);
       
  % --- PLOT RESPONSE AND EXPORT IT TO FILE ----------------------- 
    PlotStreamedData();
    ExportData();
    
    % Reset streaming communication params. Make sure that all is OK.
    [status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
    
end

function PlotStreamedData()
    global GUI
    
    if (GUI.xAxisRange == 0)
        GUI.XLims = [GUI.streamingTime(1) GUI.streamingTime(end)];
    elseif (GUI.xAxisRange == 1)
        duration = GUI.streamingTime(end)-GUI.streamingTime(1);
        GUI.XLims = GUI.streamingTime(1) + [0 duration/2];
    elseif (GUI.xAxisRange == 2)
        duration = GUI.streamingTime(end)-GUI.streamingTime(1);
        GUI.XLims = GUI.streamingTime(1) + [duration/2 duration];
    elseif (GUI.xAxisRange == 3)
        duration = GUI.streamingTime(end)-GUI.streamingTime(1);
        GUI.XLims = GUI.streamingTime(1) + [0 duration/4];
    elseif (GUI.xAxisRange == 4)
        duration = GUI.streamingTime(end)-GUI.streamingTime(1);
        GUI.XLims = GUI.streamingTime(1) + [duration/4 duration/2];
    elseif (GUI.xAxisRange == 5)
        duration = GUI.streamingTime(end)-GUI.streamingTime(1);
        GUI.XLims = GUI.streamingTime(1) + [duration/2 3*duration/4];
    elseif (GUI.xAxisRange == 6)
        duration = GUI.streamingTime(end)-GUI.streamingTime(1);
        GUI.XLims = GUI.streamingTime(1) + [3*duration/4 duration];
    end
    
    set(GUI.lineHandle, 'XData', GUI.streamingTime, 'YData', GUI.streamingLuminance);
    set(GUI.plotHandle, 'FontName', 'Helvetica', 'FontSize', 12);
    set(GUI.plotHandle, 'XLim', GUI.XLims, 'YLim', GUI.YLims, 'XColor', 'b', 'YColor', 'b');
    box(GUI.plotHandle, 'on');
    xlabel(GUI.plotHandle, 'Time (seconds) ');
    ylabel(GUI.plotHandle, 'Klein Y-filter output (arbitrary units) ');
    
    if (GUI.visualizedData == 2)
       GenerateFloatFigureWithAllData(); 
    else
        % delete figure 2, if it exits
        if (ishandle(2))
            close(2);
        end
    end
end

function GenerateFloatFigureWithAllData()
    global GUI
    
    % Determine Y range for corrected XYZ streams
    if (strcmp(GUI.luminanceRange,'Automatic'))
        correctedXYZYLims = [0 max([max(GUI.correctedXdata8HzStream) max(GUI.correctedYdata8HzStream) max(GUI.correctedZdata8HzStream)])];
    elseif (strcmp(GUI.luminanceRange, 'LockedInRange_1'))
        correctedXYZYLims = [0 20];
    elseif (strcmp(GUI.luminanceRange, 'LockedInRange_2'))
        correctedXYZYLims = [0 120];
    elseif (strcmp(GUI.luminanceRange, 'LockedInRange_3'))
        correctedXYZYLims = [0 850];
    elseif (strcmp(GUI.luminanceRange, 'LockedInRange_4'))
        correctedXYZYLims = [0 6000];     
    else
        correctedXYZYLims = [0 100000];
    end
    
      
    figure(2);
    clf;
    subplot(2,1,1);
    plot(GUI.streamingTime, GUI.streamingLuminance, 'k-', 'LineWidth', 2.0);
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'Bold');
    set(gca, 'XLim', GUI.XLims, 'YLim', GUI.YLims);
    box on
    xlabel('Time (s)');
    ylabel('Klein Y filter output (arb. units)');
    title('Uncorrected Y signal (sampled at 256 Hz)');
    
    subplot(2,1,2);
    hold on
    plot(GUI.streaming8HzTime, GUI.correctedXdata8HzStream, 'rs-', 'LineWidth', 2.0);
    plot(GUI.streaming8HzTime, GUI.correctedYdata8HzStream, 'gs-', 'LineWidth', 2.0);
    plot(GUI.streaming8HzTime, GUI.correctedZdata8HzStream, 'bs-', 'LineWidth', 2.0);
    set(gca, 'XLim', GUI.XLims, 'YLim', correctedXYZYLims);
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'Bold');
    xlabel('Time (s)');
    ylabel('CIE XYZ tristim. values');
    title('CIE (corrected) XYZ signals (sampled at 8 Hz)');
    legend('X', 'Y', 'Z');
    hold off
    box on;
    % Back to main figure
    figure(1);
end


function ExportData()
    global GUI;
    
    checkForExistingFile = true;
    while (exist(GUI.exportFullFileName, 'file')) && (checkForExistingFile)
        choice = questdlg('DO YOU WANT TO OVERWRITE IT? (IF NOT, YOU CAN SPECIFY A DIFFERENT FILE INDEX NUMBER)', ...
            sprintf('%s already exists!',GUI.completeRecordingFileName), ...
            'YES','NO', 'NO');
        % If user wants to overwrite the file do so
        if (strcmp(choice,'YES'))
            checkForExistingFile = false;
        else
            GUI.recordingFileIndex = input(sprintf('\nEnter new file index (current-> %d) :', GUI.recordingFileIndex));
            ComposeRecordingFileName();
        end
    end
    
    FID = fopen(GUI.exportFullFileName, 'w');  % overwrite file
    fprintf(FID,'%20s\r\n', datestr(clock));
    fprintf(FID,'%20s\r\n', GUI.luminanceRange);
    fprintf(FID,'%d\r\n', length(GUI.streamingLuminance));
    fprintf(FID,'%6s  %12s\r\n','Time(s)','YLum (D/A)');
    fprintf(FID,'%6.5f %10.0f\r\n',[GUI.streamingTime; GUI.streamingLuminance]);
    fprintf(FID,'%d\r\n', length(GUI.correctedXdata8HzStream));
    fprintf(FID,'%6s  %6s   %6s   %6s\r\n','Time(s)','X','Y','Z');
    fprintf(FID,'%06.5f   %06.5f  %06.5f  %06.5f\r\n', [GUI.streaming8HzTime; GUI.correctedXdata8HzStream; GUI.correctedYdata8HzStream; GUI.correctedZdata8HzStream]);    
    fclose(FID);
    fprintf('Data saved to %s\n', GUI.exportFullFileName);
    
    % Compute next filename
    GUI.recordingFileIndex = GUI.recordingFileIndex + 1;
    ComposeRecordingFileName();
    
end

function ImportExistingFile_Callback(varargin)
    global GUI
    if (isempty(GUI.lastImportLocation))
        [fileName, importDirectory] = uigetfile('*.txt','Select a file to import.');
    else
        [fileName, importDirectory] = uigetfile('*.txt','Select a file to import.', GUI.lastImportLocation);
    end
    GUI.lastImportLocation = importDirectory;
    FID = fopen(fullfile(importDirectory, fileName), 'r'); 
    recordingDate = fscanf(FID,'%s', [1 2]);
    sensitivityRange = fscanf(FID,'%s\n', [1 1]);
    Acolumns = fscanf(FID,'%d', [1 1]);
    columnHeaders = fscanf(FID,'%s', [1 3]);
    A = fscanf(FID,'%g', [2 Acolumns]);
    Bcolumns = fscanf(FID,'%d', [1 1]);
    columnHeaders = fscanf(FID,'%s', [1 4]);
    B = fscanf(FID,'%g', [4 Bcolumns]);
    fclose(FID);
    fprintf('Data imported from %s\n', fullfile(importDirectory, fileName));
    
    GUI.streamingTime           = A(1,:);
    GUI.streamingLuminance      = A(2,:);
    GUI.streaming8HzTime        = B(1,1:end);
    GUI.correctedXdata8HzStream = B(2,1:end);
    GUI.correctedYdata8HzStream = B(3,1:end);
    GUI.correctedZdata8HzStream = B(4,1:end);
    
    PlotStreamedData();
end



function status = ConsecutiveCorrectedXYZMeasurements_Callback(varargin) 
   measurementsNum = varargin{3};
   for k=1:measurementsNum 
       [status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
       fprintf('response[%d]:%s\n', k, response);
    end    
end

function status = LuminanceRange_Callback(varargin)
    global GUI
    
    luminanceRange = varargin{3};
    switch luminanceRange
       case 0
            [status, response] = K10A_device('sendCommand', 'EnableAutoRanging');
            GUI.luminanceRange = 'Automatic';
       case 1
            [status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
            [status, response] = K10A_device('sendCommand', 'LockInRange1');
            GUI.luminanceRange = 'LockedInRange_1';
       case 2
            [status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
            [status, response] = K10A_device('sendCommand', 'LockInRange2');
            GUI.luminanceRange = 'LockedInRange_2';
       case 3
            [status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
            [status, response] = K10A_device('sendCommand', 'LockInRange3');
            GUI.luminanceRange = 'LockedInRange_3';
       case 4
            [status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
            [status, response] = K10A_device('sendCommand', 'LockInRange4');
            GUI.luminanceRange = 'LockedInRange_4';
       case 5
            [status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
            [status, response] = K10A_device('sendCommand', 'LockInRange5');
            GUI.luminanceRange = 'LockedInRange_5';
       case 6
            [status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
            [status, response] = K10A_device('sendCommand', 'LockInRange6');
            GUI.luminanceRange = 'LockedInRange_6';
       otherwise
            [status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
            [status, response] = K10A_device('sendCommand', 'LockInRange2');
            GUI.luminanceRange = 'LockedInRange_2';
    end
    
    UpdateGUIrangeStatus();
end


function status = AimingLightsON_Callback(varargin)
    [status] = K10A_device('sendCommand', 'Lights ON');
end

function status = AimingLightsOFF_Callback(varargin)
    [status] = K10A_device('sendCommand', 'Lights OFF');
end

function status = ConfigureK10Adevice
    % ------ SET THE VERBOSITY LEVEL (1=minimum, 5=intermediate, 10=full)--
    status = K10A_device('setVerbosityLevel', 10);
    
    % ------ OPEN THE DEVICE ----------------------------------------------
    if (ismac)
        portName = '/dev/tty.usbserial-KU000000';
    else
        portName = '/dev/ttyUSB0';
    end

    status = K10A_device('open', portName);
    GUI.deviceStatus = status;
    
    if (status == 0)
        disp('Opened Klein port');
    elseif (status == -1)
        h = errordlg('Could not open Klein port','Error !!!');
        uiwait(h);
    elseif (status == 1)
        h = errordlg('Klein port was already opened','Warning !!!');
        uiwait(h);
    elseif (status == -99)
        h = errordlg('Invalid serial port','Error !!!');
        uiwait(h);
    end
    
    if (status ~= 0)
        status
        return;
    end
    
    % ----- SETUP DEFAULT COMMUNICATION PARAMS ----------------------------
    speed     = 9600;
    wordSize  = 8;
    parity    = 'n';
    timeOut   = 50000;
    
    status = K10A_device('updateSettings', speed, wordSize, parity,timeOut); 
    if (status == 0)
        disp('Updated communication settings in Klein port');
    elseif (status == -1)
        h = errordlg('Could not update settings in Klein port','Warning !!!');
        uiwait(h);
    elseif (status == 1)
        h = errordlg('Klein port is not open','Warning !!!');
        uiwait(h);
    end
    
    if (status ~= 0)
        status
        return;
    end
    
    % ----- READ ANY DATA AVAILABLE AT THE PORT ---------------------------
    [status, dataRead] = K10A_device('readPort');
    if ((status == 0) && (length(dataRead) > 0))
        fprintf('Read data: %s (%d chars)\n', dataRead, length(dataRead));
    end
    
    % ------------- GET THE SERIAL NO OF THE KLEIN METER ------------------
    [status, modelAndSerialNo] = ...
        K10A_device('sendCommand', 'Model and SerialNo');
    fprintf('Serial no and model: %s\n', modelAndSerialNo);
    
    if (status ~= 0)
        status
        return;
    end
    
    % ------------ GET THE FIRMWARE REVISION OF THE KLEIN METER -----------
    [status, response] = K10A_device('sendCommand', 'FlickerCal & Firmware');
    fprintf('>>> Firmware version: %s\n', response(20:20+7-1));
    
    if (status ~= 0)
        status
        return;
    end
    
    % ------------- ENABLE AUTO-RANGE -------------------------------------
    [status, response] = K10A_device('sendCommand', 'EnableAutoRanging');
    
    
    % ------------- GET SOME CORRECTED xyY MEASUREMENTS -------------------
    [status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
    fprintf('response:%s\n', response);
    
    % Set device to range 3
    status = LuminanceRange_Callback([],[],3);
            
end


function CompileK10ADriver
    % If multiple versions of xcode exist 
    % To find which one is active:
    % xcodebuild -version
    % To switch to a desired version, say 4.6.3
    % sudo xcode-select -switch /Applications/Xcode-4.6.3.app/Contents/Developer/
    disp('Compiling KleinK10A device driver ...');
    currentDir = pwd;
    programName = 'K10Ademo.m';
    d = which(programName);
    k = findstr(d, programName);
    d = d(1:k-1);
    cd(d);
    mex('K10A_device.c');
    cd(currentDir);
    disp('KleinK10A device driver compiled sucessfully!')
end


function SaveFileNameIndex_Callback(varargin)
    global GUI

    prompt={'Recording FileName Index:'};
    name='New Recording FileName Index';
    numlines=1;
    defaultanswer={sprintf('%d', GUI.recordingFileIndex)};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    GUI.recordingFileIndex = str2num(char(answer));
    ComposeRecordingFileName();
end


function SaveFileName_Callback(varargin)
    global GUI
    fileName = fullfile(GUI.exportDirectory, GUI.recordingFileName);
    [recordingFileName, exportDirectory, filterIndex] = uiputfile(fileName, GUI.completeRecordingFileName);
    % check if the user specified a filename
   if ((~isempty(recordingFileName)) && (filterIndex > 0))
       GUI.recordingFileName = recordingFileName;
       GUI.exportDirectory   = exportDirectory;
       ComposeRecordingFileName();
   end

end

function ComposeRecordingFileName
    global GUI
    GUI.completeRecordingFileName = sprintf('%s_%05d.txt', GUI.recordingFileName, GUI.recordingFileIndex);
    GUI.exportFullFileName = fullfile(GUI.exportDirectory, GUI.completeRecordingFileName);
    if (~isempty(GUI) && (isfield(GUI, 'statusSubMenu2')))
        set(GUI.statusSubMenu2, 'label', sprintf('Export FileName (next run): %s', GUI.exportFullFileName));
    end
    
end


% Method to not allow resizing of the figure
function FigureResizeCallback(varargin)
    global GUI
    a = get(GUI.figHandle,'Position');
    a(3) = GUI.figureWidth;
    a(4) = GUI.figureHeight;
    set(GUI.figHandle,'Position',a);
end


% Method called when the user clicks the exit ("x") button right before
% destroying the window
function ExitK10Ascope(varargin)
    global GUI
    % Prompt the user weather he really wants to exit the app
    selection = questdlg('',...
        'Exit K10A scope ?','Yes','No','Yes');

    if (strcmp(selection,'Yes'))
        if (GUI.deviceStatus > 0)
            % ------ CLOSE THE DEVICE -----------------------------------------
            status = K10A_device('close');
            if (status == 0)
                disp('Closed Klein port');
            elseif (status == -1)
                h = errordlg('Could not close Klein port','Error !!!');
                uiwait(h);
            elseif (status == 1)
                h = errordlg('Could not close Klein port','Warning!!!');
                uiwait(h);
            end
        end
        disp('GoodBye ...');
        delete(GUI.figHandle);
    else
        return
    end
end



    

