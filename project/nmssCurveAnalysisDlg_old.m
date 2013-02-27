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

    global nmssCurveAnalysisDlg_Data;
    
    % set gui elements
    
    % fill peak analysis parameters
    SetAnalysisMethods(handles);
    set(handles.editFitROI, 'String', ...
        num2str(nmssCurveAnalysisDlg_Data.peakFindingParams.fitFraction));
    
    
    % the show curves checkboxes
    if (nmssCurveAnalysisDlg_Data.showCurves.smoothed)
        set(handles.cbShowcurveSmoothed, 'Value', 1);
    end
    if (nmssCurveAnalysisDlg_Data.showCurves.unsmoothed)
        set(handles.cbShowcurveUnsmoothed, 'Value', 1);
    end
    if (nmssCurveAnalysisDlg_Data.showCurves.fittedcurve)
        set(handles.cbShowcurveFit, 'Value', 1);
    end
    if (nmssCurveAnalysisDlg_Data.showCurves.max)
        set(handles.cbShowcurveMaxPos, 'Value', 1);
    end
    if (nmssCurveAnalysisDlg_Data.showCurves.peak_finding_range)
        set(handles.cbShowCurvesPeakRange, 'Value', 1);
    end
    if (nmssCurveAnalysisDlg_Data.showCurves.noise_filtered)
        set(handles.cbDenoised, 'Value', 1);
    end
    
    
    % use denoised data to fit?
    set(handles.cbUseDenoised, 'Value', 0);
    if (nmssCurveAnalysisDlg_Data.use_denoised_data_to_fit)
        set(handles.cbUseDenoised, 'Value', 1);
    end
         
    
    % the unit of the x-axis of the displayed curves
    if (strcmp(nmssCurveAnalysisDlg_Data.graphXAxisUnit, 'eV'))
        set(handles.rbEV, 'Value', 1);
        set(handles.rbNm, 'Value', 0);
    else
        set(handles.rbEV, 'Value', 0);
        set(handles.rbNm, 'Value', 1);
    end

    % the index of the currently active particle (and graph)
    nmssCurveAnalysisDlg_Data.current_graph_index = 1;
    part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(nmssCurveAnalysisDlg_Data.current_graph_index);
    

    % a vector of flags that indicate if the user selected the graph or not
    nmssCurveAnalysisDlg_Data.selected_particle_index_flag = ...
        ones(1,length(nmssCurveAnalysisDlg_Data.selected_particle_index));
    
    % set selection state indicator check box
    set(handles.cbSelect, 'Value', 1);
    
    if (~isfield(nmssCurveAnalysisDlg_Data,'nmssPeakFindingRangeDlg_Data'))
        nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data = InitXAxisLimits();
    end
    if (~isfield(nmssCurveAnalysisDlg_Data,'nmssPeakFittingRangeDlg_Data'))
        nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data = InitXAxisLimits();
    end
    
    %sel_flag = (nmssCurveAnalysisDlg_Data.selected_particle_index_flag( nmssCurveAnalysisDlg_Data.current_graph_index) == 1);    
    % display the first graph in the graph structure array
    DisplayGraph(handles, nmssCurveAnalysisDlg_Data.current_graph_index);
    
    % update navigation buttons
    UpdateGraphNaviButtons(handles);
    



% Update handles structure
guidata(hObject, handles);

