function varargout = nmssImageEnhancementDlg(varargin)
% NMSSIMAGEENHANCEMENTDLG M-file for nmssImageEnhancementDlg.fig
%      NMSSIMAGEENHANCEMENTDLG, by itself, creates a new NMSSIMAGEENHANCEMENTDLG or raises the existing
%      singleton*.
%
%      H = NMSSIMAGEENHANCEMENTDLG returns the handle to a new NMSSIMAGEENHANCEMENTDLG or the handle to
%      the existing singleton*.
%
%      NMSSIMAGEENHANCEMENTDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSIMAGEENHANCEMENTDLG.M with the given input arguments.
%
%      NMSSIMAGEENHANCEMENTDLG('Property','Value',...) creates a new NMSSIMAGEENHANCEMENTDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssImageEnhancementDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssImageEnhancementDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssImageEnhancementDlg

% Last Modified by GUIDE v2.5 01-Feb-2009 21:01:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssImageEnhancementDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssImageEnhancementDlg_OutputFcn, ...
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


% --- Executes just before nmssImageEnhancementDlg is made visible.
function nmssImageEnhancementDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssImageEnhancementDlg (see VARARGIN)

    % Choose default command line output for nmssImageEnhancementDlg
    handles.output = hObject;
    
    user_data.hFigInitFcn = @InitDlg;
    
    set(hObject, 'UserData', user_data);
    set(hObject, 'Tag', 'nmssImageEnhancementDlg');

    set(hObject, 'Visible', 'off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nmssImageEnhancementDlg wait for user response (see UIRESUME)
% uiwait(handles.nmssImageEnhancementDlg);


function InitDlg(hFig)
    user_data = get(hFig, 'UserData');
    
    hTFig = user_data.targetFigure;
    figure(hTFig);
    cmap = colormap;

    new_mean = mean(cmap(:,1));
    new_std = std(cmap(:,1));

    
    user_data.cmap.mean = new_mean;
    user_data.cmap.std = new_std;
    
    set(hFig, 'UserData', user_data);
    
    set(hFig, 'Visible', 'on');
    %set(hDlg, 'WindowStyle', 'modal');
    
% returns the normalized image    
function imgn = GetNormalizedImage(hFig)
    img = GetImage(hFig);
    imgbg = img - min(img(:));
    imgn = cast(imgbg, 'double') / cast(max(imgbg(:)), 'double');


% returns the image    
function img = GetImage(hFig)
    user_data = get(hFig, 'UserData');
    
    hTFig = user_data.targetFigure;

    hImage = findobj(hTFig, 'Type', 'image');
    if (isempty(hImage))
        error(sprintf('Couldn''t find image in figure %d',  hTFig));
        return;
    end
    img = get(hImage, 'CData');
    

% --- Outputs from this function are returned to the command line.
function varargout = nmssImageEnhancementDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% uses the normal cdf (cumulative distribution function) to get a colormap
% scheme
function cmap = GetCmap(color_depth, meancmap, stdcmap)

    cmap_gauss_fit = normcdf([0:color_depth]/color_depth,meancmap,stdcmap);
    cmap =[cmap_gauss_fit(:), cmap_gauss_fit(:), cmap_gauss_fit(:)];
    

% --- Executes on button press in btnIncreaseBrightnes.
function btnIncreaseBrightnes_Callback(hObject, eventdata, handles)
% hObject    handle to btnIncreaseBrightnes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
    hTFig = user_data.targetFigure;

    figure(hTFig);
    cmap = colormap;
    new_mean = user_data.cmap.mean - 0.0025;
    new_std = user_data.cmap.std;
    
    cmap = GetCmap(length(cmap(:,1)), new_mean, new_std);
    colormap(cmap);
    
    user_data.cmap.mean = new_mean;
    user_data.cmap.std = new_std;
    set(hFig, 'UserData', user_data);
    
    DrawCmap(hFig, cmap);

% --- Executes on button press in btnReduceBrightness.
function btnReduceBrightness_Callback(hObject, eventdata, handles)
% hObject    handle to btnReduceBrightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
    hTFig = user_data.targetFigure;

    figure(hTFig);
    cmap = colormap;
    
    new_mean = user_data.cmap.mean + 0.0025;
    new_std = user_data.cmap.std;
    
    cmap = GetCmap(length(cmap(:,1)), new_mean, new_std);
    colormap(cmap);
    
    user_data.cmap.mean = new_mean;
    user_data.cmap.std = new_std;
    set(hFig, 'UserData', user_data);

    DrawCmap(hFig, cmap);

% --- Executes on button press in btnReduceContrast.
function btnReduceContrast_Callback(hObject, eventdata, handles)
% hObject    handle to btnReduceContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
    hTFig = user_data.targetFigure;

    figure(hTFig);
    cmap = colormap;
    
    new_mean = user_data.cmap.mean;
    new_std = user_data.cmap.std + 0.0025;
    
    cmap = GetCmap(length(cmap(:,1)), new_mean, new_std);
    colormap(cmap);
    
    user_data.cmap.mean = new_mean;
    user_data.cmap.std = new_std;
    set(hFig, 'UserData', user_data);

    DrawCmap(hFig, cmap);



% --- Executes on button press in btnIncreaseContrast.
function btnIncreaseContrast_Callback(hObject, eventdata, handles)
% hObject    handle to btnIncreaseContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    hFig = ancestor(hObject, 'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
    hTFig = user_data.targetFigure;

    figure(hTFig);
    cmap = colormap;
    
    new_mean = user_data.cmap.mean;
    new_std = user_data.cmap.std - 0.0025;
    if (new_std <= 0)
        new_std = user_data.cmap.std;
    end
    
    cmap = GetCmap(length(cmap(:,1)), new_mean, new_std);
    colormap(cmap);
    
    user_data.cmap.mean = new_mean;
    user_data.cmap.std = new_std;
    set(hFig, 'UserData', user_data);

    DrawCmap(hFig, cmap);

function cmap = AutoScale(hFig)
    user_data = get(hFig, 'UserData');
    
    hTFig = user_data.targetFigure;
    figure(hTFig);
    cmap = colormap;
    
    color_depth = length(cmap(:,1));
    imgn = GetNormalizedImage(hFig);    
    
    new_mean = mean(imgn(:));
    new_std = std(imgn(:));

    cmap = GetCmap(length(cmap(:,1)), new_mean, new_std);
    
    user_data.cmap.mean = new_mean;
    user_data.cmap.std = new_std;
    set(hFig, 'UserData', user_data);


% --- Executes on button press in btnAutoScale.
function btnAutoScale_Callback(hObject, eventdata, handles)
% hObject    handle to btnAutoScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
    cmap = AutoScale(hFig);
    hTFig = user_data.targetFigure;
    figure(hTFig);
    colormap(cmap);
    
    DrawCmap(hFig, cmap);

% --- Executes when user attempts to close nmssImageEnhancementDlg.
function nmssImageEnhancementDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssImageEnhancementDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % delete any figures that were called from within this figure
    hFig = ancestor(hObject, 'figure','toplevel');
    hCmapFig = findobj('Tag', 'figCmap', 'UserData', hFig);
    if (~isempty(hCmapFig))
        close(hCmapFig);
    end


% Hint: delete(hObject) closes the figure
delete(hObject);




% --- Executes on button press in btnDecreaseThreshold.
function btnDecreaseThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to btnDecreaseThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnIncreaseThreshold.
function btnIncreaseThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to btnIncreaseThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    
function DrawCmap(hFig, cmap)
    hCmapFig = findobj('Tag', 'figCmap', 'UserData', hFig);
    if (isempty(hCmapFig))
        return;
    end
    figure(hCmapFig);
    hline = findobj(hCmapFig,'type','Line','DisplayName','cmap');
    if (isempty(hline))
        hold on;
        hline = plot([1:length(cmap(:,1))]/length(cmap(:,1)),cmap(:,1), 'DisplayName','cmap');
    else
        set(hline,'YData',cmap(:,1));
        set(hline,'XData',[1:length(cmap(:,1))]/length(cmap(:,1)));
    end
    
    % always display graph in its max limits
    xlim([0, 1]);
    ylim([0, 1]);

% --- Executes on button press in btnPlotColorMap.
function btnPlotColorMap_Callback(hObject, eventdata, handles)
% hObject    handle to btnPlotColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
    % check if figure has been alread opened, if yes return, don't open new
    % figure
    hCmapFig = findobj('Tag', 'figCmap', 'UserData', hFig);
    if (~isempty(hCmapFig))
        return;
    end
    
    hTFig = user_data.targetFigure;
    figure(hTFig);
    cmap = colormap;
    
    
    cmap_autoscale = AutoScale(hFig);    
    
    hCmapFig = figure;
    set(hCmapFig, 'Tag', 'figCmap');
    set(hCmapFig, 'UserData', hFig); % remember which one is the caller dialog
    plot([1:length(cmap_autoscale(:,1))]/length(cmap_autoscale(:,1)),cmap_autoscale(:,1), 'g--', 'DisplayName','autoscale cmap', 'LineWidth', 3);
    xlabel('Intensity');
    ylabel('Displayed Intensity');
    title('Grayscale Colormap');
    hold on;
    DrawCmap(hFig, cmap);
    
%     % get target figure image
%     hImage = findobj(hTFig, 'Type', 'image');
%     img = get(hImage, 'CData');
% 
%     figure; hist(img(:),100); % (:) regards the matrix as one column



