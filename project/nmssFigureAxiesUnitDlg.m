function varargout = nmssFigureAxiesUnitDlg(varargin)
% NMSSFIGUREAXIESUNITDLG M-file for nmssFigureAxiesUnitDlg.fig
%      NMSSFIGUREAXIESUNITDLG, by itself, creates a new NMSSFIGUREAXIESUNITDLG or raises the existing
%      singleton*.
%
%      H = NMSSFIGUREAXIESUNITDLG returns the handle to a new NMSSFIGUREAXIESUNITDLG or the handle to
%      the existing singleton*.
%
%      NMSSFIGUREAXIESUNITDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSFIGUREAXIESUNITDLG.M with the given input arguments.
%
%      NMSSFIGUREAXIESUNITDLG('Property','Value',...) creates a new NMSSFIGUREAXIESUNITDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssFigureAxiesUnitDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssFigureAxiesUnitDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssFigureAxiesUnitDlg

% Last Modified by GUIDE v2.5 15-Nov-2007 19:10:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssFigureAxiesUnitDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssFigureAxiesUnitDlg_OutputFcn, ...
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


% --- Executes just before nmssFigureAxiesUnitDlg is made visible.
function nmssFigureAxiesUnitDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssFigureAxiesUnitDlg (see VARARGIN)

% Choose default command line output for nmssFigureAxiesUnitDlg
handles.output = hObject;


    % modal 'move stage dialog' (user can only intereact with this dialog)
    set(hObject,'WindowStyle','modal');
    
    global nmssFigureAxiesUnitDlg_Data;
    global doc;
    
    nmssFigureAxiesUnitDlg_Data.figure_axis = doc.figure_axis;
    
    % set radio buttons according to the current figure axis unit setting
    % we only use the x-axis, because this 
    set(handles.rbPixels, 'Value', 0);
    set(handles.rbMicrons, 'Value', 0);
    set(handles.rbNanoMeters, 'Value',0);
    set(handles.rbPixels, 'Value', 1);
    
    if (strcmp(doc.figure_axis.unit.x,'pixel'))
        set(handles.rbPixels, 'Value', 1);
    elseif (strcmp(doc.figure_axis.unit.x,'micron'))
        set(handles.rbMicrons, 'Value', 1);
    else
        set(handles.rbNanoMeters, 'Value', 1);
    end
        
    % check the setting of the grating. if inequal to zero we are in
    % spectroscopy modus
    if(doc.current_job(1).central_wavelength > 0)
        set(handles.rbMicrons, 'Enable', 'off');
    else
        set(handles.rbNanoMeters, 'Enable', 'off');
    end
        
    


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssFigureAxiesUnitDlg wait for user response (see UIRESUME)
% uiwait(handles.nmssFigureAxiesUnitDlg);


% --- Outputs from this function are returned to the command line.
function varargout = nmssFigureAxiesUnitDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.nmssFigureAxiesUnitDlg;


% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssFigureAxiesUnitDlg_CloseRequestFcn(handles.nmssFigureAxiesUnitDlg, ...
        eventdata, handles);

% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global doc;
    global nmssFigureAxiesUnitDlg_Data;
    doc.figure_axis = nmssFigureAxiesUnitDlg_Data.figure_axis;
    
    nmssFigureAxiesUnitDlg_CloseRequestFcn(handles.nmssFigureAxiesUnitDlg, ...
        eventdata, handles);


% --- Executes on button press in rbMicrons.
function rbMicrons_Callback(hObject, eventdata, handles)
% hObject    handle to rbMicrons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbMicrons
    if(get(hObject,'Value'))
        global nmssFigureAxiesUnitDlg_Data;
        unit.x = 'micron';
        unit.y = 'micron';
        nmssFigureAxiesUnitDlg_Data.figure_axis = nmssSetAxis(unit);
    else
        % do not allow unkclicking the radiobutton
        set(hObject,'Value', 1);
    end

    
% --- Executes on button press in rbNanoMeters.
function rbNanoMeters_Callback(hObject, eventdata, handles)
% hObject    handle to rbNanoMeters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbNanoMeters
    if(get(hObject,'Value'))
        %global doc;
        global nmssFigureAxiesUnitDlg_Data;
        unit.x = 'nanometer';
        unit.y = 'pixel';
        nmssFigureAxiesUnitDlg_Data.figure_axis = nmssSetAxis(unit);
    else
        % do not allow unkclicking the radiobutton
        set(hObject,'Value', 1);
    end


% --- Executes on button press in rbPixels.
function rbPixels_Callback(hObject, eventdata, handles)
% hObject    handle to rbPixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbPixels
    if(get(hObject,'Value'))
        %global doc;
        global nmssFigureAxiesUnitDlg_Data;
        unit.x = 'pixel';
        unit.y = 'pixel';
        nmssFigureAxiesUnitDlg_Data.figure_axis = nmssSetAxis(unit);
    else
        % do not allow unkclicking the radiobutton
        set(hObject,'Value', 1);
    end




% --- Executes when user attempts to close nmssFigureAxiesUnitDlg.
function nmssFigureAxiesUnitDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssFigureAxiesUnitDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    clear nmssFigureAxiesUnitDlg_Data;

% Hint: delete(hObject) closes the figure
delete(hObject);




% --- Executes on button press in rbElectronVolt.
function rbElectronVolt_Callback(hObject, eventdata, handles)
% hObject    handle to rbElectronVolt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbElectronVolt
    if(get(hObject,'Value'))
        %global doc;
        global nmssFigureAxiesUnitDlg_Data;
        unit.x = 'eV';
        unit.y = 'eV';
        nmssFigureAxiesUnitDlg_Data.figure_axis = nmssSetAxis(unit);
    else
        % do not allow unkclicking the radiobutton
        set(hObject,'Value', 1);
    end