%
function IniDlg(hFig)

    global nmssCurveAnalysisDlg_Data;
    
    % set gui elements
    
    % fill peak analysis parameters
    SetAnalysisMethods(handles);
    set(handles.editFitROI, 'String', ...
        num2str(nmssCurveAnalysisDlg_Data.peakFindingParams.fitFraction));
    
    
    % the show curves checkboxes
    if (nmssCurveAnalysisDlg_Data.showCurves.smoothed)
        set(handles.cbShowcurveSmoothed, 'Value', 1);
    end
    if (nmssCurveAnalysisDlg_Data.showCurves.unsmoothed)
        set(handles.cbShowcurveUnsmoothed, 'Value', 1);
    end
    if (nmssCurveAnalysisDlg_Data.showCurves.fittedcurve)
        set(handles.cbShowcurveFit, 'Value', 1);
    end
    if (nmssCurveAnalysisDlg_Data.showCurves.max)
        set(handles.cbShowcurveMaxPos, 'Value', 1);
    end
    if (nmssCurveAnalysisDlg_Data.showCurves.peak_finding_range)
        set(handles.cbShowCurvesPeakRange, 'Value', 1);
    end
    if (nmssCurveAnalysisDlg_Data.showCurves.noise_filtered)
        set(handles.cbDenoised, 'Value', 1);
    end
    
    
    % use denoised data to fit?
    set(handles.cbUseDenoised, 'Value', 0);
    if (nmssCurveAnalysisDlg_Data.use_denoised_data_to_fit)
        set(handles.cbUseDenoised, 'Value', 1);
    end
         
    
    % the unit of the x-axis of the displayed curves
    if (strcmp(nmssCurveAnalysisDlg_Data.graphXAxisUnit, 'eV'))
        set(handles.rbEV, 'Value', 1);
        set(handles.rbNm, 'Value', 0);
    else
        set(handles.rbEV, 'Value', 0);
        set(handles.rbNm, 'Value', 1);
    end

    % the index of the currently active particle (and graph)
    nmssCurveAnalysisDlg_Data.current_graph_index = 1;
    part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(nmssCurveAnalysisDlg_Data.current_graph_index);
    

    % a vector of flags that indicate if the user selected the graph or not
    nmssCurveAnalysisDlg_Data.selected_particle_index_flag = ...
        ones(1,length(nmssCurveAnalysisDlg_Data.selected_particle_index));
    
    % set selection state indicator check box
    set(handles.cbSelect, 'Value', 1);
    
    if (~isfield(nmssCurveAnalysisDlg_Data,'nmssPeakFindingRangeDlg_Data'))
        nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data = InitXAxisLimits();
    end
    if (~isfield(nmssCurveAnalysisDlg_Data,'nmssPeakFittingRangeDlg_Data'))
        nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data = InitXAxisLimits();
    end
    
    %sel_flag = (nmssCurveAnalysisDlg_Data.selected_particle_index_flag( nmssCurveAnalysisDlg_Data.current_graph_index) == 1);    
    % display the first graph in the graph structure array
    DisplayGraph(handles, nmssCurveAnalysisDlg_Data.current_graph_index);
    
    % update navigation buttons
    UpdateGraphNaviButtons(handles);
    


% UIWAIT makes nmssCurveAnalysisDlg wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% -------------------------------------------------------------------------
function SetAnalysisMethods(handles)
    global nmssCurveAnalysisDlg_Data;

    set(handles.rbFitParabola,'Value', 0);
    set(handles.rbFitManualPeakAnalysis,'Value', 0);
    set(handles.rbLorentzFitDenoised,'Value', 0);
    
    if (strcmp(nmssCurveAnalysisDlg_Data.peakFindingParams.method, 'fit_parabola_on_top_part_of_peak'))
        % use a parabola fitted to the top part of the peak to determine
        % the max position
        set(handles.rbFitParabola,'Value', 1);
    elseif (strcmp(nmssCurveAnalysisDlg_Data.peakFindingParams.method, 'fit_no_fit_use_manual_settings'))
        % let the user enter the peak paramters
        set(handles.rbFitManualPeakAnalysis,'Value', 1);
    elseif (strcmp(nmssCurveAnalysisDlg_Data.peakFindingParams.method, 'fit_with_1_lorentz'))
        % let the user enter the peak paramters
        set(handles.rbLorentzFit,'Value', 1);
    elseif (strcmp(nmssCurveAnalysisDlg_Data.peakFindingParams.method, 'fit_with_1_lorentz_on_denoised'))
        % let the user enter the peak paramters
        set(handles.rbLorentzFitDenoised,'Value', 1);
    else
        % use the smoothed curve to determine the position of the max
        set(handles.rbLorentzFitDenoised,'Value', 1);
    end

% -------------------------------------------------------------------------
function  GetPeakFindingMethods(handles)
    global nmssCurveAnalysisDlg_Data;

    if (get(handles.rbFitParabola,'Value') == 1)
        nmssCurveAnalysisDlg_Data.peakFindingParams.method = 'fit_parabola_on_top_part_of_peak';
    elseif (get(handles.rbFitManualPeakAnalysis,'Value') == 1)
        nmssCurveAnalysisDlg_Data.peakFindingParams.method = 'fit_no_fit_use_manual_settings';
    elseif (get(handles.rbLorentzFit,'Value') == 1)
        nmssCurveAnalysisDlg_Data.peakFindingParams.method = 'fit_with_1_lorentz';
    elseif (get(handles.rbLorentzFitDenoised,'Value') == 1)
        nmssCurveAnalysisDlg_Data.peakFindingParams.method = 'fit_with_1_lorentz_on_denoised';
    else
        nmssCurveAnalysisDlg_Data.peakFindingParams.method = 'fit_no_fit_just_smooth';
    end







