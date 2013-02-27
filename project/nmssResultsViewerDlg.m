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

% Last Modified by GUIDE v2.5 08-Dec-2010 11:40:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
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
    %global nmssResultsViewerDlg_Data;
    user_data.show_only_peaks = 0;
    user_data.num_of_graphs_in_dlg = 20;
    user_data.current_view_level = 1;
    
    user_data.hFigInitFcn = @InitDlg;
    
%     nmssResultsViewerDlg_Data.checkbox_handles = [handles.checkbox1 handles.cxGraphSelection02 handles.cxGraphSelection03 handles.checkbox4 ...
%                         handles.checkbox5 handles.cxGraphSelection06 handles.checkbox7 handles.cxGraphSelection08 ...
%                         handles.cxGraphSelection09 handles.cxGraphSelection10 handles.cxGraphSelection11 handles.cxGraphSelection12 ...
%                         handles.cxGraphSelection13 handles.cxGraphSelection14 handles.cxGraphSelection15 handles.cxGraphSelection16 ...
%                         handles.cxGraphSelection17 handles.checkbox18 handles.checkbox19 handles.cxGraphSelection20];
% 
%     nmssResultsViewerDlg_Data.axes_handles = [handles.axes01 handles.axes02 handles.axes03 handles.axes04 handles.axes05 ...
%                     handles.axes06 handles.axes07 handles.axes08 handles.axes09 handles.axes10 ...
%                     handles.axes11 handles.axes12 handles.axes13 handles.axes14 handles.axes15 ...
%                     handles.axes16 handles.axes17 handles.axes18 handles.axes19 handles.axes20];
                
    user_data.filter = FilterInit();
    
    set(hObject, 'UserData', user_data);
                
    %set(nmssResultsViewerDlg_Data.axes_handles, 'FontSize', 8);

%     user_data_ResultsViewerDlg.work_particle = nmssResultsViewerDlg_Data.particle;
    
    %InitDlg(handles);
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssResultsViewerDlg wait for user response (see UIRESUME)
% uiwait(handles.nmssResultsViewerDlg);

function InitDlg(hFig)
    %global nmssResultsViewerDlg_Data;
    
    user_data = get(hFig, 'UserData');
    handles = guihandles(hFig);
    

    % number of particles
        num_of_particles = size(user_data.results.particle,1);
        
    % number of correlation levels
        num_of_corr_view_levels = size(user_data.results.particle,2);
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
%         nmssResultsViewerDlg_Data.particle_selected = [user_data.results.particle.valid];
    
    % set number of pages
        num_of_pages = ceil( num_of_particles / GetNumOfGraphAxesInDlg(hFig));
        set(handles.editNumOfAllPages, 'String', num2str(num_of_pages));
        % switch off page cahnge buttons
        UpdatePagerButtons(hFig);
    
    %nmssResultsViewerDlg_Data.start_index = 1;
    DisplayNextSetOfGraphs(hFig, 1);

    dlgname = get(handles.nmssResultsViewerDlg, 'Name');
    set(handles.nmssResultsViewerDlg, 'Name', ...
        [dlgname, ': ', user_data.results.working_dir]);
    
    % Update handles structure
    guidata(hFig    , handles);
        

%
function num_of_particles = GetNumOfAllParticles(hFig)
    user_data = get(hFig, 'UserData');
    
    % number of particles
    num_of_particles = size(user_data.results.particle,1);

        
        
% delivers the number of axes in the dialog
function numOfGraphAxesInDlg = GetNumOfGraphAxesInDlg(hFig)
    numOfGraphAxesInDlg = 20;
%     hGraphAxes = findobj(hFig, '-regexp', 'Tag', 'axes\d*');
%     numOfGraphAxesInDlg = length(hGraphAxes);
    

