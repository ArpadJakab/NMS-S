function varargout = nmssSpecAnalysisDlg(varargin)
% NMSSSPECANALYSISDLG M-file for nmssSpecAnalysisDlg.fig
%      NMSSSPECANALYSISDLG, by itself, creates a new NMSSSPECANALYSISDLG or raises the existing
%      singleton*.
%
%      H = NMSSSPECANALYSISDLG returns the handle to a new NMSSSPECANALYSISDLG or the handle to
%      the existing singleton*.
%
%      NMSSSPECANALYSISDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSSPECANALYSISDLG.M with the given input arguments.
%
%      NMSSSPECANALYSISDLG('Property','Value',...) creates a new NMSSSPECANALYSISDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssSpecAnalysisDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssSpecAnalysisDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssSpecAnalysisDlg

% Last Modified by GUIDE v2.5 30-Nov-2010 17:23:23

% Begin initialization code - DO NOT EDITPARTICLEBGROIDISTANCE
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssSpecAnalysisDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssSpecAnalysisDlg_OutputFcn, ...
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
% End initialization code - DO NOT EDITPARTICLEBGROIDISTANCE


% --- Executes just before nmssSpecAnalysisDlg is made visible.
function nmssSpecAnalysisDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssSpecAnalysisDlg (see VARARGIN)
% Choose default command line output for nmssSpecAnalysisDlg
    handles.output = hObject;
    
    user_data.hInitFcn = @InitDlg;
    set(hObject, 'UserData', user_data);

% Update handles structure
guidata(hObject, handles);


function InitDlg(hFig)
% initializes gui elements in this dialog

    user_data = get(hFig, 'UserData');
    hParentFig = user_data.CallerFigHandle;
    handles = guihandles(hFig);

    % parent of this dialog is nmssFigure and its parent is the main window
    % disable gui elements
    if (ishandle(hParentFig))
        parent_handles = guidata(hParentFig);
        % enable buttons which were disabled before
        set(parent_handles.btnChangeAxisUnits, 'Enable', 'off');
        set(parent_handles.mnCaliLateral, 'Enable', 'off');
        set(parent_handles.mnCaliSpectral, 'Enable', 'off');
        set(parent_handles.mnAnalysis, 'Enable', 'off');
    end
    
    global doc;
    
    % converting to image units and converting width to end (bottom right) coordinates
    roi.particle = ConvertROIPixel2Unit(doc.roi.particle, doc.figure_axis.unit);
    roi.bg1 = ConvertROIPixel2Unit(doc.roi.bg1, doc.figure_axis.unit);
    roi.bg2 = ConvertROIPixel2Unit(doc.roi.bg2, doc.figure_axis.unit);
    

        set(handles.rbBackground1, 'Enable', 'off');
        set(handles.rbBackground2, 'Enable', 'off');
    
    set(handles.rbParticle, 'Value', 1);
    
    [ start_x, start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.particle, doc.figure_axis.unit);
    set(handles.editRectStartX, 'String', num2str(start_x, '%4.3f') );
    set(handles.editRectStartY, 'String', num2str(start_y, '%4.3f') );
    set(handles.editRectEndX, 'String', num2str(end_x, '%4.3f') );
    set(handles.editRectEndY, 'String', num2str(end_y, '%4.3f') );
    
    % check if white light correction can be applied.
    if (size(doc.white_light_corr.data,1) ~= size(doc.img,2))
        % white light data and image size do not match
        set(handles.btnShowWhiteLight, 'Enable', 'off');
        set(handles.cxEnableWLCorrection, 'Enable', 'off');
        set(handles.cxEnableWLCorrection, 'Value', 0);
    else
        % white light data has the correct size
        set(handles.cxEnableWLCorrection, 'Value', doc.white_light_corr.enable);
    end
    set(handles.editPathWLSpectra, 'String', doc.white_light_corr.filepath);
    
    set(handles.editStdDev_Weighting, 'String', num2str(doc.analysis.std_weighing, '%2.2f'));
    
    % particle bounding rectangle manipulations
    % old stuff:
        %set(handles.editMinROIVSize, 'String', num2str(doc.analysis.minROIVerticalSize, '%2.0f'));
    
    % init radio buttons
    if (~doc.analysis.bUseFixedROISize)
        set(handles.rbAutoSize, 'Value', 1)
        set(handles.rbFixedSize, 'Value', 0)
    else
        set(handles.rbAutoSize, 'Value', 0)
        set(handles.rbFixedSize, 'Value', 1)
    end
        
    set(handles.editMinROISizeX, 'String', num2str(doc.analysis.minROISizeX, '%2.0f'));
    set(handles.editMinROISizeY, 'String', num2str(doc.analysis.minROISizeY, '%2.0f'));
    set(handles.editFixedROISizeX, 'String', num2str(doc.analysis.fixROISizeX, '%2.0f'));
    set(handles.editFixedROISizeY, 'String', num2str(doc.analysis.fixROISizeY, '%2.0f'));
    
    % enable currently selected peak identification method GUI
    set(handles.rbPeakIdentifcation_YMax,'Value', 0.0);
    set(handles.rbPeakIdentifcationAutomatic,'Value', 0.0);
    if (strcmp(doc.analysis.method,'0th_derivative'))
        set(handles.rbPeakIdentifcation_YMax,'Value', 1.0);
    elseif (strcmp(doc.analysis.method,'1st_derivative'))
        set(handles.rbPeakIdentifcationAutomatic,'Value', 1.0);
    end
    
    UpdateROIs(handles);


% UIWAIT makes nmssSpecAnalysisDlg wait for user response (see UIRESUME)
% uiwait(handles.nmssSpecAnalysisDlg);

% --- Outputs from this function are returned to the command line.
function varargout = nmssSpecAnalysisDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;


function UpdateROIs(handles)
% this helper function updates the handles structure for the ROI
% definitions. this function is called from all functions, which change the
% ROI-s
    RefreshImage(handles);

    % Update handles structure
    guidata(handles.nmssSpecAnalysisDlg, handles);

function editRectStartX_Callback(hObject, eventdata, handles)
% hObject    handle to editRectStartX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRectStartX as text
%        str2double(get(hObject,'String')) returns contents of editRectStartX as a double
    global doc;

    if (~nmssValidateNumericEdit(hObject, 'Top Left Pos Y'))
        return;
    end
        
    if (~CheckROIs(handles))
        uicontrol(hObject);
        return;
    end
    
    start_x = floor(str2num(get(hObject, 'String')));
    
    if(get(handles.rbParticle, 'Value'))
        roi.particle = ConvertROIPixel2Unit(doc.roi.particle, doc.figure_axis.unit);
        [ old_start_x, start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.particle, doc.figure_axis.unit );
        [roi.particle] = nmssConvertStartEnd2ROI( start_x, start_y, end_x, end_y, doc.figure_axis.unit );
        roi.particle.exists = 1;
        
        doc.roi.particle = ConvertROIUnit2Pixel(roi.particle, doc.figure_axis.unit);
        
    elseif(get(handles.rbBackground1, 'Value'))
        roi.bg1 = ConvertROIPixel2Unit(doc.roi.bg1, doc.figure_axis.unit);
        [ old_start_x, start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.bg1, doc.figure_axis.unit );
        [roi.bg1] = nmssConvertStartEnd2ROI( start_x, start_y, end_x, end_y, doc.figure_axis.unit );
        roi.bg1.exists = 1;

        doc.roi.bg1 = ConvertROIUnit2Pixel(roi.bg1, doc.figure_axis.unit);
        
    elseif(get(handles.rbBackground2, 'Value'))
%         roi.bg2 = ConvertROIPixel2Unit(doc.roi.bg2, doc.figure_axis.unit);
%         roi.bg2.exists = 1;
%         roi.bg2.x = corner_x;
%         doc.roi.bg2 = ConvertROIUnit2Pixel(roi.bg2, doc.figure_axis.unit);
    end
    
    UpdateROIs(handles);


% --- Executes during object creation, after setting all properties.
function editRectStartX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRectStartX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: editParticleBgROIDistance controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function editRectStartY_Callback(hObject, eventdata, handles)
% hObject    handle to editRectStartY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRectStartY as text
%        str2double(get(hObject,'String')) returns contents of editRectStartY as a double
    global doc;

    if (~nmssValidateNumericEdit(hObject, 'Top Left Pos Y'))
        return;
    end
        
    if (~CheckROIs(handles))
        uicontrol(hObject);
        return;
    end

    start_y = floor(str2num(get(hObject, 'String')));

    if(get(handles.rbParticle, 'Value'))
        roi.particle = ConvertROIPixel2Unit(doc.roi.particle, doc.figure_axis.unit);
        [ start_x, old_start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.particle, doc.figure_axis.unit );
        [roi.particle] = nmssConvertStartEnd2ROI( start_x, start_y, end_x, end_y, doc.figure_axis.unit );
        doc.roi.particle = ConvertROIUnit2Pixel(roi.particle, doc.figure_axis.unit);
    elseif(get(handles.rbBackground1, 'Value'))
        roi.bg1 = ConvertROIPixel2Unit(doc.roi.bg1, doc.figure_axis.unit);
        [ start_x, old_start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.bg1, doc.figure_axis.unit );
        [roi.bg1] = nmssConvertStartEnd2ROI( start_x, start_y, end_x, end_y, doc.figure_axis.unit );
        roi.bg1.exists = 1;
        doc.roi.bg1 = ConvertROIUnit2Pixel(roi.bg1, doc.figure_axis.unit);
    elseif(get(handles.rbBackground2, 'Value'))
%         roi.bg2 = ConvertROIPixel2Unit(doc.roi.bg2, doc.figure_axis.unit);
%         roi.bg2.exists = 1;
%         roi.bg2.y = corner_y;
%         doc.roi.bg2 = ConvertROIUnit2Pixel(roi.bg2, doc.figure_axis.unit);
    end

    UpdateROIs(handles);