% -------------------------------------------------------------------------
function DisplayGraph(handles, selected_index)
    global nmssCurveAnalysisDlg_Data;
    
    part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(selected_index);
    particle = nmssCurveAnalysisDlg_Data.particle(part_index);
    showCurves = nmssCurveAnalysisDlg_Data.showCurves;
    eV_or_nm = nmssCurveAnalysisDlg_Data.graphXAxisUnit;
    sel_flag = (nmssCurveAnalysisDlg_Data.selected_particle_index_flag(selected_index) == 1);    
    
    
    % if the figure with zoom graph exists display the same graph there too
    if (isfield(nmssCurveAnalysisDlg_Data, 'hZoomAxes'))
        if (ishandle(nmssCurveAnalysisDlg_Data.hZoomAxes))
            DisplayGraphInAxes(nmssCurveAnalysisDlg_Data.hZoomAxes, ...
                               particle, showCurves, eV_or_nm, ...
                               nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data, ...
                               nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data);
        end
    end
    
    % display stuff in the build-in axes
    DisplayGraphInAxes(handles.axesGraph, particle, showCurves, eV_or_nm, ...
                    nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data, ...
                    nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data);
    
    if (sel_flag)
        set(handles.axesGraph, 'Color', [248 230 126] / 255); % beige
        set(handles.cbSelect, 'Value', 1);
    else
        set(handles.axesGraph, 'Color', [255 255 255] / 255); % white
        set(handles.cbSelect, 'Value', 0);
    end
                    
    DisplayCurveParameters(handles, particle);
    

% -------------------------------------------------------------------------
function DisplayGraphInAxes(hAxes, particle, showCurves, eV_or_nm, ...
                            peakFindingRange, peakFittingRange)
                            
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

        if (isfield(p, 'fit_x') && isfield(p, 'fit_y'))
            if (strcmp(eV_or_nm,'eV'))
                fit_x = p.fit_x;
                fit_y = p.fit_y;
            else
                [fit_x, fit_y] = nmssConvertGraph_eV_2_nm(p.fit_x, p.fit_y);
            end
            plot(fit_x, fit_y,  'g', 'LineWidth', 2 );

            [max_val, max_pos] = max(fit_y);
            %title(['Max pos: ', num2str(fit_x(max_pos)), ' nm (', num2str(1240 / fit_x(max_pos)),' eV)', ' Max val:' , num2str(max_val)])

        else
            uiwait(msgbox('No fit available for this graph!','Display Fit', 'error', 'modal'));
        end
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
        rPos_x_start = peakFindingRange.rangeStart;
        rPos_x_end = peakFindingRange.rangeEnd;
        
        if (strcmp(eV_or_nm,peakFindingRange.eV_or_nm))
            hs = line([rPos_x_start, rPos_x_start], [ylimits(1), ylimits(2)], ...
                 'LineWidth', 2, 'Color', 'k', 'LineStyle', ':');
            he = line([rPos_x_end, rPos_x_end], [ylimits(1), ylimits(2)], ...
                 'LineWidth', 2, 'Color', 'k', 'LineStyle', ':');
        else
            he = line([1240 / rPos_x_start, 1240 / rPos_x_start], [ylimits(1), ylimits(2)], ...
                 'LineWidth', 2, 'Color', 'k', 'LineStyle', ':');
            hs = line([1240 / rPos_x_end, 1240 / rPos_x_end], [ylimits(1), ylimits(2)], ...
                 'LineWidth', 2, 'Color', 'k', 'LineStyle', ':');
        end
        
        set(hs, 'Tag', 'PeakFindingRange_Start_line');
        set(he, 'Tag', 'PeakFindingRange_End_line');
            
        rPos_x_start = peakFittingRange.rangeStart;
        rPos_x_end = peakFittingRange.rangeEnd;
        if (strcmp(eV_or_nm,peakFittingRange.eV_or_nm))
            hs = line([rPos_x_start, rPos_x_start], [ylimits(1), ylimits(2)], ...
                 'LineWidth', 2, 'Color', 'k', 'LineStyle', '-.');
            he = line([rPos_x_end, rPos_x_end], [ylimits(1), ylimits(2)], ...
                 'LineWidth', 2, 'Color', 'k', 'LineStyle', '-.');
        else
            he = line([1240 / rPos_x_start, 1240 / rPos_x_start], [ylimits(1), ylimits(2)], ...
                 'LineWidth', 2, 'Color', 'k', 'LineStyle', '-.');
            hs = line([1240 / rPos_x_end, 1240 / rPos_x_end], [ylimits(1), ylimits(2)], ...
                 'LineWidth', 2, 'Color', 'k', 'LineStyle', '-.');
        end
        
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
    set(handles.editPeakFWHM,'String', num2str(FWHM));
    set(handles.editPeakMaxInt,'String', num2str(max_int, '%8.2e'));
    
    
    
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
    global nmssCurveAnalysisDlg_Data;
    global nmssPeakFindingRangeDlg_Data;
    
    if (isfield(nmssCurveAnalysisDlg_Data, 'nmssPeakFindingRangeDlg_Data'))
        nmssPeakFindingRangeDlg_Data = nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data;
    else
        peakFindingRange = InitXAxisLimits();
        
        nmssPeakFindingRangeDlg_Data = peakFindingRange;
    end

    if (~strcmp(nmssPeakFindingRangeDlg_Data.eV_or_nm,nmssCurveAnalysisDlg_Data.graphXAxisUnit))
        nmssPeakFindingRangeDlg_Data.rangeStart = ...
            1240/nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data.rangeEnd;
        nmssPeakFindingRangeDlg_Data.rangeEnd = ...
            1240/nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data.rangeStart;
        nmssPeakFindingRangeDlg_Data.eV_or_nm = nmssCurveAnalysisDlg_Data.graphXAxisUnit;
    end
    
    ZoomFigure(handles);

    % disable gui elements that interfere with the opened child dialog
    set(handles.rbEV, 'Enable', 'off');
    set(handles.rbNm, 'Enable', 'off');
    set(handles.pbApply, 'Enable', 'off');
    uiwait(nmssPeakFindingRangeDlg());
    
    % check if parent of nmssPeakFindingRangeDlg still exists
    h = findobj(handles.nmssCurveAnalysisDlg, 'Tag', 'nmssCurveAnalysisDlg');
    if (isempty(h))
        return;
    end
    if (~ishandle(h))
        return;
    end
    
    % enable gui elements that can interfere with the opened child dialog
    set(handles.rbEV, 'Enable', 'on');
    set(handles.rbNm, 'Enable', 'on');
    set(handles.pbApply, 'Enable', 'on');
    
    
    nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data = nmssPeakFindingRangeDlg_Data;
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    
    % display the first graph in the graph structure array
    DisplayGraph(handles, i);
    
    
