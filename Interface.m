function varargout = Interface(varargin)
% INTERFACE MATLAB code for Interface.fig
%      INTERFACE, by itself, creates a new INTERFACE or raises the existing
%      singleton*.
%
%      H = INTERFACE returns the handle to a new INTERFACE or the handle to
%      the existing singleton*.
%
%      INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFACE.M with the given input arguments.
%
%      INTERFACE('Property','Value',...) creates a new INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Interface_OpeningF gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Interface

% Last Modified by GUIDE v2.5 21-Feb-2017 00:37:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Interface_OpeningFcn, ...
                   'gui_OutputFcn',  @Interface_OutputFcn, ...
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


% --- Executes just before Interface is made visible.
function Interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Interface (see VARARGIN)

%load or create data used in the GUIDE
%% set default values for the menus
handles.SettFGenFreq.String='39.764375';
handles.SettFGenVpp.String='2';
handles.SettOsziAuto.Value=0;
handles.SettOsziCH1EN.Value=1;
handles.SettOsziCH1Res.String='5';
handles.SettOsziCH2EN.Value=1;
handles.SettOsziCH2Res.String='4';
handles.SettOsziSelTBFromFG.Value=1; %timebase from frequency as default
handles.SettOsziTimebase.String='3.40';
handles.SettOsziAq1.Value=3; %Vpp Ch2
handles.SettOsziAq2.Value=4; %f Ch1
handles.SettOsziAq3.Value=5; %f Ch2
handles.SettOsziAq4.Value=6; %dphi Ch1 Ch2
handles.SettVibAuto.Value=1;
handles.SettVibVelRes.Value=4; %=125mm/s/V
handles.SollPosX.String='33961';
handles.SollPosY.String='55705';


%% the settings will be transfert to handles.Settings by "apply" so the state will then be saved.
handles.Settings.FGen.Freq=NaN;
handles.Settings.FGen.Vpp=NaN;
handles.Settings.Oszi.AutoSettings=NaN;
handles.Settings.Oszi.CH1EN=NaN;
handles.Settings.Oszi.CH2EN=NaN;
handles.Settings.Oszi.CH1Res=NaN;
handles.Settings.Oszi.CH2Res=NaN;
handles.Settings.Oszi.SelTBFromFG=NaN;
handles.Settings.Oszi.TimeBase=NaN;
handles.Settings.Oszi.Aq{1}.Str='';
handles.Settings.Oszi.Aq{1}.Nr=NaN;
handles.Settings.Oszi.Aq{2}.Str='';
handles.Settings.Oszi.Aq{2}.Nr=NaN;
handles.Settings.Oszi.Aq{3}.Str='';
handles.Settings.Oszi.Aq{3}.Nr=NaN;
handles.Settings.Oszi.Aq{4}.Str='';
handles.Settings.Oszi.Aq{4}.Nr=NaN;
handles.Settings.Vib.AutoSettings=NaN;
handles.Settings.Vib.VelResNR=NaN;

