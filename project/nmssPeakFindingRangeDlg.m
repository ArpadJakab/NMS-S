% function varargout = nmssPeakFindingRangeDlg(varargin)
% % NMSSPEAKFINDINGRANGEDLG M-file for nmssPeakFindingRangeDlg.fig
% %      NMSSPEAKFINDINGRANGEDLG, by itself, creates a new NMSSPEAKFINDINGRANGEDLG or raises the existing
% %      singleton*.
% %
% %      H = NMSSPEAKFINDINGRANGEDLG returns the handle to a new NMSSPEAKFINDINGRANGEDLG or the handle to
% %      the existing singleton*.
% %
% %      NMSSPEAKFINDINGRANGEDLG('CALLBACK',hObject,eventData,handles,...) calls the local
% %      function named CALLBACK in NMSSPEAKFINDINGRANGEDLG.M with the given input arguments.
% %
% %      NMSSPEAKFINDINGRANGEDLG('Property','Value',...) creates a new NMSSPEAKFINDINGRANGEDLG or raises the
% %      existing singleton*.  Starting from the left, property value pairs are
% %      applied to the GUI before nmssPeakFindingRangeDlg_OpeningFunction gets called.  An
% %      unrecognized property name or invalid value makes property application
% %      stop.  All inputs are passed to nmssPeakFindingRangeDlg_OpeningFcn via varargin.
% %
% %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
% %      instance to run (singleton)".
% %
% % See also: GUIDE, GUIDATA, GUIHANDLES
% 
% % Copyright 2002-2003 The MathWorks, Inc.
% 
% % Edit the above text to modify the response to help nmssPeakFindingRangeDlg
% 
% % Last Modified by GUIDE v2.5 19-Nov-2009 12:29:41
% 
% % Begin initialization code - DO NOT EDIT
% gui_Singleton = 1;
% gui_State = struct('gui_Name',       mfilename, ...
%                    'gui_Singleton',  gui_Singleton, ...
%                    'gui_OpeningFcn', @nmssPeakFindingRangeDlg_OpeningFcn, ...
%                    'gui_OutputFcn',  @nmssPeakFindingRangeDlg_OutputFcn, ...
%                    'gui_LayoutFcn',  [] , ...
%                    'gui_Callback',   []);
% if nargin && ischar(varargin{1})
%     gui_State.gui_Callback = str2func(varargin{1});
% end
% 
% if nargout
%     [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
% else
%     gui_mainfcn(gui_State, varargin{:});
% end
% % End initialization code - DO NOT EDIT
% 
% 
% % --- Executes just before nmssPeakFindingRangeDlg is made visible.
% function nmssPeakFindingRangeDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% % This function has no output args, see OutputFcn.
% % hObject    handle to figure
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% % varargin   command line arguments to nmssPeakFindingRangeDlg (see VARARGIN)
% 
% % Choose default command line output for nmssPeakFindingRangeDlg
% handles.output = hObject;
% 
%     global nmssPeakFindingRangeDlg_Data;
%     
%     Update_GUIElements(handles);
% 
% %     set(handles.editPeakFindingRange_Start, 'String', ...
% %         num2str(nmssPeakFindingRangeDlg_Data.rangeStart));
% %     set(handles.editPeakFindingRange_End, 'String', ...
% %         num2str(nmssPeakFindingRangeDlg_Data.rangeEnd));
% %     
% %     set(handles.textPeakFindingRange_Start, 'String', ...
% %         nmssPeakFindingRangeDlg_Data.eV_or_nm);
% %     set(handles.textPeakFindingRange_End, 'String', ...
% %         nmssPeakFindingRangeDlg_Data.eV_or_nm);
% %     
%     
%     
% 
% % Update handles structure
% guidata(hObject, handles);
% 
% % UIWAIT makes nmssPeakFindingRangeDlg wait for user response (see UIRESUME)
% % uiwait(handles.figure1);
% 
% 
% % --- Outputs from this function are returned to the command line.
% function varargout = nmssPeakFindingRangeDlg_OutputFcn(hObject, eventdata, handles) 
% % varargout  cell array for returning output args (see VARARGOUT);
% % hObject    handle to figure
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Get default command line output from handles structure
% varargout{1} = handles.output;
% 
% 
% 
% function edit1_Callback(hObject, eventdata, handles)
% % hObject    handle to edit1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of edit1 as text
% %        str2double(get(hObject,'String')) returns contents of edit1 as a double
% 
% 
% % --- Executes during object creation, after setting all properties.
% function edit1_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to edit1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc
%     set(hObject,'BackgroundColor','white');
% else
%     set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
% end
% 
% 
% 
% function editPeakFindingRange_End_Callback(hObject, eventdata, handles)
% % hObject    handle to editPeakFindingRange_End (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of editPeakFindingRange_End as text
% %        str2double(get(hObject,'String')) returns contents of editPeakFindingRange_End as a double
%     
%     %valid = Validate_GUIElements(handles);
%     
%     
%     
% % checks if the conten of the peak finding range is valid    
% function valid = Validate_GUIElements(handles)
%     
%     global nmssCurveAnalysisDlg_Data;
%     global nmssPeakFindingRangeDlg_Data;
%     
%     valid = false;
%     
%     i = nmssCurveAnalysisDlg_Data.current_graph_index;
%     part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
%     p = nmssCurveAnalysisDlg_Data.particle(part_index);
%     x_axis = p.graph.axis.x;
%         
%     % the start of the range
%     hObject = handles.editPeakFindingRange_Start;
%     if (nmssValidateNumericEdit(hObject, 'Peak range start'))
%         s = str2num(get(hObject, 'String'));
%         start_limit = x_axis(1);
%         if (strcmp(nmssPeakFindingRangeDlg_Data.eV_or_nm, 'eV'))
%             start_limit = 1240 / x_axis(end);
%         end
%         if (s < start_limit)
%             uiwait(errordlg(['Please enter a number greater than ', num2str(start_limit)]));
%             uicontrol(hObject);
%             return;
%         end
%         
%         nmssPeakFindingRangeDlg_Data.rangeStart = s;
%     else
%         return;
%     end
%         
%     % the end of the range
%     hObject = handles.editPeakFindingRange_End;
%     if (nmssValidateNumericEdit(hObject, 'Peak range end'))
%         e = str2num(get(hObject, 'String'));
%         end_limit = x_axis(end);
%         if (strcmp(nmssPeakFindingRangeDlg_Data.eV_or_nm, 'eV'))
%             start_limit = 1240 / x_axis(1);
%         end
%         if (e > end_limit)
%             uiwait(errordlg(['Please enter a number smaller than ', num2str(end_limit)]));
%             uicontrol(hObject);
%             return;
%         end
%         
%         nmssPeakFindingRangeDlg_Data.rangeEnd = e;
%     else
%         return;
%     end
%     
%     valid = true;
% 
% % checks if the conten of the peak finding range is valid    
% function Update_GUIElements(handles)
%     
%     global nmssPeakFindingRangeDlg_Data;
%     
%         
%     % the start of the range
%     hObject = handles.editPeakFindingRange_Start;
%     set(hObject, 'String', num2str(nmssPeakFindingRangeDlg_Data.rangeStart));
%         
%     % the end of the range
%     hObject = handles.editPeakFindingRange_End;
%     set(hObject, 'String', num2str(nmssPeakFindingRangeDlg_Data.rangeEnd));
%     
%     set(handles.textPeakFindingRange_Start, 'String', ...
%         nmssPeakFindingRangeDlg_Data.eV_or_nm);
%     set(handles.textPeakFindingRange_End, 'String', ...
%         nmssPeakFindingRangeDlg_Data.eV_or_nm);
% 
% 
% 
% % --- Executes during object creation, after setting all properties.
% function editPeakFindingRange_End_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to editPeakFindingRange_End (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc
%     set(hObject,'BackgroundColor','white');
% else
%     set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
% end
% 
% 
% % --- Executes on button press in pbCancel.
% function pbCancel_Callback(hObject, eventdata, handles)
% % hObject    handle to pbCancel (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
%     nmssPeakFindingRangeDlg_CloseRequestFcn(handles.nmssPeakFindingRangeDlg, ...
%         eventdata, handles);
%     
% % --- Executes on button press in pbOK.
% function pbOK_Callback(hObject, eventdata, handles)
% % hObject    handle to pbOK (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
%     global nmssPeakFindingRangeDlg_Data;
%     
%     % 1 check if the entered data makes sense in itself
%     if (~Validate_GUIElements(handles))
%         return;
%     end
% 
%     % 2 check if the entered data makes sense in respect to each other
%     if (nmssPeakFindingRangeDlg_Data.rangeEnd <= nmssPeakFindingRangeDlg_Data.rangeStart)
%         uiwait(errordlg('Peak Range Start must be smaller than Peak Range End'));
%         uicontrol(handles.editPeakFindingRange_Start);
% 
%         return;
%     end
%     
%     
%     nmssPeakFindingRangeDlg_CloseRequestFcn(handles.nmssPeakFindingRangeDlg, ...
%         eventdata, handles);
%         
% 
% 
% % --- Executes when user attempts to close nmssPeakFindingRangeDlg.
% function nmssPeakFindingRangeDlg_CloseRequestFcn(hObject, eventdata, handles)
% % hObject    handle to nmssPeakFindingRangeDlg (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: delete(hObject) closes the figure
% delete(hObject);
% 
% 
% 
% 
% 
% function editPeakFindingRange_Start_Callback(hObject, eventdata, handles)
% % hObject    handle to editPeakFindingRange_Start (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of editPeakFindingRange_Start as text
% %        str2double(get(hObject,'String')) returns contents of editPeakFindingRange_Start as a double
% 
%     %valid = Validate_GUIElements(handles);
% 
% 
% 
% % --- Executes on button press in pbSetStartWithMouse.
% function pbSetStartWithMouse_Callback(hObject, eventdata, handles)
% % hObject    handle to pbSetStartWithMouse (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
%     global nmssCurveAnalysisDlg_Data;
%     global nmssPeakFindingRangeDlg_Data;
%     
%     % if zoom figure (and axes) is open then use that one
%     if (isfield(nmssCurveAnalysisDlg_Data, 'hZoomAxes'))
%         if (ishandle(nmssCurveAnalysisDlg_Data.hZoomAxes))
%             axes(nmssCurveAnalysisDlg_Data.hZoomAxes);
%             
%             hs = findobj(nmssCurveAnalysisDlg_Data.hZoomAxes, 'Tag', 'PeakFindingRange_Start_line');
%             delete(hs);
%             
%             [x,y] = ginput(1); % one mouse click on the current axes
%             
%             ylimits = ylim();
%             
%             
%             hs = line([x, x], [ylimits(1), ylimits(2)], ...
%                  'LineWidth', 2, 'Color', 'k', 'LineStyle', ':');
%             set(hs, 'Tag', 'PeakFindingRange_Start_line');
%              
%             nmssPeakFindingRangeDlg_Data.rangeStart = x;
%         end
%     end    
%     
%     Update_GUIElements(handles);
% 
% 
% % --- Executes on button press in pbSetEndWithMouse.
% function pbSetEndWithMouse_Callback(hObject, eventdata, handles)
% % hObject    handle to pbSetEndWithMouse (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
%     global nmssCurveAnalysisDlg_Data;
%     global nmssPeakFindingRangeDlg_Data;
%     
%     % if zoom figure (and axes) is open then use that one
%     if (isfield(nmssCurveAnalysisDlg_Data, 'hZoomAxes'))
%         if (ishandle(nmssCurveAnalysisDlg_Data.hZoomAxes))
%             axes(nmssCurveAnalysisDlg_Data.hZoomAxes);
%             
%             hs = findobj(nmssCurveAnalysisDlg_Data.hZoomAxes, 'Tag', 'PeakFindingRange_End_line');
%             delete(hs);
%             
%             [x,y] = ginput(1); % one mouse click on the current axes
%             
%             ylimits = ylim();
%             
%             
%             hs = line([x, x], [ylimits(1), ylimits(2)], ...
%                  'LineWidth', 2, 'Color', 'k', 'LineStyle', ':');
%             set(hs, 'Tag', 'PeakFindingRange_End_line');
%              
%             nmssPeakFindingRangeDlg_Data.rangeEnd = x;
%         end
%     end    
%     
%     Update_GUIElements(handles);

function varargout = nmssPeakFindingRangeDlg(varargin)
% nmssPeakFindingRangeDlg M-file for nmssPeakFindingRangeDlg.fig
%      nmssPeakFindingRangeDlg, by itself, creates a new nmssPeakFindingRangeDlg or raises the existing
%      singleton*.
%
%      H = nmssPeakFindingRangeDlg returns the handle to a new nmssPeakFindingRangeDlg or the handle to
%      the existing singleton*.
%
%      nmssPeakFindingRangeDlg('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in nmssPeakFindingRangeDlg.M with the given input arguments.
%
%      nmssPeakFindingRangeDlg('Property','Value',...) creates a new nmssPeakFindingRangeDlg or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssPeakFindingRangeDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssPeakFindingRangeDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssPeakFindingRangeDlg

% Last Modified by GUIDE v2.5 19-Nov-2009 12:29:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssPeakFindingRangeDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssPeakFindingRangeDlg_OutputFcn, ...
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


% --- Executes just before nmssPeakFindingRangeDlg is made visible.
function nmssPeakFindingRangeDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssPeakFindingRangeDlg (see VARARGIN)

% Choose default command line output for nmssPeakFindingRangeDlg
handles.output = hObject;

    %global nmssPeakFindingRangeDlg_Data;
    
    user_data.hFigInitFcn = @InitDlg; % called to initalize the dialog before it is made visible
    set(hObject, 'UserData', user_data);
    
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssPeakFindingRangeDlg wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%
function InitDlg(hFig)
    Update_GUIElements(hFig);
    
    set(hFig, 'Visible', 'on');


% --- Outputs from this function are returned to the command line.
function varargout = nmssPeakFindingRangeDlg_OutputFcn(hObject, eventdata, handles) 
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



function editPeakFindingRange_End_Callback(hObject, eventdata, handles)
% hObject    handle to editPeakFindingRange_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPeakFindingRange_End as text
%        str2double(get(hObject,'String')) returns contents of editPeakFindingRange_End as a double
    
    %valid = Validate_GUIElements(handles);
    
    
    
% checks if the content of the peak finding range is valid    
function valid = Validate_GUIElements(hFig)
    
%     global nmssCurveAnalysisDlg_Data;
%     global nmssPeakFindingRangeDlg_Data;
    user_data = get(hFig, 'UserData');
    handles = guihandles(hFig);
    
    valid = false;
    
    p = user_data.particle;
    x_axis = p.graph.axis.x;
        
    % the start of the range
    hObject = handles.editPeakFindingRange_Start;
    if (nmssValidateNumericEdit(hObject, 'Peak range start'))
        s = str2num(get(hObject, 'String'));
        start_limit = x_axis(1);
        if (strcmp(user_data.Dlg_Data.eV_or_nm, 'eV'))
            start_limit = 1240 / x_axis(end);
        end
        if (s < start_limit)
            uiwait(errordlg(['Please enter a number greater than ', num2str(start_limit)]));
            uicontrol(hObject);
            return;
        end
        
        user_data.Dlg_Data.rangeStart = s;
    else
        return;
    end
    set(hFig, 'UserData', user_data);
        
    % the end of the range
    hObject = handles.editPeakFindingRange_End;
    if (nmssValidateNumericEdit(hObject, 'Peak range end'))
        e = str2num(get(hObject, 'String'));
        end_limit = x_axis(end);
        if (strcmp(user_data.Dlg_Data.eV_or_nm, 'eV'))
            start_limit = 1240 / x_axis(1);
        end
        if (e > end_limit)
            uiwait(errordlg(['Please enter a number smaller than ', num2str(end_limit)]));
            uicontrol(hObject);
            return;
        end
        
        user_data.Dlg_Data.rangeEnd = e;
    else
        return;
    end
    set(hFig, 'UserData', user_data);
    
    valid = true;

% checks if the conten of the peak finding range is valid    
function Update_GUIElements(hFig)

    handles = guihandles(hFig);
    user_data = get(hFig, 'UserData');
    
        
    % the start of the range
    hObject = handles.editPeakFindingRange_Start;
    set(hObject, 'String', num2str(user_data.Dlg_Data.rangeStart));
        
    % the end of the range
    hObject = handles.editPeakFindingRange_End;
    set(hObject, 'String', num2str(user_data.Dlg_Data.rangeEnd));
    
    set(handles.textPeakFindingRange_Start, 'String', ...
        user_data.Dlg_Data.eV_or_nm);
    set(handles.textPeakFindingRange_End, 'String', ...
        user_data.Dlg_Data.eV_or_nm);



% --- Executes during object creation, after setting all properties.
function editPeakFindingRange_End_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPeakFindingRange_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssPeakFindingRangeDlg_CloseRequestFcn(handles.nmssPeakFindingRangeDlg, ...
        eventdata, handles);
    
% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, eventdata, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    handles = guihandles(hFig);

    %global nmssPeakFindingRangeDlg_Data;
    % 1 check if the entered data makes sense in itself
    if (~Validate_GUIElements(hFig))
        return;
    end

    % 2 check if the entered data makes sense in respect to each other
    if (user_data.Dlg_Data.rangeEnd <= user_data.Dlg_Data.rangeStart)
        uiwait(errordlg('Peak Range Start must be smaller than Peak Range End'));
        uicontrol(handles.editPeakFindingRange_Start);

        return;
    end
    
    % call OK function to retrieve data into the caller figure own data
    % structure
    user_data.OKFunction(hFig);
    
    
    nmssPeakFindingRangeDlg_CloseRequestFcn(handles.nmssPeakFindingRangeDlg, ...
        eventdata, handles);
        


% --- Executes when user attempts to close nmssPeakFindingRangeDlg.
function nmssPeakFindingRangeDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssPeakFindingRangeDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);





function editPeakFindingRange_Start_Callback(hObject, eventdata, handles)
% hObject    handle to editPeakFindingRange_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPeakFindingRange_Start as text
%        str2double(get(hObject,'String')) returns contents of editPeakFindingRange_Start as a double

    %valid = Validate_GUIElements(handles);



% --- Executes on button press in pbSetStartWithMouse.
function pbSetStartWithMouse_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetStartWithMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    hFig = ancestor(hObject,'figure','toplevel');
    handles = guihandles(hFig);
    user_data = get(hFig, 'UserData');
    hParentFig = user_data.CallerFigHandle;
    
    x = DrawLineWithMouse(hParentFig, ':', 'PeakFindingRange_Start_line');
    if (~isnan(x))
        user_data.Dlg_Data.rangeStart = x;
        set(hFig, 'UserData', user_data);
    end    
    
    Update_GUIElements(hFig);
    
    
%     % if zoom figure (and axes) is open then use that one
%     if (isfield(parent_user_data, 'hZoomFigure'))
%         if (ishandle(parent_user_data.hZoomFigure))
%             
%             hAxes = findobj(parent_user_data.hZoomFigure, 'Type', 'axes');
%             if (~isempty(hAxes) && ishandle(hAxes))
%                 axes(hAxes);
%             else
%                 return;
%             end
%             
%             hs = findobj(hAxes, 'Tag', 'PeakFindingRange_Start_line');
%             delete(hs);
%             
%             [x,y] = ginput(1); % one mouse click on the current axes
%             
%             ylimits = ylim();
%             
%             
%             hs = line([x, x], [ylimits(1), ylimits(2)], ...
%                  'LineWidth', 2, 'Color', 'k', 'LineStyle', ':');
%             set(hs, 'Tag', 'PeakFindingRange_Start_line');
%              
%             user_data.Dlg_Data.rangeStart = x;
%             set(hFig, 'UserData', user_data);
%         end
%     end    
%     
%     Update_GUIElements(hFig);


% --- Executes on button press in pbSetEndWithMouse.
function pbSetEndWithMouse_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetEndWithMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    hFig = ancestor(hObject,'figure','toplevel');
    handles = guihandles(hFig);
    user_data = get(hFig, 'UserData');
    hParentFig = user_data.CallerFigHandle;
    
    x = DrawLineWithMouse(hParentFig, ':', 'PeakFindingRange_End_line');
    if (~isnan(x))
        user_data.Dlg_Data.rangeEnd = x;
        set(hFig, 'UserData', user_data);
    end    
    
    Update_GUIElements(hFig);
    
    
%
function x = DrawLineWithMouse(hFig, line_style, line_tag)

    x = NaN;
    user_data = get(hFig, 'UserData');
    
    % if zoom figure (and axes) is open then use that one
    if (isfield(user_data, 'hZoomFigure'))
        if (ishandle(user_data.hZoomFigure))
            
            hAxes = findobj(user_data.hZoomFigure, 'Type', 'axes');
            if (~isempty(hAxes) && ishandle(hAxes))
                axes(hAxes);
            else
                return;
            end
            
            hs = findobj(hAxes, 'Tag', line_tag);
            delete(hs);
            
            [x,y] = ginput(1); % one mouse click on the current axes
            
            ylimits = ylim();
            
            
            hs = line([x, x], [ylimits(1), ylimits(2)], ...
                 'LineWidth', 2, 'Color', 'k', 'LineStyle', line_style);
            set(hs, 'Tag', line_tag);
             
        end
    end    