% --- Executes during object creation, after setting all properties.
function editRectStartY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRectStartY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: editParticleBgROIDistance controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editRectEndX_Callback(hObject, eventdata, handles)
% hObject    handle to editRectEndX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRectEndX as text
%        str2double(get(hObject,'String')) returns contents of editRectEndX as a double
    global doc;

    if (~nmssValidateNumericEdit(hObject, 'Btm ri. Pos X'))
        return;
    end
        
    if (~CheckROIs(handles))
        uicontrol(hObject);
        return;
    end

    end_x = floor(str2num(get(hObject, 'String')));

    if (get(handles.rbParticle, 'Value'))
        roi.particle = ConvertROIPixel2Unit(doc.roi.particle, doc.figure_axis.unit);
        [ start_x, start_y, old_end_x, end_y] = nmssConvertROI2StartEnd( roi.particle, doc.figure_axis.unit );
        [roi.particle] = nmssConvertStartEnd2ROI( start_x, start_y, end_x, end_y, doc.figure_axis.unit );
        roi.particle.exists = 1;
        doc.roi.particle = ConvertROIUnit2Pixel(roi.particle, doc.figure_axis.unit);
    elseif (get(handles.rbBackground1, 'Value'))
        roi.bg1 = ConvertROIPixel2Unit(doc.roi.bg1, doc.figure_axis.unit);
        [ start_x, start_y, old_end_x, end_y] = nmssConvertROI2StartEnd( roi.bg1, doc.figure_axis.unit );
        [roi.bg1] = nmssConvertStartEnd2ROI( start_x, start_y, end_x, end_y, doc.figure_axis.unit );
        roi.bg1.exists = 1;
        doc.roi.bg1 = ConvertROIUnit2Pixel(roi.bg1, doc.figure_axis.unit);
    elseif (get(handles.rbBackground2, 'Value'))
        doc.roi.autobgwidth.x = width_x;
        CreateAutoBGROI(doc.roi.autobgwidth.x, doc.roi.autobgwidth.y);
    end

    UpdateROIs(handles);


% --- Executes during object creation, after setting all properties.
function editRectEndX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRectEndX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: editParticleBgROIDistance controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editRectEndY_Callback(hObject, eventdata, handles)
% hObject    handle to editRectEndY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRectEndY as text
%        str2double(get(hObject,'String')) returns contents of editRectEndY as a double

    global doc;

    if (~nmssValidateNumericEdit(hObject, 'Width Y'))
        return;
    end
        
    if (~CheckROIs(handles))
        uicontrol(hObject);
        return;
    end
    
    
    
    end_y = floor(str2num(get(hObject, 'String')));

    if (get(handles.rbParticle, 'Value'))
        roi.particle = ConvertROIPixel2Unit(doc.roi.particle, doc.figure_axis.unit);
        [ start_x, start_y, end_x, old_end_y] = nmssConvertROI2StartEnd( roi.particle, doc.figure_axis.unit );
        [roi.particle] = nmssConvertStartEnd2ROI( start_x, start_y, end_x, end_y, doc.figure_axis.unit );
        roi.particle.exists = 1;

        doc.roi.particle = ConvertROIUnit2Pixel(roi.particle, doc.figure_axis.unit);

    elseif (get(handles.rbBackground1, 'Value'))
        roi.bg1 = ConvertROIPixel2Unit(doc.roi.bg1, doc.figure_axis.unit);
        [ start_x, start_y, end_x, dummy] = nmssConvertROI2StartEnd( roi.bg1, doc.figure_axis.unit );
        [roi.bg1] = nmssConvertStartEnd2ROI( start_x, start_y, end_x, end_y, doc.figure_axis.unit );
        roi.bg1.exists = 1;

        doc.roi.bg1 = ConvertROIUnit2Pixel(roi.bg1, doc.figure_axis.unit)

    elseif (get(handles.rbBackground2, 'Value'))
        doc.roi.autobgwidth.y = width_y;
        CreateAutoBGROI(doc.roi.autobgwidth.x, doc.roi.autobgwidth.y);
    end

    UpdateROIs(handles);
    


% --- Executes during object creation, after setting all properties.
function editRectEndY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRectEndY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: editParticleBgROIDistance controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in btnGetRectFromMouse.
function btnGetRectFromMouse_Callback(hObject, eventdata, handles)
% hObject    handle to btnGetRectFromMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    % activate image
    global doc;
    
    hFig = ancestor(hObject, 'figure');
    user_data = get(hFig, 'UserData');
    hParentFig = user_data.CallerFigHandle;
    
    if (ishandle(hParentFig))
        figure(hParentFig);
    else
        nmssFigure();
    end
    handles_figure = guidata(hParentFig);
    figure(hParentFig);
    
    
    % select particle
    if (get(handles.rbParticle, 'Value'))
        
        %[corner_x, corner_y, width_x, width_y] = GetRect(nmssGetFullImageLimits(doc.figure_axis.unit));
        [start_x, start_y, end_x, end_y] = GetRect(nmssGetFullImageLimits(doc.figure_axis.unit));
        
        
%         set(handles.editRectStartX, 'String', num2str(corner_x,'%4.3f'));
%         set(handles.editRectStartY, 'String', num2str(corner_y,'%4.3f'));
%         set(handles.editRectEndX, 'String', num2str(width_x ,'%4.3f'));
%         set(handles.editRectEndY, 'String', num2str(width_y ,'%4.3f'));
        
        set(handles.editRectStartX, 'String', num2str(start_x,'%4.3f'));
        set(handles.editRectStartY, 'String', num2str(start_y,'%4.3f'));
        set(handles.editRectEndX, 'String', num2str(end_x ,'%4.3f'));
        set(handles.editRectEndY, 'String', num2str(end_y ,'%4.3f'));
        
        [ roi.particle] = nmssConvertStartEnd2ROI( start_x, start_y, end_x, end_y, doc.figure_axis.unit ); 
        roi.particle.exists = 1;
        roi.particle.valid = 1;
        
        doc.roi.particle = ConvertROIUnit2Pixel(roi.particle, doc.figure_axis.unit);
        
        % reset backgroud
        doc.roi.bg1 = nmssResetROI();
        doc.roi.bg1.wx = doc.roi.particle.wx;
        doc.roi.bg1.wy = doc.roi.particle.wy;
        doc.roi.bg2 = nmssResetROI();
        doc.roi.bg2.wx = doc.roi.particle.wx;
        doc.roi.bg2.wy = doc.roi.particle.wy;
        
        
        UpdateROIs(handles);
        
    elseif (get(handles.rbBackground1, 'Value'))
        
%         [corner_x, corner_y, width_x, width_y] = GetRect(nmssGetFullImageLimits(doc.figure_axis.unit));
        [start_x, start_y, end_x, end_y] = GetRect(nmssGetFullImageLimits(doc.figure_axis.unit));

        
%         % select the top left corner of ROI
%         [start_x, start_y] = ginput(1);
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
        
        % initialization
        [ roi.bg1] = nmssConvertStartEnd2ROI( start_x, start_y, end_x, end_y, doc.figure_axis.unit ); 
        roi.bg1.exists = 1;
        roi.bg1.valid = 1;
        
        doc.roi.bg1 = ConvertROIUnit2Pixel(roi.bg1, doc.figure_axis.unit);
        
        set(handles.editRectStartX, 'String', num2str(start_x,'%4.3f'));
        set(handles.editRectStartY, 'String', num2str(start_y,'%4.3f'));
        set(handles.editRectEndX, 'String', num2str(end_x ,'%4.3f'));
        set(handles.editRectEndY, 'String', num2str(end_y ,'%4.3f'));
%         set(handles.editRectStartX, 'String', num2str(corner_x,'%4.3f'));
%         set(handles.editRectStartY, 'String', num2str(corner_y,'%4.3f'));
%         set(handles.editRectEndX, 'String', num2str(width_x ,'%4.3f'));
%         set(handles.editRectEndY, 'String', num2str(width_y ,'%4.3f'));
        
        % refresh rectangles on image
        UpdateROIs(handles);
        
    elseif (get(handles.rbBackground2, 'Value'))
        % background will be determined later automatically
        % the background is a one bixel broad frame around the selected
        % particle
        % refresh rectangles on image
        UpdateROIs(handles);
    end
    
%function [corner_x, corner_y, width_x, width_y] = GetRect(full_lim)
function [upleft_x, upleft_y, downright_x, downright_y] = GetRect(full_lim)
% GetRect activates the rubber band area selection tool over the currently
% active axis
%
% INPUT: full_lim = the limits of the axis in the units which is currently
% active for the axis. Read more here: nmssGetFullImageLimits

        k = waitforbuttonpress;
        point1 = get(gca,'CurrentPoint');    % button down detected
        finalRect = rbbox;                   % return figure units
        point2 = get(gca,'CurrentPoint');    % button up detected
        
        point1 = point1(1,1:2);              % extract x and y
        point2 = point2(1,1:2);
        
        %nmssDrawRectBetween2Points(point1, point2, 1);

        start_x = point1(1,1);
        start_y = point1(1,2);
        end_x = point2(1,1);
        end_y = point2(1,2);
        
        % get the top left corner of the rectangle
        if (end_x < start_x)
            temp = end_x;
            end_x = start_x;
            start_x = temp;
        end
        if (end_y < start_y)
            temp = end_y;
            end_y = start_y;
            start_y = temp;
        end
            
        % snap rectangle's coordinates to the outer boundary of the pixels
        % contained within or which are on the rubber box line
        corner_x = floor(start_x + 0.5);
        end_x = ceil(end_x - 0.5);
        corner_y = floor(start_y + 0.5);
        end_y = ceil(end_y - 0.5);
        
        if (corner_x < full_lim.x(1))
            corner_x = full_lim.x(1);
        elseif (end_x > full_lim.x(2))
            end_x = full_lim.x(2);
        end
        
        if (corner_y < full_lim.y(1))
            corner_y = full_lim.y(1);
        elseif (end_y > full_lim.y(2))
            end_y = full_lim.y(2);
        end
        
        width_x = abs(end_x - corner_x) + 1;
        width_y = abs(end_y - corner_y) + 1;
        
        upleft_x = corner_x;
        upleft_y = corner_y;
        downright_x = end_x;
        downright_y = end_y;
    
    