% displays graphs in the axes
function DisplayNextSetOfGraphs(hFig, start_index)
    
    user_data = get(hFig, 'UserData');
    handles = guihandles(hFig);
    
    particle = user_data.results.particle(:,user_data.current_view_level);
    num_of_corr_view_levels = size(user_data.results.particle,2);
    
    num_of_particles = length(particle);
    if (start_index > num_of_particles )
        error('Too much, man! The starting index is way higher than the number of particles in the results struct');
    end
    
    num_of_axes_in_dlg = GetNumOfGraphAxesInDlg(hFig);
    
    % display graphs
    for i=start_index:start_index + num_of_axes_in_dlg - 1
        
        % create context menu for the axes. the conext menu can contain
        % different menu entries to react on the user's mouse click
        % the menu entries will be filled up later in this function
        % 'Parent' is the figure which is the same parent as for the axes
        context_menu = uicontextmenu('Parent', hFig);
        sIndex = num2str(i-start_index+1);
        number_mask = ['00'];
            number_mask(end - length(sIndex) + 1:end) = sIndex;
        axes_handle = findobj(hFig, 'Tag', ['axes', number_mask]);
        % activate axes figure
        axes(axes_handle);
        % link axes with the context menu
        set(axes_handle, 'UIContextMenu', context_menu);
        
        % get axes Tag
        axesTag = get(axes_handle, 'Tag');
        
        checkbox_index = i-start_index+1;
        if (checkbox_index <= 9)
            sSearchNumber = sprintf('0%d', checkbox_index);
        else
            sSearchNumber = sprintf('%d', checkbox_index);
        end
        
        hCurrentCheckbox = findobj(hFig, 'Tag', ['cxGraphSelection', sSearchNumber]);
        
        if (i > num_of_particles)
            % lot empty graphs if no data is available
            set(axes_handle, 'Visible', 'off');
            set(axes_handle, 'UserData', 0);
            set(allchild(axes_handle), 'Visible', 'off');
%             plot(axes_handle, [0 1]);
%             xlim(axes_handle, [0 1]);
%             ylim(axes_handle, [0 1]);
%             hold off;
            set(hCurrentCheckbox, 'Visible', 'off');
            set(hCurrentCheckbox, 'Enable', 'off');
            set(hCurrentCheckbox, 'Value' , 0);
            SetCheckBoxBG(hCurrentCheckbox);
        else
            p = particle(i);
            
            %cla; % clear axes
            set(axes_handle, 'Visible', 'on');
            
            PlotGraph(axes_handle, p, i);
            
            hold(axes_handle, 'on');
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
                
            
            hold(axes_handle, 'off');
            
            
            set(hCurrentCheckbox, 'Visible', 'on');
            set(hCurrentCheckbox, 'Enable', 'on');
            set(hCurrentCheckbox, 'Value' , p.valid);
            set(hCurrentCheckbox, 'UserData' , i); % store the number of the partice in the checkbox
            
            % this callback will be performed if the context menu is
            % clicked by the user
            uimenu(context_menu,  'Label', 'Show smooth graph', 'Callback', {@nmssResultsViewerPopupMenu, 'SmoothGraph', i, hFig});
            uimenu(context_menu,  'Label', 'Show unsmooth graph', 'Callback', {@nmssResultsViewerPopupMenu, 'UnSmoothGraph', i, hFig});
            uimenu(context_menu,  'Label', 'Show background', 'Callback', {@nmssResultsViewerPopupMenu, 'ShowBackground', i, hFig});
            uimenu(context_menu,  'Label', 'Show raw', 'Callback', {@nmssResultsViewerPopupMenu, 'ShowRaw', i, hFig});
            uimenu(context_menu,  'Label', 'Show (raw - bg)', 'Callback', {@nmssResultsViewerPopupMenu, 'ShowRawMinusBg', i, hFig});
            
            
            % plots the spectrum with blue and the noise filtered spectrum
            % with red
            uimenu(context_menu,  'Label', 'Show Noise Filteres', 'Callback', {@nmssResultsViewerPopupMenu, 'ShowNoiseFiltered', i, hFig});
              
            % plots the peak of the spectrum with blue and the fitted
            %  curve with green
            uimenu(context_menu,  'Label', 'Show fit', 'Callback', {@nmssResultsViewerPopupMenu, 'ShowFit', i, hFig});
              
            % plots the spectrum in with eV as the x-axis
            uimenu(context_menu,  'Label', 'Show eV', 'Callback', {@nmssResultsViewerPopupMenu, 'ShoweV', i, hFig});
            
            % plots res energy / wavelength position of the peak
            uimenu(context_menu,  'Label', 'Show Data', 'Callback', {@nmssResultsViewerPopupMenu, 'ShowData', i, hFig});
            
            if (isfield(user_data.results, 'real_space_image'))
                % shows the location of the particle on real space figure
                uimenu(context_menu,  'Label', 'Show in real space image', 'Callback', {@nmssResultsViewerPopupMenu, 'ShowInRealSpaceImg', i, hFig});
            end
            
            % shows the graph in an external figure
            uimenu(context_menu,  'Label', 'Zoom', 'Callback', {@nmssResultsViewerPopupMenu, 'Zoom', i, hFig});
            
            
            % shows the graphs of correlated particles
            if (num_of_corr_view_levels > 1) % only if more than one particle spectrum is loaded for the same particle
                uimenu(context_menu,  'Label', 'Correlated Spectra', 'Callback', {@nmssResultsViewerPopupMenu, 'CorrelatedSpectra', i, hFig});
            end
            UpdateCheckBoxBG(hCurrentCheckbox);
            SetGraphBg(axes_handle);
            
        end
        % get axes Tag
        set(axes_handle, 'Tag', axesTag );
        

    end
    user_data.PlotGraphCallback = @PlotGraph; % function handle of PlotGraph, this function can be called now from outside of this script
    set(hFig, 'UserData', user_data);
    
    % display the current page index number
    set(handles.editCurrentPageNo, 'String', ceil(start_index/num_of_axes_in_dlg));


