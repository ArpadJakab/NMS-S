function varargout = nmssFigure(varargin)
% NMSSFIGURE M-file for nmssFigure.fig
%      NMSSFIGURE, by itself, creates a new NMSSFIGURE or raises the existing
%      singleton*.
%
%      H = NMSSFIGURE returns the handle to a new NMSSFIGURE or the handle to
%      the existing singleton*.
%
%      NMSSFIGURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSFIGURE.M with the given input arguments.
%
%      NMSSFIGURE('Property','Value',...) creates a new NMSSFIGURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssFigure_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssFigure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssFigure

% Last Modified by GUIDE v2.5 19-Jul-2011 18:24:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssFigure_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssFigure_OutputFcn, ...
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


% --- Executes just before nmssFigure is made visible.
function nmssFigure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssFigure (see VARARGIN)


    % Choose default command line output for nmssFigure
    handles.output = hObject;
    
    % store handle of this dialog (or call it figure)
    global app;
    app.nmssFigure = hObject;

    if (ishandle(app.nmssSpecAnalysisDlg))
        delete(app.nmssSpecAnalysisDlg);
    end

    global nmssFigureData;
    global doc;
    
    % register the function which is being called, when the user presses a
    % key while this figure window has focus
    set(hObject, 'KeyPressFcn', @nmssFigure_KeyPressFcn);
    
    % get the original dimensions of the window and its GUI elements
    % (needed for resizing informaions)
    win_size = get(hObject, 'Position');
    canvas_size = get(handles.canvasFigureAxes, 'Position');
    nmssFigureData.canvas.origpos.y = canvas_size(1,2);
    nmssFigureData.canvas.origpos.x = canvas_size(1,1);
    nmssFigureData.canvas.distfromtop = win_size(1,4) - canvas_size(1,2) - canvas_size(1,4);
    nmssFigureData.canvas.distfromright = win_size(1,3) - canvas_size(1,1) - canvas_size(1,3);
    
%     if (doc.sum_up_jobs)
%         nmssFigureData.cur_job_index = -1;
%         job = doc.current_job;
%     else
        % display the last image
        %nmssFigureData.cur_job_index = length(doc.current_job);
        nmssFigureData.cur_job_index = 1;
        job = doc.current_job(nmssFigureData.cur_job_index); % display last job (image)
%     end

        
    if(length(doc.img) == 0)
        [status camera_image] = OpenJobAndGetImage(job, doc.workDir);
        
        % job couldn't be opened for whatever reason let's take the next
        % one
        if(strcmp(status, 'ERROR'))
            return;
        end
        doc.img = camera_image;
    end
    
    PaintNewImage(handles.nmssFigure, handles.canvasFigureAxes, doc.img);
    %PaintNewImage(handles);
    
    % display in the window title bar the file name(s) of the displayed
    % file(s)
    set(handles.nmssFigure, 'Name', ['NMSS Figure: ', job.filename]);
    set(handles.editGratingCentralWL, 'String', num2str(job.central_wavelength));

    % create context menu for the axes. the conext menu can contain
    % different menu entries to react on the user's mouse click
    % the menu entries will be filled up later in this function
    % 'Parent' is the figure which is the same parent as for the axes
    context_menu = uicontextmenu('Parent', handles.nmssFigure);
    % link axes with the context menu
    % set(handles.canvasFigureAxes, 'UIContextMenu', context_menu); 
    
    % get handle of the image
    hImage = findobj(handles.canvasFigureAxes, 'Type', 'Image');
    % link image with the context menu
    set(hImage, 'UIContextMenu', context_menu); 
    
    cb = @AxesPopupMenu;
    
    if (strcmp(get(handles.menuMark_red, 'Checked'), 'on'))
        nmssFigureData.menuMarkerColor = 'r';
    elseif (strcmp(get(handles.menuMark_yellow, 'Checked'), 'on'))
        nmssFigureData.menuMarkerColor = 'y';
    elseif (strcmp(get(handles.menuMark_green, 'Checked'), 'on'))
        nmssFigureData.menuMarkerColor = 'g';
    elseif (strcmp(get(handles.menuMark_blue, 'Checked'), 'on'))
        nmssFigureData.menuMarkerColor = 'b';
    else
        nmssFigureData.menuMarkerColor = 'r';
    end
    uimenu(context_menu,  'Label', 'Mark', 'Callback', cb);    
    
    
    
    % Update handles structure
    guidata(hObject, handles);

    
    % UIWAIT makes nmssFigure wait for user response (see UIRESUME)
    % uiwait(handles.nmssFigure);

    
% procedure performed at right click on the image or the axis
function AxesPopupMenu(varargin)
    global app;
    global nmssFigureData;

    % get mouse position
    [x,y] = ginput(1);
    
    DrawMarker(x, y, 6, 6);
    
    
function hRectangle = DrawMarker(x, y, size_x, size_y)
    global nmssFigureData;
    global app;

    % create rectangle graphic object
    hRectangle = nmssDrawRectAroundCenter(x, y, size_x, size_y, 'nmss_bright_spot'); % tagged as bright spot
    set(hRectangle, 'Color', nmssFigureData.menuMarkerColor);
    
    % attach context menu to the rectanlge graphic object
    rectangle_context_menu = uicontextmenu('Parent', app.nmssFigure);
    set(hRectangle, 'UIContextMenu', rectangle_context_menu);
    
    cb = @BrightSpotPopupMenu; % function handle to the context menu call
    uimenu(rectangle_context_menu,  'Label', 'Delete', 'Callback', cb);

    

% procedure performed at right click on a bright spot marker
function BrightSpotPopupMenu(varargin)
    global app;
    
    % find the object which called this uimenu callback
    hRectangle = findobj(app.nmssFigure, 'UIContextMenu', get(varargin{1}, 'Parent'));
    delete(hRectangle);
    
    
function [status camera_image] = OpenJobAndGetImage(job, curr_dir, varargin)
    camera_image = 0;
    status = 'OK';
    
    % show error messages or not?
    silent = false;
    if (length(varargin) == 1)
        if (strcmp(varargin{1}, 'silent'))
            silent = true;
        else
            error({'Unknown input parameter: ', varargin{1}});
        end
    end

        [status camera_image job] = nmssOpenJobImage(job.filename, curr_dir);

    % job couldn't be opened for whatever reason let's take the next
    % one
    if(strcmp(status, 'ERROR'))
        
        if (silent)
            return;
        else
            errordlg(camera_image);
            return;
        end
    end
    
    camera_image = camera_image';
    

    
    
% --- Outputs from this function are returned to the command line.
function varargout = nmssFigure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = handles.canvasFigureAxes;

% Get default command line output from handles structure
varargout{1} = handles.output;

%

