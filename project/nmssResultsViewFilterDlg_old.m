function varargout = nmssResultsViewFilterDlg(varargin)
% NMSSRESULTSVIEWFILTERDLG M-file for nmssResultsViewFilterDlg.fig
%      NMSSRESULTSVIEWFILTERDLG, by itself, creates a new NMSSRESULTSVIEWFILTERDLG or raises the existing
%      singleton*.
%
%      H = NMSSRESULTSVIEWFILTERDLG returns the handle to a new NMSSRESULTSVIEWFILTERDLG or the handle to
%      the existing singleton*.
%
%      NMSSRESULTSVIEWFILTERDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSRESULTSVIEWFILTERDLG.M with the given input arguments.
%
%      NMSSRESULTSVIEWFILTERDLG('Property','Value',...) creates a new NMSSRESULTSVIEWFILTERDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssResultsViewFilterDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssResultsViewFilterDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssResultsViewFilterDlg

% Last Modified by GUIDE v2.5 06-Dec-2009 16:12:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssResultsViewFilterDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssResultsViewFilterDlg_OutputFcn, ...
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


% --- Executes just before nmssResultsViewFilterDlg is made visible.
function nmssResultsViewFilterDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssResultsViewFilterDlg (see VARARGIN)

% Choose default command line output for nmssResultsViewFilterDlg
handles.output = hObject;

    global nmssResultsViewFilterDlg_Data;
    
    % checkbox for peaks with FWHM
    set(handles.checkboxShowOnlyPeaks, 'Value', nmssResultsViewFilterDlg_Data.filter.show_only_peaks);
    
    % checkbox for max intensity filtering
    set(handles.checkboxMaxIntRange, 'Value', nmssResultsViewFilterDlg_Data.filter.filter_intensity_range);
    checkboxMaxIntRange_Callback(handles.checkboxMaxIntRange, eventdata, handles);
    set(handles.editMinIntensity, 'String', num2str(nmssResultsViewFilterDlg_Data.filter.min_int));
    set(handles.editMaxIntensity, 'String', num2str(nmssResultsViewFilterDlg_Data.filter.max_int));
    
    % checkbox for the number of peaks
    % init variable if they were not initialized yet
    if (~isfield(nmssResultsViewFilterDlg_Data.filter, 'cb_num_of_peaks'))
        nmssResultsViewFilterDlg_Data.filter.cb_num_of_peaks = 0;
    end
    if (~isfield(nmssResultsViewFilterDlg_Data.filter, 'min_num_of_peaks'))
        nmssResultsViewFilterDlg_Data.filter.min_num_of_peaks = 1;
    end
    if (~isfield(nmssResultsViewFilterDlg_Data.filter, 'max_num_of_peaks'))
        nmssResultsViewFilterDlg_Data.filter.max_num_of_peaks = inf;
    end
    set(handles.cbNumOfPeaks, 'Value', nmssResultsViewFilterDlg_Data.filter.cb_num_of_peaks);
    set(handles.editMinNumOfPeaks, 'String', num2str(nmssResultsViewFilterDlg_Data.filter.min_num_of_peaks));
    set(handles.editMaxNumOfPeaks, 'String', num2str(nmssResultsViewFilterDlg_Data.filter.max_num_of_peaks));
    cbNumOfPeaks_Callback(handles.cbNumOfPeaks, eventdata, handles);
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssResultsViewFilterDlg wait for user response (see UIRESUME)
% uiwait(handles.nmssResultsViewFilterDlg);


