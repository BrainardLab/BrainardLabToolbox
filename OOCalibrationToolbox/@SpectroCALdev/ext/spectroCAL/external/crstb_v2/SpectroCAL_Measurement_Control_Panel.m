% 11/2017 Updated error handling

function varargout = SpectroCAL_Measurement_Control_Panel(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SpectroCAL_Measurement_Control_Panel_OpeningFcn, ...
    'gui_OutputFcn',  @SpectroCAL_Measurement_Control_Panel_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SpectroCAL_Measurement_Control_Panel is made visible.
function SpectroCAL_Measurement_Control_Panel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpectroCAL_Measurement_Control_Panel (see VARARGIN)

% Choose default command line output for SpectroCAL_Measurement_Control_Panel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

axes(handles.spectrum_graph_axes);
xlabel('Wavelength (nm)');
ylabel('Radiance (watts per steradian per square meter)');

% UIWAIT makes SpectroCAL_Measurement_Control_Panel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SpectroCAL_Measurement_Control_Panel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in take_measurement_button.
function take_measurement_button_Callback(hObject, eventdata, handles)
% hObject    handle to take_measurement_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global port Start Stop Step CIEXY CIEUV Luminance Lambda Radiance

port = get(handles.COM_Port_Assignment,'String');
Start = str2double(get(handles.From_nm,'String'));
Stop = str2double(get(handles.To_nm,'String'));
Step = str2double(get(handles.Step,'String'));

[BEG_Range END_Range] = SpectroCALGetCapabilities(port);

if Start < BEG_Range
    Start = BEG_Range;
    set(handles.From_nm,'String',num2str(BEG_Range));
end

if Stop > END_Range
    Stop = END_Range;
    set(handles.To_nm,'String',num2str(END_Range));
end

if Stop < Start
    Start = BEG_Range;
    set(handles.From_nm,'String',num2str(BEG_Range));
    Stop = END_Range;
    set(handles.To_nm,'String',num2str(END_Range));
end

if Step < 1
    Step = 1;
    set(handles.Step,'String',num2str(Step));
end

if Step > 5
    Step = 5;
    set(handles.Step,'String',num2str(Step));
end

axes(handles.spectrum_graph_axes);
cla;
set(handles.Lv_value_label,     'String','-');
set(handles.vprime_value_label, 'String','-');
set(handles.uprime_value_label, 'String','-');
set(handles.small_y_value_label,'String','-');
set(handles.small_x_value_label,'String','-');

set(handles.LaserButton,'Value',[0]);

[CIEXY, CIEUV, Luminance, Lambda, Radiance, errorString] = SpectroCALMakeSPDMeasurement(port,Start,Stop,Step);

if ~isempty(errorString)
    msgbox(errorString);
else
    CIEx        = CIEXY(1,:);
    CIEy        = CIEXY(2,:);
    CIEu        = CIEUV(1,:);
    CIEv        = CIEUV(2,:);

    % PLOT THE GRAPH
    axes(handles.spectrum_graph_axes);
    hold on;
    plot(Lambda,Radiance);
    % DISPLAY THE DATA
    set(handles.vprime_value_label, 'String',num2str(CIEv));
    set(handles.uprime_value_label, 'String',num2str(CIEu));
    set(handles.small_y_value_label,'String',num2str(CIEy));
    set(handles.small_x_value_label,'String',num2str(CIEx));
    set(handles.Lv_value_label,     'String',num2str(Luminance));

    % ENSURE DISPLAYING WITH CORRECT COLORS ETC...
    set(handles.spectrum_graph_axes,'Color',[1.0 1.0 1.0]);
    axes(handles.spectrum_graph_axes);
    xlabel('Wavelength (nm)');
    ylabel('Radiance (watts per steradian per square meter)');
end


% --- Executes on button press in export_data_button.
function export_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Lambda Radiance

[file_name, path_name, filter_index] = uiputfile('*.mat', 'save spectrum as .mat file');
if filter_index == 0
    %CANCEL PRESSED
else
    save([path_name file_name], 'Lambda', 'Radiance');
end


% --- Executes during object creation, after setting all properties.
function device_selection_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to device_selection_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in device_selection_listbox.
function device_selection_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to device_selection_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns device_selection_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from device_selection_listbox

%X = contents(get(hObject,'Value'));

% --- Executes on button press in clear_graph_button.
function clear_graph_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_graph_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.spectrum_graph_axes);
cla;
set(handles.Lv_value_label,     'String','-');
set(handles.vprime_value_label, 'String','-');
set(handles.uprime_value_label, 'String','-');
set(handles.small_y_value_label,'String','-');
set(handles.small_x_value_label,'String','-');


% --- Executes during object creation, after setting all properties.
function spectrum_graph_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectrum_graph_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate spectrum_graph_axes


% --------------------------------------------------------------------
function uipanel2_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LaserButton.
function LaserButton_Callback(hObject, eventdata, handles)
% hObject    handle to LaserButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LaserButton

port = get(handles.COM_Port_Assignment,'String');

if (get(hObject,'Value') == get(hObject,'Max'))
    SpectroCALLaserOn(port);
else
    SpectroCALLaserOff(port);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over LaserButton.
function LaserButton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to LaserButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function COM_Port_Assignment_Callback(hObject, eventdata, handles)
% hObject    handle to COM_Port_Assignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of COM_Port_Assignment as text
%        str2double(get(hObject,'String')) returns contents of COM_Port_Assignment as a double

global port

port = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function COM_Port_Assignment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COM_Port_Assignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function From_nm_Callback(hObject, eventdata, handles)
% hObject    handle to From_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of From_nm as text
%        str2double(get(hObject,'String')) returns contents of From_nm as a double

global Start

Start = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function From_nm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to From_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function To_nm_Callback(hObject, eventdata, handles)
% hObject    handle to To_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of To_nm as text
%        str2double(get(hObject,'String')) returns contents of To_nm as a double
global Stop

Stop = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function To_nm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to To_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Step_Callback(hObject, eventdata, handles)
% hObject    handle to Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Step as text
%        str2double(get(hObject,'String')) returns contents of Step as a double

global Step

Step = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function Step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
