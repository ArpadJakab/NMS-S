function varargout = nmssCurveAnalysisDlg(varargin)
% NMSSCURVEANALYSISDLG M-file for nmssCurveAnalysisDlg.fig
%      NMSSCURVEANALYSISDLG, by itself, creates a new NMSSCURVEANALYSISDLG or raises the existing
%      singleton*.
%
%      H = NMSSCURVEANALYSISDLG returns the handle to a new NMSSCURVEANALYSISDLG or the handle to
%      the existing singleton*.
%
%      NMSSCURVEANALYSISDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMSSCURVEANALYSISDLG.M with the given input arguments.
%
%      NMSSCURVEANALYSISDLG('Property','Value',...) creates a new NMSSCURVEANALYSISDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nmssCurveAnalysisDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nmssCurveAnalysisDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help nmssCurveAnalysisDlg

% Last Modified by GUIDE v2.5 19-May-2010 19:36:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nmssCurveAnalysisDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @nmssCurveAnalysisDlg_OutputFcn, ...
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


% --- Executes just before nmssCurveAnalysisDlg is made visible.
function nmssCurveAnalysisDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nmssCurveAnalysisDlg (see VARARGIN)

% Choose default command line output for nmssCurveAnalysisDlg
handles.output = hObject;

    user_data.hFigInitFcn = @InitDlg;
    set(hObject, 'UserData', user_data);

% Update handles structure
guidata(hObject, handles);

%
function InitDlg(hFig)
    
    user_data = get(hFig, 'UserData');
    handles = guihandles(hFig);

    
    % set gui elements
    
%     % fill peak analysis parameters
%     SetAnalysisMethods(hFig);
    
    
    % the show curves checkboxes
    if (user_data.Dlg_Data.showCurves.smoothed)
        set(handles.cbShowcurveSmoothed, 'Value', 1);
    end
    if (user_data.Dlg_Data.showCurves.unsmoothed)
        set(handles.cbShowcurveUnsmoothed, 'Value', 1);
    end
    if (user_data.Dlg_Data.showCurves.fittedcurve)
        set(handles.cbShowcurveFit, 'Value', 1);
    end
    if (user_data.Dlg_Data.showCurves.max)
        set(handles.cbShowcurveMaxPos, 'Value', 1);
    end
    if (user_data.Dlg_Data.showCurves.peak_finding_range)
        set(handles.cbShowCurvesPeakRange, 'Value', 1);
    end
    if (user_data.Dlg_Data.showCurves.noise_filtered)
        set(handles.cbDenoised, 'Value', 1);
    end
    
    
    % use denoised data to fit?
    set(handles.cbUseDenoised, 'Value', 0);
    if (user_data.Dlg_Data.use_denoised_data_to_fit)
        set(handles.cbUseDenoised, 'Value', 1);
    end
         
    
    % the unit of the x-axis of the displayed curves
    if (strcmp(user_data.Dlg_Data.graphXAxisUnit, 'eV'))
        set(handles.rbEV, 'Value', 1);
        set(handles.rbNm, 'Value', 0);
    else
        set(handles.rbEV, 'Value', 0);
        set(handles.rbNm, 'Value', 1);
    end

    % the index of the currently active particle (and graph)
    %user_data.Dlg_Data.current_graph_index = 1;
    part_index = user_data.Dlg_Data.current_graph_index;
    
%     % a vector of flags that indicate if the user selected the graph or not
%     user_data.Dlg_Data.selected_particle_index_flag = ...
%         ones(1,length(user_data.Dlg_Data.selected_particle_index));
    
    % set selection state indicator check box
    set(handles.cbSelect, 'Value', 1);
    
    if (~isfield(user_data.Dlg_Data, 'nmssPeakFindingRangeDlgData'))
        user_data.Dlg_Data.nmssPeakFindingRangeDlgData = InitXAxisLimits(hFig, 0.05);
    end
    if (~isfield(user_data.Dlg_Data ,'nmssPeakFittingRangeDlgData'))
        user_data.Dlg_Data.nmssPeakFittingRangeDlgData = InitXAxisLimits(hFig, 0.1);
    end
    set(hFig, 'UserData', user_data);
    
    % display the first graph in the graph structure array
    DisplayGraph(handles, user_data.Dlg_Data.current_graph_index);
    
    % update navigation buttons
    UpdateGraphNaviButtons(hFig);
    


% UIWAIT makes nmssCurveAnalysisDlg wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% -------------------------------------------------------------------------
function SetAnalysisMethods(hFig, particle)
    handles = guihandles(hFig);

    set(handles.rbFitParabola,'Value', 0);
    set(handles.rbLorentzFit,'Value', 0);
    
    if (isfield(particle, 'fit'))
        peakFindingParams = particle.fit.params;
    else
        peakFindingParams = nmssResetPeakFindingParam(1240 ./ particle.graph.axis.x);
    end
    
    if (strcmp(peakFindingParams.method, 'fit_parabola_on_top_part_of_peak'))
        % use a parabola fitted to the top part of the peak to determine
        % the max position
        set(handles.rbFitParabola,'Value', 1);
    else (strcmp(peakFindingParams.method, 'fit_with_1_lorentz'))
        % let the user enter the peak paramters
        set(handles.rbLorentzFit,'Value', 1);
    end
    
    set(handles.editFitROI, 'String', ...
        num2str(peakFindingParams.fitFraction));
    

