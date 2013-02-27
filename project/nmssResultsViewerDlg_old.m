function varargout = nmssResultsViewerDlg(varargin)
% NMSSRESULTSVIEWERDLG M-file for nmssResultsViewerDlg.fig
%      NMSSRESULTSVIEWERDLG, by itself, creates a new NMSSRESULTSVIEWERDLG or raises the existing
%      singleton*.
%
%      H = NMSSRESULTSVIEWERDLG returns the handle to a new NMSSRESULTSVIEWERDLG or the handle to
%      the existing singleton*.
%
%      NMSSRESULTSVIEWERDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSRESULTSVIEWERDLG.M with the given input arguments.
%
%      NMSSRESULTSVIEWERDLG('Property','Value',...) creates a new NMSSRESULTSVIEWERDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssResultsViewerDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssResultsViewerDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssResultsViewerDlg

% Last Modified by GUIDE v2.5 14-Jul-2010 15:38:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssResultsViewerDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssResultsViewerDlg_OutputFcn, ...
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



% --- Executes just before nmssResultsViewerDlg is made visible.
function nmssResultsViewerDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssResultsViewerDlg (see VARARGIN)

% Choose default command line output for nmssResultsViewerDlg
handles.output = hObject;
    global nmssResultsViewerDlg_Data;
    nmssResultsViewerDlg_Data.show_only_peaks = 0;
    nmssResultsViewerDlg_Data.num_of_graphs_in_dlg = 20;
    
    nmssResultsViewerDlg_Data.checkbox_handles = [handles.checkbox1 handles.checkbox2 handles.checkbox3 handles.checkbox4 ...
                        handles.checkbox5 handles.checkbox6 handles.checkbox7 handles.checkbox8 ...
                        handles.checkbox9 handles.checkbox10 handles.checkbox11 handles.checkbox12 ...
                        handles.checkbox13 handles.checkbox14 handles.checkbox15 handles.checkbox16 ...
                        handles.checkbox17 handles.checkbox18 handles.checkbox19 handles.checkbox20];

    nmssResultsViewerDlg_Data.axes_handles = [handles.axes01 handles.axes02 handles.axes03 handles.axes04 handles.axes05 ...
                    handles.axes06 handles.axes07 handles.axes08 handles.axes09 handles.axes10 ...
                    handles.axes11 handles.axes12 handles.axes13 handles.axes14 handles.axes15 ...
                    handles.axes16 handles.axes17 handles.axes18 handles.axes19 handles.axes20];
                
    nmssResultsViewerDlg_Data.filter = FilterInit();
                
    %set(nmssResultsViewerDlg_Data.axes_handles, 'FontSize', 8);

    nmssResultsViewerDlg_Data.work_particle = nmssResultsViewerDlg_Data.particle;
    
    InitDlg(handles);
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssResultsViewerDlg wait for user response (see UIRESUME)
% uiwait(handles.nmssResultsViewerDlg);