addpath('functions\');

%% Instruments

%clear all instruments 
snew = instrfind;
if ~(isempty(snew) )  
    fclose(snew);
    delete(snew);
    clear snew;
end


%connect all instruments
Sucessfull=0;
try
    [sAxis,visaOszi,sFG,sVibrometer,Sucessfull]=connectDevices();
    handles.devices.sAxis =         sAxis;
    handles.devices.visaOszi =      visaOszi;
    handles.devices.sFG =        sFG;
    handles.devices.sVibrometer =   sVibrometer;
    assignin('base','sAxis',sAxis);  %transfer devices to workspace
    assignin('base','visaOszi',visaOszi);
    assignin('base','sFG',sFG);
    assignin('base','sVibrometer',sVibrometer);
catch exception
end
if Sucessfull==0
    uiwait(msgbox('Connection to devices failed - check and try to reconnect'));
end
%% set default button allowance
%everything is turned off by default. so we need to enable everything we
%want to use
if Sucessfull==1
    set(handles.axes1,'HANDLEVISIBILITY','on');
    set(handles.SettLoad,'ENABLE','on');
    set(handles.SettSave,'ENABLE','on');
    set(handles.SettApply,'ENABLE','on');
    GreyOutDeviceOptions(0,handles);
    set(handles.SettVibVelRes,'ENABLE','off');
    set(handles.SettingsLoadALL,'ENABLE','on');
    set(handles.SettOsziTimebase,'ENABLE','off'); %defalt value is calculated by FGenerator
end
 set(handles.Reconnect,'ENABLE','on');
%% Set Plot
if Sucessfull==1
    [PosX, PosY, ~] = getStagePosition(handles.devices.sAxis);
    d=str2double(handles.ScanAreaWidth.String);
    handles.figure.axesHandle= findobj(gcf,'Tag','axes1');
    handles.hdot=plot(handles.axes1,PosX,PosY,'or','MarkerSize',5,'MarkerFaceColor','r');
    xlabel('X in �m');
    ylabel('Y in �m');
    title('Scanning Area');
    pause(0.1);
    axis(handles.axes1,[PosX-2*d PosX+2*d PosY-2*d PosY+2*d])
end

% Choose default command line output for Interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




function SettFGenFreq_Callback(hObject, eventdata, handles)
% hObject    handle to SettFGenFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SettFGenFreq as text
%        str2double(get(hObject,'String')) returns contents of SettFGenFreq as a double
%if someone entered comma separated values, change them to dots
set(hObject,'String',strrep(get(hObject,'String'),',','.'));

if (handles.SettOsziSelTBFromFG.Value) %should the timebase be calculated from the frequency generator? (default)
    finput=str2double(get(hObject,'String'));
    %tBitMoreThanOnePeriode=round(180/finput,3,'significant');
    tBitMoreThanOnePeriode=ceil((180/finput*10))/10;
    handles.SettOsziTimebase.String = tBitMoreThanOnePeriode;
end


% --- Executes during object creation, after setting all properties.
function SettFGenFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettFGenFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SettFGenVpp_Callback(hObject, eventdata, handles)
% hObject    handle to SettFGenVpp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SettFGenVpp as text
%        str2double(get(hObject,'String')) returns contents of SettFGenVpp as a double


% --- Executes during object creation, after setting all properties.
function SettFGenVpp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettFGenVpp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in SettOsziAuto.
function SettOsziAuto_Callback(hObject, eventdata, handles)
% hObject    handle to SettOsziAuto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SettOsziAuto
if (get(hObject,'Value'))
    %we shall do auto settings, disable all other values
    set(handles.SettOsziCH1EN,'ENABLE','off')
    set(handles.SettOsziCH2EN,'ENABLE','off')
    set(handles.SettOsziCH1Res,'ENABLE','off')
    set(handles.SettBoxOsziCH1Res,'ENABLE','off')
    set(handles.SettBoxOsziCH1ResEinh,'ENABLE','off')
    set(handles.SettOsziCH2Res,'ENABLE','off')
    set(handles.SettBoxOsziCH2Res,'ENABLE','off')
    set(handles.SettBoxOsziCH2ResEinh,'ENABLE','off')
    set(handles.SettOsziTimebase,'ENABLE','off')
    set(handles.SettBoxOsziTimB,'ENABLE','off')
    set(handles.SettBoxOsziTimBEinh,'ENABLE','off')
    set(handles.SettOsziSelTBFromFG,'ENABLE','off')
else
    set(handles.SettOsziCH1EN,'ENABLE','on')
    set(handles.SettOsziCH2EN,'ENABLE','on')
    set(handles.SettOsziCH1Res,'ENABLE','on')
    set(handles.SettBoxOsziCH1Res,'ENABLE','on')
    set(handles.SettBoxOsziCH1ResEinh,'ENABLE','on')
    set(handles.SettOsziCH2Res,'ENABLE','on')
    set(handles.SettBoxOsziCH2Res,'ENABLE','on')
    set(handles.SettBoxOsziCH2ResEinh,'ENABLE','on')
    set(handles.SettOsziTimebase,'ENABLE','on')
    set(handles.SettBoxOsziTimB,'ENABLE','on')
    set(handles.SettBoxOsziTimBEinh,'ENABLE','on')
    set(handles.SettOsziSelTBFromFG,'ENABLE','on')
end



% --- Executes on button press in SettOsziCH1EN.
function SettOsziCH1EN_Callback(hObject, eventdata, handles)
% hObject    handle to SettOsziCH1EN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%enables channel 1 in case one of the aq1-aq4 measurements need this
%channel
% Hint: get(hObject,'Value') returns toggle state of SettOsziCH1EN
if ~(get(hObject,'Value'))
    %ch1 disabled --> remove measurement options for the channel
    if ~isempty(strfind(handles.SettOsziAq1.String{handles.SettOsziAq1.Value,1},'CHAN1'))
        handles.SettOsziAq1.Value=1;
    end
    if ~isempty(strfind(handles.SettOsziAq2.String{handles.SettOsziAq2.Value,1},'CHAN1'))
        handles.SettOsziAq2.Value=1;
    end
    if ~isempty(strfind(handles.SettOsziAq3.String{handles.SettOsziAq3.Value,1},'CHAN1'))
        handles.SettOsziAq3.Value=1;
    end
    if ~isempty(strfind(handles.SettOsziAq4.String{handles.SettOsziAq4.Value,1},'CHAN1'))
        handles.SettOsziAq4.Value=1;
    end
end



function SettOsziCH1Res_Callback(hObject, eventdata, handles)
% hObject    handle to SettOsziCH1Res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SettOsziCH1Res as text
%        str2double(get(hObject,'String')) returns contents of SettOsziCH1Res as a double
entered_value=str2double(strrep(get(hObject,'String'),',','.')); %chance , to .
entered_value=round(entered_value*100)/100; %round to two digits
set(hObject,'String',num2str(entered_value)); %set changes



% --- Executes during object creation, after setting all properties.
function SettOsziCH1Res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettOsziCH1Res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SettOsziCH2EN.
function SettOsziCH2EN_Callback(hObject, eventdata, handles)
% hObject    handle to SettOsziCH2EN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~(get(hObject,'Value'))
    %ch1 disabled --> remove measurement options for the channel
    if ~isempty(strfind(handles.SettOsziAq1.String{handles.SettOsziAq1.Value,1},'CHAN2'))
        handles.SettOsziAq1.Value=1;
    end
    if ~isempty(strfind(handles.SettOsziAq2.String{handles.SettOsziAq2.Value,1},'CHAN2'))
        handles.SettOsziAq2.Value=1;
    end
    if ~isempty(strfind(handles.SettOsziAq3.String{handles.SettOsziAq3.Value,1},'CHAN2'))
        handles.SettOsziAq3.Value=1;
    end
    if ~isempty(strfind(handles.SettOsziAq4.String{handles.SettOsziAq4.Value,1},'CHAN2'))
        handles.SettOsziAq4.Value=1;
    end
end


function SettOsziCH2Res_Callback(hObject, eventdata, handles)
% hObject    handle to SettOsziCH2Res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SettOsziCH2Res as text
%        str2double(get(hObject,'String')) returns contents of SettOsziCH2Res as a double
entered_value=str2double(strrep(get(hObject,'String'),',','.')); %chance , to .
entered_value=round(entered_value*100)/100; %round to two digits
set(hObject,'String',num2str(entered_value)); %set changes

% --- Executes during object creation, after setting all properties.
function SettOsziCH2Res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettOsziCH2Res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SettOsziTimebase_Callback(hObject, eventdata, handles)
% hObject    handle to SettOsziTimebase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SettOsziTimebase as text
%        str2double(get(hObject,'String')) returns contents of SettOsziTimebase as a double
entered_value=str2double(strrep(get(hObject,'String'),',','.')); %chance , to .
entered_value=round(entered_value*10)/10; %round to one digit
set(hObject,'String',num2str(entered_value)); %set changes

% --- Executes during object creation, after setting all properties.
function SettOsziTimebase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettOsziTimebase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in SettOsziAq1.
function SettOsziAq1_Callback(hObject, eventdata, handles)
% hObject    handle to SettOsziAq1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%automatically remove measurements with CH1 or CH2 if the channels are
%DISABLED
if (~(handles.SettOsziCH1EN.Value)) && ~isempty(strfind(handles.SettOsziAq1.String{get(hObject,'Value')},'CHAN1'))
    handles.SettOsziAq1.Value=1;
end
if (~(handles.SettOsziCH2EN.Value)) && ~isempty(strfind(handles.SettOsziAq1.String{get(hObject,'Value')},'CHAN2'))
    handles.SettOsziAq1.Value=1;
end


% --- Executes during object creation, after setting all properties.
function SettOsziAq1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettOsziAq1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SettOsziAq2.
function SettOsziAq2_Callback(hObject, eventdata, handles)
% hObject    handle to SettOsziAq2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%automatically remove measurements with CH1 or CH2 if the channels are
%DISABLED
if (~(handles.SettOsziCH1EN.Value)) && ~isempty(strfind(handles.SettOsziAq2.String{get(hObject,'Value')},'CHAN1'))
    handles.SettOsziAq2.Value=1;
end
if (~(handles.SettOsziCH2EN.Value)) && ~isempty(strfind(handles.SettOsziAq2.String{get(hObject,'Value')},'CHAN2'))
    handles.SettOsziAq2.Value=1;
end

% --- Executes during object creation, after setting all properties.
function SettOsziAq2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettOsziAq2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SettOsziAq3.
function SettOsziAq3_Callback(hObject, eventdata, handles)
% hObject    handle to SettOsziAq3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%automatically remove measurements with CH1 or CH2 if the channels are
%DISABLED
if (~(handles.SettOsziCH1EN.Value)) && ~isempty(strfind(handles.SettOsziAq3.String{get(hObject,'Value')},'CHAN1'))
    handles.SettOsziAq1.Value=3;
end
if (~(handles.SettOsziCH2EN.Value)) && ~isempty(strfind(handles.SettOsziAq3.String{get(hObject,'Value')},'CHAN2'))
    handles.SettOsziAq1.Value=3;
end

% --- Executes during object creation, after setting all properties.
function SettOsziAq3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettOsziAq3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SettOsziAq4.
function SettOsziAq4_Callback(hObject, eventdata, handles)
% hObject    handle to SettOsziAq4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%automatically remove measurements with CH1 or CH2 if the channels are
%DISABLED
if (~(handles.SettOsziCH1EN.Value)) && ~isempty(strfind(handles.SettOsziAq4.String{get(hObject,'Value')},'CHAN1'))
    handles.SettOsziAq4.Value=1;
end
if (~(handles.SettOsziCH2EN.Value)) && ~isempty(strfind(handles.SettOsziAq4.String{get(hObject,'Value')},'CHAN2'))
    handles.SettOsziAq4.Value=1;
end

% --- Executes during object creation, after setting all properties.
function SettOsziAq4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettOsziAq4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in SettVibAuto.
function SettVibAuto_Callback(hObject, eventdata, handles)
% hObject    handle to SettVibAuto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SettVibAuto
if (get(hObject,'Value'))
    %we shall do auto settings, disable all other values
    set(handles.SettVibVelRes,'ENABLE','off')
else
    set(handles.SettVibVelRes,'ENABLE','on')
end

% --- Executes on selection change in SettVibVelRes.
function SettVibVelRes_Callback(hObject, eventdata, handles)
% hObject    handle to SettVibVelRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SettVibVelRes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SettVibVelRes


% --- Executes during object creation, after setting all properties.
function SettVibVelRes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettVibVelRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SettLoad.
function SettLoad_Callback(hObject, eventdata, handles)
% hObject    handle to SettLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname pname] = uigetfile('DeviceSettings.mat','Select the Settings to load');
try 
    loadSettings = load([pname fname]);
    GreyOutStage(0,handles);%allow the next functions to be called
catch exceptions
    msgbox('No valid file selected')
    GreyOutStage(1,handles); %stop next fuction if failed
    return
end
handles.Settings=loadSettings.Settings;
writeToGUI(handles,handles.Settings);


guidata(hObject,handles);

% --- Executes on button press in SettSave.
function SettSave_Callback(hObject, eventdata, handles)
% hObject    handle to SettSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in SettApply.
Settings = readFromGUI(handles);
handles.Settings = Settings;
uisave('Settings','DeviceSettings.mat');
% Save the change you made to the structure
guidata(hObject,handles);

function SettApply_Callback(hObject, eventdata, handles)
% hObject    handle to SettApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%'Apply' Button was called. Saving all settings into 'handles.Settings'
% and call the devices with the specific settings
handles.Settings = readFromGUI(handles);

handlesSAVE=SaveANDGreyOut(handles); %'halt interface'
pause(0.001);
newSettings=configureDevices(handles.Settings,handles.devices.sAxis,handles.devices.visaOszi,handles.devices.sFG,handles.devices.sVibrometer);
RestoreGreyOut(handlesSAVE,handles); %'resume interface'
% Save the change you made to the structure
writeToGUI(handles,newSettings);
%allow the next functions to be called
GreyOutStage(0,handles);

guidata(hObject,handles);

% --- Executes on button press in SettOsziSelTBFromFG.
function SettOsziSelTBFromFG_Callback(hObject, eventdata, handles)
% hObject    handle to SettOsziSelTBFromFG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SettOsziSelTBFromFG
if get(hObject,'Value')==1
    finput=str2double(handles.SettFGenFreq.String);
    %tBitMoreThanOnePeriode=round(180/finput,2,'significant');
    tBitMoreThanOnePeriode=ceil((180/finput*10))/10;
    handles.SettOsziTimebase.String = tBitMoreThanOnePeriode;
    set(handles.SettOsziTimebase,'ENABLE','off');
else
    set(handles.SettOsziTimebase,'ENABLE','on')
