function varargout = nmssGraphSelection(varargin)
% NMSSGRAPHSELECTION M-file for nmssGraphSelection.fig
%      NMSSGRAPHSELECTION, by itself, creates a new NMSSGRAPHSELECTION or raises the existing
%      singleton*.
%
%      H = NMSSGRAPHSELECTION returns the handle to a new NMSSGRAPHSELECTION or the handle to
%      the existing singleton*.
%
%      NMSSGRAPHSELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSGRAPHSELECTION.M with the given input arguments.
%
%      NMSSGRAPHSELECTION('Property','Value',...) creates a new NMSSGRAPHSELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssGraphSelection_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssGraphSelection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssGraphSelection

% Last Modified by GUIDE v2.5 05-Jun-2008 21:37:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssGraphSelection_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssGraphSelection_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    % parse input parameters of the dialog box
%     if (length(varargin) >= 2)
%         if (strcmp(varargin{1},'Figure'))
%             global nmssGraphSelection_Data;
%             nmssGraphSelection_Data.fig = varargin{2};
%         end
%     end
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before nmssGraphSelection is made visible.
function nmssGraphSelection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssGraphSelection (see VARARGIN)

% Choose default command line output for nmssGraphSelection
handles.output = hObject;

    global nmssGraphSelection_Data;
    nmssGraphSelection_Data.get_new_graph = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssGraphSelection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nmssGraphSelection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbSelectGraph.
function pbSelectGraph_Callback(hObject, eventdata, handles)
% hObject    handle to pbSelectGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssGraphSelection_Data
    figure(nmssGraphSelection_Data.fig);
    
    [x, y] = ginput(1)
    
    

% --- Executes on button press in pbNextSetOfGraphs.
function pbNextSetOfGraphs_Callback(hObject, eventdata, handles)
% hObject    handle to pbNextSetOfGraphs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssGraphSelection_Data
    nmssGraphSelection_Data.get_new_graph = 1; % if 1 a new set of graphs is loaded
    nmssGraphSelection_CloseRequestFcn(handles.nmssGraphSelection, eventdata, handles);

% --- Executes on button press in pbQuit.
function pbQuit_Callback(hObject, eventdata, handles)
% hObject    handle to pbQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssGraphSelection_Data
    nmssGraphSelection_Data.get_new_graph = 0; % if 0 no more graphs are loaded
    nmssGraphSelection_CloseRequestFcn(handles.nmssGraphSelection, eventdata, handles);




% --- Executes when user attempts to close nmssGraphSelection.
function nmssGraphSelection_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssGraphSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