% -------------------------------------------------------------------------
% initializes the Peak finding range to a reduced x-range of the graph which
% is the full range minus 10% at both ends
function range = InitXAxisLimits(varargin)
    global nmssCurveAnalysisDlg_Data;

    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    particle = nmssCurveAnalysisDlg_Data.particle(part_index);

    rangeStart_nm = particle.graph.axis.x(1);
    rangeEnd_nm = particle.graph.axis.x(end);
    if (strcmp(nmssCurveAnalysisDlg_Data.graphXAxisUnit, 'eV'))
        rangeStart = 1240 / rangeEnd_nm;
        rangeEnd = 1240 / rangeStart_nm;
    else
        rangeStart = rangeStart_nm;
        rangeEnd = rangeEnd_nm;
    end

    if (length(varargin) == 1)
        bregion = varargin{1};
    else
        bregion = 0.1;
    end
    
    range.rangeStart = rangeStart + (rangeEnd - rangeStart) * bregion;
    range.rangeEnd = rangeEnd - (rangeEnd - rangeStart) * bregion;
    range.eV_or_nm = nmssCurveAnalysisDlg_Data.graphXAxisUnit;



function editFitROI_Callback(hObject, eventdata, handles)
% hObject    handle to editFitROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFitROI as text
%        str2double(get(hObject,'String')) returns contents of editFitROI as a double
    global nmssCurveAnalysisDlg_Data;
    
    if (nmssValidateNumericEdit(hObject, 'Fit with parabola'))
        fF = str2num(get(hObject, 'String'));
        if (fF >= 100)
            errordlg('Please enter a number smaller than 100!');
            return;
        elseif (fF <= 0)
            errordlg('Please enter a number greater than 0!');
            return;
        end
        nmssCurveAnalysisDlg_Data.peakFindingParams.fitFraction = fF;
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
    global nmssCurveAnalysisDlg_Data;
    
    if (nmssValidateNumericEdit(hObject, 'Smoothing parameter'))
        smoothParam = str2num(get(hObject, 'String'));

        if (smoothParam < 2)
            errordlg('Please enter a number greater than 2!');
            return;
        end
        nmssCurveAnalysisDlg_Data.peakFindingParams.smoothParam = smoothParam;
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