end
% --- Executes on button press in Reconnect.
function Reconnect_Callback(hObject, eventdata, handles)
% hObject    handle to Reconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handlesSAVE=SaveANDGreyOut(handles); %'halt interface'
pause(0.01);
snew = instrfind;
if ~(isempty(snew) )  
    fclose(snew);
    delete(snew);
    clear snew;
end
%connect all instruments
Sucessfull=0;
try
[sAxis,visaOszi,sFG,sVibrometer,Sucessfull]=connectDevices();
catch exception
    uiwait(msgbox('Connection to devices failed - check and try to reconnect'));
    set(handles.Reconnect,'ENABLE','on');
end
RestoreGreyOut(handlesSAVE,handles); %'resume interface'
if Sucessfull==1
    handles.devices.sAxis =         sAxis;
    handles.devices.visaOszi =      visaOszi;
    handles.devices.sFG =           sFG;
    handles.devices.sVibrometer =   sVibrometer;
    
    set(handles.axes1,'HANDLEVISIBILITY','on');
    set(handles.SettLoad,'ENABLE','on');
    set(handles.SettSave,'ENABLE','on');
    set(handles.SettApply,'ENABLE','on');
    GreyOutDeviceOptions(0,handles);
    
    %% Set Plot
    [PosX, PosY, ~] = getStagePosition(handles.devices.sAxis);
    d=str2double(handles.ScanAreaWidth.String);
    axes(handles.axes1);
    handles.hdot=plot(handles.axes1,PosX,PosY,'or','MarkerSize',5,'MarkerFaceColor','r');
    axis(handles.axes1,[PosX-2*d PosX+2*d PosY-2*d PosY+2*d])
end

% Save the change you made to the structure
guidata(hObject,handles);



% --- Executes on button press in InitializeStage.
function InitializeStage_Callback(hObject, eventdata, handles)
% hObject    handle to InitializeStage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%   1.Zero the position 
handlesSAVE=SaveANDGreyOut(handles); %'halt interface'
fprintf(handles.devices.sAxis, 'RFS START, 3');
pause(10);
[ sAxisPos.x, sAxisPos.y, sAxisPos.z] = getStagePosition(handles.devices.sAxis);
while ((sAxisPos.x > 10)||(sAxisPos.y > 10)||(sAxisPos.z > 10))
   fprintf(handles.devices.sAxis, 'RFS START, 3');
    pause(2);
    [ sAxisPos.x, sAxisPos.y, sAxisPos.z] = getStagePosition(handles.devices.sAxis);
end
RestoreGreyOut(handlesSAVE,handles); %'resume interface'


function ScanAreaStepsize_Callback(hObject, eventdata, handles)
% hObject    handle to ScanAreaStepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScanAreaStepsize as text
%        str2double(get(hObject,'String')) returns contents of ScanAreaStepsize as a double
%step size can not be larger than the width!


% --- Executes during object creation, after setting all properties.
function ScanAreaStepsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanAreaStepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SollPosX_Callback(hObject, eventdata, handles)
% hObject    handle to SollPosX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SollPosX as text
%        str2double(get(hObject,'String')) returns contents of SollPosX as a double
set(hObject,'String',round(str2double(strrep(get(hObject,'String'),',','.')))); %set , to . and round to integer


% --- Executes during object creation, after setting all properties.
function SollPosX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SollPosX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SollPosY_Callback(hObject, eventdata, handles)
% hObject    handle to SollPosY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SollPosY as text
%        str2double(get(hObject,'String')) returns contents of SollPosY as a double
set(hObject,'String',round(str2double(strrep(get(hObject,'String'),',','.')))); %set , to . and round to integer


% --- Executes during object creation, after setting all properties.
function SollPosY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SollPosY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MoveStageExec.
function MoveStageExec_Callback(hObject, eventdata, handles)
% hObject    handle to MoveStageExec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PosX = str2double(handles.SollPosX.String);
PosY = str2double(handles.SollPosY.String);
try
    handlesSAVE=SaveANDGreyOut(handles); %'halt interface'
    moveStageTo(handles.devices.sAxis,PosX, PosY);
    RestoreGreyOut(handlesSAVE,handles); %'resume interface'
    try
        axes(handles.axes1);
        handles.hdot.XData=PosX; %move red dot in figure
        handles.hdot.YData=PosY;
    catch exceptions
    end
    set(handles.DataGetFolderPath,'ENABLE','on');
catch exceptions
    RestoreGreyOut(handlesSAVE,handles); %'resume interface'
    uiwait(msgbox('Positioning failed'));
    set(handles.DataGetFolderPath,'ENABLE','off');
    return
end


% --- Executes on selection change in ScanAreaType.
function ScanAreaType_Callback(hObject, eventdata, handles)
% hObject    handle to ScanAreaType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ScanAreaType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ScanAreaType
AreaType = handles.ScanAreaType.String{handles.ScanAreaType.Value,1};
Width=str2double(handles.ScanAreaWidth.String);
Stepsize=str2double(handles.ScanAreaStepsize.String);

if strcmp(AreaType,'Square')
    handles.MeasPointsNumber.String=num2str(ceil((Width/Stepsize)^2));
    set(handles.ScanAreaWidth,'ENABLE','on')
    set(handles.ScanAreaNumSteps,'ENABLE','on')
    set(handles.SelCurPosUL,    'ENABLE','on')
    set(handles.SelCurPosCL,    'ENABLE','on')
    set(handles.SelCurPosLL,    'ENABLE','on')
    set(handles.SelCurPosUC,    'ENABLE','on')
    set(handles.SelCurPosLC,    'ENABLE','on')
    set(handles.SelCurPosUR,    'ENABLE','on')
    set(handles.SelCurPosURText,'ENABLE','on')
    set(handles.SelCurPosCR,    'ENABLE','on')
    set(handles.SelCurPosCRText,'ENABLE','on')
    set(handles.SelCurPosLR,    'ENABLE','on')
    set(handles.SelCurPosLRText,'ENABLE','on')
elseif strcmp(AreaType,'Circle')
    handles.MeasPointsNumber.String=num2str(ceil(pi*(Width/Stepsize/2)^2)); %according to the gau�-circle-problem 
    %disable the current position possibilities which will not work for the
    %circle
    if (strcmp(handles.SelCurPos.SelectedObject.Tag,'SelCurPosUL') || ...
        strcmp(handles.SelCurPos.SelectedObject.Tag,'SelCurPosLL') || ...
        strcmp(handles.SelCurPos.SelectedObject.Tag,'SelCurPosUR') || ...
        strcmp(handles.SelCurPos.SelectedObject.Tag,'SelCurPosLR'))
        set(handles.SelCurPos,'selectedobject',handles.SelCurPosCC);
    end
    set(handles.ScanAreaWidth,'ENABLE','on')
    set(handles.ScanAreaNumSteps,'ENABLE','on')
    set(handles.SelCurPosUL,    'ENABLE','off')
    set(handles.SelCurPosCL,    'ENABLE','on')
    set(handles.SelCurPosLL,    'ENABLE','off')
    set(handles.SelCurPosUC,    'ENABLE','on')
    set(handles.SelCurPosLC,    'ENABLE','on')
    set(handles.SelCurPosUR,    'ENABLE','off')
    set(handles.SelCurPosURText,'ENABLE','off')
    set(handles.SelCurPosCR,    'ENABLE','on')
    set(handles.SelCurPosCRText,'ENABLE','on')
    set(handles.SelCurPosLR,    'ENABLE','off')
    set(handles.SelCurPosLRText,'ENABLE','off')