%
function roi_def = ConvertROIUnit2Pixel(roi_in_unit, unit)
% converts roi units to pixels
    roi_def = nmssConvertROIUnit2Pixel(roi_in_unit, unit);   

%
function roi_def = ConvertROIPixel2Unit(roi_in_pixel, unit)
% converts roi units from pixels to specified unit
    roi_def = nmssConvertROIPixel2Unit(roi_in_pixel, unit);
    


function RefreshImage(handles)
% refresh image (deletes old markers)
    %nmssFigure('RefreshImage', 10);
    %nmssFigure('RefreshImage', 10);
    global doc;
    
    user_data = get(handles.nmssSpecAnalysisDlg, 'UserData');
    hParentFig = user_data.CallerFigHandle;
    
    % activate or create figure window
    if (ishandle(hParentFig))
        figure(hParentFig);
    else
        nmssFigure();
    end
    figure_handles = guidata(hParentFig);

    full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);
    current_limits.x = xlim;
    current_limits.y = ylim;
    
    nmssPaintImage('refresh', doc.img, hParentFig, figure_handles.canvasFigureAxes, full_lim, current_limits);
    
    % get the size of half pixel in unit
    [tmp1_x, tmp1_y] = nmssPixel_2_Unit(1, 1, doc.figure_axis.unit);
    [tmp2_x, tmp2_y] = nmssPixel_2_Unit(1.5, 1.5, doc.figure_axis.unit);
    half_x = abs(tmp2_x - tmp1_x);
    half_y = abs(tmp2_y - tmp1_y);
    
    % get roi in unit
    roi.particle = ConvertROIPixel2Unit(doc.roi.particle, doc.figure_axis.unit);
    roi.bg1 = ConvertROIPixel2Unit(doc.roi.bg1, doc.figure_axis.unit);
    roi.bg2 = ConvertROIPixel2Unit(doc.roi.bg2, doc.figure_axis.unit);
    
    % snap rectangle's coordinates to the outer boundary of the pixels
    % contained within and on the boundary of the rectangle
%     start_x = roi.particle.x - half_x; % -0.5 to position the rectangle at the border or the ROI
%     start_y = roi.particle.y - half_y;
%     end_x = start_x + roi.particle.wx;
%     end_y = start_y + roi.particle.wy;

    
    if (doc.roi.particle.exists)
        [ start_x, start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.particle, doc.figure_axis.unit );
        hOldROI = findobj(hParentFig, 'Tag', 'nmss_roi_particle');
        delete(hOldROI);
        
        if (get(handles.rbParticle, 'Value'))
            nmssDrawRectBetween2Points([start_x, start_y], [end_x, end_y], 1, 'g', '-', 'nmss_roi_particle');
        else
            nmssDrawRectBetween2Points([start_x, start_y], [end_x, end_y], 1, 'r', '-', 'nmss_roi_particle');
        end
    end
    
    if (get(handles.cxEnableBackground, 'Value'))
        [ start_x, start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.bg1, doc.figure_axis.unit );
%         start_x = roi.bg1.x - half_x;
%         start_y = roi.bg1.y - half_y;
%         end_x = start_x + roi.bg1.wx;
%         end_y = start_y + roi.bg1.wy;
        
        hOldROI = findobj(hParentFig, 'Tag', 'nmss_roi_bg1');
        delete(hOldROI);
            
        if (doc.roi.bg1.exists)
            
            if (get(handles.rbBackground1, 'Value'))
                nmssDrawRectBetween2Points([start_x, start_y], [end_x, end_y], 1, 'g', '-', 'nmss_roi_bg1');
            else
                nmssDrawRectBetween2Points([start_x, start_y], [end_x, end_y], 1, 'r', '-', 'nmss_roi_bg1');
            end
        end

        [ start_x, start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.bg2, doc.figure_axis.unit );
%         start_x = roi.bg2.x - half_x;
%         start_y = roi.bg2.y - half_y;
%         end_x = start_x + roi.bg2.wx;
%         end_y = start_y + roi.bg2.wy;
        
        hOldROI = findobj(hParentFig, 'Tag', 'nmss_roi_bg2');
        delete(hOldROI);
        
        if (doc.roi.bg2.exists)
            
            if (get(handles.rbBackground2, 'Value'))
                nmssDrawRectBetween2Points([start_x, start_y], [end_x, end_y], 1, 'g', '-', 'nmss_roi_bg2');
            else
                nmssDrawRectBetween2Points([start_x, start_y], [end_x, end_y], 1, 'r', '-', 'nmss_roi_bg2');
            end
        end
    end


% --- Executes on button press in rbParticle.
function rbParticle_Callback(hObject, eventdata, handles)
% hObject    handle to rbParticle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;

    % Hint: get(hObject,'Value') returns toggle state of rbParticle
    if (get(hObject,'Value'))
        set(handles.rbBackground1, 'Value', 0);
        set(handles.rbBackground2, 'Value', 0);
        UpdateROIGUI(handles, 'particle');
        

        % get roi in unit
        roi.particle = ConvertROIPixel2Unit(doc.roi.particle, doc.figure_axis.unit);
        roi.bg1 = ConvertROIPixel2Unit(doc.roi.bg1, doc.figure_axis.unit);
        roi.bg2 = ConvertROIPixel2Unit(doc.roi.bg2, doc.figure_axis.unit);
        
        [ start_x, start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.particle, doc.figure_axis.unit );
        set(handles.editRectStartX, 'String', num2str(start_x, '%4.3f') );
        set(handles.editRectStartY, 'String', num2str(start_y, '%4.3f') );
        set(handles.editRectEndX, 'String', num2str(end_x, '%4.3f') );
        set(handles.editRectEndY, 'String', num2str(end_y, '%4.3f') );
        
        % refresh rectangles on image (draw currently selected with green line)
        UpdateROIs(handles);
    else
        set(hObject,'Value', 1);
    end


% --- Executes on button press in btnClose.
function btnClose_Callback(hObject, eventdata, handles)
% hObject    handle to btnClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Update handles structure
    
    
    
    nmssSpecAnalysisDlg_CloseRequestFcn(handles.nmssSpecAnalysisDlg, eventdata, handles);
    
% --- Executes on button press in rbBackground1.
function rbBackground1_Callback(hObject, eventdata, handles)
% hObject    handle to rbBackground1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;

    % Hint: get(hObject,'Value') returns toggle state of rbBackground1
    if (get(hObject,'Value'))
        set(handles.rbParticle, 'Value', 0);
        set(handles.rbBackground2, 'Value', 0);
        UpdateROIGUI(handles, 'manu_bg');
        
        
        
        % make the other background disabled
        doc.roi.bg2.valid = 0;
        doc.roi.bg2.exists = 0;
        

        % get roi in unit
        roi.particle = ConvertROIPixel2Unit(doc.roi.particle, doc.figure_axis.unit);
        roi.bg1 = ConvertROIPixel2Unit(doc.roi.bg1, doc.figure_axis.unit);
        roi.bg2 = ConvertROIPixel2Unit(doc.roi.bg2, doc.figure_axis.unit);
        
        [ start_x, start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.bg1, doc.figure_axis.unit );
        set(handles.editRectStartX, 'String', num2str(start_x, '%4.3f') );
        set(handles.editRectStartY, 'String', num2str(start_y, '%4.3f') );
        set(handles.editRectEndX, 'String', num2str(end_x, '%4.3f') );
        set(handles.editRectEndY, 'String', num2str(end_y, '%4.3f') );

        % refresh rectangles on image (draw currently selected with green line)
        UpdateROIs(handles);
    else
        set(hObject,'Value', 1);
    end

function UpdateROIGUI(handles, guitype)
% updates GUI elements that correspond to ROI settings
    if (strcmp(guitype,'auto_bg'))
        set(handles.editRectStartX, 'Visible', 'off');
        set(handles.editRectStartY, 'Visible', 'off');
        set(handles.txROIWidth, 'String', 'Width (px)');
        set(handles.txROIStart, 'Visible', 'off');
    else
        set(handles.editRectStartX, 'Visible', 'on');
        set(handles.editRectStartY, 'Visible', 'on');
        set(handles.txROIWidth, 'String', 'Size');
        set(handles.txROIStart, 'Visible', 'on');
    end

function CreateAutoBGROI(frame_width_X_px, frame_width_Y_px)
% creates a frame around the particle ROI
    global doc;

    roi.bg2 = doc.roi.particle;
    if (roi.bg2.x >= 1+ frame_width_X_px)
        roi.bg2.x = roi.bg2.x - frame_width_X_px;
    end
    if (roi.bg2.y >= 1+frame_width_Y_px)
        roi.bg2.y = roi.bg2.y - frame_width_Y_px;
    end

    % get the image full limits in pixel
    unit = doc.figure_axis.unit;
    unit.x = 'pixel';
    full_limits = nmssGetFullImageLimits(unit);

    if (roi.bg2.x + roi.bg2.wx + 2 * frame_width_X_px - 1 <=  full_limits.x(2))
        roi.bg2.wx = roi.bg2.wx + 2 * frame_width_X_px;
    else
        roi.bg2.wx = full_limits.x(2) - roi.bg2.x + 1;
    end

    if (roi.bg2.y + roi.bg2.wy + + 2 * frame_width_Y_px - 1  <=  full_limits.y(2))
        roi.bg2.wy = roi.bg2.wy + 2 * frame_width_Y_px;
    else
        roi.bg2.wy = full_limits.y(2) - roi.bg2.y + 1;
    end

    doc.roi.bg2 = roi.bg2;
    % make the other background disabled
    doc.roi.bg1.valid = 0;

        