% --- Executes on button press in pbApply.
function pbApply_Callback(hObject, eventdata, handles)
% hObject    handle to pbApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssCurveAnalysisDlg_Data;
    
    % ask the user whether he wants to apply the changes to all selected or just to
    % the current graph
    button = questdlg('Do you want to apply changes to all selected particles?', ...
                      'Apply to all particles','Yes','No','Cancel','No');
    
    if (strcmp(button,'Cancel'))
        return;
    end
    refresh;
    
    % collect input parameters
    % set up peakFindingParams
    peakFindingParams = nmssCurveAnalysisDlg_Data.peakFindingParams;
    
    % loop over all graphs that will be processed
    start_index = 1;
    end_index = length(nmssCurveAnalysisDlg_Data.selected_particle_index);
    if (strcmp(button,'No'))
        start_index = nmssCurveAnalysisDlg_Data.current_graph_index;
        end_index = nmssCurveAnalysisDlg_Data.current_graph_index;
    end
    
    hWaitbar = waitbar(0,'Processing Curves (find peak maximum and FWHM)','CreateCancelBtn','delete(gcf);');
    p = nmssCurveAnalysisDlg_Data.particle;

    for i=start_index:end_index
        
        % refresh waitbar
        if (ishandle(hWaitbar))
            waitbar(i/(end_index-start_index + 1));
        else
            % user canceled
            break;
        end
        
        ip = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
        
        % get graphs that we need for finding the peak
        x_nm = p(ip).graph.axis.x;
        if (nmssCurveAnalysisDlg_Data.use_denoised_data_to_fit)
            if (isfield(p(ip).graph, 'noise_filtered'))
                spec_nm = p(ip).graph.noise_filtered;
            else
                spec_nm = p(ip).graph.smoothed;
            end
        else
            spec_nm = p(ip).graph.normalized;
        end
        spec_smooth_nm = p(ip).graph.smoothed;
        
        % convert them into the eV picture
        [x_eV, spec_eV] = nmssConvertGraph_nm_2_eV(x_nm, spec_nm);
        [x_eV, spec_smooth_eV] = nmssConvertGraph_nm_2_eV(x_nm, spec_smooth_nm);
        
        % the region where the search for the peak will take place
        rangeStart = nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data.rangeStart;
        rangeEnd = nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data.rangeEnd;
        eV_or_nm = nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data.eV_or_nm;
        if (strcmp(eV_or_nm,'nm'))
            rangeEnd = 1240 / nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data.rangeStart;
            rangeStart = 1240 / nmssCurveAnalysisDlg_Data.nmssPeakFindingRangeDlg_Data.rangeEnd;
        end
        peak_index_range = find(x_eV >= rangeStart &  x_eV <= rangeEnd);
        
        % the region where the fit should be applied
        peakFittingStart = nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data.rangeStart;
        peakFittingEnd = nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data.rangeEnd;
        eV_or_nm = nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data.eV_or_nm;
        if (strcmp(eV_or_nm,'nm'))
            peakFittingEnd = 1240 / nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data.rangeStart;
            peakFittingStart = 1240 / nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data.rangeEnd;
        end

        
        % lorentz fit method can find more than one peak
        if (strcmp(peakFindingParams.method, 'fit_with_1_lorentz'))
            
            % find max and FWHM, etc.
            [peak_max_v, peak_FWHM_v, peak_max_int_v, fit_x, fit_y, str_errmsg] = ...
                    nmssGetMaxAndFWHM(spec_eV, spec_smooth_eV, ...
                                      x_eV, peakFindingParams, ...
                                      rangeStart, rangeEnd, peakFittingStart, peakFittingEnd);
                
            % get the peak with the highest intensity in the provided range
            num_of_peaks = length(peak_max_v);
            if (num_of_peaks > 1)
                peak_in_range_index = find(peak_max_v >= rangeStart &  peak_max_v <= rangeEnd);
            else
                peak_in_range_index = 1;
            end
            
            [peak_max, pindex] = max(peak_max_v(peak_in_range_index)); % get the largest peak in range
            % if the maximas are not in the specified range
            if (isempty(pindex))
                [peak_max, pindex] = max(peak_max_v);
            end
            peak_FWHM = peak_FWHM_v(pindex);
            peak_max_int = peak_max_int_v(pindex);
        else
            % find max and FWHM, etc.
            [peak_max, peak_FWHM, peak_max_int, fit_x, fit_y, str_errmsg] = ...
                    nmssGetMaxAndFWHM(spec_eV(peak_index_range), ...
                                      spec_smooth_eV(peak_index_range), ...
                                      x_eV(peak_index_range), peakFindingParams, ...
                                      rangeStart, rangeEnd, peakFittingStart, peakFittingEnd);
        end
        %p = rmfield(p,'FWHM');
        
        
        p(ip).res_energy = peak_max;
        p(ip).FWHM = peak_FWHM.full;
        p(ip).max_intensity = peak_max_int;
        p(ip).fit_x = fit_x;
        p(ip).fit_y = fit_y;
        
        % update graph and particle informations
        ip = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    end

    nmssCurveAnalysisDlg_Data.particle = p;
    
    % clear waitbar
    if (ishandle(hWaitbar))
        delete(hWaitbar);
    end
    
    
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
%     ip = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
%     sel_flag = (nmssCurveAnalysisDlg_Data.selected_particle_index_flag(i) == 1);
    
    % refresh the currently displayed graph
    DisplayGraph(handles, i);
    
    % finished?
    


