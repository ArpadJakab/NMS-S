function varargout = nmssViewBergPlotGraphMenu(varargin)
% NMSSVIEWBERGPLOTGRAPHMENU M-file for nmssViewBergPlotGraphMenu.fig
%      NMSSVIEWBERGPLOTGRAPHMENU, by itself, creates a new NMSSVIEWBERGPLOTGRAPHMENU or raises the existing
%      singleton*.
%
%      H = NMSSVIEWBERGPLOTGRAPHMENU returns the handle to a new NMSSVIEWBERGPLOTGRAPHMENU or the handle to
%      the existing singleton*.
%
%      NMSSVIEWBERGPLOTGRAPHMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSVIEWBERGPLOTGRAPHMENU.M with the given input arguments.
%
%      NMSSVIEWBERGPLOTGRAPHMENU('Property','Value',...) creates a new NMSSVIEWBERGPLOTGRAPHMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssViewBergPlotGraphMenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssViewBergPlotGraphMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssViewBergPlotGraphMenu

% Last Modified by GUIDE v2.5 18-Mar-2008 20:25:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssViewBergPlotGraphMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssViewBergPlotGraphMenu_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
%     % parse input parameters of the dialog box
%     if (length(varargin) >= 2)
%         if (strcmp(varargin{1},'Results'))
%             global nmssViewBergPlotGraph_Data;
%             nmssViewBergPlotGraph_Data.results.particle = varargin{2};
%         end
%     end
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before nmssViewBergPlotGraphMenu is made visible.
function nmssViewBergPlotGraphMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssViewBergPlotGraphMenu (see VARARGIN)

% Choose default command line output for nmssViewBergPlotGraphMenu
handles.output = hObject;

    global nmssViewBergPlotGraph_Data;
    if (isfield(nmssViewBergPlotGraph_Data,'particle'))
        % reset handle that stores the figure handle of the berg plot
        nmssViewBergPlotGraph_Data.berg_plot_fig = -1;
        
        nmssViewBergPlotGraph_Data.berg_plot_fig = GetBergPlotFigure(nmssViewBergPlotGraph_Data.particle);
    end


    
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssViewBergPlotGraphMenu wait for user response (see UIRESUME)
% uiwait(handles.nmssViewBergPlotGraphMenu);


% --- Outputs from this function are returned to the command line.
function varargout = nmssViewBergPlotGraphMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function berg_plot_fig = GetBergPlotFigure(particle)
% activates or creates the berg plot figure
    global nmssViewBergPlotGraph_Data;
    berg_plot_fig = 0;
    
    if (isfield(nmssViewBergPlotGraph_Data, 'berg_plot_fig') & ishandle(nmssViewBergPlotGraph_Data.berg_plot_fig) )
        figure(nmssViewBergPlotGraph_Data.berg_plot_fig);
        berg_plot_fig = nmssViewBergPlotGraph_Data.berg_plot_fig;
    else
        nmssViewBergPlotGraph_Data.berg_plot_fig = figure;
        set(nmssViewBergPlotGraph_Data.berg_plot_fig, 'Name', 'Berg Plot');
        berg_plot = CreateBergPlot(particle);
        % display berg plot
        plot(berg_plot(:,1), berg_plot(:,2),'.');
        xlabel('Res. Energy (eV)');
        ylabel('FWHM (eV)');
    end


function berg_plot = CreateBergPlot(particle)
% creates berg plot from results
    
    % create Berg plot
    berg_plot = zeros(0,3);
    for i=1:length(particle)
        if (~isempty(particle(i)))
            if ((particle(i).valid == 1) & (particle(i).res_energy ~= 0))
                
                % fix for different definitions of the FWHM struct
                if (isstruct(particle(i).FWHM))
                    fwhm = particle(i).FWHM.full;
                else
                    fwhm = particle(i).FWHM;
                end
                    
                berg_plot = [berg_plot; particle(i).res_energy, fwhm, particle(i).max_intensity];
            end
        end
    end


% --- Executes on button press in pbSelectDataPoint.
function pbSelectDataPoint_Callback(hObject, eventdata, handles)
% hObject    handle to pbSelectDataPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global nmssViewBergPlotGraph_Data;
    
    % does berg plot figure exist? if no create it!!
    if (~ishandle(nmssViewBergPlotGraph_Data.berg_plot_fig))
        nmssViewBergPlotGraph_Data.berg_plot_fig = GetBergPlotFigure(nmssViewBergPlotGraph_Data.particle);
    end
        
    % put focus on the berg plot figure
    %figure(nmssViewBergPlotGraph_Data.berg_plot_fig);
    
    k = waitforbuttonpress;
    point1 = get(gca,'CurrentPoint');    % button down detected
    finalRect = rbbox;                   % return figure units
    point2 = get(gca,'CurrentPoint');    % button up detected
    
    % get top left and bottom right coordinates of the rectangle
    corner_top_left = point1;
    corner_bottom_right = point2;
    if (corner_top_left(1,1) > corner_bottom_right(1,1))
        tmp = corner_bottom_right(1,1);
        corner_bottom_right(1,1) = corner_top_left(1,1);
        corner_top_left(1,1) = tmp;
    end
    if (corner_top_left(1,2) < corner_bottom_right(1,2))
        tmp = corner_bottom_right(1,2);
        corner_bottom_right(1,2) = corner_top_left(1,2);
        corner_top_left(1,2) = tmp;
    end
    
    nmssDrawRectBetween2Points(corner_top_left, corner_bottom_right, 1, 'r');
    
    part2plot = {};
    j=1;
    
    for i=1:length(nmssViewBergPlotGraph_Data.particle)
        particle = nmssViewBergPlotGraph_Data.particle(i);

        % fix for different definitions of the FWHM struct
                if (isstruct(particle.FWHM))
                    fwhm = particle.FWHM.full;
                else
                    fwhm = particle.FWHM;
                end
        
        
        if (particle.res_energy >= corner_top_left(1,1) & particle.res_energy <= corner_bottom_right(1,1) & ...
            fwhm <= corner_top_left(1,2) & fwhm >= corner_bottom_right(1,2))
            
            part2plot{j,1} = particle;
            j=j+1;
            %plot a the graph corresponding to the data point
            %figure;
            %plot(particle.graph.axis.x, particle.graph.normalized);
        end
    end

    fig = nmssPlotGraph(part2plot, 'White Light normalized BG corrected spectra', 'normalized');
%     nmssPlotGraph(part2plot, 'White Light normalized BG corrected spectra, smoothed', 'smoothed');
%     nmssPlotGraph(part2plot, 'Particle raw data', 'particle');
%     nmssPlotGraph(part2plot, 'Background raw data','bg');
    
    


% --- Executes when user attempts to close nmssViewBergPlotGraphMenu.
function nmssViewBergPlotGraphMenu_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssViewBergPlotGraphMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global nmssViewBergPlotGraph_Data;
    clear nmssViewBergPlotGraph_Data;

% Hint: delete(hObject) closes the figure
delete(hObject);