% --------------------------------------------------------------------    
% plot graph
function PlotGraph(hAxes, particle, pIndex)

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
    
    % the axes know which particle is stored in them
    set(hAxes, 'UserData', pIndex);
    
    
    
% --------------------------------------------------------------------    
function SelectParticle(hCX)
    hFig = ancestor(hCX(1),'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
    particle_index = get(hCX, 'UserData');
    if (iscell(particle_index)) particle_index = cell2mat(particle_index); end;
    
    for i=1:length(particle_index)
        user_data.results.particle(particle_index(i)).valid = 1;
    end
    
    set(hFig, 'UserData', user_data);

% --------------------------------------------------------------------    
function UnSelectParticle(hCX)

    hFig = ancestor(hCX(1),'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
    particle_index = get(hCX, 'UserData');
    if (iscell(particle_index)) particle_index = cell2mat(particle_index); end;
    
    for i=1:length(particle_index)
        user_data.results.particle(particle_index(i)).valid = 0;
    end
    
    set(hFig, 'UserData', user_data);

    
function particle = GetCorrespondingParticle(hAxesOrCheckbox)

    particle_index = 0;
    particle = [];

    hFig = ancestor(hAxesOrCheckbox,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    if (isempty(user_data)) return; end;
    
    particle_index = get(hAxesOrCheckbox, 'UserData');
    if (isempty(particle_index)) return; end;
    
    try
        particle = user_data.results.particle(particle_index);
    catch
        disp(lasterr());
        keyboard;
    end


% --------------------------------------------------------------------
% sets the graph background color according to the selection status of the
% graph
function SetGraphBg(hAxes)
    particle = GetCorrespondingParticle(hAxes);
    
    if (particle.valid)
        set(hAxes, 'Color', [248 230 126] / 255);
    else
        set(hAxes, 'Color', [255 255 255] / 255);
    end


    
% -------------------------------------------------------------------- 
% reacts on the user's click on the checkbox
function CheckBoxAction(hCX)
    
    if (get(hCX, 'Value'))
         SelectParticle(hCX);
         set(hCX, 'BackgroundColor', [248 230 126] / 255);
    else
         UnSelectParticle(hCX);
         set(hCX, 'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
    end
     
    SetCheckBoxBG(hCX);

    hFig = ancestor(hCX(1),'figure','toplevel');
    particle_index = get(hCX, 'UserData');
    hAxes = findobj(hFig, '-regexp', 'Tag', ['axes\d*'],'-and', 'UserData', particle_index);
    SetGraphBg(hAxes);
     
% --------------------------------------------------------------------    
function UpdateCheckBoxBG(hCurrentCheckbox)
    particle = GetCorrespondingParticle(hCurrentCheckbox);
    
    if (particle.valid == 1)
        set(hCurrentCheckbox, 'Value', 1);
    else
        set(hCurrentCheckbox, 'Value', 0);
    end
    
    
    SetCheckBoxBG(hCurrentCheckbox);
    

function SetCheckBoxBG(hCX)

    if (get(hCX, 'Value'))
         set(hCX, 'BackgroundColor', [248 230 126] / 255);
    else
         set(hCX, 'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
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
    hFig = ancestor(hObject,'figure','toplevel');
    handles = guihandles(hFig);
    num_of_particles = GetNumOfAllParticles(hFig);
    num_of_axes_in_dlg = GetNumOfGraphAxesInDlg(hFig);    
    
%     % get particle.num in the last axes
%     hAxes = findobj(hFig, '-regexp', 'Tag', 'axes\d*');
%     particle_num = [get(hAxes, 'UserData')];
%     if (iscell(particle_num))
%         firstDisplayedParticleNum = min(cell2mat(particle_num));
%     else
%         firstDisplayedParticleNum = min(particle_num);
%     end
    
    firstDisplayedParticleNum = get(handles.axes01, 'UserData');
    
    start_index = firstDisplayedParticleNum - num_of_axes_in_dlg;

    %if (start_index + GetNumOfGraphAxesInDlg(hFig) <= num_of_particles)
    if (start_index <= num_of_particles && start_index >= 1)
        DisplayNextSetOfGraphs(hFig, start_index);
        UpdatePagerButtons(hFig);
    end

    
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    


    nmssResultsViewerDlg_CloseRequestFcn(handles.nmssResultsViewerDlg, eventdata, handles); 

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
     CheckBoxAction(hObject);
    
    
% --- Executes on button press in cxGraphSelection02.
function cxGraphSelection02_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection02
     CheckBoxAction(hObject);


% --- Executes on button press in cxGraphSelection03.
function cxGraphSelection03_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection03 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection03
     CheckBoxAction(hObject);



% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
     CheckBoxAction(hObject);


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
     CheckBoxAction(hObject);


% --- Executes on button press in cxGraphSelection06.
function cxGraphSelection06_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection06 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection06
     CheckBoxAction(hObject);


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
     CheckBoxAction(hObject);


% --- Executes on button press in cxGraphSelection08.
function cxGraphSelection08_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection08 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection08
     CheckBoxAction(hObject);

% --- Executes on button press in cxGraphSelection09.
function cxGraphSelection09_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection09 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection09
     CheckBoxAction(hObject);


% --- Executes on button press in cxGraphSelection10.
function cxGraphSelection10_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection10
     CheckBoxAction(hObject);


% --- Executes on button press in cxGraphSelection11.
function cxGraphSelection11_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection11
     CheckBoxAction(hObject);


% --- Executes on button press in cxGraphSelection12.
function cxGraphSelection12_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection12
     CheckBoxAction(hObject);


% --- Executes on button press in cxGraphSelection13.
function cxGraphSelection13_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection13
     CheckBoxAction(hObject);


% --- Executes on button press in cxGraphSelection14.
function cxGraphSelection14_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection14
     CheckBoxAction(hObject);


% --- Executes on button press in cxGraphSelection15.
function cxGraphSelection15_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection15
     CheckBoxAction(hObject);

% --- Executes on button press in cxGraphSelection16.
function cxGraphSelection16_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection16
     CheckBoxAction(hObject);


% --- Executes when user attempts to close nmssResultsViewerDlg.
function nmssResultsViewerDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssResultsViewerDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    button = questdlg('Do you really want to cancel? Any changes you have made will be lost!','Exit confirmation','Yes','No','No');
    % user does not want to exit
    if (strcmp(button,'No'))
        return;
    end
    
    Close(hObject);


function Close(hObject)    
    % perform clean up before closing the dialog
    
    % find all children with Tag containing 'nmssResultsViewerFigure_'
    hResultsViewFigure_Children = findobj('-regexp','Tag', 'nmssResultsViewerFigure_\w*');
    delete(hResultsViewFigure_Children);
%     hChildrenDlg = findobj('Tag', 'nmssCurveAnalysisDlg');
%     delete(hChildrenDlg);
    
    
    % Hint: delete(hObject) closes the figure
    delete(hObject);




% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, eventdata, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    user_data = get(handles.nmssResultsViewerDlg, 'UserData');
    
    user_canceled = user_data.hOKFcn(handles.nmssResultsViewerDlg);
    
    if (~user_canceled)
        Close(handles.nmssResultsViewerDlg); 
    end


% --- Executes on button press in pbSelectAll.
function pbSelectAll_Callback(hObject, eventdata, handles)
% hObject    handle to pbSelectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = handles.nmssResultsViewerDlg;
    user_data = get(hFig, 'UserData');
    
    % search using regular expression: 'cxGraphSelection\d{2}', means find
    % strings that contain cxGraphSelection and maximal two numeric
    % characters \d{2}
    hCx = findobj(hFig, 'Style', 'checkbox', '-and', '-regexp', 'Tag', 'cxGraphSelection\d{2}', ...
        '-and', 'Enable', 'on');
    if (iscell(hCx)) hCx = cell2mat(hCx); end;
    set(hCx, 'Value', 1);
    
    for i=1:length(hCx)
        CheckBoxAction(hCx(i));
    end
    
    % make all invalid particles that are currently not visible valid
    invalid_particle_index = find(~[user_data.results.particle(:,1).valid]);
    for i=1:length(invalid_particle_index)
        user_data.results.particle(invalid_particle_index(i),:).valid = true;
    end
    
    set(hFig, 'UserData', user_data);
        
%     
%     
%     
%     for i=1:length(nmssResultsViewerDlg_Data.checkbox_handles)
%         if (strcmp(get(nmssResultsViewerDlg_Data.checkbox_handles(i), 'Enable'),'on'))
%             set(nmssResultsViewerDlg_Data.checkbox_handles(i), 'Value', 1);
%             CheckBoxAction(i);
%         end
%     end
% 

% --- Executes on button press in pbUnselectAll.
function pbUnselectAll_Callback(hObject, eventdata, handles)
% hObject    handle to pbUnselectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    hFig = handles.nmssResultsViewerDlg;
    user_data = get(hFig, 'UserData');
    
    % search using regular expression: 'cxGraphSelection\d{2}', means find
    % strings that contain cxGraphSelection and maximal two numeric
    % characters \d{2}
    hCx = findobj(hFig, 'Style', 'checkbox', '-and', '-regexp', 'Tag', 'cxGraphSelection\d{2}', ...
        '-and', 'Enable', 'on');
    if (iscell(hCx)) hCx = cell2mat(hCx); end;
    set(hCx, 'Value', 0);
    
    for i=1:length(hCx)
        CheckBoxAction(hCx(i));
    end

    % make all valid particles that are currently not visible invalid
    particle_index = find([user_data.results.particle(:,1).valid]);
    for i=1:length(particle_index)
        user_data.results.particle(particle_index(i),:).valid = false;
    end

    set(hFig, 'UserData', user_data);


% --- Executes on button press in pbBergPlot.
function pbBergPlot_Callback(hObject, eventdata, handles)
% hObject    handle to pbBergPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    hFig = ancestor(hObject, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    particle = user_data.results.particle(find([user_data.results.particle(:).valid]),1);
    global nmssViewBergPlotGraph_Data;
    %selected_particle_index = find(nmssResultsViewerDlg_Data.particle_selected == 1);
    
    % copy selected results into the berg plot variable
    nmssViewBergPlotGraph_Data.particle = particle;
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
    
    hFig = ancestor(hObject,'figure','toplevel');
    
    user_data = get(hFig, 'UserData');
    
    user_data.hExportFcn(user_data.results);
    

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
    hFig = ancestor(hObject,'figure','toplevel');
    handles = guihandles(hFig);
    num_of_particles = GetNumOfAllParticles(hFig);
    
    
%     % get particle.num in the last axes
%     hAxes = findobj(hFig, '-regexp', 'Tag', 'axes\d*');
%     particle_num = [get(hAxes, 'UserData')];
%     if (iscell(particle_num))
%         lastDisplayedParticleNum = max(cell2mat(particle_num));
%     else
%         lastDisplayedParticleNum = max(particle_num);
%     end
    
    lastDisplayedParticleNum = get(handles.axes20, 'UserData');
    
    start_index = lastDisplayedParticleNum + 1;

    %if (start_index + GetNumOfGraphAxesInDlg(hFig) <= num_of_particles)
    if (start_index <= num_of_particles && start_index >= 1)
        DisplayNextSetOfGraphs(hFig, start_index);
        UpdatePagerButtons(hFig);
    end
    
%
% enables or diables page changing buttons in case the last or first page
% has been reached
function UpdatePagerButtons(hFig)
    handles = guihandles(hFig);
    num_of_particles = GetNumOfAllParticles(hFig);
    
    
    % get particle.num in the last axes
    hAxes = findobj(hFig, '-regexp', 'Tag', 'axes\d*');
    particle_num = [get(hAxes, 'UserData')];
    if (iscell(particle_num))
        lastDisplayedParticleNum = max(cell2mat(particle_num));
    else
        lastDisplayedParticleNum = max(particle_num);
    end
    
    start_index = lastDisplayedParticleNum - GetNumOfGraphAxesInDlg(hFig) + 1;

    if (start_index + GetNumOfGraphAxesInDlg(hFig) >= num_of_particles)
        set(handles.pbGetNextSetOfGraphs, 'Enable', 'off');
    else
        set(handles.pbGetNextSetOfGraphs, 'Enable', 'on');
    end
    if (start_index <= 1)
        set(handles.pbGetPreviousSetOfGraphs, 'Enable', 'off');
    else
        set(handles.pbGetPreviousSetOfGraphs, 'Enable', 'on');
    end
            

    
    
%--------------------------------------------------------------------------
function filter = FilterInit()
    
    filter.res_wl.use = false;
    filter.res_wl.not = false;
    filter.res_wl.operation = 'AND'; % possible values: 'AND'; 'OR'; 'NOT'; 'XOR'
    filter.res_wl.min = 0;
    filter.res_wl.max = inf;

    filter.fwhm.use = false;
    filter.fwhm.not = false;
    filter.fwhm.operation = 'AND';
    filter.fwhm.min = 0;
    filter.fwhm.max = inf;

    filter.peak_int.use = false;
    filter.peak_int.not = false;
    filter.peak_int.operation = 'AND';
    filter.peak_int.min = 0;
    filter.peak_int.max = inf;
    
    filter.selection_method = 'replace'; % other option: 'extend'

    
    
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
    hFig = ancestor(hObject,'figure','toplevel');
    %handles = guihandles(hFig);
    user_data = get(hFig, 'UserData');

    
    [user_action, filter] = nmssResultsViewFilterDlg(user_data.filter);
    if (strcmp(user_action, 'Cancel'))
        return;
    end
    user_data.filter = filter;
    
    % perform filtered selection
    % get indices that passed filter criteria
    indices_all = 1:length(user_data.results.particle(:,1));
    indices_filtered = indices_all;
    
    if (filter.res_wl.use)
        indices_res_wl = intersect(find([user_data.results.particle(:,1).res_energy] >= 1240 / filter.res_wl.max)', ...
                        find([user_data.results.particle(:,1).res_energy] <= 1240 / filter.res_wl.min)');
        if (filter.res_wl.not)
            % invers filtering
            indices_res_wl = setdiff(indices_all, indices_res_wl);
        end
        indices_filtered = indices_res_wl;
    end
    
    
    if (filter.fwhm.use)
        indices_FWHM = intersect(find([user_data.results.particle(:,1).FWHM] >= filter.fwhm.min)', ...
                        find([user_data.results.particle(:,1).FWHM] <= filter.fwhm.max)');
        if (filter.fwhm.not)
            % invers filtering
            indices_FWHM = setdiff(indices_all, indices_FWHM);
        end
        
        if (strcmp(filter.fwhm.operation, 'AND'))
            indices_filtered = intersect(indices_filtered, indices_FWHM);
        elseif (strcmp(filter.fwhm.operation, 'OR'))
            indices_filtered = union(indices_filtered, indices_FWHM);
        end
    end
                    
    if (filter.peak_int.use)
        indices_max_intensity = intersect(find([user_data.results.particle(:,1).max_intensity] >= filter.peak_int.min)', ...
                        find([user_data.results.particle(:,1).max_intensity] <= filter.peak_int.max)');
        if (filter.peak_int.not)
            % invers filtering
            indices_max_intensity = setdiff(indices_all, indices_max_intensity);
        end
        
        if (strcmp(filter.peak_int.operation, 'AND'))
            indices_filtered = intersect(indices_filtered, indices_max_intensity);
        elseif (strcmp(filter.peak_int.operation, 'OR'))
            indices_filtered = union(indices_filtered, indices_max_intensity);
        end
    end
    
    % update particle valid flag
    if (strcmp(filter.selection_method, 'replace'))
        % prepare selection to be replaced by the filtere selection
        for i=1:length(indices_all)
            user_data.results.particle(i, :).valid = 0;
        end
    end
    if (strcmp(filter.selection_method, 'remove'))
        % remove filtered particles from selection
        for i=1:length(indices_filtered)
            user_data.results.particle(indices_filtered(i), :).valid = 0;
        end
    else
        % add filtered particles to selection
        for i=1:length(indices_filtered)
            user_data.results.particle(indices_filtered(i), :).valid = 1;
        end
    end
    
    set(hFig, 'UserData', user_data);
    
    % refresh GUI:
    firstDisplayedParticleIndex = get(handles.axes01, 'UserData');
    start_index = firstDisplayedParticleIndex;
    
    DisplayNextSetOfGraphs(hFig, start_index);
    
                
            
    %InitDlg(handles);
    
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

    


% --- Executes on button press in cxGraphSelection17.
function cxGraphSelection17_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection17
     CheckBoxAction(hObject);


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18
     CheckBoxAction(hObject);


% --- Executes on button press in checkbox19.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox19
     CheckBoxAction(hObject);


% --- Executes on button press in cxGraphSelection20.
function cxGraphSelection20_Callback(hObject, eventdata, handles)
% hObject    handle to cxGraphSelection20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxGraphSelection20
     CheckBoxAction(hObject);

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

    hFig = ancestor(hObject, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    % get selected particles
    particle_index = find([user_data.results.particle(:).valid]);
    p = user_data.results.particle(particle_index,1);
%     for i=1:length(particle_index)
%         p(i).num = particle_index(i); % needed to identify the particle when returning from the dialog
%     end
    
    % OPEN dialog
    hDlg = nmssCurveAnalysisDlg();
    
    % give focus to the recently opened dialog
    figure(hDlg);
    %set(hDlg, 'WindowStyle', 'modal');
    nmssCurveAnalysisUserData = get(hDlg, 'UserData');
    
    if (isfield(user_data, 'nmssCurveAnalysisDlg_Data'))
        nmssCurveAnalysisUserData.Dlg_Data = user_data.nmssCurveAnalysisDlg_Data;
    else
        % init nmssCurveAnalysisDlg_Data here:
        
        % flag to indicate if the smoothed curve should be displayed
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.smoothed = true;
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.unsmoothed = true;
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.fittedcurve = true;
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.max = true;
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.peak_finding_range = true;
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.noise_filtered = true;
        
        % flag to indicate if the fitting should be performed on the raw
        % data or on the denoised data
        nmssCurveAnalysisUserData.Dlg_Data.use_denoised_data_to_fit = false;
        
        % the unit of the x-axis of the displayed curves
        nmssCurveAnalysisUserData.Dlg_Data.graphXAxisUnit = 'eV';
        
        % init peak parameters finding method
%        nmssCurveAnalysisUserData.Dlg_Data.peakFindingParams = nmssResetPeakFindingParam();
%         
%         % init the peak finding range dialog data
%         zzz.rangeStart = p(1).graph.axis.x(1);
%         zzz.rangeEnd = p(1).graph.axis.x(end);
%         zzz.eV_or_nm = nmssCurveAnalysisUserData.Dlg_Data.graphXAxisUnit;
%         if (strcmp(zzz.eV_or_nm, 'eV'))
%             zzz.rangeStart = 1240 / p(1).graph.axis.x(end);
%             zzz.rangeEnd = 1240 / p(1).graph.axis.x(1);
%         end
%         if (~isfield(nmssCurveAnalysisUserData.Dlg_Data, 'nmssPeakFindingRangeDlgData'))
%             nmssCurveAnalysisUserData.Dlg_Data.nmssPeakFindingRangeDlgData = zzz;
%         end
%         if (~isfield(nmssCurveAnalysisUserData.Dlg_Data, 'nmssPeakFittingRangeDlgData'))
%             nmssCurveAnalysisUserData.Dlg_Data.nmssPeakFittingRangeDlgData = zzz;
%         end
% 
    end
    
    % copy particle data structure into the particle variable
    %nmssCurveAnalysisUserData.Dlg_Data.selected_particle_index = particle_index;
    if (isempty(particle_index))
        errordlg('Please select at least one graph!')
        return;
    end
    
    nmssCurveAnalysisUserData.Dlg_Data.current_graph_index = 1;
    
    % copy particle struct to the analysis dialog particle struct
    nmssCurveAnalysisUserData.particle = p;
    
    % register callback function that is called whane user closes the
    % dialog with pressing OK
    nmssCurveAnalysisUserData.OKFunction = @CurveAnalysisDlg_OKFunction;
    nmssCurveAnalysisUserData.CallerFigHandle = hFig;
    
    % set dialog data
    set(hDlg, 'UserData', nmssCurveAnalysisUserData);
    
    % init dialog
    nmssCurveAnalysisUserData.hFigInitFcn(hDlg);
     

%
function CurveAnalysisDlg_OKFunction(hDlg)

    dlg_user_data = get(hDlg, 'UserData');
    hFig = dlg_user_data.CallerFigHandle;
    handles = guihandles(hFig);
    user_data = get(hFig, 'UserData');
    
    num_of_dialog_particle = length(dlg_user_data.particle);
    for i=1:num_of_dialog_particle
        % index magic
        pNum = dlg_user_data.particle(i,1).num; % get particle index in respect to the results viewer dialog
        pNewNum = find([user_data.results.particle(:,1).num] == pNum);
        
        %new_num = user_data.results.particle(pIndex,1).num; % get particle index in respect to the scan image analysis dialog
        user_data.results.particle(pNewNum,:) = dlg_user_data.particle(i,:);
%         user_data.results.particle(pIndex,:).num = new_num;
    end
    
    % retrieve dialog data and store parent!s dialog data
    user_data.nmssCurveAnalysisDlg_Data = dlg_user_data.Dlg_Data;
    
    set(hFig, 'UserData', user_data);
    
    % refresh GUI:
    firstDisplayedParticleIndex = get(handles.axes01, 'UserData');
    start_index = firstDisplayedParticleIndex;
    
    DisplayNextSetOfGraphs(hFig, start_index);
    
    


% --- Executes on button press in pbResonance.
function pbResonance_Callback(hObject, eventdata, handles)
% hObject    handle to pbResonance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    hFig = handles.nmssResultsViewerDlg;
    user_data = get(hFig, 'UserData');
    
    indices = intersect(find([user_data.results.particle.valid]), find([user_data.results.particle.res_energy]));
    
    res_en = [user_data.results.particle(indices).res_energy];
    
    [element_counts, bin_location] = hist(res_en, 20);
    
    m_res_en = mean(res_en);
    std_res_en = std(res_en);
    x_gauss = [min(bin_location):0.01:max(bin_location)];
    
    % this gauss curve is not normalized to have the area below the curve
    % be one
    f_gauss = max(element_counts) * exp(- ((x_gauss - m_res_en).^2) / (2 * std_res_en^2));
   
    
    % resopnance energy histogram
    figure;
    bar(bin_location, element_counts);
    hold on;
    plot(x_gauss, f_gauss, 'r-', 'Linewidth', 2);
    line([m_res_en, m_res_en], ylim, 'LineStyle', '--');
    title({'Histogram of Resonance Energy Distribution'; ...
          [sprintf('mean = %1.3f sigma= %2.3f', m_res_en, std_res_en)]});
    xlabel('E_r_e_s (eV)');
    
    % resopnance wavelength histogram
    res_wl = 1240 ./ res_en;
    m_res_wl = mean(res_wl);
    std_res_wl = std(res_wl);
    [element_counts, bin_location] = hist(res_wl, 20);
    x_gauss = [min(bin_location):0.01:max(bin_location)];
    
    % this gauss curve is not normalized to have the area below the curve
    % be one
    f_gauss = max(element_counts) * exp(- ((x_gauss - m_res_wl).^2) / (2 * std_res_wl^2));
    
    figure;
    bar(bin_location, element_counts);
    hold on;
    plot(x_gauss, f_gauss, 'r-', 'Linewidth', 2);
    line([m_res_wl, m_res_wl], ylim, 'LineStyle', '--');
    
    %hist(1240 ./ res_en, 20);
    title({'Histogram of Resonance Wavelength Distribution'; ...
          [sprintf('mean = %1.3f sigma= %2.3f', m_res_wl, std_res_wl)]});
    xlabel('\lambda_r_e_s (nm)');
    
%    
function cxCorrViewLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
