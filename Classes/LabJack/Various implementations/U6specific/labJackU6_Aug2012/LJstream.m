function varargout = LJstream(varargin)
% LJSTREAM displays an analog data stream from a LabJack U6
%
% LJSTREAM is a demonstration application built using the LABJACKU6 class.
%
% Analog input channels 0 and 1 (AIN0 AIN1) are enabled. The DAQ outputs
%  are also enabled- connect them to the AIN0/AIN1 to demonstrate analog
%  streaming.
%
%
% M.A. Hopcroft
% mhopeng@gmail.com
%

% MH Aug2012
% v1.0

%#ok<*TRYNC>

% Last Modified by GUIDE v2.5 14-Aug-2012 17:25:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LJstream_OpeningFcn, ...
                   'gui_OutputFcn',  @LJstream_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before LJstream is made visible.
function LJstream_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LJstream (see VARARGIN)

% Choose default command line output for LJstream
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LJstream wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LJstream_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Initialize Application

% make the start button green ("go")
set(handles.startbutton, 'String', 'Start','BackgroundColor', 'green')

% set the close function to automatically close the connection the daq
set(hObject,'CloseRequestFcn',{@closeProgram, handles});

% the U6 object
handles.lbj=[];

% Update handles structure
guidata(hObject, handles);  


%% Start Button
% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
% hObject    handle to startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmp(get(handles.startbutton, 'String'), 'Start') %if start button, do this

    fprintf(1,'\nLJstream v1.0\n %s\n',datestr(clock));

    %% Set up the LabJack DAQ
    %  get hardware info and do not continue if daq device/drivers unavailable
    if isempty(handles.lbj)
        lbj=labJackU6; % create the daq object
        lbj.verbose=1; % normal message level
        lbj.Tag='LabJackU6'; % set name to be the daq's name
        % open connection to the daq
        open(lbj);
        if isempty(lbj.handle)
            error('No USB connection to a LabJack was found. Check connections and try again.');
        end
        fprintf(1,'LJstream: LabJack Ready.\n\n');
        % save the daq object to use later
        handles.lbj=lbj;
    else
        lbj=handles.lbj;
    end

    % Optional output
    fprintf(1,'LJstream: Analog Outputs enabled.\n');
    analogOut(lbj,0,rand(1)); % debugging- connect DOC0 to AIN Ch0
    analogOut(lbj,1,rand(1)+1);

    % create channel list
    removeChannel(lbj,-1); % remove all channels
    addChannel(lbj,[0 1],[10 10],['s' 's']);

    % sample rate (Hz)
    lbj.SampleRateHz=100;
    
    % ADC resolution
    lbj.ResolutionADC=1;

    % configure LabJack for analog input streaming
    %  (based on channels added above)
    errorCode = streamConfigure(lbj);
    if errorCode > 0
        fprintf(1,'LJDaq: Unable to configure LabJack. Error %d.\n',errorCode);
        return
    end 

    % length of data (number of points) in plot window (20 sec)
    windowLength = 20*lbj.SampleRateHz;
    
    % Initialize the variables for storing the data that is plotted
    dataWindows.rawData=zeros(windowLength,lbj.numChannels); % for raw data
    dataWindows.numPointsNew=0; % number of new data points
    dataWindows.totalPoints=0; % total number of data points collected
    lbj.UserData=dataWindows; % save to U6 object


    %% - Prepare to Get Data
    % 1) create two timers:
    %   one to get data from daq
    %   one to plot the data
    
    % decide on the timer rate for getting data
    % (too fast causes problems for gui)
    % 5-10 Hz is a good target value    
    dataUpdateRate=5;
    % update the plot at 4 Hz, it looks fine
    plotUpdateRate=4;

    % create timer which will get data from device
    dataTimer=timer('Name','LabJackData','ExecutionMode','fixedRate',...
        'Period',1/dataUpdateRate,'UserData',lbj,'ErrorFcn',{@timerErrorFcnStop,handles},...
        'TimerFcn',{@dataStreamGet},'StartDelay',0.1); % StartDelay allows other parts of the gui to execute

    % create timer object which will do the plotting
    plotTimer=timer('Name','LabJackTimer','ExecutionMode','fixedRate',...
        'Period',1/plotUpdateRate,'UserData',lbj,'ErrorFcn',{@timerErrorFcnStop,handles},...
        'TimerFcn',{@plotStreamData,handles.axes1}); % StartDelay allows other parts of the gui to execute
    % save to handles
    handles.dataTimer=dataTimer;
    handles.plotTimer=plotTimer;
    
    % now that data acq will start, change 
    %  the green "start" button to a red "stop" button
    set(handles.startbutton, 'String', 'Stop', 'BackgroundColor', 'red')
    
   
    % update handles of dataFile and DAQ
    handles.lbj = lbj;
    
    % Update handles structure
    guidata(hObject, handles);    
    
    

    %% Start Data Acquisition
    % start the timers, and the daq data stream
    
    % start plot routine
    start(plotTimer);    
    % start data routine
    start(dataTimer);    
    % Start the DAQ
	startStream(lbj);

    
    
    