% --- Outputs from this function are returned to the command line.
function varargout = nmssResultsViewFilterDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in obOK.
function obOK_Callback(hObject, eventdata, handles)
% hObject    handle to obOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssResultsViewFilterDlg_Data;
    nmssResultsViewFilterDlg_Data.user_clicked_OK = 1;
    
    % validate edit field entries
    if (~nmssValidateNumericEdit(handles.editMinIntensity, 'Lower end of Max Intensity Range'))
        return;
    end
    if (~nmssValidateNumericEdit(handles.editMaxIntensity, 'Upper end of Max Intensity Range'))
        return;
    end
    
    % save edit field value in corresponding variables
    nmssResultsViewFilterDlg_Data.filter.min_int = str2num(get(handles.editMinIntensity, 'String'));
    nmssResultsViewFilterDlg_Data.filter.max_int = str2num(get(handles.editMaxIntensity, 'String'));
   
    
    % validate edit field entries
    if (~nmssValidateNumericEdit(handles.editMinNumOfPeaks, 'Min number of peaks'))
        return;
    end
    if (~nmssValidateNumericEdit(handles.editMaxNumOfPeaks, 'Max number of peaks'))
        return;
    end
    if (nmssResultsViewFilterDlg_Data.filter.cb_num_of_peaks == 1)
        min_num = str2num(get(handles.editMinNumOfPeaks, 'String'));
        nmssResultsViewFilterDlg_Data.filter.min_num_of_peaks = min_num;
        max_num = str2num(get(handles.editMaxNumOfPeaks, 'String'));
        nmssResultsViewFilterDlg_Data.filter.max_num_of_peaks = max_num;
    end

    

    nmssResultsViewFilterDlg_CloseRequestFcn(handles.nmssResultsViewFilterDlg, eventdata, handles);
        
% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssResultsViewFilterDlg_Data;
    nmssResultsViewFilterDlg_Data.user_clicked_OK = 0;

    nmssResultsViewFilterDlg_CloseRequestFcn(handles.nmssResultsViewFilterDlg, eventdata, handles);

% --- Executes on button press in checkboxShowOnlyPeaks.
function checkboxShowOnlyPeaks_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowOnlyPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxShowOnlyPeaks
    global nmssResultsViewFilterDlg_Data;
    if (get(hObject,'Value') == 1)
        nmssResultsViewFilterDlg_Data.filter.show_only_peaks = 1;
    else
        nmssResultsViewFilterDlg_Data.filter.show_only_peaks = 0;
    end

    
% --- Executes when user attempts to close nmssResultsViewFilterDlg.
function nmssResultsViewFilterDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssResultsViewFilterDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);




% --- Executes on button press in checkboxMaxIntRange.
function checkboxMaxIntRange_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxMaxIntRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxMaxIntRange
    global nmssResultsViewFilterDlg_Data;
    if (get(hObject,'Value') == 1)
        set(handles.editMinIntensity, 'Enable', 'on');
        set(handles.editMaxIntensity, 'Enable', 'on');
        set(handles.pbGetMaxInt, 'Enable', 'on');
        nmssResultsViewFilterDlg_Data.filter.filter_intensity_range = 1;
    else
        set(handles.editMinIntensity, 'Enable', 'off');
        set(handles.editMaxIntensity, 'Enable', 'off');
        set(handles.pbGetMaxInt, 'Enable', 'off');
        nmssResultsViewFilterDlg_Data.filter.filter_intensity_range = 0;
    end


function editMinIntensity_Callback(hObject, eventdata, handles)
% hObject    handle to editMinIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMinIntensity as text
%        str2double(get(hObject,'String')) returns contents of editMinIntensity as a double


% --- Executes during object creation, after setting all properties.
function editMinIntensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMinIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editMaxIntensity_Callback(hObject, eventdata, handles)
% hObject    handle to editMaxIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaxIntensity as text
%        str2double(get(hObject,'String')) returns contents of editMaxIntensity as a double


% --- Executes during object creation, after setting all properties.
function editMaxIntensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaxIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in pbGetMaxInt.
function pbGetMaxInt_Callback(hObject, eventdata, handles)
% hObject    handle to pbGetMaxInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    
    



% --- Executes on button press in checkboxSelectedRegion.
function checkboxSelectedRegion_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSelectedRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSelectedRegion
    global nmssResultsViewFilterDlg_Data;
    if (get(hObject,'Value') == 1)
        set(handles.editImageROI_topleft_x, 'Enable', 'on');
        set(handles.editImageROI_topleft_y, 'Enable', 'on');
        set(handles.editImageROI_bottomright_x, 'Enable', 'on');
        set(handles.editImageROI_bottomright_y, 'Enable', 'on');
        set(handles.pbShowRealSpaceImage, 'Enable', 'on');
        set(handles.pbMouse, 'Enable', 'on');
        %nmssResultsViewFilterDlg_Data.filter.filter_intensity_range = 1;
    else
        set(handles.editImageROI_topleft_x, 'Enable', 'off');
        set(handles.editImageROI_topleft_y, 'Enable', 'off');
        set(handles.editImageROI_bottomright_x, 'Enable', 'off');
        set(handles.editImageROI_bottomright_y, 'Enable', 'off');
        set(handles.pbShowRealSpaceImage, 'Enable', 'off');
        set(handles.pbMouse, 'Enable', 'off');
        %nmssResultsViewFilterDlg_Data.filter.filter_intensity_range = 0;
    end