% --- Executes on button press in rbBackground2.
function rbBackground2_Callback(hObject, eventdata, handles)
% hObject    handle to rbBackground2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;

    % Hint: get(hObject,'Value') returns toggle state of rbBackground2
    if (get(hObject,'Value'))
        set(handles.rbParticle, 'Value', 0);
        set(handles.rbBackground1, 'Value', 0);
        doc.roi.bg1.exists = 0;
        doc.roi.bg1.valid = 0;
        
        UpdateROIGUI(handles, 'auto_bg');

        % get roi in pixel as we operate on pixel level for the automatic
        % background set up
%         if (~strcmp(doc.figure_axis.unit.x,'pixel'))
%             roi.particle = ConvertROIUnit2Pixel(doc.roi.particle, doc.figure_axis.unit);
%         else
%             roi.particle = doc.roi.particle;
%         end
        
        CreateAutoBGROI(doc.roi.autobgwidth.x, doc.roi.autobgwidth.y);
        
        set(handles.editRectEndX, 'String', num2str(doc.roi.autobgwidth.x, '%4.3f') );
        set(handles.editRectEndY, 'String', num2str(doc.roi.autobgwidth.y, '%4.3f') );
            
        % refresh rectangles on image (draw currently selected with green line)
        UpdateROIs(handles);
    else
        set(hObject,'Value', 1);
    end


% --- Executes on button press in cxEnableWLCorrection.
function cxEnableWLCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to cxEnableWLCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxEnableWLCorrection
    global doc;
    doc.white_light_corr.enable = get(hObject,'Value');

% --- Executes on button press in btnBrowseWLSpectra.
function btnBrowseWLSpectra_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrowseWLSpectra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    
    global doc;
    hFig = ancestor(hObject, 'figure');
    user_data = get(hFig, 'UserData');
    hParentFig = user_data.CallerFigHandle;
    
    
    
    old_dir = pwd();
    
    % change to the directory of the application (this is where the white
    % light text files are stored)
    cd(doc.workDir);
    [filename, dirname] = uigetfile({'*.mat', 'Mat-File (*.mat)'; ...
                                     '*.txt', 'Tab-deliminted text files (*.txt)'}, 'Load White Light - Select File');
    cd(old_dir);
    
    % change to the working directory
    %cd(doc.workDir);
    
    if (filename == 0) % user pressed cancel
        return;
    end
    
    image_x_size = size(doc.img,2);
    white_light = ones(image_x_size,1); % column vector
    
    file_path = fullfile(dirname, filename);
    [pathstr_dummy,name_dummy,extension] = fileparts(file_path);    
    
    if (strcmp(extension, '.mat'))
        try
            % read tab delimited data from the text file
            tmp = load(file_path);
            
            % let's see what we have read
            if (isstruct(tmp))
                struct_fieldnames = fieldnames(tmp);
                if (length(struct_fieldnames) ~= 1)
                    errordlg({'Incorrect white light file.';...
                              'This .mat file contains more than one variable'; ....
                              'How should I know which one is the white light?'});
                    return;
                end
                
                white_light = getfield(tmp, struct_fieldnames{1});
            else
                errordlg({'Error while reading the white light file'});
            end
            
        catch
            msg_txt = lasterr();
            errordlg(msg_txt);
        end
        
    elseif (strcmp(extension, '.txt'))
        try
            % read tab delimited data from the text file
            white_light = dlmread(file_path, '\t');
            
        catch
            msg_txt = lasterr();
            errordlg(msg_txt);
        end
    else
        errordlg(['Unknown file extension: ', extension]);
        return;
    end
            

    % check if the imported white light spectra complies with the
    % requirements set by the image dimension
    % these two value must match!!!
    num_of_white_light_datapoints = size(white_light,1);

    if (num_of_white_light_datapoints ~= image_x_size )
        errtxt = {['The number of data points in the imported white light spectra (', num2str(num_of_white_light_datapoints, '%d'),') ',...
                  'does not match the x-size of the image (',num2str(image_x_size, '%d'),')!']};
        errordlg(errtxt);
        return;
    end

    % check if the number of columns is equal to two, 1st column =
    % wavelength, 2nd column = Intensity
    if (size(white_light,2) ~= 2)
        errtxt = {'Incorrect white light data format!';'';'There are two columns expected:';...
                  '1st column: wavelength ';'2nd column: white light intenisty'};

        errordlg(errtxt);
        return;
    end

    global doc;
    max_white_light = max(white_light(:,2));
    doc.white_light_corr.data = [white_light(:,1), white_light(:,2) / max_white_light]; % normalize white light to max=1

    doc.white_light_corr.filepath = file_path;

    % update editPathWLSpectra field containing the white light spectrum
    set(handles.editPathWLSpectra, 'String', file_path);
    % enable show white light spectra button and other corresponding
    % gui elements
    set(handles.btnShowWhiteLight, 'Enable', 'on');
    set(handles.cxEnableWLCorrection, 'Enable', 'on');
    set(handles.cxEnableWLCorrection, 'Value', doc.white_light_corr.enable);
    
    
    
    


    
function valid = IsValidROI(roi_definition, img)
% roi_definition - the ROI structure roi.particle or roi.bg1 ... etc.
% img - the image on which the ROI will be placed
    valid = 1;
    
    % check ROIs
    if ((roi_definition.x + roi_definition.wx - 1) > size(img,2))
        valid = 0;
        return;
    end
    
    if ((roi_definition.y + roi_definition.wy - 1) > size(img,1))
        valid = 0;
        return;
    end
        
    if (roi_definition.x < 1)
        valid = 0;
        return;
    end
    
    if (roi_definition.y < 1)
        valid = 0;
        return;
    end
    
    
    
function graph = GetGraphFromROI(roi, img, white_light)

    % get particle data
    corner_x = roi.particle.x;
    corner_y = roi.particle.y;
    width_x = roi.particle.wx;
    width_y = roi.particle.wy;
    roi_img = img(corner_y:corner_y+width_y-1, corner_x:corner_x+width_x-1);
    graph.particle = sum(roi_img,1)/size(roi_img,1);
    
    % get particle data
    if (roi.bg1.valid)
        corner_x = roi.bg1.x;
        corner_y = roi.bg1.y;
        width_x = roi.bg1.wx;
        width_y = roi.bg1.wy;
        roi_img = img(corner_y:corner_y+width_y-1, corner_x:corner_x+width_x-1);
        graph.bg = sum(roi_img,1)/size(roi_img,1);
    else
        graph.bg = zeros(1, size(graph.particle,2));
    end
    
    % get particle data
    if (roi.bg2.valid)
        corner_x = roi.bg2.x;
        corner_y = roi.bg2.y;
        width_x = roi.bg1.wx;
        width_y = roi.bg2.wy;
        roi_img = img(corner_y:corner_y+width_y-1, corner_x:corner_x+width_x-1);
        graph.bg2 = sum(roi_img,1)/size(roi_img,1);
        
        graph.bg = (graph.bg + graph.bg2) / 2.0;
    end
    
    graph.bg_subtracted = graph.particle - graph.bg;
    
    % element wise division (graph.bg_subtracted is a row vector, white_light is a column vector)
    graph.normalized = graph.bg_subtracted ./ white_light';
    
function ErrorDlg(content)
    hErrDlg = errordlg(content);
    set(hErrDlg, 'WindowStyle', 'modal');
    uiwait(hErrDlg);


function valid = CheckROIs(handles)
% Wrapper for ROI checking methods. this function is dialog bound, it is
% using global variables used by the dialog 
    global doc;
    img = doc.img;    
    valid = 0;
    
    start_x = str2num(get(handles.editRectStartX, 'String'));
    start_y = str2num(get(handles.editRectStartY, 'String'));
    end_x = str2num(get(handles.editRectEndX, 'String'));
    end_y = str2num(get(handles.editRectEndY, 'String'));
    
    full_limits = nmssGetFullImageLimits(doc.figure_axis.unit);
    
    
    % max boundaries
    if (start_x > full_limits.x(2))
        ErrorDlg({'X of Top Left Pos must be smaller or equal than/to ', num2str(full_limits.x(2))});
        return;
    end
    
    if (start_y > full_limits.y(2))
        ErrorDlg({'Y of Top Left Pos must be smaller or equal than/to ', num2str(full_limits.y(2))});
        return;
    end
    
    if (end_x > full_limits.x(2))
        ErrorDlg({'X of Btm. Ri. Pos must be smaller or equal than/to ', num2str(full_limits.x(2))});
        return;
    end
    
    if (end_y > full_limits.y(2))
        ErrorDlg({'Y of Btm. Ri. Pos must be smaller or equal than/to ', num2str(full_limits.y(2))});
        return;
    end
    
    % min boundaries
    if (start_x < full_limits.x(1))
        ErrorDlg({'X of Top Left Pos must be smaller or equal than/to ', num2str(full_limits.x(1))});
        return;
    end
    
    if (start_y < full_limits.y(1))
        ErrorDlg({'Y of Top Left Pos must be smaller or equal than/to ', num2str(full_limits.y(1))});
        return;
    end
    
    if (end_x < full_limits.x(1))
        ErrorDlg({'X of Btm. Ri. Pos must be smaller or equal than/to ', num2str(full_limits.x(1))});
        return;
    end
    
    if (end_y < full_limits.y(1))
        ErrorDlg({'Y of Btm. Ri. Pos must be smaller or equal than/to ', num2str(full_limits.y(1))});
        return;
    end
    
    % consistency
    if (start_x > end_x)
        ErrorDlg({'X of Top Left Pos must be smaller than X of Btm. Ri. Pos!'});
        return;
    end
    
    if (start_y > end_y)
        ErrorDlg({'Y of Top Left Pos must be smaller than Y of Btm. Ri. Pos!'});
        return;
    end
    
    valid = 1;
    