% -------------------------------------------------------------------------
function  GetPeakFindingMethods(handles)

    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');
    

    if (get(handles.rbFitParabola,'Value') == 1)
        user_data.Dlg_Data.peakFindingParams.method = 'fit_parabola_on_top_part_of_peak';
    elseif (get(handles.rbFitManualPeakAnalysis,'Value') == 1)
        user_data.Dlg_Data.peakFindingParams.method = 'fit_no_fit_use_manual_settings';
    elseif (get(handles.rbLorentzFit,'Value') == 1)
        user_data.Dlg_Data.peakFindingParams.method = 'fit_with_1_lorentz';
    elseif (get(handles.rbLorentzFitDenoised,'Value') == 1)
        user_data.Dlg_Data.peakFindingParams.method = 'fit_with_1_lorentz_on_denoised';
    else
        user_data.Dlg_Data.peakFindingParams.method = 'fit_no_fit_just_smooth';
    end

    set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);





% -------------------------------------------------------------------------
function DisplayGraph(handles, selected_index)

    hFig = handles.nmssCurveAnalysisDlg;
    user_data = get(hFig, 'UserData');
    
    
    part_index = selected_index;
    particle = user_data.particle(part_index);
    showCurves = user_data.Dlg_Data.showCurves;
    eV_or_nm = user_data.Dlg_Data.graphXAxisUnit;
    %sel_flag = (user_data.Dlg_Data.selected_particle_index_flag(selected_index) == 1);    
    
    
    % if the figure with zoom graph exists display the same graph there too
    if (isfield(user_data, 'hZoomFigure'))
        if (ishandle(user_data.hZoomFigure))
            hZoomAxes = findobj(user_data.hZoomFigure, 'Type', 'axes');
            DisplayGraphInAxes(hZoomAxes, ...
                               particle, showCurves, eV_or_nm);
        end
    end
    
    % display stuff in the build-in axes
    DisplayGraphInAxes(handles.axesGraph, particle, showCurves, eV_or_nm);
    
    if (particle.valid)
        set(handles.axesGraph, 'Color', [248 230 126] / 255); % beige
        set(handles.cbSelect, 'Value', 1);
    else
        set(handles.axesGraph, 'Color', [255 255 255] / 255); % white
        set(handles.cbSelect, 'Value', 0);
    end
                    
    DisplayCurveParameters(handles, particle);
    