% --- Executes on button press in pbGetPrevGraph.
function pbGetPrevGraph_Callback(hObject, eventdata, handles)
% hObject    handle to pbGetPrevGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssCurveAnalysisDlg_Data;
    
    % copy used global variables into local one so that it is easier to
    % overllok what we have here
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    istart = 1;
    iend = length(nmssCurveAnalysisDlg_Data.selected_particle_index);
    
    if (i > istart)
        i = i-1;
%         part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
%         sel_flag = (nmssCurveAnalysisDlg_Data.selected_particle_index_flag(i) == 1);

        % display the first graph in the graph structure array
        DisplayGraph(handles, i);
        
        nmssCurveAnalysisDlg_Data.current_graph_index = i;
    end

    UpdateGraphNaviButtons(handles);

% --- Executes on button press in pbGetNextGraph.
function pbGetNextGraph_Callback(hObject, eventdata, handles)
% hObject    handle to pbGetNextGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssCurveAnalysisDlg_Data;
    
    % copy used global variables into local one so that it is easier to
    % overllok what we have here
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    istart = 1;
    iend = length(nmssCurveAnalysisDlg_Data.selected_particle_index);
    
    if (i < iend)
        i = i+1;
%         part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
%         sel_flag = (nmssCurveAnalysisDlg_Data.selected_particle_index_flag(i) == 1);
    
        % display the first graph in the graph structure array
        DisplayGraph(handles, i);
        
        nmssCurveAnalysisDlg_Data.current_graph_index = i;
    end
    
    UpdateGraphNaviButtons(handles);
    
% -------------------------------------------------------------------------
% updates the navigations buttons that are intended to navigate between the
% selected graphs
function UpdateGraphNaviButtons(handles)
    
    global nmssCurveAnalysisDlg_Data;
    
    % copy used global variables into local one so that it is easier to
    % overllok what we have here
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    istart = 1;
    iend = length(nmssCurveAnalysisDlg_Data.selected_particle_index);
    
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

%     % open new figure and display curves in there
%     global nmssCurveAnalysisDlg_Data;
%     
%     nmssCurveAnalysisDlg_Data.hZoomFigure = figure;
%     nmssCurveAnalysisDlg_Data.hZoomAxes = axes;
%     
%     i = nmssCurveAnalysisDlg_Data.current_graph_index;
% %     ip = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
% %     sel_flag = (nmssCurveAnalysisDlg_Data.selected_particle_index_flag(i) == 1);
%     
%     % refresh the currently displayed graph
%     DisplayGraph(handles, i);
    
    ZoomFigure(handles);
    
function ZoomFigure(handles)

    % open new figure and display curves in there
    global nmssCurveAnalysisDlg_Data;
    
    if (~isfield(nmssCurveAnalysisDlg_Data, 'hZoomAxes') || ...
            ~ishandle(nmssCurveAnalysisDlg_Data.hZoomAxes))
        nmssCurveAnalysisDlg_Data.hZoomFigure = figure;
        nmssCurveAnalysisDlg_Data.hZoomAxes = axes;
    else
        axes(nmssCurveAnalysisDlg_Data.hZoomAxes);
    end
    
    
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    
    % refresh the currently displayed graph
    DisplayGraph(handles, i);
    
    % position this figure right below the parent dialog
    set(handles.nmssCurveAnalysisDlg, 'Unit', 'pixels');
    parent_pos = get(handles.nmssCurveAnalysisDlg, 'Position');
    set(nmssCurveAnalysisDlg_Data.hZoomFigure, 'Unit', 'pixels');
    child_pos = get(nmssCurveAnalysisDlg_Data.hZoomFigure, 'Position');
    child_pos(2) = parent_pos(2) - child_pos(4);
    child_pos(1) = parent_pos(1);
    child_pos(3) = parent_pos(3);
    set(nmssCurveAnalysisDlg_Data.hZoomFigure, 'Position', child_pos);