function InitDlg(handles)
    global nmssResultsViewerDlg_Data;
    
    nmssResultsViewerDlg_Data.current_view_level = 1;

    % number of particles
        num_of_particles = size(nmssResultsViewerDlg_Data.work_particle,1);
        
    % number of correlation levels
        num_of_corr_view_levels = size(nmssResultsViewerDlg_Data.work_particle,2);
        if (num_of_corr_view_levels == 1)
            set(handles.textCorrViewLevel, 'Visible', 'off');
            set(handles.cxCorrViewLevel, 'Visible', 'off');
        else
            set(handles.textCorrViewLevel, 'Visible', 'on');
            set(handles.cxCorrViewLevel, 'Visible', 'on');
            
            % fill combo box with data
            levels = 1:num_of_corr_view_levels;
            set(handles.cxCorrViewLevel, 'String', num2str(levels'));
            
        end
    
    % flag vector indicating the selection state of the particle at the
    % corresponding index
        %nmssResultsViewerDlg_Data.particle_selected = zeros(num_of_particles);
        nmssResultsViewerDlg_Data.particle_selected = [nmssResultsViewerDlg_Data.work_particle(:).valid];
    
    % set number of pages
        num_of_pages = ceil( num_of_particles / nmssResultsViewerDlg_Data.num_of_graphs_in_dlg);
        set(handles.editNumOfAllPages, 'String', num2str(num_of_pages));
        % switch off page cahnge buttons
        if (num_of_pages == 1)
            set(handles.pbGetNextSetOfGraphs, 'Enable', 'off');
            set(handles.pbGetPreviousSetOfGraphs, 'Enable', 'off');
        end

    nmssResultsViewerDlg_Data.start_index = 1;
    DisplayNextSetOfGraphs(handles, nmssResultsViewerDlg_Data.start_index);

    % the largest measured intensity
    nmssResultsViewerDlg_Data.max_intensity = Inf;
    
    % register file name
    [fpart,fname,fext,fversn] = fileparts(nmssResultsViewerDlg_Data.results_file_path);
    
        
    dlgname = get(handles.nmssResultsViewerDlg, 'Name');
    set(handles.nmssResultsViewerDlg, 'Name', ...
        [dlgname, ': ', fname, fext]);

    

% displays graphs in the axes
function DisplayNextSetOfGraphs(handles, start_index)
    global nmssResultsViewerDlg_Data;
    particle = nmssResultsViewerDlg_Data.work_particle(:,nmssResultsViewerDlg_Data.current_view_level);
    num_of_corr_view_levels = size(nmssResultsViewerDlg_Data.work_particle,2);
    
    num_of_particles = length(particle);
    if (start_index > num_of_particles )
        error('Too much, man! The starting index is way higher than the number of particles in the results struct');
    end
    
    
    % display 16 (or 20 or whatever number I'll agree on at the end) graphs or less
    for i=start_index:start_index+nmssResultsViewerDlg_Data.num_of_graphs_in_dlg-1
        
        % create context menu for the axes. the conext menu can contain
        % different menu entries to react on the user's mouse click
        % the menu entries will be filled up later in this function
        % 'Parent' is the figure which is the same parent as for the axes
        context_menu = uicontextmenu('Parent', handles.nmssResultsViewerDlg);
        axes_handle = nmssResultsViewerDlg_Data.axes_handles(i-start_index+1);
        % activate axes figure
        axes(axes_handle);
        % link axes with the context menu
        set(axes_handle, 'UIContextMenu', context_menu);
        
        checkbox_index = i-start_index+1;
        
        current_checkbox = nmssResultsViewerDlg_Data.checkbox_handles(checkbox_index);
        if (i > num_of_particles)
            % plot empty graphs if no data is available
            plot(axes_handle, [0 1]);
            xlim(axes_handle, [0 1]);
            ylim(axes_handle, [0 1]);
            set(current_checkbox, 'Enable', 'off');
            set(current_checkbox, 'Value' , 0);
        else
            p = particle(i);
            
            cla; % clear axes
            hold on;
            PlotGraph(axes_handle, p);
            
            posAxes = get(axes_handle, 'Position');
            xlims = xlim();
            dx = xlims(2) - xlims(1);
            x = xlims(2) - dx * 0.15;
            ylims = ylim();
            dy = ylims(2) - ylims(1);
            y = ylims(2) - dy * 0.1;
            
            if (isfield(p, 'num'))
                text(x,y, num2str(p.num));
            else
                text(x,y, num2str(i));
            end
                
            
            hold off;
            
            
            set(current_checkbox, 'Enable', 'on');
            set(current_checkbox, 'Value' ,nmssResultsViewerDlg_Data.particle_selected(i));
            
            % this callback will be performed if the context menu is
            % clicked by the user
            cb = ['nmssResultsViewerPopupMenu(''SmoothGraph'', ', num2str(i), ');'];
            uimenu(context_menu,  'Label', 'Show smooth graph', 'Callback', cb);
            
            cb = ['nmssResultsViewerPopupMenu(''UnSmoothGraph'', ', num2str(i), ');'];
            uimenu(context_menu,  'Label', 'Show unsmooth graph', 'Callback', cb);

            cb = ['nmssResultsViewerPopupMenu(''ShowBackground'', ', num2str(i), ');'];
            uimenu(context_menu,  'Label', 'Show background', 'Callback', cb);
            
            cb = ['nmssResultsViewerPopupMenu(''ShowRaw'', ', num2str(i), ');'];
            uimenu(context_menu,  'Label', 'Show raw', 'Callback', cb);
            
            cb = ['nmssResultsViewerPopupMenu(''ShowRawMinusBg'', ', num2str(i), ');'];
            uimenu(context_menu,  'Label', 'Show (raw - bg)', 'Callback', cb);
            
            
            % plots the spectrum with blue and the noise filtered spectrum
            % with red
            cb = ['nmssResultsViewerPopupMenu(''ShowNoiseFiltered'', ', num2str(i), ');'];
            uimenu(context_menu,  'Label', 'Show Noise Filteres', 'Callback', cb);
              
            % plots the peak of the spectrum with blue and the fitted
            %  curve with green
            cb = ['nmssResultsViewerPopupMenu(''ShowFit'', ', num2str(i), ');'];
            uimenu(context_menu,  'Label', 'Show fit', 'Callback', cb);
              
            % plots the spectrum in with eV as the x-axis
            cb = ['nmssResultsViewerPopupMenu(''ShoweV'', ', num2str(i), ');'];
            uimenu(context_menu,  'Label', 'Show eV', 'Callback', cb);
            
            % plots res energy / wavelength position of the peak
            cb = ['nmssResultsViewerPopupMenu(''ShowData'', ', num2str(i), ');'];
            uimenu(context_menu,  'Label', 'Show Data', 'Callback', cb);
            
            if (isfield(nmssResultsViewerDlg_Data, 'real_space_image'))
                % shows the location of the particle on real space figure
                cb = ['nmssResultsViewerPopupMenu(''ShowInRealSpaceImg'', ', num2str(i), ');'];
                uimenu(context_menu,  'Label', 'Show in real space image', 'Callback', cb);
            end
            
            % shows the graph in an external figure
            cb = ['nmssResultsViewerPopupMenu(''Zoom'', ', num2str(i), ');'];
            uimenu(context_menu,  'Label', 'Zoom', 'Callback', cb);
            
            
            % shows the graphs of correlated particles
            if (num_of_corr_view_levels > 1) % only if more than one particle spectrum is loaded for the same particle
                cb = ['nmssResultsViewerPopupMenu(''CorrelatedSpectra'', ', num2str(i), ');'];
                uimenu(context_menu,  'Label', 'Correlated Spectra', 'Callback', cb);
            end
            
        end
        UpdateCheckBoxBG(checkbox_index);
        SetGraphBg(checkbox_index);

    end
    nmssResultsViewerDlg_Data.PlotGraphCallback = @PlotGraph; % function handle of PlotGraph, this function can be called now from outside of this script
    
    % display the current page index number
    set(handles.editCurrentPageNo, 'String', ceil(start_index/nmssResultsViewerDlg_Data.num_of_graphs_in_dlg));
    
% --------------------------------------------------------------------    
% plot graph
function PlotGraph(hAxes, particle)

    if (isfield(particle.graph, 'smoothed'))
        spec = particle.graph.smoothed;
    else
        spec = particle.graph.normalized;
    end
    plot(hAxes, particle.graph.axis.x, spec, 'LineWidth', 2);

    % plot each spectrum corresponding to the summed sepctrum
    if (isfield(particle, 'res_en_vs_pos'))
        plot_number = size(particle.res_en_vs_pos,1);
        % the colors of the graphs
        color_matrix = hsv(plot_number);
        hold on;
        
        % plot each graph on the same axis
        for plot_index = 1:plot_number

            plot(hAxes, particle.graph.axis.x, particle.res_en_vs_pos(plot_index,3:end), ...
                 'Color', color_matrix(plot_index, :));
        end
    end
    
    xlim(hAxes, [min(particle.graph.axis.x) max(particle.graph.axis.x)]);
    ylim(hAxes, [min(spec) max(spec) * 1.1]);
    
    
    
% --------------------------------------------------------------------    
function SelectParticle(checkbox_index)
    global nmssResultsViewerDlg_Data;
    
    selected_particle_index = nmssResultsViewerDlg_Data.start_index+checkbox_index - 1;
    
    %nmssResultsViewerDlg_Data.particle(selected_particle_index);

    
    nmssResultsViewerDlg_Data.particle_selected(selected_particle_index) = 1;

% --------------------------------------------------------------------    
function UnSelectParticle(checkbox_index)
    global nmssResultsViewerDlg_Data;
    nmssResultsViewerDlg_Data.particle_selected(nmssResultsViewerDlg_Data.start_index+checkbox_index-1) = 0;

% --------------------------------------------------------------------
% sets the graph background color according to the selection status of the
% graph
function SetGraphBg(index)
    global nmssResultsViewerDlg_Data;
    
    sel_particle_index = nmssResultsViewerDlg_Data.start_index+index-1;
    if (sel_particle_index <= length(nmssResultsViewerDlg_Data.particle_selected))

        if (nmssResultsViewerDlg_Data.particle_selected(sel_particle_index) == 1)
            set(nmssResultsViewerDlg_Data.axes_handles(index), 'Color', [248 230 126] / 255);
        else
            set(nmssResultsViewerDlg_Data.axes_handles(index), 'Color', [255 255 255] / 255);
        end
    end


    
% -------------------------------------------------------------------- 
% reacts on the user's click on the checkbox
function CheckBoxAction(checkbox_index)
     global nmssResultsViewerDlg_Data;
    
     if (get(nmssResultsViewerDlg_Data.checkbox_handles(checkbox_index),'Value') == 1)
         SelectParticle(checkbox_index);
         set(nmssResultsViewerDlg_Data.axes_handles(checkbox_index), 'Color', [248 230 126] / 255);
     else
         UnSelectParticle(checkbox_index);
         set(nmssResultsViewerDlg_Data.axes_handles(checkbox_index), 'Color', [255 255 255] / 255);
     end
     
     SetCheckBoxBG(nmssResultsViewerDlg_Data.checkbox_handles(checkbox_index));
     %UpdateCheckBoxBG(checkbox_index);
     SetGraphBg(checkbox_index);
     
% --------------------------------------------------------------------    
function UpdateCheckBoxBG(checkbox_index)
    global nmssResultsViewerDlg_Data;
    hObject = nmssResultsViewerDlg_Data.checkbox_handles(checkbox_index);
    
    sel_particle_index = nmssResultsViewerDlg_Data.start_index+checkbox_index-1;
    if (sel_particle_index <= length(nmssResultsViewerDlg_Data.particle_selected))
        if (nmssResultsViewerDlg_Data.particle_selected(sel_particle_index) == 1)
            set(hObject, 'Value', 1);
        else
            set(hObject, 'Value', 0);
        end
    end
    
    SetCheckBoxBG(hObject);
    

function SetCheckBoxBG(hObject)

    if (get(hObject,'Value') == 1)
        set(hObject, 'BackgroundColor', [248 230 126] / 255);
    else
        set(hObject, 'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
    end


% --- Outputs from this function are returned to the command line.
function varargout = nmssResultsViewerDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbGetPreviousSetOfGraphs.
function pbGetPreviousSetOfGraphs_Callback(hObject, eventdata, handles)
% hObject    handle to pbGetPreviousSetOfGraphs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssResultsViewerDlg_Data;
    if (nmssResultsViewerDlg_Data.start_index > nmssResultsViewerDlg_Data.num_of_graphs_in_dlg)
        nmssResultsViewerDlg_Data.start_index = nmssResultsViewerDlg_Data.start_index -nmssResultsViewerDlg_Data.num_of_graphs_in_dlg;
        DisplayNextSetOfGraphs(handles, nmssResultsViewerDlg_Data.start_index);
    end

    
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbClose.
function pbClose_Callback(hObject, eventdata, handles)
% hObject    handle to pbClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssResultsViewerDlg_CloseRequestFcn(handles.nmssResultsViewerDlg, eventdata, handles); 

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
    CheckBoxAction(1);
    
    
% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
    CheckBoxAction(2);


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
    CheckBoxAction(3);


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
     CheckBoxAction(4);


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
    CheckBoxAction(5);


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
     CheckBoxAction(6);


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
    CheckBoxAction(7);


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8
    CheckBoxAction(8);

% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9
     CheckBoxAction(9);


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10
    CheckBoxAction(10);


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11
    CheckBoxAction(11);


% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12
    CheckBoxAction(12);


% --- Executes on button press in checkbox13.
function checkbox13_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox13
    CheckBoxAction(13);


% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox14
    CheckBoxAction(14);


% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox15
    CheckBoxAction(15);

% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16
    CheckBoxAction(16);


% --- Executes when user attempts to close nmssResultsViewerDlg.
function nmssResultsViewerDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssResultsViewerDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    button = questdlg('Do you really want to exit? Maybe exporting the selected results would be a good idea!','Exit confirmation','Yes','No','No');
    % user does not want to exit
    if (strcmp(button,'No'))
        return;
    end

    global nmssResultsViewerDlg_Data;
    
    % perform clean up before closing the dialog
    
    % find all children with Tag containing 'nmssResultsViewerFigure_'
    hResultsViewFigure_Children = findobj('-regexp','Tag', 'nmssResultsViewerFigure_\w*');
    delete(hResultsViewFigure_Children);
    hChildrenDlg = findobj('Tag', 'nmssCurveAnalysisDlg');
    delete(hChildrenDlg);
    
    
    % Hint: delete(hObject) closes the figure
    delete(hObject);




% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, eventdata, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssResultsViewerDlg_CloseRequestFcn(handles.nmssResultsViewerDlg, eventdata, handles); 


% --- Executes on button press in pbSelectAll.
function pbSelectAll_Callback(hObject, eventdata, handles)
% hObject    handle to pbSelectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssResultsViewerDlg_Data;
    for i=1:length(nmssResultsViewerDlg_Data.checkbox_handles)
        if (strcmp(get(nmssResultsViewerDlg_Data.checkbox_handles(i), 'Enable'),'on'))
            set(nmssResultsViewerDlg_Data.checkbox_handles(i), 'Value', 1);
            CheckBoxAction(i);
        end
    end


% --- Executes on button press in pbUnselectAll.
function pbUnselectAll_Callback(hObject, eventdata, handles)
% hObject    handle to pbUnselectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssResultsViewerDlg_Data;
    for i=1:length(nmssResultsViewerDlg_Data.checkbox_handles)
        if (strcmp(get(nmssResultsViewerDlg_Data.checkbox_handles(i), 'Enable'),'on'))
            set(nmssResultsViewerDlg_Data.checkbox_handles(i), 'Value', 0);
            CheckBoxAction(i);
        end
    end


% --- Executes on button press in pbBergPlot.
function pbBergPlot_Callback(hObject, eventdata, handles)
% hObject    handle to pbBergPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global nmssResultsViewerDlg_Data;
    global nmssViewBergPlotGraph_Data;
    selected_particle_index = find(nmssResultsViewerDlg_Data.particle_selected == 1);
    
    % copy selected results into the berg plot variable
    nmssViewBergPlotGraph_Data.particle = nmssResultsViewerDlg_Data.work_particle(selected_particle_index,1);
    % call berg plotter
    nmssViewBergPlotGraphMenu();
    
    

function editCurrentPageNo_Callback(hObject, eventdata, handles)
% hObject    handle to editCurrentPageNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCurrentPageNo as text
%        str2double(get(hObject,'String')) returns contents of editCurrentPageNo as a double


% --- Executes during object creation, after setting all properties.
function editCurrentPageNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCurrentPageNo (see GCBO)
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




% --- Executes on button press in pbExportSelectedResults.
function pbExportSelectedResults_Callback(hObject, eventdata, handles)
% hObject    handle to pbExportSelectedResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global nmssResultsViewerDlg_Data;
    selected_particle_index = find(nmssResultsViewerDlg_Data.particle_selected == 1);
    
    % copy selected results into the berg plot variable
    results = nmssResultsViewerDlg_Data.results;
    results.particle = nmssResultsViewerDlg_Data.results.particle(selected_particle_index);
    
    nmssResultsViewerDlg_Data.hExportFcn(particle);
    

%     % save results file
%     
%     % get old working directory
%     old_current_dir = pwd;
% 
%     %change to nmss working directory (which is not the same as the
%     %matlab working directory)
%     cd(nmssResultsViewerDlg_Data.workDir);
% 
%     [filename, dirname] = uiputfile({'*.mat','Matlab data (*.mat)'}, 'Save results', 'results_selected.mat');
%     cd(old_current_dir);
% 
%     if (filename ~= 0) % user pressed OK in file save dialog
% 
%         % save berg plot matrix
%         filepath = fullfile(dirname, filename)
%         try
%             save(filepath, 'results', '-mat');
%         catch
%             errordlg(lasterr());
%         end
%     end
    
    
    
% --- Executes on button press in pbGetNextSetOfGraphs.
function pbGetNextSetOfGraphs_Callback(hObject, eventdata, handles)
% hObject    handle to pbGetNextSetOfGraphs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global nmssResultsViewerDlg_Data;
    num_of_particles = size(nmssResultsViewerDlg_Data.work_particle, 1);
    
    if (nmssResultsViewerDlg_Data.start_index + nmssResultsViewerDlg_Data.num_of_graphs_in_dlg <= num_of_particles)
        nmssResultsViewerDlg_Data.start_index = nmssResultsViewerDlg_Data.start_index + nmssResultsViewerDlg_Data.num_of_graphs_in_dlg;
        DisplayNextSetOfGraphs(handles, nmssResultsViewerDlg_Data.start_index);
    end

%--------------------------------------------------------------------------
function filter = FilterInit()
    
    % filter for FWHM characteristics of the peak
    filter.show_only_peaks = 0;
    
    % filter for max intensity
    filter.filter_intensity_range = 0;
    filter.min_int = 0;
    filter.max_int = Inf;
    
    % more filter coming soon...
    
%--------------------------------------------------------------------------
function true_or_false = FilterCompare(source_filter, target_filter)

    true_or_false = (target_filter.show_only_peaks == source_filter.show_only_peaks ...
        & target_filter.filter_intensity_range == source_filter.filter_intensity_range ...
        & target_filter.min_int == source_filter.min_int ...
        & target_filter.max_int == source_filter.max_int);
    
    % more filters coming soon...



% --- Executes on button press in pbFilter.
function pbFilter_Callback(hObject, eventdata, handles)
% hObject    handle to pbFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global nmssResultsViewFilterDlg_Data;
    global nmssResultsViewerDlg_Data;
    
    % initialize filter dialog data
    nmssResultsViewFilterDlg_Data.filter = nmssResultsViewerDlg_Data.filter;
    nmssResultsViewFilterDlg_Data.particle = nmssResultsViewerDlg_Data.particle;
    
    %nmssResultsViewFilterDlg_Data.  = GetMaxIntensity(nmssResultsViewerDlg_Data.work_results);
    
    uiwait(nmssResultsViewFilterDlg());
    
    % did the user exit with OK or Cancel?
    if (nmssResultsViewFilterDlg_Data.user_clicked_OK == 1)
        % get results which we will filter
        nmssResultsViewerDlg_Data.work_particle = nmssResultsViewerDlg_Data.particle;
        
        % get filter
        filter = nmssResultsViewFilterDlg_Data.filter;
        
        % if the filter is activated perform filtering of the results
        if (filter.show_only_peaks == 1)
            nmssResultsViewerDlg_Data.work_particle = SelectPeaksWithFWHM(nmssResultsViewerDlg_Data.work_particle);
        end

        % intensity range filter
        if (filter.filter_intensity_range == 1)
            min_int = filter.min_int;
            max_int = filter.max_int; % positive infinity
            nmssResultsViewerDlg_Data.work_particle = ...
                FilterIntensityRange(nmssResultsViewerDlg_Data.work_particle, min_int, max_int);
        end
        
        % number of peaks filter
        if (filter.cb_num_of_peaks == 1)
            min_num_of_peaks = filter.min_num_of_peaks;
            max_num_of_peaks = filter.max_num_of_peaks;
            nmssResultsViewerDlg_Data.work_particle = ...
                FilterNumOfPeaks(nmssResultsViewerDlg_Data.work_particle, min_num_of_peaks, max_num_of_peaks);
        end
                
            
        InitDlg(handles);
        
        % store filter in the dialog's own data structure
        nmssResultsViewerDlg_Data.filter = filter;
    end
    
% --- filters the results according to the number of detected peaks
function filtered_particle = FilterNumOfPeaks(particle, min_num_of_peaks, max_num_of_peaks);

    num_of_particles = length(particle);
    
    % vector to store the indices of particles which match the filter
    % criteria
    filtered_particles_idices = [];
    j =1; % index for the vector defined above
    for i=1:num_of_particles
        spec = particle(i).graph.normalized;
        smooth_factor = 30;
        [maxima minima] = nmssFindExtrema(spec, smooth_factor);
        
        if (length(maxima) >= min_num_of_peaks && ...
            length(maxima) <= max_num_of_peaks)
            filtered_particles_idices(j) = i;
            j = j+1;        
        end
    end

    % set return struct
    filtered_particle = particle;
    if (length(filtered_particles_idices) > 0)
        filtered_particle = particle(filtered_particles_idices);
    end

    


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17
    CheckBoxAction(17);


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18
    CheckBoxAction(18);


% --- Executes on button press in checkbox19.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox19
    CheckBoxAction(19);


% --- Executes on button press in checkbox20.
function checkbox20_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox20
    CheckBoxAction(20);

% selects peaks where FWHM could be determined
function filtered_particle = SelectPeaksWithFWHM(particle)
    
    num_of_particles = length(particle);
    
    j =1;
    filtered_particles_idices = [];
    for i=1:num_of_particles
        if (~isnan(particle(i).FWHM))
            filtered_particles_idices(j) = i;
            j = j+1;
        end
    end
    
    filtered_particle = particle;
    if (length(filtered_particles_idices) > 0)
        filtered_particle = particle(filtered_particles_idices);
    end


% find maximum peak intensity    
function max_intensity = GetMaxIntensity(particle)
    num_of_particles = length(particle);
    
    max_intensity = -Inf;
    for i=1:num_of_particles
        if (particle(i).max_intensity > max_intensity)
            max_intensity = particle(i).max_intensity;
        end
    end


function filtered_particle = FilterIntensityRange(particle, min_int, max_int)
    num_of_particles = length(particle);
    
    % vector to store the indices of particles which match the filter
    % criteria
    filtered_particles_idices = [];
    j =1; % index for the vector defined above
    for i=1:num_of_particles
        if (particle(i).max_intensity > min_int ...
                & particle(i).max_intensity < max_int )
            filtered_particles_idices(j) = i;
            j = j+1;        
        end
    end

    filtered_particle = particle;
    if (length(filtered_particles_idices) > 0)
        filtered_particle = particle(filtered_particles_idices);
    end

        


% --- Executes on button press in pbAnalyze.
function pbAnalyze_Callback(hObject, eventdata, handles)
% hObject    handle to pbAnalyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    global nmssCurveAnalysisDlg_Data;
    global nmssResultsViewerDlg_Data;
 
%    if true
    if (isfield(doc, 'nmssCurveAnalysisDlg_Data'))
        nmssCurveAnalysisDlg_Data = doc.nmssCurveAnalysisDlg_Data;
    else
        % init nmssCurveAnalysisDlg_Data here:
        
        
        % the graph index to be displayed
        nmssCurveAnalysisDlg_Data.current_graph_index = 1;
        
        % flag to indicate if the smoothed curve should be displayed
        nmssCurveAnalysisDlg_Data.showCurves.smoothed = true;
        nmssCurveAnalysisDlg_Data.showCurves.unsmoothed = true;
        nmssCurveAnalysisDlg_Data.showCurves.fittedcurve = true;
        nmssCurveAnalysisDlg_Data.showCurves.max = true;
        nmssCurveAnalysisDlg_Data.showCurves.peak_finding_range = true;
        nmssCurveAnalysisDlg_Data.showCurves.noise_filtered = true;
        
        % flag to indicate if the fitting should be performed on the raw
        % data or on the denoised data
        nmssCurveAnalysisDlg_Data.use_denoised_data_to_fit = false;
        
        % the unit of the x-axis of the displayed curves
        nmssCurveAnalysisDlg_Data.graphXAxisUnit = 'eV';
        
        % init peak parameters finding method
        nmssCurveAnalysisDlg_Data.peakFindingParams = nmssResetPeakFindingParam();
        
        % init the peak finding range dialog data
        zzz.rangeStart = nmssResultsViewerDlg_Data.work_particle(1,1).graph.axis.x(1);
        zzz.rangeEnd = nmssResultsViewerDlg_Data.work_particle(1,1).graph.axis.x(end);
        zzz.eV_or_nm = nmssCurveAnalysisDlg_Data.graphXAxisUnit;
        if (strcmp(zzz.eV_or_nm, 'eV'))
            zzz.rangeStart = 1240 / nmssResultsViewerDlg_Data.work_particle(1,1).graph.axis.x(end);
            zzz.rangeEnd = 1240 / nmssResultsViewerDlg_Data.work_particle(1,1).graph.axis.x(1);
        end
        nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data = zzz;

    end
    
    % copy particle data structure into the particle variable
    nmssCurveAnalysisDlg_Data.selected_particle_index = find(nmssResultsViewerDlg_Data.particle_selected == 1);
    if (isempty(nmssCurveAnalysisDlg_Data.selected_particle_index))
        errordlg('Please select at least one graph!')
        return;
    end
    
    % copy particle struct to the analysis dialog particle struct
%     nmssCurveAnalysisDlg_Data.particle = nmssResultsViewerDlg_Data.work_particle(...
%         nmssCurveAnalysisDlg_Data.selected_particle_index, ...
%         nmssResultsViewerDlg_Data.current_view_level);
    nmssCurveAnalysisDlg_Data.particle = nmssResultsViewerDlg_Data.work_particle(...
        :, ...
        nmssResultsViewerDlg_Data.current_view_level);
    
        
    % switch off controls (user should not mess around with the dialog box)
        hControls = findobj(handles.nmssResultsViewerDlg, 'Style', 'pushbutton', '-or', 'Style', 'popupmenu');
        set(hControls, 'Enable', 'off');
    
    % register callback function that is called whane user closes the
    % dialog with pressing OK
    nmssCurveAnalysisDlg_Data.OKFunction = @nmssCurveAnalysisDlg_OKFunction;
    % OPEN dialog
    hDlg = nmssCurveAnalysisDlg();
    
    DisplayNextSetOfGraphs(handles, nmssResultsViewerDlg_Data.start_index);
    
    % give focus to the recently opened dialog
    figure(hDlg);
    

%
function nmssCurveAnalysisDlg_OKFunction(nmssCurveAnalysisDlg_Data)

    global doc;

    wanted_index = find(nmssCurveAnalysisDlg_Data.selected_particle_index_flag == 1);
    wanted_part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(wanted_index);
    nmssResultsViewerDlg_Data.work_particle(wanted_part_index) = ...
        nmssCurveAnalysisDlg_Data.particle(wanted_part_index);
    
    nmssResultsViewerDlg_Data.particle_selected(wanted_part_index) = 1;
    
    unwanted_index = find(nmssCurveAnalysisDlg_Data.selected_particle_index_flag == 0);
    unwanted_part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(unwanted_index);
    nmssResultsViewerDlg_Data.particle_selected(unwanted_part_index) = 0;
        
    
    doc.nmssCurveAnalysisDlg_Data = nmssCurveAnalysisDlg_Data;


% --- Executes on button press in pbResonance.
function pbResonance_Callback(hObject, eventdata, handles)
% hObject    handle to pbResonance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssResultsViewerDlg_Data;
    particle = nmssResultsViewerDlg_Data.work_particle(:,nmssResultsViewerDlg_Data.current_view_level);
    
    res_en = [];
    k = 1;

    for i=1:length(particle)
        if (~isempty(particle(i)))
            if ((particle(i).valid == 1) & (particle(i).res_energy ~= 0))
                res_en(k) = particle(i).res_energy;
                k = k +1;
            end
        end
    end
    
    % resopnance energy histogram
    figure;
    hist(res_en, 20);
    title('Histogram of Resonance Energy Distribution');
    xlabel('E_r_e_s (eV)');
    
    % resopnance wavelength histogram
    figure;
    hist(1240 ./ res_en, 20);
    title('Histogram of Resonance Wavelength Distribution');
    xlabel('\lambda_r_e_s (nm)');
    