% -------------------------------------------------------------------------
% function DisplayGraphInAxes(hAxes, particle, showCurves, eV_or_nm, ...
%                             peakFindingRange, peakFittingRange)
function DisplayGraphInAxes(hAxes, particle, showCurves, eV_or_nm)
                            
    axes(hAxes);
    cla; % clear axes
    hold on;
    
    graph = particle.graph;
    
    spec_nm = graph.normalized; % initialization
    x_nm = graph.axis.x;
    
    % indicate the zero intensity
    if (strcmp(eV_or_nm,'eV'))
        [x, spec] = nmssConvertGraph_nm_2_eV(x_nm, spec_nm);
    else
        x = x_nm;
        spec = spec_nm;
    end
    line([x(1), x(end)], [0,0], 'LineWidth', 1, 'Color', 'k', 'LineStyle', '-');
    
    if (showCurves.unsmoothed)
        spec_nm = graph.normalized;
        if (strcmp(eV_or_nm,'eV'))
            [x, spec] = nmssConvertGraph_nm_2_eV(x_nm, spec_nm);
        else
            x = x_nm;
            spec = spec_nm;
        end
        plot(x, spec, 'LineWidth', 2, 'Color', 'r');
    end
    
    if (showCurves.smoothed)
        if (isfield(graph, 'smoothed'))
            spec_nm = graph.smoothed;
        else
            spec_nm = nmssSmoothGraph( spec_nm );
        end
        if (strcmp(eV_or_nm,'eV'))
            [x, spec] = nmssConvertGraph_nm_2_eV(x_nm, spec_nm);
        else
            x = x_nm;
            spec = spec_nm;
        end
        plot(x, spec, 'LineWidth', 1, 'Color', 'b');
    end
    
    if (showCurves.fittedcurve)
        p = particle;

        if (isfield(p, 'fit'))
            if (strcmp(eV_or_nm,'eV'))
                fit_x = p.fit.fit_x;
                fit_y = p.fit.fit_y;
            else
                [fit_x, fit_y] = nmssConvertGraph_eV_2_nm(p.fit.fit_x, p.fit.fit_y);
            end
        elseif (isfield(p, 'fit_x') && isfield(p, 'fit_y'))
            if (strcmp(eV_or_nm,'eV'))
                fit_x = p.fit_x;
                fit_y = p.fit_y;
            else
                [fit_x, fit_y] = nmssConvertGraph_eV_2_nm(p.fit_x, p.fit_y);
            end
        end
        
        plot(fit_x, fit_y,  'g', 'LineWidth', 2 );

        [max_val, max_pos] = max(fit_y);
            %title(['Max pos: ', num2str(fit_x(max_pos)), ' nm (', num2str(1240 / fit_x(max_pos)),' eV)', ' Max val:' , num2str(max_val)])

    end
    
    if (showCurves.max && isfield(particle, 'res_energy'))
            axis_y_limits = ylim;
            if (strcmp(eV_or_nm,'eV'))
                line([particle.res_energy, particle.res_energy], ...
                     [axis_y_limits(1), axis_y_limits(2)], ...
                     'LineWidth', 1, 'Color', 'k', 'LineStyle', '--');
            else
                line([1240/particle.res_energy, 1240/particle.res_energy], ...
                     [axis_y_limits(1), axis_y_limits(2)], ...
                     'LineWidth', 1, 'Color', 'k', 'LineStyle', '--');
            end
    end
    
    
    % indicate the area where there will be no peak finding applied. Two
    % dotted line will show the range boundaries
    if (showCurves.peak_finding_range)
        ylimits = ylim();
        
        if (isfield(particle, 'fit'))
            fit_params = particle.fit.params;
        else
            fit_params = nmssResetPeakFindingParam(1240 ./ particle.graph.axis.x);
        end
        
        if (strcmp(eV_or_nm,'eV'))
            rPos_x_start = fit_params.finding_range.min;
            rPos_x_end = fit_params.finding_range.max;
        else
            rPos_x_start = 1240 / fit_params.finding_range.max;
            rPos_x_end = 1240 / fit_params.params.finding_range.min;
        end
            
        
        hs = line([rPos_x_start, rPos_x_start], [ylimits(1), ylimits(2)], ...
             'LineWidth', 2, 'Color', 'k', 'LineStyle', ':');
        he = line([rPos_x_end, rPos_x_end], [ylimits(1), ylimits(2)], ...
             'LineWidth', 2, 'Color', 'k', 'LineStyle', ':');
        
        set(hs, 'Tag', 'PeakFindingRange_Start_line');
        set(he, 'Tag', 'PeakFindingRange_End_line');
            
        if (strcmp(eV_or_nm,'eV'))
            rPos_x_start = fit_params.fit_range.max;
            rPos_x_end = fit_params.fit_range.min;
        else
            rPos_x_start = 1240 / fit_params.fit_range.min;
            rPos_x_end = 1240 / fit_params.fit_range.max;
        end
        
        hs = line([rPos_x_start, rPos_x_start], [ylimits(1), ylimits(2)], ...
             'LineWidth', 2, 'Color', 'k', 'LineStyle', '-.');
        he = line([rPos_x_end, rPos_x_end], [ylimits(1), ylimits(2)], ...
             'LineWidth', 2, 'Color', 'k', 'LineStyle', '-.');
        
        set(hs, 'Tag', 'PeakFittingRange_Start_line');
        set(he, 'Tag', 'PeakFittingRange_End_line');
    end
    
    if (showCurves.noise_filtered)
        if (isfield(graph, 'noise_filtered'))
            spec_nm = graph.noise_filtered;
        else
            [spec_nm, filter_th] = noisefilter(x_nm, graph.normalized, 50);            
        end
        if (strcmp(eV_or_nm,'eV'))
            [x, spec] = nmssConvertGraph_nm_2_eV(x_nm, spec_nm);
        else
            x = x_nm;
            spec = spec_nm;
        end
        plot(x, spec, 'LineWidth', 1, 'Color', 'k');
    end
    
    
    
    if (strcmp(eV_or_nm,'eV'))
        xlabel('E (eV)');
    else
        xlabel('\lambda (nm)');
    end

    if (isfield(p, 'num'))
        posAxes = get(hAxes, 'Position');
        xlims = xlim();
        dx = xlims(2) - xlims(1);
        x = xlims(2) - dx * 0.15;
        ylims = ylim();
        dy = ylims(2) - ylims(1);
        y = ylims(2) - dy * 0.1;
        
        text(x,y, num2str(particle.num));
    end
    
    
    hold off;
    

% ------------------------------------------------------------------------
% 
function DisplayCurveParameters(handles, particle)

    if (isfield(particle, 'res_energy'))
        max_pos = particle.res_energy;
    else
        max_pos = NaN;
    end
    if (isfield(particle, 'max_intensity'))
        max_int = particle.max_intensity;
    else
        max_int = NaN;
    end
    
    if (isfield(particle, 'FWHM'))
        FWHM = particle.FWHM;
    else
        FWHM = NaN;
    end
    

    set(handles.editPeakMaxPos,'String', num2str(max_pos));
    set(handles.editPeakMaxPos_nm,'String', num2str(1240/max_pos));
    if (isstruct(FWHM))
        set(handles.editPeakFWHM,'String', num2str(FWHM.full));
    else
        set(handles.editPeakFWHM,'String', num2str(FWHM));
    end
    set(handles.editPeakMaxInt,'String', num2str(max_int, '%8.2e'));
    
    SetAnalysisMethods(handles.nmssCurveAnalysisDlg, particle);
    
    
    
    
% --- Outputs from this function are returned to the command line.
function varargout = nmssCurveAnalysisDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editPeakMaxPos_Callback(hObject, eventdata, handles)
% hObject    handle to editPeakMaxPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPeakMaxPos as text
%        str2double(get(hObject,'String')) returns contents of editPeakMaxPos as a double


