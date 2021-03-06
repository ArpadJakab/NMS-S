function varargout = nmssZoomDlg(varargin)
% NMSSZOOMDLG M-file for nmssZoomDlg.fig
%      NMSSZOOMDLG, by itself, creates a new NMSSZOOMDLG or raises the existing
%      singleton*.
%
%      H = NMSSZOOMDLG returns the handle to a new NMSSZOOMDLG or the handle to
%      the existing singleton*.
%
%      NMSSZOOMDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSZOOMDLG.M with the given input arguments.
%
%      NMSSZOOMDLG('Property','Value',...) creates a new NMSSZOOMDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssZoomDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssZoomDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssZoomDlg

% Last Modified by GUIDE v2.5 29-Jan-2010 14:53:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssZoomDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssZoomDlg_OutputFcn, ...
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


% --- Executes just before nmssZoomDlg is made visible.
function nmssZoomDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssZoomDlg (see VARARGIN)

% Choose default command line output for nmssZoomDlg
handles.output = hObject;

    global nmssZoomDlg_Data;

    set(handles.editTopX, 'String', num2str(nmssZoomDlg_Data.topX));
    set(handles.editTopY, 'String', num2str(nmssZoomDlg_Data.topY));
    set(handles.editBottomX, 'String', num2str(nmssZoomDlg_Data.bottomX));
    set(handles.editBottomY, 'String', num2str(nmssZoomDlg_Data.bottomY));
    

    set(hObject, 'WindowStyle', 'modal');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssZoomDlg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nmssZoomDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editBottomY_Callback(hObject, eventdata, handles)
% hObject    handle to editBottomY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBottomY as text
%        str2double(get(hObject,'String')) returns contents of editBottomY as a double


% --- Executes during object creation, after setting all properties.
function editBottomY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBottomY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global app;
    global nmssZoomDlg_Data;
    
    % get data from the edit fields
    topX = str2num(get(handles.editTopX, 'String'))
    topY = str2num(get(handles.editTopY, 'String'));
    bottomX = str2num(get(handles.editBottomX, 'String'));
    bottomY = str2num(get(handles.editBottomY, 'String'));
    
    % get axis limits and store in zoom
    hAxes = findobj(app.nmssFigure, 'Type', 'axes');
    
    if (ishandle(hAxes))
        xlim(hAxes, [topX, bottomX]);
        ylim(hAxes, [topY, bottomY]);
        zoom(app.nmssFigure, 'reset');
    end
    
    
    
    nmssZoomDlg_CloseRequestFcn(handles.nmssZoomDlg, eventdata, handles);



% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssZoomDlg_CloseRequestFcn(handles.nmssZoomDlg, eventdata, handles);


% --- Executes when user attempts to close nmssZoomDlg.
function nmssZoomDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssZoomDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);




% --- Executes on button press in btnResetX.
function btnResetX_Callback(hObject, eventdata, handles)
% hObject    handle to btnResetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    
    unit = doc.figure_axis.unit;

    full_limits = nmssGetFullImageLimits(unit);
    
    set(handles.editTopX, 'String', num2str(full_limits.x(1)));
    set(handles.editBottomX, 'String', num2str(full_limits.x(2)));




% --- Executes on button press in btnResetY.
function btnResetY_Callback(hObject, eventdata, handles)
% hObject    handle to btnResetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global doc;
    
    unit = doc.figure_axis.unit;

    full_limits = nmssGetFullImageLimits(unit);
    
    set(handles.editTopY, 'String', num2str(full_limits.y(1)));
    set(handles.editBottomY, 'String', num2str(full_limits.y(2)));


