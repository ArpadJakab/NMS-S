function varargout = nmssInputROIDlg(varargin)
% NMSSINPUTROIDLG M-file for nmssInputROIDlg.fig
%      NMSSINPUTROIDLG, by itself, creates a new NMSSINPUTROIDLG or raises the existing
%      singleton*.
%
%      H = NMSSINPUTROIDLG returns the handle to a new NMSSINPUTROIDLG or the handle to
%      the existing singleton*.
%
%      NMSSINPUTROIDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSINPUTROIDLG.M with the given input arguments.
%
%      NMSSINPUTROIDLG('Property','Value',...) creates a new NMSSINPUTROIDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssInputROIDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssInputROIDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssInputROIDlg

% Last Modified by GUIDE v2.5 04-Mar-2009 15:07:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssInputROIDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssInputROIDlg_OutputFcn, ...
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


% --- Executes just before nmssInputROIDlg is made visible.
function nmssInputROIDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to nmssInputROIDlg (see VARARGIN)

    % Choose default command line output for nmssInputROIDlg
    handles.output = hObject;


    global nmssInputROIDlg_Data;

    set(handles.editROI_x, 'String', num2str(nmssInputROIDlg_Data.ROI_x));
    set(handles.editROI_y, 'String', num2str(nmssInputROIDlg_Data.ROI_y));
    set(handles.editROI_wx, 'String', num2str(nmssInputROIDlg_Data.ROI_wx));
    set(handles.editROI_wy, 'String', num2str(nmssInputROIDlg_Data.ROI_wy));


    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes nmssInputROIDlg wait for user response (see UIRESUME)
    % uiwait(handles.nmssInputROIDlg);


% --- Outputs from this function are returned to the command line.
function varargout = nmssInputROIDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editROI_x_Callback(hObject, eventdata, handles)
% hObject    handle to editROI_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editROI_x as text
%        str2double(get(hObject,'String')) returns contents of editROI_x as a double


% --- Executes during object creation, after setting all properties.
function editROI_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editROI_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editROI_y_Callback(hObject, eventdata, handles)
% hObject    handle to editROI_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editROI_y as text
%        str2double(get(hObject,'String')) returns contents of editROI_y as a double


% --- Executes during object creation, after setting all properties.
function editROI_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editROI_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editROI_wx_Callback(hObject, eventdata, handles)
% hObject    handle to editROI_wx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editROI_wx as text
%        str2double(get(hObject,'String')) returns contents of editROI_wx as a double


% --- Executes during object creation, after setting all properties.
function editROI_wx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editROI_wx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editROI_wy_Callback(hObject, eventdata, handles)
% hObject    handle to editROI_wy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editROI_wy as text
%        str2double(get(hObject,'String')) returns contents of editROI_wy as a double


% --- Executes during object creation, after setting all properties.
function editROI_wy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editROI_wy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssInputROIDlg_CloseRequestFcn(handles.nmssInputROIDlg, eventdata, handles);

% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global nmssInputROIDlg_Data;

    if (nmssValidateNumericEdit(handles.editROI_x, 'ROI Definition x'))
        nmssInputROIDlg_Data.ROI_x = str2num(get(handles.editROI_x, 'String'));
    end
    if (nmssValidateNumericEdit(handles.editROI_y, 'ROI Definition y'))
        nmssInputROIDlg_Data.ROI_y = str2num(get(handles.editROI_y, 'String'));
    end
    if (nmssValidateNumericEdit(handles.editROI_wx, 'ROI Definition wx'))
        nmssInputROIDlg_Data.ROI_wx = str2num(get(handles.editROI_wx, 'String'));
    end
    if (nmssValidateNumericEdit(handles.editROI_wy, 'ROI Definition wy'))
        nmssInputROIDlg_Data.ROI_wy = str2num(get(handles.editROI_wy, 'String'));
    end

    nmssInputROIDlg_CloseRequestFcn(handles.nmssInputROIDlg, eventdata, handles);


% --- Executes when user attempts to close nmssInputROIDlg.
function nmssInputROIDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssInputROIDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