% --- Executes during object creation, after setting all properties.
function editPeakMaxPos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPeakMaxPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editPeakFWHM_Callback(hObject, eventdata, handles)
% hObject    handle to editPeakFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPeakFWHM as text
%        str2double(get(hObject,'String')) returns contents of editPeakFWHM as a double


% --- Executes during object creation, after setting all properties.
function editPeakFWHM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPeakFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editPeakMaxInt_Callback(hObject, eventdata, handles)
% hObject    handle to editPeakMaxInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPeakMaxInt as text
%        str2double(get(hObject,'String')) returns contents of editPeakMaxInt as a double


% --- Executes during object creation, after setting all properties.
function editPeakMaxInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPeakMaxInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% -------------------------------------------------------------------------
% --- Executes on button press in btnSetXAxisLimits.
function btnSetXAxisLimits_Callback(hObject, eventdata, handles)
% hObject    handle to btnSetXAxisLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in pbSetFitXLimits.
        
    hFig = ancestor(hObject,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    selected_index = user_data.Dlg_Data.current_graph_index;
    
    hDlg = nmssPeakFindingRangeDlg();
    dlgUserData = get(hDlg, 'UserData');
    
    

    if (isfield(user_data.Dlg_Data, 'nmssPeakFindingRangeDlgData'))
        dlgUserData.Dlg_Data = user_data.Dlg_Data.nmssPeakFindingRangeDlgData;
    else
        peakFindingRange = InitXAxisLimits(hFig, 0.05);
        
        dlgUserData.Dlg_Data = peakFindingRange;
    end
    
    dlgUserData.particle = user_data.particle(selected_index);

    if (~strcmp(dlgUserData.Dlg_Data.eV_or_nm, user_data.Dlg_Data.graphXAxisUnit))
        
        dlgUserData.Dlg_Data.rangeStart = ...
            1240/user_data.Dlg_Data.nmssPeakFindingRangeDlgData.rangeEnd;
        
        dlgUserData.Dlg_Data.rangeEnd = ...
            1240/user_data.Dlg_Data.nmssPeakFindingRangeDlgData.rangeStart;
        
        dlgUserData.Dlg_Data.eV_or_nm = user_data.Dlg_Data.graphXAxisUnit;
    end
    
    ZoomAxes(hFig);
        
    
    %set(hDlg, 'WindowStyle', 'modal');

    dlgUserData.OKFunction = @PeakFindingRangeDlg_OKFunction;
    dlgUserData.CallerFigHandle = hFig;
    
    % set dialog data
    set(hDlg, 'UserData', dlgUserData);
    
    % init dialog
    dlgUserData.hFigInitFcn(hDlg);
    
    
% called if the peak finding dialog is closed by klicking OK
function PeakFindingRangeDlg_OKFunction(hDlg)

    dlgUserData = get(hDlg, 'UserData');
    
    hFig = dlgUserData.CallerFigHandle;
    user_data = get(hFig, 'UserData');
    user_data.Dlg_Data.nmssPeakFindingRangeDlgData = dlgUserData.Dlg_Data;
    set(hFig, 'UserData', user_data);
    
    % display the first graph in the graph structure array
    handles = guihandles(hFig);
    DisplayGraph(handles, user_data.Dlg_Data.current_graph_index);
    
    

    
% -------------------------------------------------------------------------
% initializes the Peak finding range to a reduced x-range of the graph which
% is the full range minus 10% at both ends
% IN:
%  rel_distance_from_boundary - a number between 1 and 0 to specify the
%  realtive distance of the range position from the upper and lower boundaries
%  if 0 then the returned range is equal with the full axis
function range = InitXAxisLimits(hFig, rel_distance_from_boundary)
    user_data = get(hFig, 'UserData');

    i = user_data.Dlg_Data.current_graph_index;
    part_index = i;
    particle = user_data.particle(part_index);

    rangeStart_nm = particle.graph.axis.x(1);
    rangeEnd_nm = particle.graph.axis.x(end);
    if (strcmp(user_data.Dlg_Data.graphXAxisUnit, 'eV'))
        rangeStart = 1240 / rangeEnd_nm;
        rangeEnd = 1240 / rangeStart_nm;
    else
        rangeStart = rangeStart_nm;
        rangeEnd = rangeEnd_nm;
    end


    range.rangeStart = rangeStart + (rangeEnd - rangeStart) * rel_distance_from_boundary;
    range.rangeEnd = rangeEnd - (rangeEnd - rangeStart) * rel_distance_from_boundary;
    range.eV_or_nm = user_data.Dlg_Data.graphXAxisUnit;



function editFitROI_Callback(hObject, eventdata, handles)
% hObject    handle to editFitROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFitROI as text
%        str2double(get(hObject,'String')) returns contents of editFitROI as a double
    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');
    if (nmssValidateNumericEdit(hObject, 'Fit with parabola'))
        fF = str2num(get(hObject, 'String'));
        if (fF >= 100)
            errordlg('Please enter a number smaller than 100!');
            return;
        elseif (fF <= 0)
            errordlg('Please enter a number greater than 0!');
            return;
        end
        user_data.Dlg_Data.peakFindingParams.fitFraction = fF;
        set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);
        
    end
        