function valid = CheckROIs_Old(varargin)
% Wrapper for ROI checking methods. this function is dialog bound, it is
% using global variables used by the dialog 
    global doc;
    img = doc.img;
    
    valid = 0;
    
    if (length(varargin) == 1)
        roi = varargin{1};
        if (~IsValidROI(roi, img))
            hErrDlg = errordlg({'Incorrect ROI definition'; ' ';'ROI extends over the image boundaries!'});
            set(hErrDlg, 'WindowStyle', 'modal');
            uiwait(hErrDlg);
            return;
        end
    else
        roi.particle = doc.roi.particle;
        roi.bg1 = doc.roi.bg1;
        roi.bg2 = doc.roi.bg2;

        % check particle ROI
        if (roi.particle.exists)
            if (~IsValidROI(roi.particle, img))
                errordlg({'Incorrect ROI definition'; ' ';'Particle ROI extends over the image boundaries!'});
                return;
            end
            doc.roi.particle.valid = 1;
    %     else
    %         % user forgot to define particle ROI (yes, sir we need it to show a
    %         % graph of a spectrum)
    %         errordlg({'Please define the ROI for a particle.';''; ...
    %             'In automatic peak identification modus the definied particle ROI x-width will be taken for all particles.'});
    %         return;
        end

        % check background 1 ROI
        doc.roi.bg1.valid = 0;
        if (roi.bg1.exists)
            if (~IsValidROI(roi.bg1, img))
                errordlg({'Incorrect ROI definition'; ' ';'Background 1 ROI extends over the image boundaries!'});
                return;
            end
            doc.roi.bg1.valid = 1;
        end

        % check background 2 ROI
        doc.bg2.valid = 0;
        if (roi.bg2.exists)
            if (~IsValidROI(roi.bg2, img))
                errordlg({'Incorrect ROI definition'; ' ';'Background 2 ROI extends over the image boundaries!'});
                return;
            end
            doc.roi.bg2.valid = 1;
        end

        % if the ROI has survived the previous check, than it can be declared
        % as valid ROI
    end
    
    valid = 1;
    

% --- Executes on button press in btnShowGraph.
function btnShowGraph_Callback(hObject, eventdata, handles)
% hObject    handle to btnShowGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;

    % set mouse cursor to busy (watch)
    set(handles.nmssSpecAnalysisDlg,'Pointer','watch');
    
        
        % check if ROIs are inside of the image
        if (CheckROIs())
            % get image
            global doc;
            img = doc.img;

            white_light = ones(size(img,2), 1);

            white_light_roi = white_light(doc.roi.particle.x : doc.roi.particle.x+doc.roi.particle.wx - 1)';

            graph = nmssCreateGraph( img, doc.roi, white_light_roi, 0);

            %fig = PlotGraph(graph, 'Vertically binned data of ROI');
            fig = nmssPlotGraph(graph, 'Vertically binned data of ROI', {'particle', 'smoothed'});

        end
    
    
    % switch back the busy cursor to the normal arrow
    set(handles.nmssSpecAnalysisDlg,'Pointer','arrow');





% --- Executes when user attempts to close nmssSpecAnalysisDlg.
function nmssSpecAnalysisDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssSpecAnalysisDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global doc;
    hFig = ancestor(hObject, 'figure');
    user_data = get(hFig, 'UserData');
    hParentFig = user_data.CallerFigHandle;
    
    
    if (~CheckROIs(handles))
        return;
    end
    
    % save settings into the global variable called doc
    % doc.roi.particle = ConvertROIUnit2Pixel(doc.roi.particle);
    
%     % ensure that the background ROIs have the same widths as the particle
%     % ROI...
%     doc.roi.bg1.wx = doc.roi.particle.wx;
%     doc.roi.bg1.wy = doc.roi.particle.wy;
%     doc.roi.bg2.wx = doc.roi.particle.wx;
%     doc.roi.bg2.wy = doc.roi.particle.wy;
    
    
    
    % enable disabled gui elements
    if (ishandle(hParentFig))
        parent_handles = guidata(hParentFig);
        % enable buttons which were disabled before
        set(parent_handles.btnChangeAxisUnits, 'Enable', 'on');
        set(parent_handles.mnCaliLateral, 'Enable', 'on');
        set(parent_handles.mnCaliSpectral, 'Enable', 'on');
        set(parent_handles.mnAnalysis, 'Enable', 'on');
    end
    

% Hint: delete(hObject) closes the figure
    delete(hObject);


function editPathWLSpectra_Callback(hObject, eventdata, handles)
% hObject    handle to editPathWLSpectra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPathWLSpectra as text
%        str2double(get(hObject,'String')) returns contents of editPathWLSpectra as a double


% --- Executes during object creation, after setting all properties.
function editPathWLSpectra_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPathWLSpectra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: editParticleBgROIDistance controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in btnYSum.
%function btnYSum_Callback(hObject, eventdata, handles)
function graph = PeakIdentification_FittedBackground( white_light, roi_in_pixel)
% Identifies the peaks using a threshold on the residuals obtained by 
% a polynomial fit on the x-direction sum of the image
% white_light - column vector containing the white light intensity values,
%               this is used to normalize the measured signal
% roi_in_pixel - region of interest. Only the x and the wx field is used to
%                determine the x-range of the graphs (woring on the whole x-range 
%                of the CCD chip is not useful as the border regions are very noisy)

    global doc;

    analysis = nmssResetAnalysisParam('fit_background');
    graph = nmssSpecAnalysis(doc.img, white_light, roi_in_pixel, analysis);
        


% --- Executes on button press in btnYMax.
function graph = PeakIdentification_0th_derivative(handles, white_light, roi_in_pixel)
% Identifies the peaks using the maximum of the image silouhette
% along the x-direction
% handles    structure with handles and user data (see GUIDATA)
% white_light - column vector containing the white light intensity values,
%               this is used to normalize the measured signal
% roi_in_pixel - region of interest. Only the x and the wx field is used to
%                determine the x-range of the graphs (woring on the whole x-range 
%                of the CCD chip is not useful as the border regions are very noisy)

    global doc;

    analysis = nmssResetAnalysisParam('0th_derivative');
    [analysis.threshold, analysis.std_weighing] = GetCustomizedThreshold(handles);
        
    graph = nmssSpecAnalysis(doc.img, white_light, roi_in_pixel, analysis);

function graph = PeakIdentification_1st_derivative(handles, white_light, roi_in_pixel)
% Identifies the peaks using the maximum of the image silouhette
% along the x-direction
% handles    structure with handles and user data (see GUIDATA)
% white_light - column vector containing the white light intensity values,
%               this is used to normalize the measured signal
% roi_in_pixel - region of interest. Only the x and the wx field is used to
%                determine the x-range of the graphs (woring on the whole x-range 
%                of the CCD chip is not useful as the border regions are very noisy)

    global doc;

    analysis = nmssResetAnalysisParam('1st_derivative');
    [analysis.threshold, analysis.std_weighing] = GetCustomizedThreshold(handles);
    
    graph = nmssSpecAnalysis(doc.img, white_light, roi_in_pixel, analysis);