function PaintNewImage(hFigure, hAxes, img)
    global doc;
    global nmssFigureData;
    
    doc.figure_axis = nmssSetAxis(doc.figure_axis.unit);
    
    job = doc.current_job(nmssFigureData.cur_job_index);
    
    % conflicting unit settings
    % imaging mode and nanometers
    if (job.central_wavelength == 0 && strcmp(doc.figure_axis.unit.x,'nanometer'))
        % set axis to pixels
        px_units.x = 'pixel';
        px_units.y = 'pixel';
        doc.figure_axis = nmssSetAxis(px_units);
    
    % spectroscopy mode and microns
    elseif (job.central_wavelength ~= 0 && strcmp(doc.figure_axis.unit.x,'micron'))
        % set axis to pixels
        px_units.x = 'pixel';
        px_units.y = 'pixel';
        doc.figure_axis = nmssSetAxis(px_units);
    elseif (job.central_wavelength ~= 0 && ~strcmp(doc.figure_axis.unit.x,'nanometer'))
        % set axis to nanometers if in spectroscopy mode
        px_units.x = 'nanometer';
        px_units.y = 'pixel';
        doc.figure_axis = nmssSetAxis(px_units);
    end

    full_lim.x = ([1, size(img,2)] - size(img,2) / 2.0) * doc.figure_axis.scale.current.x + doc.figure_axis.center.x;
    full_lim.y = ([1, size(img,1)] - size(img,1) / 2.0) * doc.figure_axis.scale.current.y + doc.figure_axis.center.y;
    
    nmssPaintImage('new', img, hFigure, hAxes, full_lim, full_lim);



%
function RefreshImage(hFigure, hAxes, img)
%function RefreshImage(handles)
    global doc;

    full_lim.x = ([1, size(img,2)] - size(img,2) / 2.0) * doc.figure_axis.scale.current.x + doc.figure_axis.center.x;
    full_lim.y = ([1, size(img,1)] - size(img,1) / 2.0) * doc.figure_axis.scale.current.y + doc.figure_axis.center.y;

    figure(hFigure);
    current_limits.x = xlim;
    current_limits.y = ylim;
    
    nmssPaintImage('refresh', img, hFigure, hAxes, full_lim, current_limits);


% --- Executes on button press in btnPan.
function btnPan_Callback(hObject, eventdata, handles)
% hObject    handle to btnPan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of btnPan
    if (get(hObject,'Value'))
        pan on;
    else
        pan off;
    end

% --- Executes on button press in btnZoom.
function btnZoom_Callback(hObject, eventdata, handles)
% hObject    handle to btnZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of btnZoom
    if (get(hObject,'Value'))
        zoom on;
    else
        zoom off;
    end

    
function nmssUncheckZoomAndPan(handles)
% handles    structure with handles and user data (see GUIDATA)

% nmssUncheckZoomAndPan unchecks the Zoom and the Pan Button. Call this
% function in case the user clicks any other buttons
    set(handles.btnZoom, 'Value', 0);
    zoom off;
    set(handles.btnPan, 'Value', 0);
    pan off;
    


% --- Executes on mouse press over axes background.
function canvasFigureAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to canvasFigureAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    disp('mouse button down');



% --- Executes on button press in btnCalibration.
function btnCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to btnCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    nmssUncheckZoomAndPan(handles);
    
    nmssCalibrationDlg();
    nmssCalibrationDlg('Set_Figure', handles.nmssFigure);



% --- Executes on button press in btnDrawLine.
function btnDrawLine_Callback(hObject, eventdata, handles)
% hObject    handle to btnDrawLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    
    nmssUncheckZoomAndPan(handles);

    [xPos1 yPos1] = ginput(1);

    nmssDrawCross(xPos1, yPos1, 3, 3);

    [xPos2 yPos2] = ginput(1);

    nmssDrawCross(xPos2, yPos2, 3, 3);

    % draw line
    line([xPos1; xPos2], [yPos1; yPos2], 'Color','r','LineWidth',2);
   
    
    %line_length_px = sqrt((xPos2-xPos1)^2 + (yPos2-yPos1)^2);
    if (strcmp(doc.figure_axis.unit.x,'nanometer'))
        xline_length = abs(xPos2-xPos1) * doc.figure_axis.scale.current.x;
        yline_length = abs(yPos2-yPos1) * doc.figure_axis.scale.current.y;
        txt = {['Horizontal line length is:'], [num2str(xline_length, '%4.2f'), ' ', doc.figure_axis.unit.x]; ...
               ['Vertical line length is:'], [num2str(yline_length, '%4.2f'), ' ', doc.figure_axis.unit.y]};
    else
        line_length = sqrt((xPos2-xPos1)^2 + (yPos2-yPos1)^2);
        txt = {['Line length is:'], [num2str(line_length, '%4.2f'), ' ', doc.figure_axis.unit.x]};
    end
    
    msgbox_handle = msgbox(txt,'Line Length Measurement','modal');
    
    uiwait(msgbox_handle);
     
    RefreshImage(handles.nmssFigure, handles.canvasFigureAxes, doc.img)
    





