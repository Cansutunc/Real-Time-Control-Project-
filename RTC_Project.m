function varargout = RTC_Project(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RTC_Project_OpeningFcn, ...
                   'gui_OutputFcn',  @RTC_Project_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end
 
if nargout 
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%------------------------Opening Function---------------------------------%
function RTC_Project_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

global Kp; %Global variable created to hold Kp value and move it from one function to other. 
global Ki; %Global variable created to hold Ki value and move it from one function to other.
global Kd; %Global variable created to hold Kd value and move it from one function to other.
global reference_data; %Global variable created to hold Referance Input and be able to plot it.
global response_data; %Global variable created to hold System Response and be able to plot it.
global t y d time %Global variabes created to plot 
t=[]; %An empty array created to hold time as an array and be able to plot it.
y=[]; %An empty array created to hold Reference Input data as an array and be able to plot it.
d=[]; %An empty array created to hold System Response data as an array and be able to plot it.
time=0; %A counter started to count.
axes(handles.plotData); %Axes is choosen
xlabel('Time(sec)', 'FontSize', 15); %X Label Named
ylabel('Datas(meter)', 'FontSize', 15); %Y Label Named
delete(instrfind({'Port'},{'COM6'})) %The serial port cleaned.

function varargout = RTC_Project_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
%-------------------------------------------------------------------------%

%-------------------Edit Box TO Get and Create P Gain---------------------%
function editP_gain_Callback(hObject, eventdata, handles)
global Kp;
Kp=get(hObject,'String'); %P Gain taken from edit box.
Kp=char(Kp)
Kp=[Kp,'kp']; %The "kp" tag has been added so that Arduino can recognize the incoming data.
if length(Kp)<8 %If the length of entered value is smaller than 8 
    n=8-length(Kp);
    for i=1:n 
        Kp=['0',Kp]; %"0" value added to the start of the entered value until the length is 8
    end
end %The Kp data is become 8-bit.

function editP_gain_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%-------------------------------------------------------------------------%

%------------------Edit Box TO Get and Create D Gain----------------------%
function editD_gain_Callback(hObject, eventdata, handles)
global Kd;
Kd=get(hObject,'String'); %D Gain taken from edit box.
Kd=char(Kd)
Kd=[Kd,'kd']; %The "kd" tag has been added so that Arduino can recognize the incoming data.
if length(Kd)<8 %If the length of entered value is smaller than 8
    n=8-length(Kd);
    for i=1:n
        Kd=['0',Kd]; %"0" value added to the start of value until the length is 8
    end
end %The Kp data is become 8-bit.

function editD_gain_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%-------------------------------------------------------------------------%

%-------------------Edit Box TO Get and Create I Gain---------------------%
function editI_gain_Callback(hObject, eventdata, handles)
global Ki;
Ki=get(hObject,'String'); %I Gain taken from edit box.
Ki=char(Ki)
Ki=[Ki,'ki']; %The "ki" tag has been added so that Arduino can recognize the incoming data.
if length(Ki)<8 %If the length of entered value is smaller than 8
    n=8-length(Ki);
    for i=1:n
        Ki=['0',Ki]; %"0" value added to the start of value until the length is 8
    end
end %The Kp data is become 8-bit.

function editI_gain_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%-------------------------------------------------------------------------%

%-------------------------Push Button TO Send All Controller Gains-------------------------%
function pushbuttonSend_Callback(hObject, eventdata, handles)
global Kp;
global Ki;
global Kd;
for i=1:8 %Sending Kp, Ki and Kd values 8 times in a row to be sure that they arrived.
    fwrite(handles.s,Kp); %Writes Kp value to serial port
    fwrite(handles.s,Ki); %Writes Ki value to serial port
    fwrite(handles.s,Kd); %Writes Kd value to serial port
end
guidata(hObject, handles); % Update handles structure
%-------------------------------------------------------------------------%

%---------------------Push Button TO Connect Arduino----------------------%
function pushbuttonConnect_Callback(hObject, eventdata, handles)
handles.s = serial('COM6','Baudrate',9600); %Serial Com is created
handles.s.BytesAvailableFcn = {@ReadData, handles}; 
handles.s.BytesAvailableFcnCount = 16;
handles.s.BytesAvailableFcnMode = 'byte';
fopen(handles.s); %Serial Com is opened.
guidata(hObject, handles); % Update handles structure

function ReadData(hObject,eventdata,handles)  
global reference_data;
global response_data;
global t y d time
system_response=fscanf(handles.s,'%c'); %System Response readed from serial port
reference_input=fscanf(handles.s,'%c'); %Referance Input readed from serial port
analog_voltage=(str2double(reference_input)*5)/1; %Analog Voltage value calculated according to Reference Input
set(handles.textSystemResponse, 'String',system_response); %System Response displayed on text box.
set(handles.textReferenceInput, 'String',reference_input); %Referance Input displayed on text box.
set(handles.textAnalogVoltage, 'String',num2str(analog_voltage)); %Analog Voltage displayed on text box.
reference_data=str2double(char(reference_input)); %Referance input converted to double class.
response_data=str2double(char(system_response)); %System Response converted to double class.
t=[t; time]; %Current time valaue is added to a array called t.
y=[y; reference_data]; %Current reference input valaue is added to a array called y.
d=[d; response_data]; %Current system response valaue is added to a array called d.
axes(handles.plotData); %Axes is choosen
plot(handles.plotData,t,[y d]);%Datas are plotted
time=time+0.05; %Here the Time is increased by the sampling time.

function pushbuttonDisconnect_Callback(hObject, eventdata, handles)
fclose(handles.s); %Serial Com is closed.
guidata(hObject, handles);
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
function editVoltage_Callback(hObject, eventdata, handles)
%editVoltage edit box is created only to write user interface a constant "Analog Voltage(V)" tag
function editVoltage_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
function editReference_Callback(hObject, eventdata, handles)
%editReference edit box is created only to write user interface a constant "Reference Input(m)" tag
function editReference_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
function editResponse_Callback(hObject, eventdata, handles)
%editResponse edit box is created only to write user interface a constant "System Response(m)" tag
function editResponse_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
function textAnalogVoltage_CreateFcn(hObject, eventdata, handles)
%textAnalogVoltage text box is created to display Analog Voltage value.
%-------------------------------------------------------------------------%

%------------------Push Button TO Clear Datas and Graph-------------------%
function pushClear_Callback(hObject, eventdata, handles)
global y t d time
y=[]; %y value is cleared
t=[]; %t value is cleared
d=[]; %d value is cleared
time=0; %time value is cleared
cla(handles.plotData); %The plot axes is cleared
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
function edit10_Callback(hObject, eventdata, handles)
%This edit box created to display "Reference Input" legend.
function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
function edit11_Callback(hObject, eventdata, handles)
%This edit box created to display ",system Response" legend.
function edit11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%-------------------------------------------------------------------------%