% --- Executes during object creation, after setting all properties.
function editFitROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFitROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editSmoothingParam_Callback(hObject, eventdata, handles)
% hObject    handle to editSmoothingParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSmoothingParam as text
%        str2double(get(hObject,'String')) returns contents of editSmoothingParam as a double
    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');

    if (nmssValidateNumericEdit(hObject, 'Smoothing parameter'))
        smoothParam = str2num(get(hObject, 'String'));

        if (smoothParam < 2)
            errordlg('Please enter a number greater than 2!');
            return;
        end
        user_data.Dlg_Data.peakFindingParams.smoothParam = smoothParam;
        set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);
    end
    


% --- Executes during object creation, after setting all properties.
function editSmoothingParam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSmoothingParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in pbClose.
function pbClose_Callback(hObject, eventdata, handles)
% hObject    handle to pbClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    nmssCurveAnalysisDlg_CloseRequestFcn(handles.nmssCurveAnalysisDlg, eventdata, handles)


function pbFitCurves(hObject, eventdata, handles)
    pbApply_Callback(hObject, eventdata, handles);
    

% --- Executes on button press in pbApply.
function pbApply_Callback(hObject, eventdata, handles)
% hObject    handle to pbApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');
    
    current_particle = user_data.particle(user_data.Dlg_Data.current_graph_index,1);
    if (~isfield(current_particle, 'fit'))
        % old results file
        current_particle.fit.params = nmssResetPeakFindingParam(current_particle.graph.axis.x);
    end
        
    [user_action, fit_params_eV_out, apply_to_all] = nmssPeakFindingParamSettingDlg( current_particle.fit.params,  user_data.Dlg_Data.graphXAxisUnit, ...
                                    false, current_particle.graph.axis.x);
    if (strcmp(user_action, 'Cancel')) return; end;
    
    % loop over all graphs that will be processed
    start_index = 1;
    end_index = length(user_data.particle);
    if (~apply_to_all)
        start_index = user_data.Dlg_Data.current_graph_index;
        end_index = user_data.Dlg_Data.current_graph_index;
    end
    
    hWaitbar = waitbar(0,'Processing Curves (find peak maximum and FWHM)','CreateCancelBtn','delete(gcf);');

    for i=start_index:end_index
        
        p = user_data.particle(i);
        
        % refresh waitbar
        if (ishandle(hWaitbar))
            waitbar(i/(end_index-start_index + 1));
        else
            % user canceled
            break;
        end
        
        
        
        % get graphs that we need for finding the peak
        x_nm = p.graph.axis.x;
        if (user_data.Dlg_Data.use_denoised_data_to_fit)
            if (isfield(p.graph, 'noise_filtered'))
                spec_nm = p.graph.noise_filtered;
            else
                spec_nm = p.graph.smoothed;
            end
        else
            spec_nm = p.graph.normalized;
        end
        spec_smooth_nm = p.graph.smoothed;
        
        % convert them into the eV picture
        [x_eV, spec_eV] = nmssConvertGraph_nm_2_eV(x_nm, spec_nm);
        [x_eV, spec_smooth_eV] = nmssConvertGraph_nm_2_eV(x_nm, spec_smooth_nm);
        
        % the region where the search for the peak will take place
        p.fit.params = fit_params_eV_out;
        
        peak_index_range = intersect([find(x_eV >= p.fit.params.finding_range.min)], ...
                                     [find(x_eV <= p.fit.params.finding_range.max)]);
        
        
        % lorentz fit method can find more than one peak
        if (strcmp(p.fit.params.method, 'fit_with_1_lorentz'))
            
            % find max and FWHM, etc.
            [peak_max_v, peak_FWHM_v, peak_max_int_v, fit_x, fit_y, str_errmsg] = ...
                    nmssGetMaxAndFWHM(spec_eV(peak_index_range), spec_smooth_eV(peak_index_range), ...
                                      x_eV(peak_index_range), p.fit.params);
                
            peak_max = peak_max_v;
            peak_FWHM = peak_FWHM_v;
            peak_max_int = peak_max_int_v;
%             % get the peak with the highest intensity in the provided range
%             num_of_peaks = length(peak_max_v);
%             if (num_of_peaks > 1)
%                 peak_in_range_index = intersect([find(peak_max_v >= p.fit.params.finding_range.min)], ...
%                                                 [find(peak_max_v <= p.fit.params.finding_range.max)]);
%             else
%                 peak_in_range_index = 1;
%             end
%             
%             [dummy, pindex] = max(peak_max_int_v(peak_in_range_index)); % get the largest peak in range
%             % if the maximas are not in the specified range
%             if (isempty(pindex))
%                 [peak_max, pindex] = max(peak_max_v);
%                 peak_max = peak_max_v(pindex)
%                 peak_FWHM = peak_FWHM_v(pindex);
%                 peak_max_int = peak_max_int_v(pindex);
%             else
%                 peak_max = peak_max_v(peak_in_range_index(pindex))
%                 peak_FWHM = peak_FWHM_v(peak_in_range_index(pindex));
%                 peak_max_int = peak_max_int_v(peak_in_range_index(pindex));
%             end
        else
            % find max and FWHM, etc.
            [peak_max, peak_FWHM, peak_max_int, fit_x, fit_y, str_errmsg] = ...
                    nmssGetMaxAndFWHM(spec_eV(peak_index_range), ...
                                      spec_smooth_eV(peak_index_range), ...
                                      x_eV(peak_index_range), p.fit.params);
        end
        %p = rmfield(p,'FWHM');
        
        
        p.res_energy = peak_max;
        p.FWHM = peak_FWHM.full;
        p.max_intensity = peak_max_int;
        p.fit.fit_x = fit_x;
        p.fit.fit_y = fit_y;
        
        user_data.particle(i) = p;
    end

    set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);
    
    % clear waitbar
    if (ishandle(hWaitbar))
        delete(hWaitbar);
    end
    
    % refresh the currently displayed graph
    DisplayGraph(handles, user_data.Dlg_Data.current_graph_index);
    
    % finished?
    