% % --- Executes on button press in rbPixels.
% function rbPixels_Callback(hObject, eventdata, handles)
% % hObject    handle to rbPixels (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of rbPixels
%     nmssUncheckZoomAndPan(handles);
%     
%     if (get(hObject,'Value'))
%         
%         global app;
%         
%         nmssRefreshImage_method(handles, app.calidata.ratio, 1);
%         % change to pixels representation of the axes
%         
%         % limits defined in microns!
%         xLimits = xlim(handles.canvasFigureAxes);
%         yLimits = ylim(handles.canvasFigureAxes);
%         
%         % axis scaling now in pixels
%         xlim(handles.canvasFigureAxes, xLimits / app.calidata.ratio.x);
%         ylim(handles.canvasFigureAxes, yLimits / app.calidata.ratio.y);
%     else
%         disp('pixels 0');
%         % this prevents the unchecking of the radiobutton if the user
%         % clicks on it while checked
%         set(hObject, 'Value', 1);
%     end
% 
% 
% 
% 
% % --- Executes on button press in rbMicrons.
% function rbMicrons_Callback(hObject, eventdata, handles)
% % hObject    handle to rbMicrons (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of rbMicrons
%     nmssUncheckZoomAndPan(handles);
%     
%     if (get(hObject,'Value'))
%         global doc;
%         global app;
%         
%         % limits defined in pixels!
%         xLimits = xlim(handles.canvasFigureAxes);
%         yLimits = ylim(handles.canvasFigureAxes);
%         
%         % axis scaling now in microns
% 
%         xlim(handles.canvasFigureAxes, xLimits * doc.figure_axis.scale.current.x);
%         ylim(handles.canvasFigureAxes, yLimits * doc.figure_axis.scale.current.y);
%         
%         nmssRefreshImage_method(handles, app.calidata.ratio, 0);
%         
%     else
%         disp('microns 0');
%         % this prevents the unchecking of the radiobutton if the user
%         % clicks on it while checked
%         set(hObject, 'Value', 1);
%     end
% 
    


% --- Executes on button press in btnImageProcessing.
function btnImageProcessing_Callback(hObject, eventdata, handles)
% hObject    handle to btnImageProcessing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    nmssImageEnhancementDlg();
    nmssImageEnhancementDlg('Set_Figure', handles.nmssFigure);
    
    


% --- Executes on button press in btnAnalysis.
function btnAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to btnAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    
    
    

function handle = nmssFigure_GetHandle()
    handle = handles.nmssFigure;




% --- Executes when nmssFigure is resized.
function nmssFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to nmssFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
% fills up the whole available area of the window with the image if the window is getting
% resized.

    win_size = get(hObject, 'Position');
    ctrl_gui_size = get(handles.panelControlGUI, 'Position');
    canvas_size = get(handles.canvasFigureAxes, 'Position');
    
    
    global nmssFigureData;
    canvas_size(1,2) = nmssFigureData.canvas.origpos.y;
    canvas_size(1,4) = win_size(1,4) - nmssFigureData.canvas.origpos.y - nmssFigureData.canvas.distfromtop;
    canvas_size(1,1) = nmssFigureData.canvas.origpos.x;
    canvas_size(1,3) = win_size(1,3) - nmssFigureData.canvas.origpos.x - nmssFigureData.canvas.distfromright;
    
    set(handles.canvasFigureAxes, 'Position', canvas_size);
     




% --- Executes when user attempts to close nmssFigure.
function nmssFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = hObject;

    % delete all figures that were called from within this dialog
    hChildDlgs = findobj('Type', 'figure');
    user_data = get(hChildDlgs, 'UserData');
    if (iscell(user_data))
        for i=1:length(user_data)
            if (~isempty(user_data{i}))
                if (isfield(user_data{i}, 'CallerFigHandle'))
                    if (user_data{i}.CallerFigHandle == hFig)
                        delete(hChildDlgs(i));
                    end
                end
            end
        end
    else
        if (~isempty(user_data))
            if (isfield(user_data, 'CallerFigHandle'))
                if (user_data.CallerFigHandle == hFig)
                    delete(hChildDlgs);
                end
            end
        end
    end
        
    
    % Hint: delete(hObject) closes the figure
    delete(hObject);
    



% --- Executes on button press in btnYCrosssection.
function btnYCrosssection_Callback(hObject, eventdata, handles)
% hObject    handle to btnYCrosssection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% diaplays the y-crossection of the image at the position selected by the
% user with the mouse
    
    % select the top left corner of ROI
    [start_x, start_y] = ginput(1);
    
    global doc;
    
    crosssec = doc.img(1:size(doc.img,1),floor(start_x));
    crosssec_mean = mean(crosssec);
    crosssec_median = median(crosssec); % this is usually equal with the background
        
    crossec_minus_mean = crosssec - (crosssec_mean + crosssec_median) / 2;
    indices_of_non_zero_values = find(crossec_minus_mean > 0);
    
    crossec_minus_mean_positive = zeros(size(crossec_minus_mean));
    crossec_minus_mean_positive(indices_of_non_zero_values) = crossec_minus_mean(indices_of_non_zero_values);
    
    left_of_peak = crossec_minus_mean_positive(1:floor(start_y),1);
    right_of_peak = crossec_minus_mean_positive(floor(start_y)+1:size(crosssec,1),1);
    
    index_of_right_side_of_peak = find(right_of_peak == 0, 1,'first') + floor(start_y);
    index_of_left_side_of_peak = find(left_of_peak == 0, 1,'last');
    
%     figure('Name','Y-Crossection - processed');
%     plot(crossec_minus_mean_positive);
    figure('Name','Y-Crossection');
    plot(crosssec);
    y_limits = ylim
    disp([index_of_left_side_of_peak index_of_left_side_of_peak]);
    
    line([ceil(start_y) ceil(start_y)], ylim, ...
        'Color', 'k','LineWidth', 1, 'LineStyle', '-.');
    line([index_of_left_side_of_peak index_of_left_side_of_peak], ylim, ...
        'Color', 'r','LineWidth', 1, 'LineStyle', '-.');
    line([index_of_right_side_of_peak index_of_right_side_of_peak], ylim, ...
        'Color', 'r','LineWidth', 1, 'LineStyle', '-.');
    



% --- Executes on button press in btnWavelengthCalibration.
function btnWavelengthCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to btnWavelengthCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    if (strcmp(doc.figure_axis.unit.x,'nanometer'))
        errtxt = {['Current x-axis unit is set to nanometers, please change to pixels and start the Wavelength Calibration again!']};
        errordlg(errtxt );
        return;
    end

    % disable buttons wich start functions wich may interfere with the
    % wavelength calibration
    set(handles.btnCalibration , 'Enable','off');
    set(handles.btnChangeAxisUnits , 'Enable','off');
    set(handles.btnWavelengthCalibration , 'Enable','off');
    set(handles.btnAnalysis , 'Enable','off');
    
    nmssWavelengthCalDlg('Set_Figure', handles.nmssFigure);
    % wait until the dialog gets closed
    uiwait(nmssWavelengthCalDlg());

    % enable buttons wich start functions wich may interfere with the
    % wavelength calibration
    set(handles.btnCalibration , 'Enable','on');
    set(handles.btnChangeAxisUnits , 'Enable','on');
    set(handles.btnWavelengthCalibration , 'Enable','on');
    set(handles.btnAnalysis , 'Enable','on');
    


% --- Executes on button press in btnChangeAxisUnits.
function btnChangeAxisUnits_Callback(hObject, eventdata, handles)
% hObject    handle to btnChangeAxisUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    hFig = ancestor(hObject, 'figure');
    
    hSpecDlg = findobj('Tag', 'nmssSpecAnalysisDlg');
    if (~isempty(hSpecDlg))
        delete(hSpecDlg);
    end

    
    % retain initial zoom setting
    unit = doc.figure_axis.unit;
    full_limits = nmssGetFullImageLimits(unit);
    hAxes = findobj(hFig, 'Type', 'axes');
    
    if (ishandle(hAxes))
        xlim(hAxes, [full_limits.x(1), full_limits.x(2)]);
        ylim(hAxes, [full_limits.y(1), full_limits.y(2)]);
        zoom(hFig, 'reset');
    end

    orig_axis = doc.figure_axis;
    
    % open dialog box
    uiwait(nmssFigureAxiesUnitDlg());
    
    % user pressed cancel
    if (strcmp(orig_axis.unit.x, doc.figure_axis.unit.x) && strcmp(orig_axis.unit.y, doc.figure_axis.unit.y))
        return;
    end
    
    ChangeAxisUnits(handles, orig_axis, doc.figure_axis);

%    
function ChangeAxisUnits(handles, old_axis, new_axis)
% re-displays the figure with the chaged axes units
    global doc;

    doc.figure_axis = new_axis;

    % limits defined in pixels!
    xLimits = xlim(handles.canvasFigureAxes);
    yLimits = ylim(handles.canvasFigureAxes);

    new_lim.x = xLimits;
    new_lim.y = yLimits;
    
    % initialize the full size of the image with the pixel values
    full_lim.x = [1, size(doc.img,2)];
    full_lim.y = [1, size(doc.img,1)];
    
    % find image and delete, we will display it new
    hImage = findobj(handles.canvasFigureAxes, 'Type', 'image', 'Tag', 'camera_image');
    delete(hImage);
    
    %disp(old_axis.unit.x);
    if (strcmp(old_axis.unit.x ,'pixel'))
        % get the current axis limits in the defined units
        [new_lim.x new_lim.y] = nmssPixel_2_Unit(xLimits, yLimits, doc.figure_axis.unit);
        % get the full image size in the defined units
        [full_lim.x full_lim.y] = nmssPixel_2_Unit([1, size(doc.img,2)], [1, size(doc.img,1)],doc.figure_axis.unit);
    else
        % figure limits unit was nanometer (if spectrogrphic mode was active) or 
        % micrometer (imaging mode) now we want them in pixels
        % now we have to take the inverse of the scaling factors as we go
        % back to pixels and the scaling facto is defined as <unit> / pixel
        [new_lim.x, new_lim.y] = nmssUnit_2_Pixel(xLimits, yLimits, old_axis.unit)
    end
    
    nmssPaintImage('new', doc.img, handles.nmssFigure , handles.canvasFigureAxes, full_lim, new_lim);
    
    % set new figure limits as the initial figure limits for zoom
    zoom reset;

   
%



function editGratingCentralWL_Callback(hObject, eventdata, handles)
% hObject    handle to editGratingCentralWL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGratingCentralWL as text
%        str2double(get(hObject,'String')) returns contents of editGratingCentralWL as a double


% --- Executes during object creation, after setting all properties.
function editGratingCentralWL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGratingCentralWL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));