% --- Executes on button press in cbShowcurveFit.
function cbShowcurveFit_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowcurveFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowcurveFit
    global nmssCurveAnalysisDlg_Data;
    if (get(hObject,'Value') == 1)
        nmssCurveAnalysisDlg_Data.showCurves.fittedcurve = true;
    else
        nmssCurveAnalysisDlg_Data.showCurves.fittedcurve = false;
    end
    
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    %part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);

    DisplayGraph(handles, i);
    


% --- Executes on button press in cbShowcurveMaxPos.
function cbShowcurveMaxPos_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowcurveMaxPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowcurveMaxPos
    global nmssCurveAnalysisDlg_Data;
    if (get(hObject,'Value') == 1)
        nmssCurveAnalysisDlg_Data.showCurves.max = true;
    else
        nmssCurveAnalysisDlg_Data.showCurves.max = false;
    end
    
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    %part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    DisplayGraph(handles,i);
    


% --- Executes on button press in cbShowcurveFWHM.
function cbShowcurveFWHM_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowcurveFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowcurveFWHM
    global nmssCurveAnalysisDlg_Data;
    if (get(hObject,'Value') == 1)
        nmssCurveAnalysisDlg_Data.showCurves.FWHM = true;
    else
        nmssCurveAnalysisDlg_Data.showCurves.FWHM = false;
    end
    
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
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

    global nmssCurveAnalysisDlg_Data;
    
    if (isfield(nmssCurveAnalysisDlg_Data, 'hZoomFigure'))
        if (ishandle(nmssCurveAnalysisDlg_Data.hZoomFigure))
            delete(nmssCurveAnalysisDlg_Data.hZoomFigure);
        end
    end
    
    % find parent dialog
    hParent = findobj('Tag', 'nmssResultsViewerDlg');
    if (ishandle(hParent))
        % switch off controls (user should not mess around with the dialog box)
        hControls = findobj(hParent, 'Style', 'pushbutton', '-or', 'Style', 'popupmenu');
        set(hControls, 'Enable', 'on');
    end
    



% Hint: delete(hObject) closes the figure
delete(hObject);




% --- Executes on button press in rbEV.
function rbEV_Callback(hObject, eventdata, handles)
% hObject    handle to rbEV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssCurveAnalysisDlg_Data

% Hint: get(hObject,'Value') returns toggle state of rbEV
    if (get(hObject,'Value') == 1)
        set(handles.rbNm, 'Value', 0);
        nmssCurveAnalysisDlg_Data.graphXAxisUnit = 'eV';
        
        i = nmssCurveAnalysisDlg_Data.current_graph_index;
        %part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    
        % display the first graph in the graph structure array
        DisplayGraph(handles, i);
    end
        
        
        


% --- Executes on button press in rbNm.
function rbNm_Callback(hObject, eventdata, handles)
% hObject    handle to rbNm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssCurveAnalysisDlg_Data

% Hint: get(hObject,'Value') returns toggle state of rbEV
    if (get(hObject,'Value') == 1)
        set(handles.rbEV, 'Value', 0);
        nmssCurveAnalysisDlg_Data.graphXAxisUnit = 'nm';
        
        i = nmssCurveAnalysisDlg_Data.current_graph_index;
        %part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    
        % display the first graph in the graph structure array
        DisplayGraph(handles, i);
    end
        




% --- Executes on button press in cbShowcurveSmoothed.
function cbShowcurveSmoothed_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowcurveSmoothed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowcurveSmoothed

    global nmssCurveAnalysisDlg_Data;
    if (get(hObject,'Value') == 1)
        nmssCurveAnalysisDlg_Data.showCurves.smoothed = true;
    else
        nmssCurveAnalysisDlg_Data.showCurves.smoothed = false;
    end
    
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    %part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    DisplayGraph(handles, i);
    



% --- Executes on button press in cbShowcurveUnsmoothed.
function cbShowcurveUnsmoothed_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowcurveUnsmoothed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowcurveUnsmoothed
    global nmssCurveAnalysisDlg_Data;
    if (get(hObject,'Value') == 1)
        nmssCurveAnalysisDlg_Data.showCurves.unsmoothed = true;
    else
        nmssCurveAnalysisDlg_Data.showCurves.unsmoothed = false;
    end
    
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    %part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    DisplayGraph(handles, i);
    





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
    global nmssCurveAnalysisDlg_Data;
    if (get(hObject,'Value') == 1)
        nmssCurveAnalysisDlg_Data.showCurves.peak_finding_range = true;
    else
        nmssCurveAnalysisDlg_Data.showCurves.peak_finding_range = false;
    end
    
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    %part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    DisplayGraph(handles, i);




% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, eventdata, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global nmssCurveAnalysisDlg_Data;
    global nmssResultsViewerDlg_Data;
    global doc;
    