% --- Executes on button press in pbGetPrevGraph.
function pbGetPrevGraph_Callback(hObject, eventdata, handles)
% hObject    handle to pbGetPrevGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
    % copy used global variables into local one so that it is easier to
    % overllok what we have here
    i = user_data.Dlg_Data.current_graph_index;
    istart = 1;
    iend = length(user_data.particle);
    
    
    if (i > istart)
        i = i-1;

        % display the first graph in the graph structure array
        DisplayGraph(handles, i);
        
        user_data.Dlg_Data.current_graph_index = i;
    end
    
    set(hFig, 'UserData', user_data);


    UpdateGraphNaviButtons(hFig);

% --- Executes on button press in pbGetNextGraph.
function pbGetNextGraph_Callback(hObject, eventdata, handles)
% hObject    handle to pbGetNextGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject,'figure','toplevel');
    user_data = get(hFig, 'UserData');

    % copy used global variables into local one so that it is easier to
    % overllok what we have here
    i = user_data.Dlg_Data.current_graph_index;
    istart = 1;
    iend = length(user_data.particle);
    
    if (i < iend)
        i = i+1;
    
        % display the first graph in the graph structure array
        DisplayGraph(handles, i);
        
        user_data.Dlg_Data.current_graph_index = i;
    end
    
    set(hFig, 'UserData', user_data);
    
    UpdateGraphNaviButtons(hFig);
    
% -------------------------------------------------------------------------
% updates the navigations buttons that are intended to navigate between the
% selected graphs
function UpdateGraphNaviButtons(hFig)
    
    user_data = get(hFig, 'UserData');
    handles = guihandles(hFig);
    
    % copy used global variables into local one so that it is easier to
    % overllok what we have here
    i = user_data.Dlg_Data.current_graph_index;
    istart = 1;
    iend = length(user_data.particle);
    
    if (i == iend)
        set(handles.pbGetNextGraph, 'Enable', 'off');
    else
        set(handles.pbGetNextGraph, 'Enable', 'on');
    end
    if (i == istart)
        set(handles.pbGetPrevGraph, 'Enable', 'off');
    else
        set(handles.pbGetPrevGraph, 'Enable', 'on');
    end
        
    
    
    

% --- Executes on button press in btnZoom.
function btnZoom_Callback(hObject, eventdata, handles)
% hObject    handle to btnZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject,'figure','toplevel');
    
    ZoomAxes(hFig);
    
function ZoomAxes(hFig)

    user_data = get(hFig, 'UserData');
    handles = guihandles(hFig);
    
    if (~isfield(user_data, 'hZoomFigure') || ...
        ~ishandle(user_data.hZoomFigure))
        user_data.hZoomFigure = figure;
        hZoomAxes = axes('Parent', user_data.hZoomFigure);
        set(user_data.hZoomFigure, 'Units', 'normalized');
        
        %hZoomAxes = copyobj(handles.axesGraph, user_data.hZoomFigure);
        set(hFig, 'UserData', user_data);
    else
        hZoomAxes = findobj(user_data.hZoomFigure, 'Type', 'axes');
        axes(hZoomAxes);
    end
    
    
    
    i = user_data.Dlg_Data.current_graph_index;
    
    % refresh the currently displayed graph
    DisplayGraph(handles, i);
    
    % position this figure right below the parent dialog
    set(handles.nmssCurveAnalysisDlg, 'Unit', 'pixels');
    parent_pos = get(handles.nmssCurveAnalysisDlg, 'Position');
    set(user_data.hZoomFigure, 'Unit', 'pixels');
    child_pos = get(user_data.hZoomFigure, 'Position');
    child_pos(2) = parent_pos(2) - child_pos(4);
    child_pos(1) = parent_pos(1);
    child_pos(3) = parent_pos(3);
    set(user_data.hZoomFigure, 'Position', child_pos);



% --- Executes on button press in cbShowcurveFit.
function cbShowcurveFit_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowcurveFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowcurveFit
    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');
    if (get(hObject,'Value') == 1)
        user_data.Dlg_Data.showCurves.fittedcurve = true;
    else
        user_data.Dlg_Data.showCurves.fittedcurve = false;
    end
    
    set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);
    
    i = user_data.Dlg_Data.current_graph_index;

    DisplayGraph(handles,i);


% --- Executes on button press in cbShowcurveMaxPos.
function cbShowcurveMaxPos_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowcurveMaxPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowcurveMaxPos
    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');
    if (get(hObject,'Value') == 1)
        user_data.Dlg_Data.showCurves.max = true;
    else
        user_data.Dlg_Data.showCurves.max = false;
    end
    
    set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);
    
    i = user_data.Dlg_Data.current_graph_index;
    %part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    DisplayGraph(handles,i);
    