% --- Executes on button press in pbPrevImage.
function pbPrevImage_Callback(hObject, eventdata, handles)
% hObject    handle to pbPrevImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    global nmssFigureData;
    global doc;

    if (nmssFigureData.cur_job_index > 1)
        
        nmssFigureData.cur_job_index = nmssFigureData.cur_job_index - 1;
        
        job = doc.current_job(nmssFigureData.cur_job_index);

        % set mouse cursor to busy (watch)
        set(handles.nmssFigure,'Pointer','watch');
        [status camera_image] = OpenJobAndGetImage(job, doc.workDir, 'silent');
        % switch back the busy cursor to the normal arrow
        set(handles.nmssFigure,'Pointer','arrow');
        if (~strcmp(status,'OK'))
            return;
        end
        
        % end of the list of selected jobs reached -> switch off the button
        if (nmssFigureData.cur_job_index == 1)
            set(hObject,'Enable','off');
        end
        
        % activate the other button
        set(handles.pbNextImage,'Enable','on');
        
        
        RefreshImage(handles.nmssFigure, handles.canvasFigureAxes, camera_image);
        set(handles.nmssFigure, 'Name', ['NMSS Figure: ', job.filename]);
    else
        set(hObject,'Enable','off');        
    end



% --- Executes on button press in pbNextImage.
function pbNextImage_Callback(hObject, eventdata, handles)
% hObject    handle to pbNextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if (GetNextImage() == 0)
        set(hObject,'Enable','off');
    end
    % activate the other button
    set(handles.pbPrevImage,'Enable','on');
    
%----------------    
function job_index = GetNextImage()

    global nmssFigureData;
    global doc;
    global app;
    
    handles = guidata(app.nmssFigure);
    
    job_index = 0;
    if (nmssFigureData.cur_job_index < length(doc.current_job))
        
        nmssFigureData.cur_job_index = nmssFigureData.cur_job_index + 1;
        
        job = doc.current_job(nmssFigureData.cur_job_index);

        % set mouse cursor to busy (watch)
        set(handles.nmssFigure,'Pointer','watch');
        [status camera_image] = OpenJobAndGetImage(job, doc.workDir, 'silent');
        % switch back the busy cursor to the normal arrow
        set(handles.nmssFigure,'Pointer','arrow');
        
        if (~strcmp(status,'OK'))
            return;
        end
        
        % end of the list of selected jobs reached -> switch off the button
        if (nmssFigureData.cur_job_index == length(doc.current_job))
            job_index = 0;
        else
            job_index = nmssFigureData.cur_job_index;
        end
        
        RefreshImage(handles.nmssFigure, handles.canvasFigureAxes, camera_image);
        set(handles.nmssFigure, 'Name', ['NMSS Figure: ', job.filename]);
    end




% --------------------------------------------------------------------
function mnFigure_Callback(hObject, eventdata, handles)
% hObject    handle to mnFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press over nmssFigure with no controls selected.
function nmssFigure_KeyPressFcn(src, eventdata)
% src    handle to nmssFigure (see GCBO)
% eventdata  - a structure which contains necessary infromations about the
% key event. eventdata.Modifier = 'alt', 'ctrl', 'shift' etc..
% eventdata.Key = the name of the key, that is pressed


%     last_char = get(hObject, 'CurrentCharacter');
%     selection_type = get(hObject, 'SelectionType');
%     disp(['Key pressed: ', last_char, ' Selection Type:', selection_type]);

    global app;
    
    % get structure of the child gui elements
    handles = guidata(app.nmssFigure);
    
    if (length(eventdata.Modifier) == 0)
            if (strcmp(eventdata.Key, 'rightarrow'))
                % call next image
                pbNextImage_Callback(handles.pbNextImage, eventdata, handles)
            elseif (strcmp(eventdata.Key, 'leftarrow'))
                % call prev image
                pbPrevImage_Callback(handles.pbPrevImage, eventdata, handles)
            end
    end
    
    



% --------------------------------------------------------------------
function menuManualPartilceTracking_Callback(hObject, eventdata, handles)
% hObject    handle to menuManualPartilceTracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global app;
    global nmssFigureData;
    global doc;
    %global nmsstest;
    strHelp = {'Use this feature to track particles with the mouse on subsequent images.';; ...
               'Use the left mouse button to mark the a particle on this images.'; ...
               'After pressing, the next image will be loaded, and proceed until'; ...
               'You reach the last image.';; ...
               'Press right mouse button to skip the current image (in case the image is corrupted).';...
        };
    uiwait(helpdlg(strHelp,'Particle tracking tool'));
    
    disp('start');
    
    
    % activate figure containing the image
    figure(app.nmssFigure);
    
    k = 1;
    xPos = [];
    yPos = [];
    posJob = [];
    job_index = nmssFigureData.cur_job_index;
    
% TEST
    %     if (isfield(nmsstest, 'xPos') & isfield(nmsstest, 'yPos') & isfield(nmsstest, 'posJob'))
%         xPos = nmsstest.xPos;
%         yPos = nmsstest.yPos;
%         posJob = nmsstest.posJob;
%     else
% END OF TEST
        while (job_index ~= 0)
            [x, y, button] = ginput(1);
            if (button == 2)
                continue;
            end
            nmssDrawCross(x, y, 3, 3);

            % remember particle position and job index
            xPos(k) = x;
            yPos(k) = y;
            posJob(k) = job_index;

            % increase array index
            k=k+1;

            % get next job
            job_index = GetNextImage();
            if (job_index == 0)
                break;
            end
        end
