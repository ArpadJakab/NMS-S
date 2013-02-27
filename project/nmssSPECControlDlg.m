function varargout = nmssSPECControlDlg(varargin)
% NMSSSPECCONTROLDLG M-file for nmssSPECControlDlg.fig
%      NMSSSPECCONTROLDLG, by itself, creates a new NMSSSPECCONTROLDLG or raises the existing
%      singleton*.
%
%      H = NMSSSPECCONTROLDLG returns the handle to a new NMSSSPECCONTROLDLG or the handle to
%      the existing singleton*.
%
%      NMSSSPECCONTROLDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSSPECCONTROLDLG.M with the given input arguments.
%
%      NMSSSPECCONTROLDLG('Property','Value',...) creates a new NMSSSPECCONTROLDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssSPECControlDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssSPECControlDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssSPECControlDlg

% Last Modified by GUIDE v2.5 05-Sep-2007 18:22:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssSPECControlDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssSPECControlDlg_OutputFcn, ...
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


% --- Executes just before nmssSPECControlDlg is made visible.
function nmssSPECControlDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssSPECControlDlg (see VARARGIN)

    % Choose default command line output for nmssSPECControlDlg
    handles.output = hObject;
    
    % modal 'move stage dialog' (user can only intereact with this dialog)
    set(hObject,'WindowStyle','modal');

    % Initialize GUI
    global doc;
    set(handles.textSPECControlDlg_Name, 'String', doc.specinfo.Name);
    set(handles.cxSPECControlDlg_GratingSelect, 'String', doc.specinfo.ListOfGratings(:, 2) );    
    set(handles.cxSPECControlDlg_GratingSelect, 'Value', doc.specinfo.CurrentGratingIndex );
    set(handles.editSPECControlDlg_CentralWavelength, 'String', num2str(doc.specinfo.CurrentWavelength , '%4.1f'));
    
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes nmssSPECControlDlg wait for user response (see UIRESUME)
    % uiwait(handles.nmssSPECControlDlg);


% --- Outputs from this function are returned to the command line.
function varargout = nmssSPECControlDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.nmssSPECControlDlg;



% --- Executes on selection change in cxSPECControlDlg_GratingSelect.
function cxSPECControlDlg_GratingSelect_Callback(hObject, eventdata, handles)
% hObject    handle to cxSPECControlDlg_GratingSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cxSPECControlDlg_GratingSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cxSPECControlDlg_GratingSelect


% --- Executes during object creation, after setting all properties.
function cxSPECControlDlg_GratingSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cxSPECControlDlg_GratingSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editSPECControlDlg_CentralWavelength_Callback(hObject, eventdata, handles)
% hObject    handle to editSPECControlDlg_CentralWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSPECControlDlg_CentralWavelength as text
%        str2double(get(hObject,'String')) returns contents of editSPECControlDlg_CentralWavelength as a double


% --- Executes during object creation, after setting all properties.
function editSPECControlDlg_CentralWavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSPECControlDlg_CentralWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in btnSPECControl_OK.
function btnSPECControl_OK_Callback(hObject, eventdata, handles)
% hObject    handle to btnSPECControl_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if (~nmssValidateNumericEdit(handles.editSPECControlDlg_CentralWavelength, 'Central Wavelength'))
        return;
    end
    
    target_grating_index = get(handles.cxSPECControlDlg_GratingSelect,'Value');
    target_wavelength = str2double(get(handles.editSPECControlDlg_CentralWavelength,'String'));
    global doc;
    global app;
    
    % set mouse cursor to busy (watch)
    set(handles.nmssSPECControlDlg,'Pointer','watch');

    h_waitbar = waitbar(0,'Please wait unitl the spectrograph is aligned!');
    
    % get grating number
    [status gratings] = nmssSPECGetListOfGratings(app.hSpectrograph);
    if (strcmp(status, 'ERROR')) 
        errordlg(gratings);
    else
        [status msg] = nmssSPECSetCurrentGrating(app.hSpectrograph, gratings(target_grating_index));
        if (strcmp(status, 'ERROR')) 
            errordlg(msg);
        end
    end

    % set center wavelength
    [status wavelength] = nmssSPECSetWavelength(app.hSpectrograph, target_wavelength);
    if (strcmp(status, 'ERROR')) 
        errordlg(wavelength);
    end;

    % update application variables
    doc.specinfo.CurrentGratingIndex = gratings(target_grating_index);
    doc.specinfo.CurrentWavelength = target_wavelength;
    
    handle_parent = findobj('Tag', 'nmssMainWindow');
    
    %handle_main_window = app.nmssMainWindow;
    %handles.parent = guidata(handle_main_window);
    parent_handles = guidata(handle_parent);
    
    set(parent_handles.editCurrentGrating, 'String', doc.specinfo.ListOfGratings{ doc.specinfo.CurrentGratingIndex, 2 });
    set(parent_handles.editSpecGraphWavelength, 'String', num2str( doc.specinfo.CurrentWavelength , '%4.1f'));
    
%     set(handles.parent.editCurrentGrating, 'String', doc.specinfo.ListOfGratings{ doc.specinfo.CurrentGratingIndex, 2 });
%     set(handles.parent.editSpecGraphWavelength, 'String', num2str( doc.specinfo.CurrentWavelength , '%4.1f'));
    
    % save data to the parent's application data
    %guidata(handle_main_window , handles.parent);
    
    % set mouse cursor to arrow
    set(handles.nmssSPECControlDlg,'Pointer','arrow');
    
    % closes waitbar
    delete(h_waitbar);
    

    nmssSPECControlDlg_CloseRequestFcn(handles.nmssSPECControlDlg, eventdata, handles)

    
    

% --- Executes on button press in btnSPECControl_Cancel.
function btnSPECControl_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnSPECControl_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssSPECControlDlg_CloseRequestFcn(handles.nmssSPECControlDlg, eventdata, handles)


% --- Executes when user attempts to close nmssSPECControlDlg.
function nmssSPECControlDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssSPECControlDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hint: delete(hObject) closes the figure
    delete(hObject);