% --- Executes on button press in cbShowcurveFWHM.
function cbShowcurveFWHM_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowcurveFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowcurveFWHM
    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');
    if (get(hObject,'Value') == 1)
        user_data.Dlg_Data.showCurves.FWHM = true;
    else
        user_data.Dlg_Data.showCurves.FWHM = false;
    end
    set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);

    i = user_data.Dlg_Data.current_graph_index;
    %part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    DisplayGraph(handles, i);
    




% --- Executes on button press in rbFitParabola.
function rbFitParabola_Callback(hObject, eventdata, handles)
% hObject    handle to rbFitParabola (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbFitParabola
    
    % this asserts that the radio button can not be switched off but
    % clicking
    if (get(hObject,'Value') == 0)
        set(hObject,'Value', 1)
    end

    GetPeakFindingMethods(handles);



% --- Executes on button press in rbFitManualPeakAnalysis.
function rbFitManualPeakAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to rbFitManualPeakAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbFitManualPeakAnalysis
    % this asserts that the radio button can not be switched off but
    % clicking
    if (get(hObject,'Value') == 0)
        set(hObject,'Value', 1)
    end

    GetPeakFindingMethods(handles);



% --- Executes on button press in rbLorentzFitDenoised.
function rbLorentzFitDenoised_Callback(hObject, eventdata, handles)
% hObject    handle to rbLorentzFitDenoised (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbLorentzFitDenoised
    % this asserts that the radio button can not be switched off but
    % clicking
    if (get(hObject,'Value') == 0)
        set(hObject,'Value', 1)
    end

    GetPeakFindingMethods(handles);



% --- Executes when user attempts to close nmssCurveAnalysisDlg.
function nmssCurveAnalysisDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to nmssCurveAnalysisDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    user_data = get(hObject, 'UserData');
    if (isfield(user_data, 'hZoomFigure') && ...
        ishandle(user_data.hZoomFigure))
            delete(user_data.hZoomFigure);
    end
    
%     % find parent dialog
%     hParent = findobj('Tag', 'nmssResultsViewerDlg');
%     if (ishandle(hParent))
%         % switch off controls (user should not mess around with the dialog box)
%         hControls = findobj(hParent, 'Style', 'pushbutton', '-or', 'Style', 'popupmenu');
%         set(hControls, 'Enable', 'on');
%     end
    



% Hint: delete(hObject) closes the figure
delete(hObject);




% --- Executes on button press in rbEV.
function rbEV_Callback(hObject, eventdata, handles)
% hObject    handle to rbEV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject,'figure','toplevel');
    user_data = get(hFig, 'UserData');

% Hint: get(hObject,'Value') returns toggle state of rbEV
    if (get(hObject,'Value') == 1)
        set(handles.rbNm, 'Value', 0);
        user_data.Dlg_Data.graphXAxisUnit = 'eV';
        
        set(hFig, 'UserData', user_data);
        % display the first graph in the graph structure array
        DisplayGraph(handles, user_data.Dlg_Data.current_graph_index);
    end
        
        
        


% --- Executes on button press in rbNm.
function rbNm_Callback(hObject, eventdata, handles)
% hObject    handle to rbNm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
% Hint: get(hObject,'Value') returns toggle state of rbEV
    if (get(hObject,'Value') == 1)
        set(handles.rbEV, 'Value', 0);
        user_data.Dlg_Data.graphXAxisUnit = 'nm';
        
        set(hFig, 'UserData', user_data);
    
        % display the first graph in the graph structure array
        DisplayGraph(handles, user_data.Dlg_Data.current_graph_index);
        
    end
        




% --- Executes on button press in cbShowcurveSmoothed.
function cbShowcurveSmoothed_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowcurveSmoothed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowcurveSmoothed

    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');

    if (get(hObject,'Value') == 1)
        user_data.Dlg_Data.showCurves.smoothed = true;
    else
        user_data.Dlg_Data.showCurves.smoothed = false;
    end
    set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);

    DisplayGraph(handles, user_data.Dlg_Data.current_graph_index);
    



% --- Executes on button press in cbShowcurveUnsmoothed.
function cbShowcurveUnsmoothed_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowcurveUnsmoothed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowcurveUnsmoothed
    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');
    if (get(hObject,'Value') == 1)
        user_data.Dlg_Data.showCurves.unsmoothed = true;
    else
        user_data.Dlg_Data.showCurves.unsmoothed = false;
    end
    set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);

    DisplayGraph(handles, user_data.Dlg_Data.current_graph_index);
    





function editPeakMaxPos_nm_Callback(hObject, eventdata, handles)
% hObject    handle to editPeakMaxPos_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPeakMaxPos_nm as text
%        str2double(get(hObject,'String')) returns contents of editPeakMaxPos_nm as a double


% --- Executes during object creation, after setting all properties.
function editPeakMaxPos_nm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPeakMaxPos_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in cbShowCurvesPeakRange.
function cbShowCurvesPeakRange_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowCurvesPeakRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowCurvesPeakRange
    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');
    
    if (get(hObject,'Value') == 1)
        user_data.Dlg_Data.showCurves.peak_finding_range = true;
    else
        user_data.Dlg_Data.showCurves.peak_finding_range = false;
    end
    
    set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);

    i = user_data.Dlg_Data.current_graph_index;
    DisplayGraph(handles, i);




% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, eventdata, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
    
    
    %doc.nmssCurveAnalysisDlg_Data = nmssCurveAnalysisDlg_Data;
    user_data.OKFunction(hFig);
    
    nmssCurveAnalysisDlg_CloseRequestFcn(handles.nmssCurveAnalysisDlg, eventdata, handles);



% --- Executes on button press in rbLorentzFit.
function rbLorentzFit_Callback(hObject, eventdata, handles)
% hObject    handle to rbLorentzFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbLorentzFit
    % this asserts that the radio button can not be switched off but
    % clicking
    if (get(hObject,'Value') == 0)
        set(hObject,'Value', 1)
    end

    GetPeakFindingMethods(handles);
    

% --- Executes on button press in cbSelect.
function cbSelect_Callback(hObject, eventdata, handles)
% hObject    handle to cbSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    selected_index = user_data.Dlg_Data.current_graph_index;
    i = selected_index;


% Hint: get(hObject,'Value') returns toggle state of cbSelect
    if (~get(hObject,'Value'))
        user_data.particle(i).valid = 0;
        set(handles.axesGraph, 'Color', [255 255 255] / 255); % white        
    else
        user_data.particle(i).valid = 1;
        set(handles.axesGraph, 'Color', [248 230 126] / 255); % beige
    end
    
    set(hFig, 'UserData', user_data);
    



% --- Executes on selection change in dropdownPeakIndex.
function dropdownPeakIndex_Callback(hObject, eventdata, handles)
% hObject    handle to dropdownPeakIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns dropdownPeakIndex contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdownPeakIndex


% --- Executes during object creation, after setting all properties.
function dropdownPeakIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dropdownPeakIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in pbSetFitXLimits.
function pbSetFitXLimits_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetFitXLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        
    hFig = ancestor(hObject,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    selected_index = user_data.Dlg_Data.current_graph_index;
    
    hDlg = nmssPeakFittingRangeDlg();
    dlgUserData = get(hDlg, 'UserData');
    
    

    if (isfield(user_data.Dlg_Data, 'nmssPeakFittingRangeDlgData'))
        dlgUserData.Dlg_Data = user_data.Dlg_Data.nmssPeakFittingRangeDlgData;
    else
        peakFindingRange = InitXAxisLimits(hFig, 0.08);
        
        dlgUserData.Dlg_Data = peakFindingRange;
    end
    
    dlgUserData.particle = user_data.particle(selected_index);

    if (~strcmp(dlgUserData.Dlg_Data.eV_or_nm, user_data.Dlg_Data.graphXAxisUnit))
        
        dlgUserData.Dlg_Data.rangeStart = ...
            1240/user_data.Dlg_Data.nmssPeakFittingRangeDlgData.rangeEnd;
        
        dlgUserData.Dlg_Data.rangeEnd = ...
            1240/user_data.Dlg_Data.nmssPeakFittingRangeDlgData.rangeStart;
        
        dlgUserData.Dlg_Data.eV_or_nm = user_data.Dlg_Data.graphXAxisUnit;
    end
    
    ZoomAxes(hFig);
        
    
    %set(hDlg, 'WindowStyle', 'modal');

    dlgUserData.OKFunction = @PeakFittingRangeDlg_OKFunction;
    dlgUserData.CallerFigHandle = hFig;
    
    % set dialog data
    set(hDlg, 'UserData', dlgUserData);
    
    % init dialog
    dlgUserData.hFigInitFcn(hDlg);
    
% called if the peak fitting is closed by klicking OK
function PeakFittingRangeDlg_OKFunction(hDlg)

    dlgUserData = get(hDlg, 'UserData');
    
    hFig = dlgUserData.CallerFigHandle;
    user_data = get(hFig, 'UserData');
    
    user_data.Dlg_Data.nmssPeakFittingRangeDlgData = dlgUserData.Dlg_Data;
    set(hFig, 'UserData', user_data);
    
    % display the first graph in the graph structure array
    handles = guihandles(hFig);
    DisplayGraph(handles, user_data.Dlg_Data.current_graph_index);
    
    



% --- Executes on button press in cbDenoised.
function cbDenoised_Callback(hObject, eventdata, handles)
% hObject    handle to cbDenoised (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbDenoised
    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');
    
    if (get(hObject,'Value') == 1)
        user_data.Dlg_Data.showCurves.noise_filtered = true;
    else
        user_data.Dlg_Data.showCurves.noise_filtered = false;
    end
    
    set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);
    
    i = user_data.Dlg_Data.current_graph_index;
    %part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    DisplayGraph(handles, i);




% --- Executes on button press in cbUseDenoised.
function cbUseDenoised_Callback(hObject, eventdata, handles)
% hObject    handle to cbUseDenoised (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbUseDenoised
    user_data = get(handles.nmssCurveAnalysisDlg, 'UserData');
    if (get(hObject,'Value') == 1)
        user_data.Dlg_Data.use_denoised_data_to_fit = true;
    else
        user_data.Dlg_Data.use_denoised_data_to_fit = false;
    end
    
    set(handles.nmssCurveAnalysisDlg, 'UserData', user_data);