%         % TEST -----------------------------
%         nmsstest.xPos = xPos;
%         nmsstest.yPos = yPos;
%         nmsstest.posJob = posJob;
%         % TEST -----------------------------
%     end % end else
    
    figure; plot(xPos, yPos);
    
    % calc max x,y and min x,y of the particle location
    x_min = min(xPos);
    x_max = max(xPos);
    
    y_min = min(yPos);
    y_max = max(yPos);
    
    % calc center positions
    x_center = (x_min + x_max) / 2.0;
    y_center = (y_min + y_max) / 2.0;
    
    
    button = questdlg({'Do you want to export jobs with applied drift correction?'},'Job Export Dialog','Yes','No','Yes');
    if (strcmp(button,'No'))
        return; % user canceled drift correction
    end
    
    % get directory to export the jobs  
    export_dir = uigetdir(doc.workDir, 'Select export directory');
    
    % directory selected
    if (export_dir == 0)
        return; % user canceled drift correction
    end
    
    % --------------------------------------------------
    % apply drift correction to each job and export them
    % --------------------------------------------------
    
    
    % get job structure
    num_of_jobs = length(doc.current_job);
    num_of_pos = length(posJob);
    
    % the indices of the jobs with drift correction infromation
    for i=1:num_of_pos-1
        
        dx = floor(x_center - xPos(i) + 0.5);
        dy = floor(y_center - yPos(i) + 0.5);
        
        % jobs that receive the same drift correction
        for k=posJob(i):posJob(i+1)-1
            job = doc.current_job(k);
            
            [status camera_image] = OpenJobAndGetImage(job, doc.workDir, 'silent');
            new_img = camera_image;
            
            % apply drift correction
            if (dx >= 0 & dy >= 0)
                new_img(1+dy:end, 1+dx:end) = camera_image(1:end-dy, 1:end-dx);
            elseif (dx >= 0 & dy <= 0)
                new_img(1:end+dy, 1+dx:end) = camera_image(1-dy:end, 1:end-dx);
            elseif (dx <= 0 & dy >= 0)
                new_img(1+dy:end, 1:end+dx) = camera_image(1:end-dy, 1-dx:end);
            else
                try
                    new_img(1:end+dy, 1:end+dx) = camera_image(1-dy:end, 1-dx:end);
                catch
                    keyboard;
                end
            end
            
            % now we have to save the jobs
            filepath = fullfile(export_dir, job.filename);
            nmssSaveJob(filepath, job, new_img');
        end
    end
    
    % save list_of_jobs.mat
    filepath = fullfile(export_dir, 'list_of_jobs.mat');
    try
        list_of_jobs = doc.list_of_jobs;
        measurement_info = doc.measurement_info;
        save(filepath, 'list_of_jobs', 'measurement_info', '-mat');
    catch
        error_msg = ['Error saving file: ' lasterr()];
        disp(error_msg);
        errordlg(error_msg);
    end
    
    
    
    
    
    
    
    
    
    


% --------------------------------------------------------------------
function menu_SaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to menu_SaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    job = doc.current_job;

    old_dir = pwd;
    
    cd(doc.workDir);
    
    c = clock();
    
    def_file_name = ['Single_Exp_', num2str(c(1)), '-', num2str(c(2)), '-', num2str(c(3)), ...
                     '_h', num2str(c(4)), 'm', num2str(c(5)), 's', num2str(floor(c(6))), '.mat'];
    
    
    [filename, dirname, filterIndex] = uiputfile({'*.mat', 'Save Graph as Mat-File...'}, 'Save Job As...', def_file_name);

    cd(old_dir);
    
    % user hit cancel button
    if (filename == 0)
        return;
    end
    
    % check for extension if user hasn't given any, append .mat at the end
    [pathstr,name,ext] = fileparts(filename);
    if (isempty(ext))
        filename = [filename,'.mat'];
    end
    
    % the file name of the job
    job.filename = filename;
        
    filepath = fullfile(dirname, filename);
    camera_image = doc.img;
    nmssSaveJob( filepath, job, camera_image');



% --------------------------------------------------------------------
function file_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function mnCaliLateral_Callback(hObject, eventdata, handles)
% hObject    handle to mnCaliLateral (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    nmssUncheckZoomAndPan(handles);
    
    nmssCalibrationDlg();
    nmssCalibrationDlg('Set_Figure', handles.nmssFigure);


% --------------------------------------------------------------------
function mnCaliSpectral_Callback(hObject, eventdata, handles)
% hObject    handle to mnCaliSpectral (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    if (strcmp(doc.figure_axis.unit.x,'nanometer'))
        errtxt = {['Current x-axis unit is set to nanometers, please change to pixels and start the Wavelength Calibration again!']};
        errordlg(errtxt );
        return;
    end

    % disable buttons wich start functions wich may interfere with the
    % wavelength calibration
    set(handles.mnCaliSpectral , 'Enable','off');
    set(handles.btnChangeAxisUnits , 'Enable','off');
    set(handles.mnCaliLateral , 'Enable','off');
    set(handles.mnAnalysis , 'Enable','off');
    
    nmssWavelengthCalDlg('Set_Figure', handles.nmssFigure);
    % wait until the dialog gets closed
    uiwait(nmssWavelengthCalDlg());

    % enable buttons wich start functions wich may interfere with the
    % wavelength calibration
    set(handles.mnCaliSpectral , 'Enable','on');
    set(handles.btnChangeAxisUnits , 'Enable','on');
    set(handles.mnCaliLateral , 'Enable','on');
    set(handles.mnAnalysis , 'Enable','on');


% --------------------------------------------------------------------
function mnCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to mnCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to mnAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global app;
    hFig = ancestor(hObject, 'figure');

    % open dialog only if itis not opened yet
    hSpecAnalysisDlg = findobj('Tag', 'nmssSpecAnalysisDlg');
    
    if (isempty(hSpecAnalysisDlg) || ~ishandle(hSpecAnalysisDlg))
        nmssUncheckZoomAndPan(handles);

        app.nmssSpecAnalysisDlg = nmssSpecAnalysisDlg();
        user_data = get(app.nmssSpecAnalysisDlg, 'UserData');
        user_data.CallerFigHandle = hFig;
        set(app.nmssSpecAnalysisDlg, 'UserData', user_data);
        
        % init opened dialog
        user_data.hInitFcn(app.nmssSpecAnalysisDlg);
        
    else
        figure(hSpecAnalysisDlg);
    end
    
    

% --------------------------------------------------------------------
function mnBrightContrast_Callback(hObject, eventdata, handles)
% hObject    handle to mnBrightContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure', 'toplevel');


    hDlg = nmssImageEnhancementDlg();
    dlg_user_data = get(hDlg, 'UserData');
    
    dlg_user_data.targetFigure  = hFig;
    dlg_user_data.CallerFigHandle = hFig;
    
    set(hDlg, 'UserData',dlg_user_data);
    
    %start dialog
    dlg_user_data.hFigInitFcn(hDlg);
    

% --------------------------------------------------------------------
function mnTools_Callback(hObject, eventdata, handles)
% hObject    handle to mnTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnImage_Callback(hObject, eventdata, handles)
% hObject    handle to mnImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in btnCrossSection.
function btnCrossSection_Callback(hObject, eventdata, handles)
% hObject    handle to btnCrossSection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        
    global doc;
    global nmssFigureData;
    image_full_limits = nmssGetFullImageLimits(doc.figure_axis.unit);

    hAxis = gca;
    

    % select the top left corner of ROI
    [start_x, start_y] = ginput(1);

    set(hAxis, 'Units', 'pixels');
    axis_pos = get(gca, 'Position');
    
    % get the current view limits
    xlimits = xlim(hAxis);
    ylimits = ylim(hAxis);
    
    % get the axis x-size
    axis_size_x = axis_pos(3);
    % get the axis y-size
    axis_size_y = axis_pos(4);

    % set up ROIs that will contain the cross sections
    cs_x_roi = nmssResetROI();
    cs_y_roi = nmssResetROI();
    
    % the size of a pixel in unit
    one_px_roi =  nmssResetROI();
    one_unit_roi = nmssConvertROIPixel2Unit(one_px_roi, doc.figure_axis.unit);

    cs_x_roi.exists = 1;
    cs_x_roi.valid = 1;
    cs_x_roi.x = image_full_limits.x(1);
    cs_x_roi.y = ceil(start_y);
    
    cs_y_roi.exists = 1;
    cs_y_roi.valid = 1;
    cs_y_roi.x = ceil(start_x);
    cs_y_roi.y = image_full_limits.y(1);
    
    cs_x_roi.wx = image_full_limits.x(2) - cs_x_roi.x + one_unit_roi.wx;
    cs_x_roi.wy = 1;

    cs_y_roi.wx = 1;
    cs_y_roi.wy = image_full_limits.y(2) - cs_y_roi.y + one_unit_roi.wy;

    if (~strcmp(doc.figure_axis.unit.x,'pixel'))
        cs_x_roi_px = nmssConvertROIUnit2Pixel(cs_x_roi, doc.figure_axis.unit);
        cs_y_roi_px = nmssConvertROIUnit2Pixel(cs_y_roi, doc.figure_axis.unit);
    else
        cs_x_roi_px = cs_x_roi;
        cs_y_roi_px = cs_y_roi;
    end
    
    if (cs_x_roi_px.wy > 1)
        cs_x_roi_px.wy = 1;
    end
    if (cs_y_roi_px.wx > 1)
        cs_y_roi_px.wx = 1;
    end
    
    % get image data for the given cross section
    cs_x = doc.img(cs_x_roi_px.y : cs_x_roi_px.y + cs_x_roi_px.wy - 1, ...
                   cs_x_roi_px.x : cs_x_roi_px.x + cs_x_roi_px.wx - 1);
               
    cs_y = doc.img(cs_y_roi_px.y : cs_y_roi_px.y + cs_y_roi_px.wy - 1, ...
                   cs_y_roi_px.x : cs_y_roi_px.x + cs_y_roi_px.wx - 1);

            % background signal
            roi = doc.roi;
            img = doc.img;
            median_bg = 0;
            if (roi.bg1.exists == 1 || roi.bg2.exists == 1)
                if (roi.bg1.valid == 1)
                    bg = img(roi.bg1.y : roi.bg1.y+roi.bg1.wy - 1,...
                                roi.bg1.x : roi.bg1.x+roi.bg1.wx - 1);
                    median_bg = cast(median(median(bg)), 'double');
                    
                elseif (roi.bg2.valid == 1)
                    %bg = img(roi.bg2.y : roi.bg2.y+roi.bg2.wy - 1,...
                    %            roi.bg2.x : roi.bg2.x+roi.bg2.wx - 1);
                    
                    % we split the background roi (which contains also the
                    % particle roi) into four regions, illustrated like
                    % below (P = particle roi)
                    % 132
                    % 1P2
                    % 142
                                
                    real_bg_1 = img(roi.bg2.y : roi.bg2.y+roi.bg2.wy - 1, ...
                                    roi.bg2.x : roi.particle.x - 1);
                    real_bg_2 = img(roi.bg2.y : roi.bg2.y+roi.bg2.wy - 1, ...
                                    roi.particle.x+roi.particle.wx : roi.bg2.x+roi.bg2.wx - 1);
                    real_bg_3 = img(roi.bg2.y : roi.particle.y - 1, ...
                                    roi.particle.x : roi.particle.x+roi.particle.wx - 1);
                    real_bg_4 = img(roi.particle.y + roi.particle.wy : roi.bg2.y+roi.bg2.wy - 1, ...
                                    roi.particle.x : roi.particle.x+roi.particle.wx - 1);
                    
                    real_bg = [real_bg_1(:); real_bg_2(:); real_bg_3(:); real_bg_4(:)];
                    median_bg = cast(median(real_bg),'double');
                    
                end
            end
                   
               
    % display cross sections
    % x cross section
    hFig_x_cs = figure;
    x_axis_step_size = (image_full_limits.x(2)-image_full_limits.x(1)) / length(cs_x);
    x_axis = image_full_limits.x(1):x_axis_step_size:image_full_limits.x(2);
    plot(x_axis(1:end-1),cs_x, '.--'); % (1:end-1) cuts off the last vector element that parasitically attached during the reconstruction of the axis
    title('X cross section');
    plot_y_limits = ylim();
    % get particle and background ROI data to display them on the cross section plot 
    if (doc.roi.particle.valid == 1)
        line([doc.roi.particle.x, doc.roi.particle.x], [plot_y_limits(1), plot_y_limits(2)], ...
             'LineStyle', '-', 'Color', 'g');
        line([doc.roi.particle.x+doc.roi.particle.wx-1, doc.roi.particle.x+doc.roi.particle.wx-1], ...
             [plot_y_limits(1), plot_y_limits(2)], ...
             'LineStyle', '-', 'Color', 'g');
    end
    if (doc.roi.bg1.valid == 1)
        line([doc.roi.bg1.x, doc.roi.bg1.x], [plot_y_limits(1), plot_y_limits(2)], ...
             'LineStyle', '--', 'Color', 'g');
        line([doc.roi.bg1.x+doc.roi.bg1.wx-1, doc.roi.bg1.x+doc.roi.bg1.wx-1], ...
             [plot_y_limits(1), plot_y_limits(2)], ...
             'LineStyle', '--', 'Color', 'g');
    elseif (doc.roi.bg2.valid == 1)
        line([doc.roi.bg2.x, doc.roi.bg2.x], [plot_y_limits(1), plot_y_limits(2)], ...
             'LineStyle', '--', 'Color', 'g');
        line([doc.roi.bg2.x+doc.roi.bg2.wx-1, doc.roi.bg2.x+doc.roi.bg2.wx-1], ...
             [plot_y_limits(1), plot_y_limits(2)], ...
             'LineStyle', '--', 'Color', 'g');
    end
    
    line([image_full_limits.x(1),image_full_limits.x(2)], [median_bg, median_bg], 'LineStyle', '-', 'Color', 'k');
    % set corresponding zoom
    xlim(xlimits);
    
    
    
    
    % y cross section
    hFig_y_cs = figure;
    y_axis_step_size = (image_full_limits.y(2)-image_full_limits.y(1)) / length(cs_y);
    y_axis = image_full_limits.y(1):y_axis_step_size:image_full_limits.y(2);
    
    plot(cs_y, y_axis(1:end-1), '.--'); % (1:end-1) cuts off the last vector element that parasitically attached during the reconstruction of the axis
    title('Y cross section');
    plot_x_limits = xlim();
    % get particle and background ROI data to display them on the cross section plot 
    if (doc.roi.particle.valid == 1)
        line([plot_x_limits(1), plot_x_limits(2)], [doc.roi.particle.y, doc.roi.particle.y], ...
             'LineStyle', '-', 'Color', 'g');
        line([plot_x_limits(1), plot_x_limits(2)], ...
             [doc.roi.particle.y+doc.roi.particle.wy-1, doc.roi.particle.y+doc.roi.particle.wy-1], ...
             'LineStyle', '-', 'Color', 'g');
    end
    if (doc.roi.bg1.valid == 1)
        line([plot_x_limits(1), plot_x_limits(2)], [doc.roi.bg1.y, doc.roi.bg1.y], ...
             'LineStyle', '--', 'Color', 'g');
        line([plot_x_limits(1), plot_x_limits(2)], ...
             [doc.roi.bg1.y+doc.roi.bg1.wy-1, doc.roi.bg1.y+doc.roi.bg1.wy-1], ...
             'LineStyle', '--', 'Color', 'g');
    elseif (doc.roi.bg2.valid == 1)
        line([plot_x_limits(1), plot_x_limits(2)], [doc.roi.bg2.y, doc.roi.bg2.y], ...
             'LineStyle', '--', 'Color', 'g');
        line([plot_x_limits(1), plot_x_limits(2)], ...
             [doc.roi.bg2.y+doc.roi.bg2.wy-1, doc.roi.bg2.y+doc.roi.bg2.wy-1], ...
             'LineStyle', '--', 'Color', 'g');
    end
    line([median_bg, median_bg], [image_full_limits.y(1),image_full_limits.y(2)], 'LineStyle', '-', 'Color', 'k');
    
    ylim(ylimits);
    handle_axes = findobj(hFig_y_cs,'type','axes');
    set(handle_axes,'YDir','reverse');
    
               
        
        
        
        
        
        
%         
%         % snap rectangle's coordinates to the outer boundary of the pixels
%         % contained within or which are on the rubber box line
%         corner_x = floor(start_x + 0.5);
%         corner_y = floor(start_y + 0.5);
%         
%         full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);
%         if (corner_x < full_lim.x(1))
%             corner_x = full_lim.x(1);
%         end
%         
%         if (corner_y < full_lim.y(1))
%             corner_y = full_lim.y(1);
%         end



% --- Executes on button press in btnZoomDlg.
function btnZoomDlg_Callback(hObject, eventdata, handles)
% hObject    handle to btnZoomDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnZoomDlg
    global app;
    global nmssZoomDlg_Data;
    

    % get axis limits and store in zoom
    hAxes = findobj(app.nmssFigure, 'Type', 'axes');

    
    if (ishandle(hAxes))
        xlimits = xlim(hAxes);
        ylimits = ylim(hAxes);
    end
    
    nmssZoomDlg_Data.topX = xlimits(1);
    nmssZoomDlg_Data.bottomX = xlimits(2);
        
    nmssZoomDlg_Data.topY = ylimits(1);
    nmssZoomDlg_Data.bottomY = ylimits(2);
    
    uiwait(nmssZoomDlg());
        
    
    





% --------------------------------------------------------------------
function menuEdit_Callback(hObject, eventdata, handles)
% hObject    handle to menuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
% DO NOTHING HERE!!!




% --------------------------------------------------------------------
function menuCopy_Callback(hObject, eventdata, handles)
% hObject    handle to menuCopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    



% --------------------------------------------------------------------
function menuOpenAsFigure_Callback(hObject, eventdata, handles)
% hObject    handle to menuOpenAsFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hAxes = findobj(handles, 'Type', 'axes');
    
    figure(handles.nmssFigure);
    cmap = colormap;

    hFig = figure;
    colormap(cmap);
    
    hNewAxes = copyobj(handles.canvasFigureAxes, hFig);
    
    set(hNewAxes, 'Unit', 'normalized');
    pos = [0.0875, 0.08 0.9 0.9];
    
    % fill out most of the available place
    set(hNewAxes, 'Position', pos);
    





% --------------------------------------------------------------------
function menuMarker_Callback(hObject, eventdata, handles)
% hObject    handle to menuMarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function menuMark_Callback(hObject, eventdata, handles)
% hObject    handle to menuMark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function menuMark_red_Callback(hObject, eventdata, handles)
% hObject    handle to menuMark_red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssFigureData;
    nmssFigureData.menuMarkerColor = 'r';
    
    set(handles.menuMark_red, 'Checked', 'on');
    set(handles.menuMark_yellow, 'Checked', 'off');
    set(handles.menuMark_green, 'Checked', 'off');
    set(handles.menuMark_blue, 'Checked', 'off');
    


% --------------------------------------------------------------------
function menuMark_yellow_Callback(hObject, eventdata, handles)
% hObject    handle to menuMark_yellow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssFigureData;
    
    set(handles.menuMark_red, 'Checked', 'off');
    set(handles.menuMark_yellow, 'Checked', 'on');
    set(handles.menuMark_green, 'Checked', 'off');
    set(handles.menuMark_blue, 'Checked', 'off');
    
    nmssFigureData.menuMarkerColor = 'y';


% --------------------------------------------------------------------
function menuMark_green_Callback(hObject, eventdata, handles)
% hObject    handle to menuMark_green (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssFigureData;
    nmssFigureData.menuMarkerColor = 'g';

    
    set(handles.menuMark_red, 'Checked', 'off');
    set(handles.menuMark_yellow, 'Checked', 'off');
    set(handles.menuMark_green, 'Checked', 'on');
    set(handles.menuMark_blue, 'Checked', 'off');
    


% --------------------------------------------------------------------
function menuMark_blue_Callback(hObject, eventdata, handles)
% hObject    handle to menuMark_blue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssFigureData;
    nmssFigureData.menuMarkerColor = 'b';
    
    
    set(handles.menuMark_red, 'Checked', 'off');
    set(handles.menuMark_yellow, 'Checked', 'off');
    set(handles.menuMark_green, 'Checked', 'off');
    set(handles.menuMark_blue, 'Checked', 'on');
    




% --------------------------------------------------------------------
function menuDeleteAllMarkers_Callback(hObject, eventdata, handles)
% hObject    handle to menuDeleteAllMarkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %global app;
    
    hRectangles = findobj(handles.nmssFigure, 'Tag', 'nmss_bright_spot');
    delete(hRectangles);
    
    


% --------------------------------------------------------------------
function menuDeleteSingleMarker_Callback(hObject, eventdata, handles)
% hObject    handle to menuDeleteSingleMarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    helpdlg('Right click on the marker and select ''Delete'' menu item','Delete Single Marker');



% --------------------------------------------------------------------
function menuExportMarkerPos_Callback(hObject, eventdata, handles)
% hObject    handle to menuExportMarkerPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    
    hRectangles = findobj(handles.nmssFigure, 'Tag', 'nmss_bright_spot');
%     pos_x = cell2mat(get(hRectangles, 'XData'));
%     pos_y = cell2mat(get(hRectangles, 'YData'));
%     
%     % since this is a rectangle, we can calculate the postion by averaging
%     % over all coordinate values of each axis
%     mean_pos_x = mean(pos_x(:,1:4)');
%     mean_pos_y = mean(pos_y(:,1:4)');
%     
%     pos_xy = [mean_pos_x; mean_pos_y]';
    
    marker = GetRectangleInfo(hRectangles);
    
    current_dir = pwd();
    cd(doc.workDir);
    
    [filename, dirname, filterIndex] = uiputfile({'*.mat', 'Save marker positions as Mat-File...';}, 'Save results', 'marker.mat');
        
    % user hit cancel button
    if (filename == 0)
        return;
    end

    filepath = fullfile(dirname, filename);
    
    hW = waitbar(1, 'Please Wait, Data storage is under way! It can take some seconds...');

    save(filepath, 'marker');
    
    delete(hW);
    
    cd(current_dir);
    
function marker = GetRectangleInfo(hRectangles)
% calculates the center of a rectangular nmss_bright_spot marker
% returns a n x 2 size matrix, column 1 = x coordinate, column 2 = y
% coordinate

    lpos = size(hRectangles,1);
    
    for i=1:lpos

        pos_x = get(hRectangles(i), 'XData');
        pos_y = get(hRectangles(i), 'YData');

        % get top left corner
        pos.x1 = pos_x(1);
        pos.y1 = pos_y(1);

        % get bottom right corner
        pos.x2 = pos_x(3);
        pos.y2 = pos_y(3);

        marker(i).pos = pos;

        marker(i).color = get(hRectangles(i), 'Color');
        marker(i).linewidth = get(hRectangles(i), 'LineWidth');
    end
    
    
    

% --------------------------------------------------------------------
function menuLoadMarkerPos_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadMarkerPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    [filename, dirname] = uigetfile({'*.mat', 'Mat-File (*.mat)'}, 'Load marker positions - Select File');
    
    % change to the working directory
    %cd(doc.workDir);
    
    if (filename == 0) % user pressed cancel
        return;
    end
    
    file_path = fullfile(dirname, filename);
    [pathstr_dummy,name_dummy,extension] = fileparts(file_path);    
    
    load(file_path); % loads pos_xy
    
    % old style marker data
    if (exist('pos_xy'))
        lpos = size(pos_xy,1);
        
        for i=1:lpos
            DrawMarker(pos_xy(i,1), pos_xy(i,2), 6, 6);
        end
    elseif (exist('marker')) % new style marker data
        lpos = length(marker);
        
        for i=1:lpos
            center_x = (marker(i).pos.x1 + marker(i).pos.x2) / 2;
            center_y = (marker(i).pos.y1 + marker(i).pos.y2) / 2;
            width_x = marker(i).pos.x2 - marker(i).pos.x1;
            width_y = marker(i).pos.y2 - marker(i).pos.y1;
            
            hRectangle = DrawMarker(center_x, center_y, width_x, width_y);
            
            %set(hRectangle, 'Color', marker(i).color);
            global nmssFigureData;
            set(hRectangle, 'Color', nmssFigureData.menuMarkerColor);
            set(hRectangle, 'LineWidth', marker(i).linewidth);
        end
        
    else
        errordlg('This .mat file doesn!t contain marker position data!');
    end
    


% --------------------------------------------------------------------
function menuShiftAllMarkers_Callback(hObject, eventdata, handles)
% hObject    handle to menuShiftAllMarkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    % allow user to define shift vector manually by drawing a vector line
    [xPos1, yPos1] = ginput(1);

    hCross1 = nmssDrawCross(xPos1, yPos1, 3, 3);

    [xPos2, yPos2] = ginput(1);


    % draw line
    hLine = line([xPos1; xPos2], [yPos1; yPos2], 'Color','m','LineWidth',2);
    
    % delete cross_1, it was intended only for the user to know, where he
    % clicked the mouse button first
    delete(hCross1);
    
    % draw a rectangle at the end of the line, so that it looks like an
    % arrow
    hArrowHead = nmssDrawRectAroundCenter(xPos2, yPos2, 2, 2, 'nmss_arrow_head');
    set(hArrowHead, 'Color', 'm');
    
    
    % use vector data and relocate all markers
    shift_x = xPos2-xPos1;
    shift_y = yPos2-yPos1;
    
    % get positions of the old markers
    hOldRectangles = findobj(handles.nmssFigure, 'Tag', 'nmss_bright_spot');
    
    
    lRect = length(hOldRectangles);
    
    for i=1:lRect
        set(hOldRectangles(i), 'XData', get(hOldRectangles(i), 'XData') + shift_x);
        set(hOldRectangles(i), 'YData', get(hOldRectangles(i), 'YData') + shift_y);
    end
    
    delete(hArrowHead);
    delete(hLine);
    % yes, we're done



% --------------------------------------------------------------------
function menuMarkSpot_Callback(hObject, eventdata, handles)
% hObject    handle to menuMarkSpot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    AxesPopupMenu();


% --------------------------------------------------------------------
function menuMarkerColor_Callback(hObject, eventdata, handles)
% hObject    handle to menuMarkerColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function menuFileExportVideo_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileExportVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssFigureData;
    global doc;
    global app;

    % create video file
    current_dir = pwd();
    cd(doc.workDir);
    
    [filename, dirname, filterIndex] = uiputfile({'*.mat', 'Export images as video';}, 'Export video', 'nmss.avi');
        
    % user hit cancel button
    if (filename == 0)
        return;
    end

    filepath = fullfile(dirname, filename);
    
    % create avi video file
    aviobj = avifile(filepath,'fps',1);
    
    

    

    % collect infromations about the images that will be exported
    
    handles = guidata(app.nmssFigure);
    
    % set mouse cursor to busy (watch)
    set(handles.nmssFigure,'Pointer','watch');
    
    for ( i = 1:length(doc.current_job))
        
        nmssFigureData.cur_job_index = i;
        job = doc.current_job(nmssFigureData.cur_job_index);

        [status camera_image] = OpenJobAndGetImage(job, doc.workDir, 'silent');
        if (~strcmp(status,'OK'))
            % switch back the busy cursor to the normal arrow
            set(handles.nmssFigure,'Pointer','arrow');
            return;
        end
        
        RefreshImage(handles.nmssFigure, handles.canvasFigureAxes, camera_image);
        set(handles.nmssFigure, 'Name', ['NMSS Figure: ', job.filename]);
        
        % store video
        frame = getframe(handles.canvasFigureAxes);
        aviobj = addframe(aviobj,frame);
        
        
    end
    
    
    aviobj = close(aviobj);
    % switch back the busy cursor to the normal arrow
    set(handles.nmssFigure,'Pointer','arrow');
    
    cd(current_dir);
    