%
%        
%function [threshold, tuning_param, roi_min_y_size] = GetCustomizedThreshold(handles)
function [threshold, tuning_param] = GetCustomizedThreshold(handles)
    global doc;
    threshold = 0;
    tuning_param = 1;
    roi_min_y_size = 0;
    
    % check if the weighting parameter for the standard deviation is a
    % number
    if (~nmssValidateNumericEdit(handles.editStdDev_Weighting, 'Weighting for Std. Dev'))
        return;
    end
    

    % get max value of each row of the image
    [ymax_of_image, col_index] = max(doc.img');

    % the threshold above which the intensity values can be treated as
    % signals
    tuning_param = str2num(get(handles.editStdDev_Weighting,'String'));
    threshold = mean(cast(ymax_of_image, 'double')) + tuning_param * std(cast(ymax_of_image, 'double'));
    
    
    
%    
function fig = PlotGraph(graph, figname)
% plots graph with blue if background could be identified and with red if
% backgrouond couldn't be identified
% graph - the graph structure
    
    %fig = nmssPlotGraph(graph, [figname, 'smoothed'], 'smoothed');
    fig = nmssPlotGraph(graph, [figname, ' Normalized'], {'normalized'});




% --- Executes on button press in btnRefreshImage.
function btnRefreshImage_Callback(hObject, eventdata, handles)
% hObject    handle to btnRefreshImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    
    if (get(handles.rbParticle, 'Value'))
        % converting to image units and converting width to end (bottom right) coordinates
        roi.particle = ConvertROIPixel2Unit(doc.roi.particle, doc.figure_axis.unit);
        [ start_x, start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.particle, doc.figure_axis.unit);
        set(handles.editRectStartX, 'String', num2str(start_x, '%4.3f') );
        set(handles.editRectStartY, 'String', num2str(start_y, '%4.3f') );
        set(handles.editRectEndX, 'String', num2str(end_x, '%4.3f') );
        set(handles.editRectEndY, 'String', num2str(end_y, '%4.3f') );

    elseif (get(handles.rbBackground1, 'Value'))
        % converting to image units and converting width to end (bottom right) coordinates
        roi.bg1 = ConvertROIPixel2Unit(doc.roi.bg1, doc.figure_axis.unit);
        [ start_x, start_y, end_x, end_y] = nmssConvertROI2StartEnd( roi.bg1, doc.figure_axis.unit );
        set(handles.editRectStartX, 'String', num2str(start_x, '%4.3f') );
        set(handles.editRectStartY, 'String', num2str(start_y, '%4.3f') );
        set(handles.editRectEndX, 'String', num2str(end_x, '%4.3f') );
        set(handles.editRectEndY, 'String', num2str(end_y, '%4.3f') );

    elseif (get(handles.rbBackground2, 'Value'))
        doc.roi.autobgwidth.y = width_y;
        CreateAutoBGROI(doc.roi.autobgwidth.x, doc.roi.autobgwidth.y);
    end


    RefreshImage(handles);



function HighLightPeaks(graph, hParentFig)
% draws dash-dot lines on the image indicating the peak locations
%
% INPUT:
% graph -  a structure cell array containing information on each peak (as returned from nmssSpecAnalysis)
    
    % activate or create figure window
    if (ishandle(hParentFig))
        figure(hParentFig);
    else
        nmssFigure();
    end

    num_of_peaks = length(graph);
    
    for k=1:num_of_peaks
        
        global doc;
        unit = doc.figure_axis.unit;
        image_limts = nmssGetFullImageLimits(unit);
        roi_in_unit = ConvertROIPixel2Unit(graph{k}.roi.particle, unit);
        
        peak_center_y = floor(roi_in_unit.y + roi_in_unit.wy * 0.5);
        
        % horizontal line to show the peak
        line(image_limts.x, [peak_center_y  peak_center_y],'Color', 'b','LineWidth', 1, 'LineStyle', '-.', 'Tag', 'bright_spots');
        
        % vertical tick to indicate the max of the peak
        [max_x_value, max_x_index] = max(graph{k}.normalized);
        
        max_x_px = graph{k}.offset_x_px + max_x_index;
        
        [max_x_pos, dummy] = nmssPixel_2_Unit(max_x_px, 0, unit);
        
        % x-axis can be in pixels or in nm, y-axis is always in pixels
        line([max_x_pos, max_x_pos],[roi_in_unit.y, roi_in_unit.y + roi_in_unit.wy], ...
            'Color', 'b','LineWidth', 1, 'LineStyle', '-.', 'Tag', 'bright_spots');
        
        % draw particle ROI
        p_roi_in_unit = ConvertROIPixel2Unit(graph{k}.roi.particle, unit);
        point1 = [p_roi_in_unit.x, p_roi_in_unit.y];
        point2 = [p_roi_in_unit.x + p_roi_in_unit.wx, p_roi_in_unit.y + p_roi_in_unit.wy];
        nmssDrawRectBetween2Points(point1, point2, 1, 'y', '-', 'bright_spots');
        
        % draw background
        % horizontal line to show the background
%         bg1_roi_in_unit = ConvertROIPixel2Unit(graph{k}.roi.bg1, unit);
%         point1 = [bg1_roi_in_unit.x, bg1_roi_in_unit.y];
%         point2 = [bg1_roi_in_unit.x + bg1_roi_in_unit.wx, bg1_roi_in_unit.y + bg1_roi_in_unit.wy];
%         nmssDrawRectBetween2Points(point1, point2, 1, 'y');
%         
%         bg2_roi_in_unit = ConvertROIPixel2Unit(graph{k}.roi.bg2, unit);
%         point1 = [bg2_roi_in_unit.x, bg2_roi_in_unit.y];
%         point2 = [bg2_roi_in_unit.x + bg2_roi_in_unit.wx, bg2_roi_in_unit.y + bg2_roi_in_unit.wy];
%         nmssDrawRectBetween2Points(point1, point2, 1, 'y');
        
        
    end
    

% --- Executes on button press in btnFullXSpan.
function btnFullXSpan_Callback(hObject, eventdata, handles)
% hObject    handle to btnFullXSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    
    roi_in_pixel.x = 1;
    roi_in_pixel.wx = size(doc.img, 2);
    roi_in_pixel.y = 1;
    roi_in_pixel.wy = size(doc.img, 1);
    
    
    roi_in_unit = ConvertROIPixel2Unit(roi_in_pixel, doc.figure_axis.unit);
        
    set(handles.editRectStartX, 'String', num2str(roi_in_unit.x, '%4.3f') );
    set(handles.editRectEndX, 'String', num2str(roi_in_unit.wx, '%4.3f'));
    
    % the width can only be set for particle ROI, background ROIs have the
    % same width as the particle ROI
    if(get(handles.rbParticle, 'Value'))
        doc.roi.particle.exists = 1;
        doc.roi.particle.x = roi_in_pixel.x;
        doc.roi.particle.wx = roi_in_pixel.wx;
    elseif(get(handles.rbBackground1, 'Value'))
        doc.roi.bg1.exists = 1;
        doc.roi.bg1.x = roi_in_pixel.x;
        doc.roi.bg1.wx = roi_in_pixel.wx;
    elseif(get(handles.rbBackground2, 'Value'))
        doc.roi.bg2.exists = 1;
        doc.roi.bg2.x = roi_in_pixel.x;
        doc.roi.bg2.wx = roi_in_pixel.wx;
    end
    
    UpdateROIs(handles);
    


% --- Executes on button press in btnFullYSpan.
function btnFullYSpan_Callback(hObject, eventdata, handles)
% hObject    handle to btnFullYSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;

    roi_in_pixel.x = 1;
    roi_in_pixel.wx = size(doc.img, 2);
    roi_in_pixel.y = 1;
    roi_in_pixel.wy = size(doc.img, 1);
    
    roi_in_unit = ConvertROIPixel2Unit(roi_in_pixel, doc.figure_axis.unit);
    
    set(handles.editRectStartY, 'String', num2str(roi_in_unit.y, '%4.3f') );
    set(handles.editRectEndY, 'String', num2str(roi_in_unit.wy , '%4.3f'));
    % the width can only be set for particle ROI, background ROIs have the
    % same width as the particle ROI
    if(get(handles.rbParticle, 'Value'))
        doc.roi.particle.exists = 1;
        doc.roi.particle.y = roi_in_pixel.y;
        doc.roi.particle.wy = roi_in_pixel.wy;
    elseif(get(handles.rbBackground1, 'Value'))
        doc.roi.bg1.exists = 1;
        doc.roi.bg1.y = roi_in_pixel.y;
        doc.roi.bg1.wy = roi_in_pixel.wy;
    elseif(get(handles.rbBackground2, 'Value'))
        doc.roi.bg2.exists = 1;
        doc.roi.bg2.y = roi_in_pixel.y;
        doc.roi.bg2.wy = roi_in_pixel.wy;
    end

    UpdateROIs(handles);



% --- Executes on button press in btnClearROI.
function btnClearROI_Callback(hObject, eventdata, handles)
% hObject    handle to btnClearROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    hFig = ancestor(hObject, 'figure');
    user_data = get(hFig, 'UserData');
    hParentFig = user_data.CallerFigHandle;
    

    txt = {'This will delete all ROIs (particle, backgroound 1)';' ';'Are you sure you wanna delete all ROIs?'};
    button = questdlg(txt,'nmss','Yes','No','No');
    if (strcmp('No',button))  % user changed his mind...
        return;
    end
    
    doc.roi.particle = nmssResetROI();
    doc.roi.bg1 = nmssResetROI();
    doc.roi.bg2 = nmssResetROI();
    
    roi_in_unit.particle = ConvertROIPixel2Unit(doc.roi.particle, doc.figure_axis.unit);
    roi_in_unit.bg1 = ConvertROIPixel2Unit(doc.roi.bg1, doc.figure_axis.unit);
    roi_in_unit.bg2 = ConvertROIPixel2Unit(doc.roi.bg2, doc.figure_axis.unit);

    set(handles.editRectStartX, 'String', num2str(roi_in_unit.particle.x, '%.3f') );
    set(handles.editRectStartY, 'String', num2str(roi_in_unit.particle.y, '%.3f') );
    set(handles.editRectEndX, 'String', num2str(roi_in_unit.particle.wx, '%.3f'));
    set(handles.editRectEndY, 'String', num2str(roi_in_unit.particle.wy, '%.3f'));

    % find all roi related objects and delete them
    % activate or create figure window
    if (ishandle(hParentFig))
        figure(hParentFig);
    else
        nmssFigure();
    end
    % delete rois
    h_nmss_roi_particle = findobj(hParentFig, 'Tag', 'nmss_roi_particle');
    delete(h_nmss_roi_particle);
    h_nmss_roi_bg1 = findobj(hParentFig, 'Tag', 'nmss_roi_bg1');
    delete(h_nmss_roi_bg1);
    h_nmss_roi_bg2 = findobj(hParentFig, 'Tag', 'nmss_roi_bg2');
    delete(h_nmss_roi_bg2);
    
    
    UpdateROIs(handles);
    
    
    



% --- Executes on button press in btnExportTabDelimitedFile.
function btnExportTabDelimitedFile_Callback(hObject, eventdata, handles)
% hObject    handle to btnExportTabDelimitedFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    if (CheckROIs(handles))
        % get image
        global doc;
        img = doc.img;

        % white light - is either flat or if enabled read it from the white
        % light data
        white_light = ones(size(doc.img,2),1);
        if (get(handles.cxEnableWLCorrection, 'Value'))
            white_light = doc.white_light_corr.data(:,2);
        end
        
%         unit = doc.figure_axis.unit;
%         roi.particle = ConvertROIUnit2Pixel(doc.roi.particle);
%         roi.bg1 = ConvertROIUnit2Pixel(doc.roi.bg1);
%         roi.bg2 = ConvertROIUnit2Pixel(doc.roi.bg2);
        
        
        % create graph structure containing graphs for signal, background
        % and axis in nm if activated
        graph = nmssCreateGraph(img, doc.roi, white_light, 0);

        [filename, dirname, filterIndex] = uiputfile({'*.mat', 'Save Graph as Mat-File...'; ...
                                         '*.txt', 'Save Graph as ASCII...'});
        
        % user hit cancel button
        if (filename == 0)
            return;
        end
        

        filepath = fullfile(dirname, filename);
        
        %if (strcmp(extension, '.mat'))
        if (filterIndex == 1)
            SaveGraphData(graph, filepath);
        else
            ExportGraphData_txt(graph, filepath);
        end
    end
        
function ExportGraphData_txt(graph, filepath)
        
    try
        if (size(graph.normalized,2) ~= 1)
            graph.normalized = graph.normalized';
        end

        if (size(graph.axis.x,2) ~= 1)
            graph.axis.x = graph.axis.x';
        end

        % prepare data to export
        normalized_graph = [graph.axis.x, graph.normalized];

        % export data. tab delimited ascii file. 1st column =
        % wavelength, 2nd column = intensity
        dlmwrite(filepath, normalized_graph, 'delimiter', '\t', 'newline', 'pc', 'precision', '%10.2f');
    catch
        msg_txt = lasterr();
        errordlg(msg_txt);
    end

function SaveGraphData(graph, filepath)

    try
        if (size(graph.normalized,2) ~= 1)
            graph.normalized = graph.normalized';
        end

        if (size(graph.axis.x,2) ~= 1)
            graph.axis.x = graph.axis.x';
        end

        % prepare data to export
        normalized_graph = [graph.axis.x, graph.normalized];

        % export data as a mat file:
        % 1st column = wavelength, 
        % 2nd column = intensity
        save(filepath, 'normalized_graph');
    catch
        msg_txt = lasterr();
        errordlg(msg_txt);
    end
    
    

% --- Executes on button press in btnShowWhiteLight.
function btnShowWhiteLight_Callback(hObject, eventdata, handles)
% hObject    handle to btnShowWhiteLight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global doc;
    figure('Name', 'Normalized White Light Spectrum (max = 1)');
    plot(doc.white_light_corr.data(:,1), doc.white_light_corr.data(:,2));
    title(['File:', doc.white_light_corr.filepath], 'Interpreter', 'none');

    
    


% --- Executes on button press in cxEnableBackground.
function cxEnableBackground_Callback(hObject, eventdata, handles)
% hObject    handle to cxEnableBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cxEnableBackground
    global doc;

    if (get(hObject,'Value'))
        set(handles.rbBackground1, 'Enable', 'on');
        set(handles.rbBackground2, 'Enable', 'on');
        doc.roi.bg1.exists = 1;
        doc.roi.bg2.exists = 1;
    else
        set(handles.rbBackground1, 'Value', 0);
        set(handles.rbBackground1, 'Enable', 'off');
        set(handles.rbBackground2, 'Value', 0);
        set(handles.rbBackground2, 'Enable', 'off');
        set(handles.rbParticle, 'Value', 1);
        doc.roi.bg1.exists = 0;
        doc.roi.bg2.exists = 0;
    end

    UpdateROIs(handles);
    
    
% --- Executes on button press in btnShowPeaks.
function btnShowPeaks_Callback(hObject, eventdata, handles)
% hObject    handle to btnShowPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;
    global nmssFigureData;

    hFig = ancestor(hObject, 'figure');
    user_data = get(hFig, 'UserData');
    hParentFig = user_data.CallerFigHandle;
    
    % set mouse cursor to busy (watch)
    set(handles.nmssSpecAnalysisDlg,'Pointer','watch');
    
    if (get(handles.rbPeakIdentifcation_YMax, 'Value'))
        % identify bright spots by using user setting of threshold
        doc.analysis.method = '0th_derivative';
        %graph = PeakIdentification_0th_derivative(handles, white_light, roi_in_pixel);
    elseif (get(handles.rbPeakIdentifcationAutomatic, 'Value'))
        % identify bright spots automatically that is try to find the
        % highest number of spots
        doc.analysis.method = '1st_derivative';
    else
        error('Unknown peak identification method. Contact the developer')
        return;
    end
    
    [doc.analysis.threshold, doc.analysis.std_weighing] = GetCustomizedThreshold(handles);

    % get image and check ROIs
    if (CheckROIs(handles))
        roi_in_pixel = doc.roi.particle;
        
        % depending on the type of the image we need different handling of
        % the features which we find
        if (doc.current_job(1).central_wavelength > 0)
            % we have aspectrum

            % activate image
            UpdateROIs(handles);

            % white light that is used for normalilzation
            white_light = ones(size(doc.img,2),1);
            if (get(handles.cxEnableWLCorrection, 'Value'))
                white_light = doc.white_light_corr.data(:,2);
            end


            graph = nmssSpecAnalysis(doc.img, white_light, roi_in_pixel, doc.analysis);
            
            
            % check if any graph has been returned
            if (isempty(graph))
                errordlg('No peak found!');
                return;
            end

            HighLightPeaks(graph, hParentFig);

            PlotGraph(graph, 'Particle Spectrum');

        else
            % we have an image now
            
            % cut out the part of image that will be used for bright spot
            % searching
            img_work = doc.img(roi_in_pixel.y:roi_in_pixel.y+roi_in_pixel.wy-1, roi_in_pixel.x:roi_in_pixel.x+roi_in_pixel.wx-1);
            
            % send image to the spot finder
            [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, threshold] = ...
                nmssFindBrightSpots( img_work, doc.analysis);
            

            
            % activate or create figure window
            if (ishandle(hParentFig))
                figure(hParentFig);
            else
                nmssFigure();
            end
            
            unit = doc.figure_axis.unit;
            image_limts = nmssGetFullImageLimits(unit);
            
%             nmssDrawRectBetween2Points([top_left_x' + roi_in_pixel.x - 1, top_left_y'+ roi_in_pixel.y - 1 ], ...
%                                        [bottom_right_x'+ roi_in_pixel.x - 1, bottom_right_y' + roi_in_pixel.y - 1 ], ...
%                                         1, 'r', '-', 'nmss_bright_spots');
            lmax_pos = length(max_pos_x);
            for i=1:lmax_pos
                hRectangle = nmssDrawRectAroundCenter(max_pos_x(i) + roi_in_pixel.x - 1, ...
                                                      max_pos_y(i) + roi_in_pixel.y - 1, 6, 6, 'nmss_bright_spot'); % tagged as bright spot
                set(hRectangle, 'Color', nmssFigureData.menuMarkerColor);

                rectangle_context_menu = uicontextmenu('Parent', hParentFig);
                set(hRectangle, 'UIContextMenu', rectangle_context_menu);

                cb = @BrightSpotPopupMenu;
                uimenu(rectangle_context_menu,  'Label', 'Delete', 'Callback', cb);
            end
            
        end
        
    end
    
    % restore arrow mouse cursor
    set(handles.nmssSpecAnalysisDlg,'Pointer','arrow');
    
% procedure performed at right click on a bright spot marker
function BrightSpotPopupMenu(src, evntdata)
    hFig = ancestor(src, 'figure');
    user_data = get(hFig, 'UserData');
    hParentFig = user_data.CallerFigHandle;
    
    % find the object which called this uimenu callback
    hRectangle = findobj(hParentFig, 'UIContextMenu', get(varargin{1}, 'Parent'));
    delete(hRectangle);
    
    


% --- Executes during object creation, after setting all properties.
function editStdDev_Weighting_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStdDev_Weighting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: editParticleBgROIDistance controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in rbPeakIdentifcation_YMax.
function rbPeakIdentifcation_YMax_Callback(hObject, eventdata, handles)
% hObject    handle to rbPeakIdentifcation_YMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbPeakIdentifcation_YMax
    global doc;
    if (get(hObject,'Value'))
        %doc.analysis.method = 'absolute_maximum';
        doc.analysis.method = '0th_derivative';
        [doc.analysis.threshold, doc.analysis.std_weighing] = GetCustomizedThreshold(handles);
    else
        % do not allow unkclicking the radiobutton
        set(hObject,'Value', 1);
    end


function editStdDev_Weighting_Callback(hObject, eventdata, handles)
% hObject    handle to editStdDev_Weighting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStdDev_Weighting as text
%        str2double(get(hObject,'String')) returns contents of editStdDev_Weighting as a double
    global doc;
    
        [doc.analysis.threshold, doc.analysis.std_weighing] = GetCustomizedThreshold(handles);


% --- Executes on button press in rbPeakIdentifcationAutomatic.
function rbPeakIdentifcationAutomatic_Callback(hObject, eventdata, handles)
% hObject    handle to rbPeakIdentifcationAutomatic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbPeakIdentifcationAutomatic
    global doc;
    if (get(hObject,'Value'))
        %doc.analysis.method = 'absolute_maximum';
        doc.analysis.method = '1st_derivative';
        [doc.analysis.threshold, doc.analysis.std_weighing] = GetCustomizedThreshold(handles);
    else
        % do not allow unkclicking the radiobutton
        set(hObject,'Value', 1);
    end



% function editParticleBgROIDistance_Callback(hObject, eventdata, handles)
% % hObject    handle to editParticleBgROIDistance (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of editParticleBgROIDistance as text
% %        str2double(get(hObject,'String')) returns contents of editParticleBgROIDistance as a double
%     global doc;
%     [doc.analysis.threshold, doc.analysis.std_weighing, ...
%         doc.analysis.ROIExtendY, doc.analysis.particleBgROIDistance] = GetCustomizedThreshold(handles);


% % --- Executes during object creation, after setting all properties.
% function editParticleBgROIDistance_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to editParticleBgROIDistance (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: editParticleBgROIDistance controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc
%     set(hObject,'BackgroundColor','white');
% else
%     set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
% end
% 



% --- Executes on button press in btnSaveToWorkDir.
function btnSaveToWorkDir_Callback(hObject, eventdata, handles)
% hObject    handle to btnSaveToWorkDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;

    white_light = doc.white_light_corr.data;
    
    
    old_dir = pwd;
    
    cd(doc.workDir);
    [filename, dirname, filterIndex] = uiputfile({'*.mat', 'Save Graph as Mat-File...'});

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
        
    filepath = fullfile(dirname, filename);
    save(filepath, 'white_light');
    
    








% --- Executes on button press in btnCopy.
function btnCopy_Callback(hObject, eventdata, handles)
% hObject    handle to btnCopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    x = floor(str2num(get(handles.editRectStartX, 'String')));
    y = floor(str2num(get(handles.editRectStartY, 'String')));
    wx = floor(str2num(get(handles.editRectEndX, 'String')));
    wy = floor(str2num(get(handles.editRectEndY, 'String')));
    
    clipboard('copy', [x y wx wy]);


% --- Executes on button press in btnPaste.
function btnPaste_Callback(hObject, eventdata, handles)
% hObject    handle to btnPaste (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    cb_data_str = clipboard('paste');
    
    cb_data = str2num(cb_data_str);
    
    x = cb_data(1);
    y = cb_data(2);
    wx = cb_data(3);
    wy = cb_data(4);
    
    set(handles.editRectStartX, 'String', num2str(x));
    set(handles.editRectStartY, 'String',num2str(y));
    set(handles.editRectEndX, 'String', num2str(wx));
    set(handles.editRectEndY, 'String', num2str(wy));
    
    editRectStartX_Callback(handles.editRectStartX, eventdata, handles);
    editRectStartY_Callback(handles.editRectStartY, eventdata, handles);
    editRectEndX_Callback(handles.editRectEndX, eventdata, handles);
    editRectEndY_Callback(handles.editRectEndY, eventdata, handles);




% --- Executes on button press in btnDeletePeaks.
function btnDeletePeaks_Callback(hObject, eventdata, handles)
% hObject    handle to btnDeletePeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure');
    user_data = get(hFig, 'UserData');
    hParentFig = user_data.CallerFigHandle;

    % activate or create figure window
    if (ishandle(hParentFig))
        figure(hParentFig);
    else
        nmssFigure();
    end
    
    hBrightSpots = findobj(hParentFig, 'Tag', 'bright_spots');
    
    delete(hBrightSpots);
    



function editMinROISizeX_Callback(hObject, eventdata, handles)
% hObject    handle to editMinROISizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMinROISizeX as text
%        str2double(get(hObject,'String')) returns contents of editMinROISizeX as a double

    global doc;
    
    % validate numeric entry in entry field
    if (~nmssValidateNumericEdit(hObject, 'Fixed size X:'))
        return;
    end
    
    [doc.analysis.threshold, doc.analysis.std_weighing] = GetCustomizedThreshold(handles);
    
    % set ROI size constraints
    x = str2num(get(hObject, 'String'));
    if (~ValidateROISize(x))
        set(hObject, 'String', num2str(doc.analysis.minROISizeX));
        return;
    end
    
    doc.analysis.minROISizeX = x;
    

% --- Executes during object creation, after setting all properties.
function editMinROISizeX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMinROISizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editMinROISizeY_Callback(hObject, eventdata, handles)
% hObject    handle to editMinROISizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMinROISizeY as text
%        str2double(get(hObject,'String')) returns contents of editMinROISizeY as a double
    global doc;
    
    % validate numeric entry in entry field
    if (~nmssValidateNumericEdit(hObject, 'Fixed size X:'))
        return;
    end
    
    [doc.analysis.threshold, doc.analysis.std_weighing] = GetCustomizedThreshold(handles);
    
    % set ROI size constraints
    x = str2num(get(hObject, 'String'));
    if (~ValidateROISize(x))
        set(hObject, 'String', num2str(doc.analysis.minROISizeY));
        return;
    end
    
    doc.analysis.minROISizeY = x;


% --- Executes during object creation, after setting all properties.
function editMinROISizeY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMinROISizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on button press in rbAutoSize.
function rbAutoSize_Callback(hObject, eventdata, handles)
% hObject    handle to rbAutoSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbAutoSize
    global doc;
    
    [doc.analysis.threshold, doc.analysis.std_weighing] = GetCustomizedThreshold(handles);
    
    % disable fixed ROI size entry fields
    set(handles.editFixedROISizeX, 'Enable', 'off');
    set(handles.editFixedROISizeY, 'Enable', 'off');
    
    % enable min ROI size entry fields
    set(handles.editMinROISizeX, 'Enable', 'on');
    set(handles.editMinROISizeX, 'Enable', 'on');
    
    % update corresponding variables


% --- Executes on button press in rbFixedSize.
function rbFixedSize_Callback(hObject, eventdata, handles)
% hObject    handle to rbFixedSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbFixedSize
    global doc;
    
    [doc.analysis.threshold, doc.analysis.std_weighing] = GetCustomizedThreshold(handles);
    
    % enable fixed ROI size entry fields
    set(handles.editFixedROISizeX, 'Enable', 'on');
    set(handles.editFixedROISizeY, 'Enable', 'on');
    
    % disable min ROI size entry fields
    set(handles.editMinROISizeX, 'Enable', 'off');
    set(handles.editMinROISizeX, 'Enable', 'off');



function editFixedROISizeY_Callback(hObject, eventdata, handles)
% hObject    handle to editFixedROISizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFixedROISizeY as text
%        str2double(get(hObject,'String')) returns contents of editFixedROISizeY as a double
    global doc;
    
    % validate numeric entry in entry field
    if (~nmssValidateNumericEdit(hObject, 'Fixed size X:'))
        return;
    end
    
    [doc.analysis.threshold, doc.analysis.std_weighing] = GetCustomizedThreshold(handles);
    
    % set ROI size constraints
    x = str2num(get(hObject, 'String'));
    if (~ValidateROISize(x))
        set(hObject, 'String', num2str(doc.analysis.fixROISizeY));
        return;
    end
    
    doc.analysis.fixROISizeY = x;
    


% --- Executes during object creation, after setting all properties.
function editFixedROISizeY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFixedROISizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editFixedROISizeX_Callback(hObject, eventdata, handles)
% hObject    handle to editFixedROISizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFixedROISizeX as text
%        str2double(get(hObject,'String')) returns contents of editFixedROISizeX as a double
    global doc;
    
    % validate numeric entry in entry field
    if (~nmssValidateNumericEdit(hObject, 'Fixed size X:'))
        return;
    end
    
    [doc.analysis.threshold, doc.analysis.std_weighing] = GetCustomizedThreshold(handles);
    
    % set ROI size constraints
    x = str2num(get(hObject, 'String'));
    if (~ValidateROISize(x))
        set(hObject, 'String', num2str(doc.analysis.fixROISizeX));
        return;
    end
    
    doc.analysis.fixROISizeX = x;
    
% Validated the numeric entry for the ROI size
function valid = ValidateROISize(x)
    valid = false;

    if (isempty(x) || x < 1)
        errdlg('Please enter a number greater than 0');
        return;
    end
    
    valid = true;
    



% --- Executes during object creation, after setting all properties.
function editFixedROISizeX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFixedROISizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --------------------------------------------------------------------
function menuLoadAnalysisSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadAnalysisSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global doc;

    current_dir = pwd();
    cd(doc.workDir);
    [filename, dirname] = uigetfile({'*.mat', 'Mat-File (*.mat)'}, 'Load Analysis (from results)  - Select File');
    cd(current_dir);
    
    if (filename == 0) % user pressed cancel
        return;
    end
    
    file_path = fullfile(dirname, filename);
    [pathstr_dummy,name_dummy,extension] = fileparts(file_path);    
    
    load(file_path); % loads analysis, roi and white_light_corr
    
    % extract particle data from regular results file
    if (exist('results'))
        if (isfield(results, 'spec_analysis'))
            doc.roi = results.spec_analysis.roi;
            doc.analysis = results.spec_analysis.analysis;
            doc.white_light_corr = results.spec_analysis.white_light_corr;
        else
            hErrDlg = errordlg('This results file is missing the analysis infos!');
            set(hErrDlg, 'WindowStyle', 'modal');
        end
    else
        if (~exist('analysis'))
            hErrDlg = errordlg('This analysis file is missing the analysis variable!');
            set(hErrDlg, 'WindowStyle', 'modal');
        else
            doc.analysis = analysis;
        end
        if (~exist('roi'))
            hErrDlg = errordlg('This analysis file is missing the roi variable!');
            set(hErrDlg, 'WindowStyle', 'modal');
        else
            doc.roi = roi;
        end

        if (~exist('white_light_corr'))
            hErrDlg = errordlg('This analysis file is missing the white_light_corr variable!');
            set(hErrDlg, 'WindowStyle', 'modal');
        else
            doc.white_light_corr = white_light_corr;
        end

    end
    
    
    % update edit fields
    hFig = ancestor(hObject, 'figure');
    
    InitDlg(hFig);

% --------------------------------------------------------------------
function menuSaveAnalysisSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveAnalysisSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %global nmssDataEvaluationDlg_Data;
    global doc;
    
    % save analysis file
    
    % get old working directory
    old_current_dir = pwd;
    
    save_dir = doc.workDir;

    %change to nmss working directory (which is not the same as the
    %matlab working directory)
    cd(save_dir);

    [filename, dirname] = uiputfile({'*.mat','Matlab data (*.mat)'}, 'Save Analysis Parameters', 'analysis.mat');
    cd(old_current_dir);

    if (filename ~= 0) % user pressed OK in file save dialog
        
        % save berg plot matrix
        filepath = fullfile(dirname, filename)
        try
            roi = doc.roi;
            analysis = doc.analysis;
            white_light_corr = doc.white_light_corr;
            
            save(filepath, 'roi', 'analysis', 'white_light_corr' , '-mat');
        catch
            errordlg(lasterr());
        end
    end
    