function editImageROI_topleft_x_Callback(hObject, eventdata, handles)
% hObject    handle to editImageROI_topleft_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editImageROI_topleft_x as text
%        str2double(get(hObject,'String')) returns contents of editImageROI_topleft_x as a double


% --- Executes during object creation, after setting all properties.
function editImageROI_topleft_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editImageROI_topleft_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editImageROI_topleft_y_Callback(hObject, eventdata, handles)
% hObject    handle to editImageROI_topleft_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editImageROI_topleft_y as text
%        str2double(get(hObject,'String')) returns contents of editImageROI_topleft_y as a double


% --- Executes during object creation, after setting all properties.
function editImageROI_topleft_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editImageROI_topleft_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editImageROI_bottomright_x_Callback(hObject, eventdata, handles)
% hObject    handle to editImageROI_bottomright_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editImageROI_bottomright_x as text
%        str2double(get(hObject,'String')) returns contents of editImageROI_bottomright_x as a double


% --- Executes during object creation, after setting all properties.
function editImageROI_bottomright_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editImageROI_bottomright_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in pbShowRealSpaceImage.
function pbShowRealSpaceImage_Callback(hObject, eventdata, handles)
% hObject    handle to pbShowRealSpaceImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssResultsViewFilterDlg_Data;
    
    real_space_image = nmssResultsViewFilterDlg_Data.results.real_space_image;

    real_image_figure_handle = figure;
    colormap gray;
    brighten(0.6);
    % display real space image scaled to its physical coordinates
    imagesc([real_space_image.x_min, real_space_image.x_max], ...
            [real_space_image.y_min, real_space_image.y_max], ...
             real_space_image.data);

    
    hold on;



% --- Executes on button press in pbMouse.
function pbMouse_Callback(hObject, eventdata, handles)
% hObject    handle to pbMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in cbNumOfPeaks.
function cbNumOfPeaks_Callback(hObject, eventdata, handles)
% hObject    handle to cbNumOfPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbNumOfPeaks

    global nmssResultsViewFilterDlg_Data;
    if (get(hObject,'Value') == 1)
        set(handles.editMinNumOfPeaks, 'Enable', 'on');
        set(handles.editMaxNumOfPeaks, 'Enable', 'on');
        set(handles.textMinNumOfPeaks, 'Enable', 'on');
        set(handles.textMaxNumOfPeaks, 'Enable', 'on');
        nmssResultsViewFilterDlg_Data.filter.cb_num_of_peaks = 1;
    else
        nmssResultsViewFilterDlg_Data.filter.cb_num_of_peaks = 0;
        set(handles.editMinNumOfPeaks, 'Enable', 'off');
        set(handles.editMaxNumOfPeaks, 'Enable', 'off');
        set(handles.textMinNumOfPeaks, 'Enable', 'off');
        set(handles.textMaxNumOfPeaks, 'Enable', 'off');
    end


function editMinNumOfPeaks_Callback(hObject, eventdata, handles)
% hObject    handle to editMinNumOfPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMinNumOfPeaks as text
%        str2double(get(hObject,'String')) returns contents of editMinNumOfPeaks as a double


% --- Executes during object creation, after setting all properties.
function editMinNumOfPeaks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMinNumOfPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editMaxNumOfPeaks_Callback(hObject, eventdata, handles)
% hObject    handle to editMaxNumOfPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaxNumOfPeaks as text
%        str2double(get(hObject,'String')) returns contents of editMaxNumOfPeaks as a double


% --- Executes during object creation, after setting all properties.
function editMaxNumOfPeaks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaxNumOfPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