elseif strcmp(AreaType,'Point')
    handles.MeasPointsNumber.String='1';
    %restrict positon options
    set(handles.SelCurPosUL,    'ENABLE','off')
    set(handles.SelCurPosCL,    'ENABLE','off')
    set(handles.SelCurPosLL,    'ENABLE','off')
    set(handles.SelCurPosUC,    'ENABLE','off')
    set(handles.SelCurPosLC,    'ENABLE','off')
    set(handles.SelCurPosUR,    'ENABLE','off')
    set(handles.SelCurPosURText,'ENABLE','off')
    set(handles.SelCurPosCR,    'ENABLE','off')
    set(handles.SelCurPosCRText,'ENABLE','off')
    set(handles.SelCurPosLR,    'ENABLE','off')
    set(handles.SelCurPosLRText,'ENABLE','off')
    %restrict width options
    set(handles.ScanAreaWidth,'ENABLE','off')
    set(handles.ScanAreaNumSteps,'ENABLE','off')
    %if there is only one point, there is only one step and a diametoer of 0
    handles.ScanAreaWidth.String='0';
    handles.ScanAreaNumSteps.String='1';
    handles.ScanAreaStepsize.String='1';
    handles.SelCurPosCC.Value=1;
    set(handles.SelCurPosCC,'ENABLE','on')
 elseif strcmp(AreaType,'Line  |')
    handles.MeasPointsNumber.String=num2str(ceil((Width/Stepsize)));
    set(handles.SelCurPosUL,'ENABLE','off')
    set(handles.SelCurPosCL,'ENABLE','off')
    set(handles.SelCurPosLL,'ENABLE','off')
    set(handles.SelCurPosUC,'ENABLE','on')
    set(handles.SelCurPosLC,'ENABLE','on')
    set(handles.SelCurPosUR,'ENABLE','off')
    set(handles.SelCurPosURText,'ENABLE','off')
    set(handles.SelCurPosCR,'ENABLE','off')
    set(handles.SelCurPosCRText,'ENABLE','off')
    set(handles.SelCurPosLR,'ENABLE','off')
    set(handles.SelCurPosLRText,'ENABLE','off')
    set(handles.ScanAreaWidth,'ENABLE','on')
    set(handles.ScanAreaNumSteps,'ENABLE','on')
 elseif strcmp(AreaType,'Line  -')
    handles.MeasPointsNumber.String=num2str(ceil((Width/Stepsize)));
    set(handles.SelCurPosUL,'ENABLE','off')
    set(handles.SelCurPosCL,'ENABLE','on')
    set(handles.SelCurPosLL,'ENABLE','off')
    set(handles.SelCurPosUC,'ENABLE','off')
    set(handles.SelCurPosLC,'ENABLE','off')
    set(handles.SelCurPosUR,'ENABLE','off')
    set(handles.SelCurPosURText,'ENABLE','off')
    set(handles.SelCurPosCR,'ENABLE','on')
    set(handles.SelCurPosCRText,'ENABLE','on')
    set(handles.SelCurPosLR,'ENABLE','off')
    set(handles.SelCurPosLRText,'ENABLE','off')
    set(handles.ScanAreaWidth,'ENABLE','on')
    set(handles.ScanAreaNumSteps,'ENABLE','on')
end


% --- Executes during object creation, after setting all properties.
function ScanAreaType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanAreaType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ScanAreaWidth_Callback(hObject, eventdata, handles)
% hObject    handle to ScanAreaWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScanAreaWidth as text
%        str2double(get(hObject,'String')) returns contents of ScanAreaWidth as a double
set(hObject,'String',round(str2double(strrep(get(hObject,'String'),',','.')))); %set , to . and round to integer
%width can not be smaler than the step size!
handles.ScanAreaStepsize.String=num2str(ceil(str2double(handles.ScanAreaWidth.String) / (str2double(handles.ScanAreaNumSteps.String)-1)));
% Save the change you made to the structure
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ScanAreaWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanAreaWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showOutlineScanArea.
function showOutlineScanArea_Callback(hObject, eventdata, handles)
% hObject    handle to showOutlineScanArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handlesSAVE=SaveANDGreyOut(handles); %'halt interface'
set(handles.AbortOutlinePreview,'ENABLE','on');

set(handles.AbortOutlinePreview,'UserData',0); 
OutlinePoints=handles.Settings.Scanning.OutlineContour;
for i=1:length(OutlinePoints)
    %drive to the positions
    if get(handles.AbortOutlinePreview,'UserData')==1 
        RestoreGreyOut(handlesSAVE,handles); %'resume interface'
        set(handles.AbortOutlinePreview,'ENABLE','off');
        return %stop the preview by the 'Abort button'
    end  
    moveStageTo(handles.devices.sAxis,OutlinePoints(i,2), OutlinePoints(i,1))
    axes(handles.axes1);
    handles.hdot.XData=OutlinePoints(i,2); %move red dot in figure
    handles.hdot.YData=OutlinePoints(i,1);
end
RestoreGreyOut(handlesSAVE,handles); %'resume interface'
set(handles.AbortOutlinePreview,'ENABLE','off');


% --- Executes on button press in ApplyScanningArea.
function ApplyScanningArea_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyScanningArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%here we save all the values and then calculate the positioning matrix
%first save all the settings in handles.Settings
handles.Settings.Scanning.Stepsize=str2double(handles.ScanAreaStepsize.String);
handles.Settings.Scanning.NumSteps=str2double(handles.ScanAreaNumSteps.String);
handles.Settings.Scanning.DiaWidth=str2double(handles.ScanAreaWidth.String);
handles.Settings.Scanning.Area=handles.ScanAreaType.String{handles.ScanAreaType.Value,1};
handles.Settings.Scanning.LocCurrentPos = handles.SelCurPos.SelectedObject.Tag;
%get the current position
try
    handlesSAVE=SaveANDGreyOut(handles); %'halt interface'
    [posx,posy,~]=getStagePosition(handles.devices.sAxis);
    handles.Settings.Scanning.PosX = posx;
    handles.Settings.Scanning.PosY = posy;
    [handles.Settings.Measurement.MeasureStructur,handles.Settings.Scanning.OutlineContour]=calculateScanningPositions(handles.Settings);
    RestoreGreyOut(handlesSAVE,handles); %'resume interface'
    
catch exceptions
    uiwait(msgbox('Read Position or Scanning calculation failed'));
    RestoreGreyOut(handlesSAVE,handles); %'resume interface'
    return
end
    set(handles.showOutlineScanArea,'ENABLE','on');
    set(handles.RUNMeasurement,'ENABLE','on');
    set(handles.SettingsSaveALL,'ENABLE','on');
%refresh the plot
[sizeY, sizeX]=size(handles.Settings.Measurement.MeasureStructur);
Gridpoints=NaN(1,2);
for ix=1:sizeX
    for iy=1:sizeY
        Gridpoints=[Gridpoints;...
            handles.Settings.Measurement.MeasureStructur{iy,ix}.PosX, ...
            handles.Settings.Measurement.MeasureStructur{iy,ix}.PosY...
            ];
    end 
end

d=str2double(handles.ScanAreaWidth.String);
axes(handles.axes1);
handles.hdot=plot(handles.figure.axesHandle,posx,posy,'or','MarkerSize',5,'MarkerFaceColor','r');
if d==0; d=5; end
axis(handles.axes1,[posx-0.6*d posx+0.6*d posy-0.6*d posy+0.6*d])
hold on
handles.gridplot=plot(Gridpoints(:,1),Gridpoints(:,2), '.','Parent',handles.axes1);
hold off

set(handles.showOutlineScanArea,'ENABLE','on');
% Save the change you made to the structure
guidata(hObject,handles);


function MeasPointsNumber_Callback(hObject, eventdata, handles)
% hObject    handle to MeasPointsNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MeasPointsNumber as text
%        str2double(get(hObject,'String')) returns contents of MeasPointsNumber as a double


% --- Executes during object creation, after setting all properties.
function MeasPointsNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MeasPointsNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AbortOutlinePreview.
function AbortOutlinePreview_Callback(hObject, eventdata, handles)
% hObject    handle to AbortOutlinePreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.AbortOutlinePreview,'UserData',1); 



% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in SetPosAsStart.
function SetPosAsStart_Callback(hObject, eventdata, handles)
% hObject    handle to SetPosAsStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    [posx,posy,~]=getStagePosition(handles.devices.sAxis);
    handles.SollPosX.String=num2str(posx);
    handles.SollPosY.String=num2str(posy);
    set(handles.DataGetFolderPath,'ENABLE','on');
catch exceptions
    uiwait(msgbox('reading failed...try to reconnect'));
    set(handles.DataGetFolderPath,'ENABLE','off');
    return
