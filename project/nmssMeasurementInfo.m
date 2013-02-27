function varargout = nmssMeasurementInfo(varargin)
% NMSSMEASUREMENTINFO M-file for nmssMeasurementInfo.fig
%      NMSSMEASUREMENTINFO, by itself, creates a new NMSSMEASUREMENTINFO or raises the existing
%      singleton*.
%
%      H = NMSSMEASUREMENTINFO returns the handle to a new NMSSMEASUREMENTINFO or the handle to
%      the existing singleton*.
%
%      NMSSMEASUREMENTINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSMEASUREMENTINFO.M with the given input arguments.
%
%      NMSSMEASUREMENTINFO('Property','Value',...) creates a new NMSSMEASUREMENTINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssMeasurementInfo_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssMeasurementInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssMeasurementInfo

% Last Modified by GUIDE v2.5 22-Apr-2008 21:24:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssMeasurementInfo_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssMeasurementInfo_OutputFcn, ...
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


% --- Executes just before nmssMeasurementInfo is made visible.
function nmssMeasurementInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssMeasurementInfo (see VARARGIN)

% Choose default command line output for nmssMeasurementInfo
handles.output = hObject;

    % modal 'move stage dialog' (user can only intereact with this dialog)
    set(hObject,'WindowStyle','modal');

    global doc;
    global app;

    set(handles.editProject, 'String', '');
    set(handles.editSample, 'String', '');
    set(handles.editMedium, 'String', '');
    set(handles.editRemarks, 'String', '');
    set(handles.cbIRFilterUsed, 'Value', 0);
    if (isfield(doc, 'measurement_info'))
        set(handles.editProject, 'String', doc.measurement_info.project);
        set(handles.editSample, 'String', doc.measurement_info.sample);
        set(handles.editMedium, 'String', doc.measurement_info.medium);
        set(handles.editRemarks, 'String', doc.measurement_info.remarks);
        set(handles.cbIRFilterUsed, 'Value', doc.measurement_info.ir_filter_used);
%         set(handles.pmObjective, 'Value', 1);
%         set(handles.pmObjective, 'String', app.objective(1));
    elseif (isfield(doc, 'project_description'))
        set(handles.editRemarks, 'String', doc.project_description);
    end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssMeasurementInfo wait for user response (see UIRESUME)
% uiwait(handles.nmssMeasurementInfoDlg);


% --- Outputs from this function are returned to the command line.
function varargout = nmssMeasurementInfo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in cbIRFilterUsed.
function cbIRFilterUsed_Callback(hObject, eventdata, handles)
% hObject    handle to cbIRFilterUsed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbIRFilterUsed




function editMedium_Callback(hObject, eventdata, handles)
% hObject    handle to editMedium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMedium as text
%        str2double(get(hObject,'String')) returns contents of editMedium as a double


% --- Executes during object creation, after setting all properties.
function editMedium_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMedium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editRemarks_Callback(hObject, eventdata, handles)
% hObject    handle to editRemarks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRemarks as text
%        str2double(get(hObject,'String')) returns contents of editRemarks as a double


% --- Executes during object creation, after setting all properties.
function editRemarks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRemarks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssMeasurementInfoDlg_CloseRequestFcn(handles.nmssMeasurementInfoDlg, eventdata, handles);


% --- Executes on button press in buttonOK.
function buttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to buttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    
    doc.measurement_info.project = get(handles.editProject, 'String');
    doc.measurement_info.sample = get(handles.editSample, 'String');
    doc.measurement_info.medium = get(handles.editMedium, 'String');
    doc.measurement_info.remarks = get(handles.editRemarks, 'String');
    doc.measurement_info.ir_filter_used = get(handles.cbIRFilterUsed, 'Value');
    
    nmssMeasurementInfoDlg_CloseRequestFcn(handles.nmssMeasurementInfoDlg, eventdata, handles);



% --- Executes when user attempts to close nmssMeasurementInfoDlg.
function nmssMeasurementInfoDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssMeasurementInfoDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


function editProject_Callback(hObject, eventdata, handles)
% hObject    handle to editProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editProject as text
%        str2double(get(hObject,'String')) returns contents of editProject as a double



function editSample_Callback(hObject, eventdata, handles)
% hObject    handle to editSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSample as text
%        str2double(get(hObject,'String')) returns contents of editSample as a double


% --- Executes during object creation, after setting all properties.
function editProject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes during object creation, after setting all properties.
function editSample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on selection change in pmObjective.
function pmObjective_Callback(hObject, eventdata, handles)
% hObject    handle to pmObjective (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pmObjective contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmObjective


% --- Executes during object creation, after setting all properties.
function pmObjective_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmObjective (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