%% Stop    
else % stop
    
    disp('LJstream Stop')
    
    % stop the plotting
    stop(timerfind);
    delete(timerfind);    
    % stop the DAQ
    stopStream(handles.lbj);
    
    % set the gui items to "ready" state
    set(handles.startbutton, 'String', 'Start','BackgroundColor', 'green')
    drawnow;    
    
end




%% dataStreamGet Fcn
function dataStreamGet(obj,event)
% reads stream data from the LabJack

% handle to labjack is in Timer UserData
lbj=obj.UserData;

% get stream data
[dRaw errorCode] = getStreamData(lbj);                                      %#ok<NASGU>

% concatenate new data with previous for a moving display window
dataWindows=lbj.UserData; % UserData must be initialized w daq setup
dataWindows.rawData = [dataWindows.rawData(size(dRaw,1)+1:end,:); dRaw]; % concat newest points, cut oldest
dataWindows.numPointsNew = dataWindows.numPointsNew + length(dRaw);
dataWindows.totalPoints = dataWindows.totalPoints + length(dRaw);
%fprintf(1,'LJstream: read %g data points. Total in buffer %g\n',length(dRaw),dataWindows.numPoints);
lbj.UserData=dataWindows; % save new points to UserData


%% plotStreamData Fcn
function plotStreamData(obj,event,daqaxes)
% This function gets data from the daq, averages data points, and saves
%  data to a file. It is the "SamplesAcquiredFcn" for the daq, so this
%  function is executed every time "SamplesAcquiredFcnCount" number of
%  samples are acquired by the daq.

% handle to labjack is in Timer UserData
lbj=obj.UserData;
%disp('Plot Data')
% if we have new data, use it
dataWindows=lbj.UserData;
if dataWindows.numPointsNew <= 0
    return
else
    % get new data
    dRaw=dataWindows.rawData;
    dataWindows.numPointsNew=0;
    
    % % concatenate new data with previous for a moving display window
    lbj.UserData=dataWindows; % save new points to UserData

    % update data plot
    timestep = 1/(lbj.SampleRateHz); % define time interval of samples
    timeaxes1 = [0:1:size(dRaw,1)-1].*timestep; % make array of timepoints
    plot(daqaxes(1),timeaxes1,dRaw,'.-');
    title(daqaxes(1),['Analog Input from ' lbj.Tag ' [' datestr(now) ']'],'FontSize',16,'FontWeight','Bold')
    ylabel(daqaxes(1),'Analog Input [V]','FontSize',14);
    xlabel(daqaxes(1),['Time [sec]'],'FontSize',14);

    drawnow % update plots
    
end



%% Close program
function closeProgram(hObject, eventdata, handles)
% this function is called  when the user closes the main window
%
fprintf(1,'LJstream: close window\n');
% close the connection to the Sutter
try clear('handles.lbj'); end
try delete(timerfind); end

% close the program window
delete(handles.figure1);