end
set(handles.DataGetFolderPath,'ENABLE','on');
% Save the change you made to the structure
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SelCurPos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelCurPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in DataGetFolderPath.
function DataGetFolderPath_Callback(hObject, eventdata, handles)
% hObject    handle to DataGetFolderPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Prepare saving folders
try
    WorkDir = uigetdir;          %choose woking directory
    WorkOut = 'Result_Data';     % Save in directory
    if exist(strcat(WorkDir,'\',WorkOut),'dir') == 0
        mkdir(strcat(WorkDir,'\',WorkOut));
    end
    fnameOverview = strcat(WorkDir,'\',WorkOut,'\overview.txt');
    %save path and filname in Settings
    handles.Settings.Path.WorkDir=WorkDir;
    handles.Settings.Path.WorkOut=WorkOut;
    handles.Settings.Path.fnameOverview=fnameOverview;
    handles.PathText.String=WorkDir; %write path to text field
    GreyOutScanning(0,handles)
    set(handles.ApplyScanningArea,'ENABLE','on');
catch exception
    uiwait(msgbox('Selecting Path failed..please try again'));
    GreyOutScanning(1,handles)
    set(handles.ApplyScanningArea,'ENABLE','off');
    return
end

% Save the change you made to the structure
guidata(hObject,handles);

% --- Executes on button press in RUNMeasurement.
function RUNMeasurement_Callback(hObject, eventdata, handles)
% hObject    handle to RUNMeasurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

WorkDir= handles.Settings.Path.WorkDir;
WorkOut= handles.Settings.Path.WorkOut;
fnameOverview=handles.Settings.Path.fnameOverview;
handles.Settings=readFromGUI(handles);
MSStructure=handles.Settings.Measurement.MeasureStructur;
MSSize=size(MSStructure);

ErrorValue=9.9E+37;
VelocityRes=[1,5,25,125,1000]; %corrects sorting of velocity values of vibrometer
VelocityResNr=[2,3,4,5,1]; %turn the weird numbering of the vibrometer into a compatible to 'VelocityRes'

%check that the output of the frequency generator is running
if str2double(query(handles.devices.sFG,'OUTP1?'))~=1
    fprintf(handles.devices.sFG,'OUTP1 ON');
end

%refresh the plot in case we restart the measurement with the saved grid
[sizeY, sizeX]=size(handles.Settings.Measurement.MeasureStructur);
Gridpoints=NaN(1,2);
for ix=1:sizeX
    for iy=1:sizeY
        Gridpoints=[Gridpoints;...
            handles.Settings.Measurement.MeasureStructur{iy,ix}.PosX, ...
            handles.Settings.Measurement.MeasureStructur{iy,ix}.PosY...
            ];
    end 
end
[posx, posy,~]=getStagePosition(handles.devices.sAxis);
d=str2double(handles.ScanAreaWidth.String);
axes(handles.axes1);
handles.hdot=plot(handles.figure.axesHandle,posx,posy,'or','MarkerSize',5,'MarkerFaceColor','b');
axis(handles.axes1,'auto')%[posx-0.6*d posx+0.6*d posy-0.6*d posy+0.6*d])
hold on
handles.gridplot=plot(Gridpoints(:,1),Gridpoints(:,2), '.','Parent',handles.axes1);
hold off


%create the general overview file
fileOV= fopen(fnameOverview,'w');
%fprintf(fileOV,'ix\t iy\t PosX\t PosY\t PhaseShift\t VoltsPerDiv1\t VoltsPerDiv2\t SecPerDiv\t Points\t');
fprintf(fileOV,'iy\t ix\t PosX\t PosY\t PosXrelToCenter\t PosYrelToCenter\t PhaseShift\t VoltsPerDiv1\t VoltsPerDiv2\t SecPerDiv\t Points\r\n');
fclose(fileOV);

handlesSAVE=SaveANDGreyOut(handles); %'halt interface'
set(handles.AbortMeasurement,'UserData',0); 
set(handles.AbortMeasurement,'ENABLE','on');
set(handles.WebcamON,'ENABLE','on');
for ix=1:MSSize(2)
    for iy=1:MSSize(1)
        if get(handles.AbortMeasurement,'UserData')==1 
            fpathMSStructureIncomplete = strcat(WorkDir,'\',WorkOut,'\MeasurementValuesIncomplete.mat');
            save(fpathMSStructureIncomplete,'MSStructure')
            RestoreGreyOut(handlesSAVE,handles); %'resume interface'
            set(handles.AbortMeasurement,'ENABLE','off');
            assignin('base','MeasureStructurIncomplete',MSStructure);
            return %stop the measuremt by the 'Abort button'
        end  
        PosX=MSStructure{iy,ix}.PosX;
        PosY=MSStructure{iy,ix}.PosY;
        
        if ~(isnan(PosX)||isnan(PosY)) %it is a point we should measure at
             %Get there!
            moveStageTo(handles.devices.sAxis,PosX, PosY)
            [PosX, PosY,~]=getStagePosition(handles.devices.sAxis);
    
            try
                hold on;
                axes(handles.axes1);
                handles.hdot.XData=PosX; %move red dot in figure
                handles.hdot.YData=PosY;
                handles.MeasCurrPOSX.String=num2str(PosX); %plot current position in interface
                handles.MeasCurrPOSY.String=num2str(PosY);
            catch exceptions
            end

            %Stop all Axis from moving!
            fprintf(handles.devices.sAxis, 'MST 3');
            pause(0.3);         
            
            
            %############
            %Measure
            %############
            not_done=true;
            Retry=0;
            while (not_done&&(Retry<=3)&&(get(handles.AbortMeasurement,'UserData')==0))    %repeat measurement if Error result of 9.9E+37
                               
                iVelocityRes=VelocityRes(VelocityResNr(str2double(query(handles.devices.sVibrometer,'VELO?')))); %the range will be saved as 1,5,125,1000 [mm/V] 
                if handles.Settings.Vib.AutoSettings
                    %the best resolution of the vibrometer should be set at
                    %EVERY point!
                    iValues=acquireWaveform(handles.devices.visaOszi,handles.Settings);
                    iOutOfRange=0;
                    for i=1:3
                        iOutOfRange=iOutOfRange+str2double(query(handles.devices.sVibrometer,'OVR')); %check for out-of-range of vibrometer
                        pause(0.3); %do it multiple times to make sure we're not out of range
                    end

                    if ((iValues.PhaseShift ==  ErrorValue)||iOutOfRange>0||iValues.Aq1<1||Retry>0||iValues.Aq1>20)
                        %fprintf(handles.devices.visaOszi,':RUN'); %start the oszi during settings change
                        iVelocityRes=VelocityRes(determineBestVibrometerRange40kHz(handles.devices.sVibrometer)); %the range will be saved as 1,5,125,1000 [mm/V]
                    end
                end
                handles.Settings.Vib.VelResNR=str2double(query(handles.devices.sVibrometer,'VELO?'));
                
                if handles.Settings.Oszi.AutoSettings
                    %if OszilloscopeAutoSettings are on, we should determine
                    %the resolution of the Oszilloscope at every point
                   [handles.Settings.Oszi.CH1Res,handles.Settings.Oszi.CH2Res]=adjustOsziScale(visaOszi); 
                end
                %write setting changes to interface
                writeToGUI(handles.Settings);
                
                %measure with all (potentially new) settings
                iValues=acquireWaveform(handles.devices.visaOszi,handles.Settings);
                
                if iValues.PhaseShift ==ErrorValue
                    Retry=Retry+1;
                    not_done=true;
                    %speedup the process if we're out of range
                    if ((iValues.Aq1<0.3)&&(iVelocityRes==1)&&(Retry>0))
                        Retry=Inf;
                        disp('Velocity is too small even with highest settings. Retry will not help');
                    end
                else
                    not_done=false;
                end
            end %of retry the measurement routine
            %save the voltage+frequency of the wave-generator as well
            [iValues.iFreqExcitation,iValues.iVppExcitation,~]=getFGSettings(handles.sFG);
            
            %save the data to the MeasurementValues
            iValues.PosX=PosX; %add the position to the save values
            iValues.PosY=PosY;
            iValues.PosXrelToCenter=MSStructure{iy,ix}.PosXrelToCenter;
            iValues.PosYrelToCenter=MSStructure{iy,ix}.PosYrelToCenter;
            %add important values from the settings
            iValues.VelocityRes=iVelocityRes; %the range will be saved as 1,5,125,1000 [mm/V]
            MSStructure{iy,ix}=iValues; %we assign the new values because it's easier to append the position then to merge the cells
            
            
            %set a green dot where we're done
            axis(handles.axes1);
            hold on
            if not_done
                plot(handles.figure.axesHandle,PosX,PosY,'or','MarkerSize',6,'MarkerFaceColor','r');
                disp(['Measurement Error at X:' num2str(PosX) ' �m, Y:' num2str(PosY) ' �m. Nr. of reattemtps: ' num2str(Retry)]);
            else
                plot(handles.figure.axesHandle,PosX,PosY,'or','MarkerSize',6,'MarkerFaceColor','g');
                %disp(['Measurement Successull at X:' num2str(PosX) ' �m, Y:' num2str(PosY) ' �m. Nr. of reattemtps: ' num2str(Retry)]);
            end
            hold off
            
            %save the general overview file
            fileOV= fopen(fnameOverview,'a');
            fprintf(fileOV,'%d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\r\n',...
                iy, ix,...
                iValues.PosX,iValues.PosY,...
                iValues.PosXrelToCenter,iValues.PosYrelToCenter,...
                iValues.PhaseShift,...
                iValues.VoltsPerDiv1,iValues.VoltsPerDiv2,...
                iValues.SecPerDiv,iValues.Points,...
                iValues.VelocityRes);
            fclose(fileOV);
            %save the data points to seperate files
            fnamepathGraph = strcat(WorkDir,'\',WorkOut,'\');
            fnameGraph = sprintf('%sgraphPos[%d,%d].txt',fnamepathGraph,iy,ix);
            GraphMat=[(iValues.XData'),iValues.YData1,iValues.YData2];
            save(fnameGraph,'GraphMat','-ascii'); 
        else
            %we don't need to measure here (probably cause it is outside
            %the circle area we need to evaluate
            
        end

    end
end
%SAVE THE MEASUREMENT VALUES!!!
fpathMSStructure = strcat(WorkDir,'\',WorkOut,'\MeasurementValues.mat');
save(fpathMSStructure,'MSStructure')
handles.Settings.Measurement.MeasureStructur=MSStructure;
assignin('base','MeasureStructur',MSStructure);
% Save the change you made to the structure
guidata(hObject,handles);
RestoreGreyOut(handlesSAVE,handles); %'resume interface'
set(handles.AbortMeasurement,'ENABLE','off');
set(handles.EvaluateResults,'ENABLE','on');
%turn the output of the function generator off to emmit fewer noise
fprintf(handles.devices.sFG,'OUTP1 OFF');



% --- Executes on button press in AbortMeasurement.
function AbortMeasurement_Callback(hObject, eventdata, handles)
% hObject    handle to AbortMeasurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.AbortMeasurement,'UserData',1);
uiwait(msgbox('Incomplete Data will be transfered to the workspace'));

% --- Executes on button press in SettingsLoadALL.
function SettingsLoadALL_Callback(hObject, eventdata, handles)
% hObject    handle to SettingsLoadALL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fname pname] = uigetfile('MeasurementSettings.mat','Select the Settings to load');
handlesSAVE=SaveANDGreyOut(handles); %'halt interface'
try 
    loadSettings = load([pname fname]);
catch exceptions
    uiwait(msgbox('No valid file selected'))
    RestoreGreyOut(handlesSAVE,handles); %'resume interface'
    return
end
RestoreGreyOut(handlesSAVE,handles); %'resume interface'
GreyOutStage(0,handles);%allow the next functions to be called

handles.Settings=loadSettings.MeasurementSettings;
writeToGUI(handles,handles.Settings);

handles.SollPosX.String = num2str(loadSettings.MeasurementSettings.Stage.SollPosX);
handles.SollPosY.String=num2str(loadSettings.MeasurementSettings.Stage.SollPosY);
handles.ScanAreaType.Value=loadSettings.MeasurementSettings.Scanning.AreaType;
handles.ScanAreaWidth.String=num2str(loadSettings.MeasurementSettings.Scanning.DiaWidth);
handles.ScanAreaStepsize.String=num2str(loadSettings.MeasurementSettings.Scanning.StepSize);
handles.ScanAreaNumSteps.String=num2str(loadSettings.MeasurementSettings.Scanning.NumSteps);
handles.SelCurPosUL.Value=loadSettings.MeasurementSettings.Scanning.CPos.UL;
handles.SelCurPosLC.Value=loadSettings.MeasurementSettings.Scanning.CPos.CL;
handles.SelCurPosLL.Value=loadSettings.MeasurementSettings.Scanning.CPos.LL;
handles.SelCurPosUC.Value=loadSettings.MeasurementSettings.Scanning.CPos.UC;
handles.SelCurPosCC.Value=loadSettings.MeasurementSettings.Scanning.CPos.CC;
handles.SelCurPosLC.Value=loadSettings.MeasurementSettings.Scanning.CPos.LC;
handles.SelCurPosUR.Value=loadSettings.MeasurementSettings.Scanning.CPos.UR;
handles.SelCurPosCR.Value=loadSettings.MeasurementSettings.Scanning.CPos.CR;
handles.SelCurPosLR.Value=loadSettings.MeasurementSettings.Scanning.CPos.LR;
handles.MeasPointsNumber.String=num2str(loadSettings.MeasurementSettings.Scanning.NumPoints);
handles.PathText.String=loadSettings.MeasurementSettings.Path.WorkDir; %write path to text field


%refresh the with the saved grid
[sizeY, sizeX]=size(handles.Settings.Measurement.MeasureStructur);
Gridpoints=NaN(1,2);
for ix=1:sizeX
    for iy=1:sizeY
        Gridpoints=[Gridpoints;...
            handles.Settings.Measurement.MeasureStructur{iy,ix}.PosX, ...
            handles.Settings.Measurement.MeasureStructur{iy,ix}.PosY...
            ];
    end 
end
[posx, posy,~]=getStagePosition(handles.devices.sAxis);
d=str2double(handles.ScanAreaWidth.String);
axes(handles.axes1);
handles.hdot=plot(handles.figure.axesHandle,posx,posy,'or','MarkerSize',5,'MarkerFaceColor','r');
axis(handles.axes1,'auto')%[posx-0.6*d posx+0.6*d posy-0.6*d posy+0.6*d])
hold on
handles.gridplot=plot(Gridpoints(:,1),Gridpoints(:,2), '.','Parent',handles.axes1);
hold off

%allow all the previously restricted functions
set(handles.SettingsSaveALL,'ENABLE','on');
GreyOutStage(0,handles); %enable stage settings
set(handles.DataGetFolderPath,'ENABLE','on'); %allow folder settings
GreyOutScanning(0,handles)  %Scanning settings
set(handles.ApplyScanningArea,'ENABLE','on');
set(handles.showOutlineScanArea,'ENABLE','on'); %previw area
set(handles.RUNMeasurement,'ENABLE','on');  %allow measurement
% Save the change you made to the structure
guidata(hObject,handles);
uiwait(msgbox('Data save path is restored. Please check or set again to prevent data loss'));

% --- Executes on button press in SettingsSaveALL.
function SettingsSaveALL_Callback(hObject, eventdata, handles)
% hObject    handle to SettingsSaveALL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%save the device settings, then add the others
MeasurementSettings=readFromGUI(handles);
handles.Settings.FGen = MeasurementSettings.FGen;
handles.Settings.Oszi = MeasurementSettings.Oszi;
handles.Settings.Vib = MeasurementSettings.Vib;
MeasurementSettings.Measurement=handles.Settings.Measurement;
MeasurementSettings.Stage.SollPosX=str2double(handles.SollPosX.String);
MeasurementSettings.Stage.SollPosY=str2double(handles.SollPosY.String);
MeasurementSettings.Scanning.AreaType=handles.ScanAreaType.Value;
MeasurementSettings.Scanning.DiaWidth=str2double(handles.ScanAreaWidth.String);
MeasurementSettings.Scanning.StepSize=str2double(handles.ScanAreaStepsize.String);
MeasurementSettings.Scanning.NumSteps=str2double(handles.ScanAreaNumSteps.String);
MeasurementSettings.Scanning.CPos.UL=handles.SelCurPosUL.Value;
MeasurementSettings.Scanning.CPos.CL=handles.SelCurPosLC.Value;
MeasurementSettings.Scanning.CPos.LL=handles.SelCurPosLL.Value;
MeasurementSettings.Scanning.CPos.UC=handles.SelCurPosUC.Value;
MeasurementSettings.Scanning.CPos.CC=handles.SelCurPosCC.Value;
MeasurementSettings.Scanning.CPos.LC=handles.SelCurPosLC.Value;
MeasurementSettings.Scanning.CPos.UR=handles.SelCurPosUR.Value;
MeasurementSettings.Scanning.CPos.CR=handles.SelCurPosCR.Value;
MeasurementSettings.Scanning.CPos.LR=handles.SelCurPosLR.Value;
MeasurementSettings.Scanning.NumPoints=str2double(handles.MeasPointsNumber.String);
MeasurementSettings.Scanning.MeasureStructur=handles.Settings.Measurement.MeasureStructur;
MeasurementSettings.Scanning.OutlineContour=handles.Settings.Scanning.OutlineContour;
MeasurementSettings.Path.WorkDir=handles.Settings.Path.WorkDir;
MeasurementSettings.Path.WorkOut=handles.Settings.Path.WorkOut;
MeasurementSettings.Path.fnameOverview=handles.Settings.Path.fnameOverview;
filewithpath=strcat(handles.Settings.Path.WorkDir,'\MeasurementSettings.mat');
uisave('MeasurementSettings',filewithpath);
% Save the change you made to the structure
guidata(hObject,handles);


function MeasCurrPOSX_Callback(hObject, eventdata, handles)
% hObject    handle to MeasCurrPOSX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MeasCurrPOSX as text
%        str2double(get(hObject,'String')) returns contents of MeasCurrPOSX as a double


% --- Executes during object creation, after setting all properties.
function MeasCurrPOSX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MeasCurrPOSX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MeasCurrPOSY_Callback(hObject, eventdata, handles)
% hObject    handle to MeasCurrPOSY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MeasCurrPOSY as text
%        str2double(get(hObject,'String')) returns contents of MeasCurrPOSY as a double


% --- Executes during object creation, after setting all properties.
function MeasCurrPOSY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MeasCurrPOSY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function GreyOutDeviceOptions(greyOut,handles)
if greyOut==1
    set(handles.SettFGenFreq ,'ENABLE','off');
    set(handles.SettBoxFGenFreq ,'ENABLE','off');
    set(handles.SettBoxFGenFreqEinh ,'ENABLE','off');
    set(handles.SettFGenVpp ,'ENABLE','off');
    set(handles.SettBoxFGenAmp ,'ENABLE','off');
    set(handles.SettBoxFGenAmpEinh ,'ENABLE','off');
    set(handles.SettOsziAuto ,'ENABLE','off');
    set(handles.SettOsziCH1EN ,'ENABLE','off');
    set(handles.SettOsziCH1Res ,'ENABLE','off');
    set(handles.SettBoxOsziCH1Res ,'ENABLE','off');
    set(handles.SettBoxOsziCH1ResEinh ,'ENABLE','off');
    set(handles.SettOsziCH2EN ,'ENABLE','off');
    set(handles.SettOsziCH2Res ,'ENABLE','off');
    set(handles.SettBoxOsziCH2Res ,'ENABLE','off');
    set(handles.SettBoxOsziCH2ResEinh ,'ENABLE','off');
    set(handles.SettOsziSelTBFromFG ,'ENABLE','off');
    set(handles.SettOsziTimebase ,'ENABLE','off');
    set(handles.SettBoxOsziTimB ,'ENABLE','off');
    set(handles.SettBoxOsziTimBEinh ,'ENABLE','off');
    set(handles.SettOsziAq1 ,'ENABLE','off');
    set(handles.SettOsziAq2 ,'ENABLE','off');
    set(handles.SettOsziAq3 ,'ENABLE','off');
    set(handles.SettOsziAq4 ,'ENABLE','off');
    set(handles.SettVibAuto ,'ENABLE','off');
    set(handles.SettVibVelRes ,'ENABLE','off');
    set(handles.SettBoxVibVelRes ,'ENABLE','off');
else
    set(handles.SettFGenFreq ,'ENABLE','on');
    set(handles.SettBoxFGenFreq ,'ENABLE','on');
    set(handles.SettBoxFGenFreqEinh ,'ENABLE','on');
    set(handles.SettFGenVpp ,'ENABLE','on');
    set(handles.SettBoxFGenAmp ,'ENABLE','on');
    set(handles.SettBoxFGenAmpEinh ,'ENABLE','on');
    set(handles.SettOsziAuto ,'ENABLE','on');
    set(handles.SettOsziCH1EN ,'ENABLE','on');
    set(handles.SettOsziCH1Res ,'ENABLE','on');
    set(handles.SettBoxOsziCH1Res ,'ENABLE','on');
    set(handles.SettBoxOsziCH1ResEinh ,'ENABLE','on');
    set(handles.SettOsziCH2EN ,'ENABLE','on');
    set(handles.SettOsziCH2Res ,'ENABLE','on');
    set(handles.SettBoxOsziCH2Res ,'ENABLE','on');
    set(handles.SettBoxOsziCH2ResEinh ,'ENABLE','on');
    set(handles.SettOsziSelTBFromFG ,'ENABLE','on');
    set(handles.SettOsziTimebase ,'ENABLE','on');
    set(handles.SettBoxOsziTimB ,'ENABLE','on');
    set(handles.SettBoxOsziTimBEinh ,'ENABLE','on');
%     set(handles.SettOsziAq1 ,'ENABLE','on');
%     set(handles.SettOsziAq2 ,'ENABLE','on');
%     set(handles.SettOsziAq3 ,'ENABLE','on');
%     set(handles.SettOsziAq4 ,'ENABLE','on');
    set(handles.SettVibAuto ,'ENABLE','on');
    set(handles.SettVibVelRes ,'ENABLE','on');
    set(handles.SettBoxVibVelRes ,'ENABLE','on');
end

function GreyOutStage(greyOut,handles)
if greyOut==1
    set(handles.SollPosX,'ENABLE','off');
    set(handles.SollPosXText,'ENABLE','off');
    set(handles.SollPosXTextum,'ENABLE','off');
    set(handles.SollPosY,'ENABLE','off');
    set(handles.SollPosYText,'ENABLE','off');
    set(handles.SollPosYTextum,'ENABLE','off');
    set(handles.InitializeStage,'ENABLE','off'); %buttons
    set(handles.MoveStageExec,'ENABLE','off');%buttons
    set(handles.SetPosAsStart,'ENABLE','off');%buttons
else
    set(handles.SollPosX,'ENABLE','on');
    set(handles.SollPosXText,'ENABLE','on');
    set(handles.SollPosXTextum,'ENABLE','on');
    set(handles.SollPosY,'ENABLE','on');
    set(handles.SollPosYText,'ENABLE','on');
    set(handles.SollPosYTextum,'ENABLE','on');
    set(handles.InitializeStage,'ENABLE','on');%buttons
    set(handles.MoveStageExec,'ENABLE','on');%buttons
    set(handles.SetPosAsStart,'ENABLE','on');%buttons
end

function GreyOutScanning(greyOut,handles)
if greyOut==1
    set(handles.ScanAreaType,'ENABLE','off');
    set(handles.ScanAreaTypeText,'ENABLE','off');
    set(handles.ScanAreaWidth,'ENABLE','off');
    set(handles.ScanAreaWText,'ENABLE','off');
    set(handles.ScanAreaWTextum,'ENABLE','off');
    set(handles.ScanAreaStepsize,'ENABLE','off');
    set(handles.ScanAreaStepText,'ENABLE','off');
    set(handles.ScanAreaNumSteps,'ENABLE','off');
    set(handles.ScanAreaNumStepsText,'ENABLE','off');
    set(handles.ScanAreaStepTextum,'ENABLE','off');
    set(handles.SelCurPosUL,'ENABLE','off');
    set(handles.SelCurPosCL,'ENABLE','off');
    set(handles.SelCurPosLL,'ENABLE','off');
    set(handles.SelCurPosUC,'ENABLE','off');
    set(handles.SelCurPosCC,'ENABLE','off');
    set(handles.SelCurPosCCText,'ENABLE','off');
    set(handles.SelCurPosLC,'ENABLE','off');
    set(handles.SelCurPosUR,'ENABLE','off');
    set(handles.SelCurPosURText,'ENABLE','off');
    set(handles.SelCurPosCR,'ENABLE','off');
    set(handles.SelCurPosCRText,'ENABLE','off');
    set(handles.SelCurPosLR,'ENABLE','off');
    set(handles.SelCurPosLRText,'ENABLE','off');
    set(handles.MeasPointsNumber,'ENABLE','off');
    set(handles.ScanAreaNumPointsText,'ENABLE','off');
else
    set(handles.ScanAreaType,'ENABLE','on');
    set(handles.ScanAreaTypeText,'ENABLE','on');
    set(handles.ScanAreaWidth,'ENABLE','on');
    set(handles.ScanAreaWText,'ENABLE','on');
    set(handles.ScanAreaWTextum,'ENABLE','on');
    set(handles.ScanAreaNumSteps,'ENABLE','on');
    set(handles.ScanAreaNumStepsText,'ENABLE','on');
    %set(handles.ScanAreaStepsize,'ENABLE','on');
    set(handles.ScanAreaStepText,'ENABLE','on'); 
    set(handles.ScanAreaStepTextum,'ENABLE','on');
    set(handles.SelCurPosUL,'ENABLE','on');
    set(handles.SelCurPosCL,'ENABLE','on');
    set(handles.SelCurPosLL,'ENABLE','on');
    set(handles.SelCurPosUC,'ENABLE','on');
    set(handles.SelCurPosCC,'ENABLE','on');
    set(handles.SelCurPosCCText,'ENABLE','on');
    set(handles.SelCurPosLC,'ENABLE','on');
    set(handles.SelCurPosUR,'ENABLE','on');
    set(handles.SelCurPosURText,'ENABLE','on');
    set(handles.SelCurPosCR,'ENABLE','on');
    set(handles.SelCurPosCRText,'ENABLE','on');
    set(handles.SelCurPosLR,'ENABLE','on');
    set(handles.SelCurPosLRText,'ENABLE','on');
    set(handles.ScanAreaNumPointsText,'ENABLE','on');
end

function[safeState]= SaveANDGreyOut(handles)
    allhandles=[...
        findobj(gcf,'style','edit');...
        findobj(gcf,'style','checkbox');...
        findobj(gcf,'style','radiobutton');...
        findobj(gcf,'style','pushbutton');...
        findobj(gcf,'style','popupmenu');...
        findobj(gcf,'style','text')...
        ];
    safeState=cell(length(allhandles),1);
    for i=1:length(allhandles)
        safeState{i}=get(allhandles(i),'ENABLE');
        set(allhandles(i),'ENABLE','off');
    end
    
function RestoreGreyOut(safeState,handles)
    allhandles=[...
        findobj(gcf,'style','edit');...
        findobj(gcf,'style','checkbox');...
        findobj(gcf,'style','radiobutton');...
        findobj(gcf,'style','pushbutton');...
        findobj(gcf,'style','popupmenu');...
        findobj(gcf,'style','text')...
        ];
    for i=1:length(allhandles)
        set(allhandles(i),'ENABLE',safeState{i});
    end




% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handlesSAVE=SaveANDGreyOut(handles);

RestoreGreyOut(handlesSAVE,handles);



function PathText_Callback(hObject, eventdata, handles)
% hObject    handle to PathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PathText as text
%        str2double(get(hObject,'String')) returns contents of PathText as a double


% --- Executes during object creation, after setting all properties.
function PathText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on key press with focus on AbortMeasurement and none of its controls.
function AbortMeasurement_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to AbortMeasurement (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


%EVALUATE

% --- Executes on button press in EvaluateResults.
function EvaluateResults_Callback(hObject, eventdata, handles)
% hObject    handle to EvaluateResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handlesSAVE=SaveANDGreyOut(handles); %'halt interface
pause(0.001);

WorkDir= handles.Settings.Path.WorkDir;
fnamepathGraphVelo = strcat(WorkDir,'\MaxVelocity.fig');
fnamepathGraphDisp = strcat(WorkDir,'\MaxDisplacement.fig');
fnamepathGraphPhase = strcat(WorkDir,'\MaxPhaseShift.fig');
fnamepathMsValuesWithPlot = strcat(WorkDir,'\PlotValues.mat');

[PlotX,PlotY,PlotZPhase,PlotZDisplacement,PlotZVelocity,PlotZ_t,overview]= evaluateMeasurementValues(handles.Settings.Measurement.MeasureStructur);
PlotValues.PlotX=PlotX;
PlotValues.PlotY=PlotY;
PlotValues.PlotZPhase=PlotZPhase;
PlotValues.PlotZDisplacement=PlotZDisplacement;
PlotValues.PlotZVelocity=PlotZVelocity;
PlotValues.PlotZ_t=PlotZ_t;
PlotValues.overview=overview;
handles.PlotValues=PlotValues;
save(fnamepathMsValuesWithPlot,'PlotValues');
RestoreGreyOut(handlesSAVE,handles); %'resume interface'

velMAX=max(overview(:,12));
velMIN=min(overview(:,13));
displMAX=max(overview(:,14));
displMIN=min(overview(:,15));
%plot the images in seperate figures
handles.fig.f1=figure;
surf(PlotX,PlotY,PlotZPhase);
title('Phaseshift between Velocity and stimulating Amplitude');
zlabel('Phase in deg');
xlabel('X in �m');
ylabel('Y in �m');
savefig(fnamepathGraphVelo)

handles.fig.f2=figure;
surf(PlotX,PlotY,PlotZDisplacement);
title('Absolut Maximum Displacement Value. Not Phase correct');
zlabel('Displacement in m');
xlabel('X in �m');
ylabel('Y in �m');
savefig(fnamepathGraphDisp)

handles.fig.f3=figure;
surf(PlotX,PlotY,PlotZVelocity);
title('Absolut Maximum Velocity Value. Not Phase correct');
zlabel('Velocity in m/s');
xlabel('X in �m');
ylabel('Y in �m');
savefig(fnamepathGraphPhase)

%plot the time dependend values
axes(handles.axes1)
handles.s1 = surf(handles.axes1,PlotX,PlotY,PlotZ_t{1,1}.Velocity,'EdgeColor','none');
zlim([velMIN velMAX]);
caxis([velMIN velMAX]);
title('Surface velocity of the transducer');
zlabel('Velocity in m/s');
xlabel('X in �m');
ylabel('Y in �m');

for i=1:length(PlotZ_t{1,1}.Velocity)
        handles.s1.ZData = PlotZ_t{i,1}.Velocity;
        caxis manual
        axis manual %Keep the current axis limits by setting the limits mode to manual.
        pause(0.005);
end

axes(handles.axes4)
handles.s2 = surf(handles.axes4,PlotX,PlotY,PlotZ_t{1,1}.Displacement,'EdgeColor','none');
zlim([displMIN displMAX]);
caxis([displMIN displMAX]);
title('Surface displacement of the transducer');
zlabel('Displacement in m');
xlabel('X in �m');
ylabel('Y in �m');

for i=1:length(PlotZ_t{1,1}.Displacement)
        handles.s2.ZData = PlotZ_t{i,1}.Displacement;
        caxis manual
        axis manual %Keep the current axis limits by setting the limits mode to manual.
        pause(0.005);
end
% Save the change you made to the structure
guidata(hObject,handles);
set(handles.ShowPlot,'ENABLE','on')

% --- Executes on slider movement.
function timeSlide_Callback(hObject, eventdata, handles)
% hObject    handle to timeSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
timepos=round(get(hObject,'Value'));
if timepos>length(handles.PlotValues.PlotZ_t); timepos=length(handles.PlotValues.PlotZ_t); end
 handles.s1.ZData = handles.PlotValues.PlotZ_t{timepos,1}.Velocity;
 handles.s2.ZData = handles.PlotValues.PlotZ_t{timepos,1}.Displacement;
axis manual %Keep the current axis limits by setting the limits mode to manual.


% --- Executes during object creation, after setting all properties.
function timeSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in ShowPlot.
function ShowPlot_Callback(hObject, eventdata, handles)
% hObject    handle to ShowPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%replay the plots
PlotZ_t=handles.PlotValues.PlotZ_t;
for i=1:length(PlotZ_t)
        set(handles.timeSlide,'Value',i);
        handles.s1.ZData = handles.PlotValues.PlotZ_t{i,1}.Velocity;
        handles.s2.ZData = handles.PlotValues.PlotZ_t{i,1}.Displacement;
        axis manual %Keep the current axis limits by setting the limits mode to manual.
        pause(0.005);
end


% for i=1:length(PlotZ_t)
%         
%         axis manual %Keep the current axis limits by setting the limits mode to manual.
%         pause(0.05);
% end
assignin('base','PlotZ_t',PlotZ_t)

% --- Executes on button press in WebcamON.
function WebcamON_Callback(hObject, eventdata, handles)
% hObject    handle to WebcamON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    handles.cam=webcam;
    axes(handles.axesImage); 
    set(handles.AbortWebcam,'UserData',0);
    set(handles.AbortWebcam,'ENABLE','on');
    while  ~get(handles.AbortWebcam,'UserData')==1 
        img = snapshot(handles.cam);
        axes(handles.axesImage);
        image(img);
        pause(.05)
    end
    delete(handles.cam);
catch exceptions
    uiwait(msgbox('No device detected'));
end


% --- Executes on button press in AbortWebcam.
function AbortWebcam_Callback(hObject, eventdata, handles)
% hObject    handle to AbortWebcam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.AbortWebcam,'UserData',1);
set(handles.AbortWebcam,'ENABLE','off');


% --- Executes on button press in LoadMeasValues.
function LoadMeasValues_Callback(hObject, eventdata, handles)
% hObject    handle to LoadMeasValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname pname] = uigetfile('MeasurementValues.mat','Select the Measurement Values to load');
handlesSAVE=SaveANDGreyOut(handles); %'halt interface'

if isfield(handles.Settings, 'Path') %path is not set. use the one from the data
    if ~isfield(handles.Settings.Path, 'WorkDir')
        handles.Settings.Path.WorkDir=pname;
    end
else
    handles.Settings.Path.WorkDir=pname;
end
try 
    Values = load([pname fname]); 
    cellName=fieldnames(Values);%get the name of the data.. somtimes the old versions were called differently
    handles.Settings.Measurement.MeasureStructur=Values.(cellName{1});
catch
    RestoreGreyOut(handlesSAVE,handles); %'resume interface'
    return
end
% Save the change you made to the structure
guidata(hObject,handles);
RestoreGreyOut(handlesSAVE,handles); %'resume interface'
set(handles.EvaluateResults,'ENABLE','on');



function ScanAreaNumSteps_Callback(hObject, eventdata, handles)
% hObject    handle to ScanAreaNumSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScanAreaNumSteps as text
%        str2double(get(hObject,'String')) returns contents of ScanAreaNumSteps as a double
set(hObject,'String',round(str2double(strrep(get(hObject,'String'),',','.')))); %set , to . and round to integer

AreaType = handles.ScanAreaType.String{handles.ScanAreaType.Value,1};
NumSteps=str2double(handles.ScanAreaNumSteps.String);
ScanAreaWidth=str2double(handles.ScanAreaWidth.String);

handles.ScanAreaStepsize.String=num2str(ceil(ScanAreaWidth/(NumSteps-1)));
if strcmp(AreaType,'Square')
    handles.MeasPointsNumber.String=num2str(NumSteps^2);
elseif strcmp(AreaType,'Circle')
    handles.MeasPointsNumber.String=num2str(ceil(pi*(NumSteps/2)^2)); %according to the gau�-circle-problem 
elseif strcmp(AreaType,'Point')
    handles.MeasPointsNumber.String=num2str(1);
else
    handles.MeasPointsNumber.String=num2str(NumSteps);
end
% Save the change you made to the structure
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ScanAreaNumSteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanAreaNumSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu15.
function popupmenu15_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu15 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu15


% --- Executes during object creation, after setting all properties.
function popupmenu15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton17.
function radiobutton17_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton17


% --- Executes on button press in radiobutton18.
function radiobutton18_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton18



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu16.
function popupmenu16_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu16 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu16


% --- Executes during object creation, after setting all properties.
function popupmenu16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu17.
function popupmenu17_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu17 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu17


% --- Executes during object creation, after setting all properties.
function popupmenu17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu18.
function popupmenu18_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu18 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu18


% --- Executes during object creation, after setting all properties.
function popupmenu18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu19.
function popupmenu19_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu19 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu19


% --- Executes during object creation, after setting all properties.
function popupmenu19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11