%     wanted_index = find(nmssCurveAnalysisDlg_Data.selected_particle_index_flag == 1);
%     wanted_part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(wanted_index);
%     nmssResultsViewerDlg_Data.work_particle(wanted_part_index) = ...
%         nmssCurveAnalysisDlg_Data.particle(wanted_part_index);
%     
%     nmssResultsViewerDlg_Data.particle_selected(wanted_part_index) = 1;
%     
%     unwanted_index = find(nmssCurveAnalysisDlg_Data.selected_particle_index_flag == 0);
%     unwanted_part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(unwanted_index);
%     nmssResultsViewerDlg_Data.particle_selected(unwanted_part_index) = 0;
%         
        
    
    %doc.nmssCurveAnalysisDlg_Data = nmssCurveAnalysisDlg_Data;
    nmssCurveAnalysisDlg_Data.OKFunction(nmssCurveAnalysisDlg_Data);
    
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
    global nmssCurveAnalysisDlg_Data;

% Hint: get(hObject,'Value') returns toggle state of cbSelect
    if (~get(hObject,'Value'))
        nmssCurveAnalysisDlg_Data.selected_particle_index_flag(...
            nmssCurveAnalysisDlg_Data.current_graph_index) = 0;
        set(handles.axesGraph, 'Color', [255 255 255] / 255); % white        
    else
        nmssCurveAnalysisDlg_Data.selected_particle_index_flag(...
            nmssCurveAnalysisDlg_Data.current_graph_index) = 1;
        set(handles.axesGraph, 'Color', [248 230 126] / 255); % beige
    end
    
    



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
    global nmssPeakFittingRangeDlg_Data;
    global nmssCurveAnalysisDlg_Data;
    
    if (isfield(nmssCurveAnalysisDlg_Data, 'nmssPeakFittingRangeDlg_Data'))
        nmssPeakFittingRangeDlg_Data = nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data;
    else
        peakFindingRange = InitXAxisLimits(0.08);
        
        nmssPeakFittingRangeDlg_Data = peakFindingRange;
    end

    if (~strcmp(nmssPeakFittingRangeDlg_Data.eV_or_nm,nmssCurveAnalysisDlg_Data.graphXAxisUnit))
        nmssPeakFittingRangeDlg_Data.rangeStart = ...
            1240/nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data.rangeEnd;
        nmssPeakFittingRangeDlg_Data.rangeEnd = ...
            1240/nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data.rangeStart;
        nmssPeakFittingRangeDlg_Data.eV_or_nm = nmssCurveAnalysisDlg_Data.graphXAxisUnit;
    end
    
    ZoomFigure(handles);
        
    set(handles.rbEV, 'Enable', 'off');
    set(handles.rbNm, 'Enable', 'off');
    set(handles.pbApply, 'Enable', 'off');
    uiwait(nmssPeakFittingRangeDlg());
    
    h = findobj(handles.nmssCurveAnalysisDlg, 'Tag', 'nmssCurveAnalysisDlg');
    if (isempty(h))
        return;
    end
    if (~ishandle(h))
        return;
    end
    
    set(handles.rbEV, 'Enable', 'on');
    set(handles.rbNm, 'Enable', 'on');
    set(handles.pbApply, 'Enable', 'on');
    
    nmssCurveAnalysisDlg_Data.nmssPeakFittingRangeDlg_Data = nmssPeakFittingRangeDlg_Data;
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    
    % display the first graph in the graph structure array
    DisplayGraph(handles, i);
    
    



% --- Executes on button press in cbDenoised.
function cbDenoised_Callback(hObject, eventdata, handles)
% hObject    handle to cbDenoised (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbDenoised
    global nmssCurveAnalysisDlg_Data;
    if (get(hObject,'Value') == 1)
        nmssCurveAnalysisDlg_Data.showCurves.noise_filtered = true;
    else
        nmssCurveAnalysisDlg_Data.showCurves.noise_filtered = false;
    end
    
    i = nmssCurveAnalysisDlg_Data.current_graph_index;
    %part_index = nmssCurveAnalysisDlg_Data.selected_particle_index(i);
    DisplayGraph(handles, i);




% --- Executes on button press in cbUseDenoised.
function cbUseDenoised_Callback(hObject, eventdata, handles)
% hObject    handle to cbUseDenoised (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbUseDenoised
    global nmssCurveAnalysisDlg_Data;
    if (get(hObject,'Value') == 1)
        nmssCurveAnalysisDlg_Data.use_denoised_data_to_fit = true;
    else
        nmssCurveAnalysisDlg_Data.use_denoised_data_to_fit = false;
    end

