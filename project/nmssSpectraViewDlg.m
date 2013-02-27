function varargout = nmssSpectraViewDlg(varargin)
% NMSSSPECTRAVIEWDLG M-file for nmssSpectraViewDlg.fig
%      NMSSSPECTRAVIEWDLG, by itself, creates a new NMSSSPECTRAVIEWDLG or raises the existing
%      singleton*.
%
%      H = NMSSSPECTRAVIEWDLG returns the handle to a new NMSSSPECTRAVIEWDLG or the handle to
%      the existing singleton*.
%
%      NMSSSPECTRAVIEWDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSSPECTRAVIEWDLG.M with the given input arguments.
%
%      NMSSSPECTRAVIEWDLG('Property','Value',...) creates a new NMSSSPECTRAVIEWDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssSpectraViewDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssSpectraViewDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssSpectraViewDlg

% Last Modified by GUIDE v2.5 30-Apr-2008 22:12:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssSpectraViewDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssSpectraViewDlg_OutputFcn, ...
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


% --- Executes just before nmssSpectraViewDlg is made visible.
function nmssSpectraViewDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssSpectraViewDlg (see VARARGIN)

% Choose default command line output for nmssSpectraViewDlg
handles.output = hObject;

    % modal 'move stage dialog' (user can only intereact with this dialog)
    set(hObject,'WindowStyle','modal');
    
    global nmssSpectraViewDlg_Data;
    set(handles.editParticleIndex , 'String', num2str(nmssSpectraViewDlg_Data.index));
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssSpectraViewDlg wait for user response (see UIRESUME)
% uiwait(handles.nmssSpectraViewDlg);


% --- Outputs from this function are returned to the command line.
function varargout = nmssSpectraViewDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editParticleIndex_Callback(hObject, eventdata, handles)
% hObject    handle to editParticleIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editParticleIndex as text
%        str2double(get(hObject,'String')) returns contents of editParticleIndex as a double


% --- Executes during object creation, after setting all properties.
function editParticleIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParticleIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in btnOk.
function btnOk_Callback(hObject, eventdata, handles)
% hObject    handle to btnOk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if (~nmssValidateNumericEdit(handles.editParticleIndex, 'Particle #'))
        return;
    end
    
    index = get(handles.editParticleIndex, 'String');
    
    global nmssSpectraViewDlg_Data;
    nmssSpectraViewDlg_Data.index = floor(str2double(index));
    
    nmssSpectraViewDlg_CloseRequestFcn(handles.nmssSpectraViewDlg, eventdata, handles);    

% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssSpectraViewDlg_Data;
    nmssSpectraViewDlg_Data.index = 0;

    nmssSpectraViewDlg_CloseRequestFcn(handles.nmssSpectraViewDlg, eventdata, handles);

% --- Executes when user attempts to close nmssSpectraViewDlg.
function nmssSpectraViewDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssSpectraViewDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


