function varargout = nmssImageOverlay(varargin)
% NMSSIMAGEOVERLAY M-file for nmssImageOverlay.fig
%      NMSSIMAGEOVERLAY, by itself, creates a new NMSSIMAGEOVERLAY or raises the existing
%      singleton*.
%
%      H = NMSSIMAGEOVERLAY returns the handle to a new NMSSIMAGEOVERLAY or the handle to
%      the existing singleton*.
%
%      NMSSIMAGEOVERLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSIMAGEOVERLAY.M with the given input arguments.
%
%      NMSSIMAGEOVERLAY('Property','Value',...) creates a new NMSSIMAGEOVERLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssImageOverlay_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssImageOverlay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssImageOverlay

% Last Modified by GUIDE v2.5 22-Feb-2009 21:02:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssImageOverlay_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssImageOverlay_OutputFcn, ...
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


% --- Executes just before nmssImageOverlay is made visible.
function nmssImageOverlay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssImageOverlay (see VARARGIN)

% Choose default command line output for nmssImageOverlay
handles.output = hObject;
    
    hFig = hObject;

    %global nmssImageOverlayDlg_Data;

    % initialize variables
    user_data.results = {};
    
    set(hFig, 'UserData');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssImageOverlay wait for user response (see UIRESUME)
% uiwait(handles.nmssImageOverlay);


% --- Outputs from this function are returned to the command line.
function varargout = nmssImageOverlay_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in lbResults.
function lbResults_Callback(hObject, eventdata, handles)
% hObject    handle to lbResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lbResults contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbResults


% --- Executes during object creation, after setting all properties.
function lbResults_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in btnClose.
function btnClose_Callback(hObject, eventdata, handles)
% hObject    handle to btnClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    nmssImageOverlay_CloseRequestFcn(handles.nmssImageOverlay, eventdata, handles);

% --- Executes on button press in btnImportResults.
function btnImportResults_Callback(hObject, eventdata, handles)
% hObject    handle to btnImportResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %global nmssImageOverlayDlg_Data;
    global doc;
    
    hFig = ancestor(hObject, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    old_work_dir = pwd();
    
    if (isfield(doc, 'workDir'))
        cd(doc.workDir);
    end
    
    [filename, dirname] = uigetfile({'*.mat','Matlab data file (*.mat)'}, 'Load results - Select file');
    
    cd(old_work_dir);
    
    if (filename == 0) % user pressed cancel
        return;
    end
    
    results_file_path = fullfile(dirname, filename);
    
    load(results_file_path ); % load struct called: results
    
    
    
    % Before opening the dialog fill dialog data
    if (exist('results'))
        results_tmp = results;
    elseif (exist('results_selected'))
        results_tmp = results_selected;
    else
        errordlg('No results data found in this file');
        return;
    end
    
    % we will need the file path from which the results have been loaded
    results_tmp.source_dir = results_file_path;
    if (isfield(user_data, 'results'))
        user_data.results{end + 1} = results_tmp;
    else
        user_data.results{1} = results_tmp;
    end
    
    % update listbox
    list_box_entry = get(handles.lbResults, 'String');
    num_of_new_entry = length(list_box_entry) + 1;
    
    list_box_entry{end + 1} = [num2str(num_of_new_entry), ' ', results_file_path];
    
    set(handles.lbResults, 'String', list_box_entry);
    set(handles.lbResults, 'Value', num_of_new_entry);
    
    set(hFig, 'UserData', user_data);
    



% --- Executes on button press in btnCorrelate.
function btnCorrelate_Callback(hObject, eventdata, handles)
% hObject    handle to btnCorrelate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
%     hButtons = findobj(handles.nmssImageOverlay, 'Style','pushbutton');
%     set(hButtons, 'Enable', 'off');
% 
%     ParticleCorrelation(handles);
%     
%     set(hButtons, 'Enable', 'on');

    hFig = ancestor(hObject, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');

    
    % loop through each results data
    % find valid particles and link them if their numbers match
    
    num_of_results = length(user_data.results);
    
    % get indices of valid particles in data the first results struct
    % this seems to be sufficient, since we want to have the intersection
    % of all results data sets
    
    vi = [find([user_data.results{1}.particle(:).valid])];
    valid_particle_num = [user_data.results{1}.particle(vi).num];
    
    num_of_corr_particles = 0;
    
    % create a vector of particle numbers that refer to valid particles in
    % all results data sets
    for i=2:num_of_results
        vi = [find([user_data.results{i}.particle(:).valid])];
        valid_particle_num = intersect(valid_particle_num,[user_data.results{1}.particle(vi).num]);
    end
    
    num_of_corr_particles = length(valid_particle_num);
    for i=1:num_of_corr_particles
        for j=1:num_of_results
            corr_part.particle(i,j) = user_data.results{j}.particle(find([user_data.results{j}.particle(:).num] == valid_particle_num(i)));
        end
    end
    
    % get old working directory
    old_current_dir = pwd;
    
    cd(doc.workDir);

    [filename, dirname] = uiputfile({'*.mat','Matlab data (*.mat)'}, 'Save correlated particles', 'corr_part.mat');
    cd(old_current_dir);

    if (filename ~= 0) % user pressed OK in file save dialog

        % save berg plot matrix
        filepath = fullfile(dirname, filename)
        try
            save(filepath, 'corr_part', '-mat');
        catch
            errordlg(lasterr());
        end
    end
    
    
    
function ParticleCorrelation(handles)    

    global nmssImageOverlayDlg_Data;
    global doc;

    
    selected_results_index = get(handles.lbResults, 'Value');
    num_of_selected_results = length(selected_results_index);
    if(num_of_selected_results < 2)
        errordlg('Please select at least two results to correlate!');
        return;
    end
    
    res = {};
    for i = 1:num_of_selected_results
        res{i} = nmssImageOverlayDlg_Data.results{selected_results_index(i)};
    end
    

    
    % here we start the particle correlation module
    corr_part = nmssFindParticle( res );
    
    % get old working directory
    old_current_dir = pwd;
    
    cd(doc.workDir);

    [filename, dirname] = uiputfile({'*.mat','Matlab data (*.mat)'}, 'Save correlated particles', 'corr_part.mat');
    cd(old_current_dir);

    if (filename ~= 0) % user pressed OK in file save dialog

        % save berg plot matrix
        filepath = fullfile(dirname, filename)
        try
            save(filepath, 'corr_part', '-mat');
        catch
            errordlg(lasterr());
        end
    end

% --- Executes when user attempts to close nmssImageOverlay.
function nmssImageOverlay_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssImageOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    clear nmssImageOverlayDlg_Data;
    


% Hint: delete(hObject) closes the figure
delete(hObject);


