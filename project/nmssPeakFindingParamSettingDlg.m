function [user_action, fit_params_out, apply_to_all] = nmssPeakFindingParamSettingDlg( fit_params_in,  ev_or_nm, apply_to_all, x_axis)
% doc = struct to contain input parameters

    % init figure data
    user_data.user_action = 'Cancel';
    user_data.fit_params = fit_params_in;
    user_data.ev_or_nm = ev_or_nm;
    if (strcmp(ev_or_nm, 'eV'))
        % conversion to eV
        user_data.x_axis = 1240 ./ x_axis;
    else
        % conversion to nm
        user_data.x_axis = x_axis;
        user_data.fit_params.fit_range.min = 1240 / fit_params_in.fit_range.max;
        user_data.fit_params.fit_range.max = 1240 / fit_params_in.fit_range.min;
        user_data.fit_params.finding_range.min = 1240 / fit_params_in.finding_range.max;
        user_data.fit_params.finding_range.max = 1240 / fit_params_in.finding_range.min;
    end
    user_data.apply_to_all = false;
    
    hFig = figure;
    set(hFig, 'Units', 'characters', 'MenuBar', 'none', 'Resize', 'off', 'Name', 'Peak Finding Settings', ...
        'NumberTitle', 'off', 'CloseRequestFcn', @CloseFigure);
    
    % add callback for if user presses a key (for keyboard
    % shortcuts
    set(hFig, 'KeyPressFcn', @FigureKeyPressedCallback);
    set(hFig, 'UserData', user_data); % initialize default user action
    
    % SOMETHING HAPPENS HERE!
    % create gui here
    
    CreateFigure(hFig);

    % wait until the visibility of the figure property changed to 'off' -
    % this happens in the CloseFigure procedure
    %set(hFig, 'WindowStyle', 'modal');
    
    waitfor(hFig,'Visible', 'off');
    
    % return new parameter (or the old one is user pressed cancel)
    user_data = get(hFig, 'UserData');
    fit_params_out = user_data.fit_params;
    apply_to_all = user_data.apply_to_all;
    user_action = user_data.user_action;
    
    close(hFig);

    
function CreateFigure(hFig)

    user_data = get(hFig, 'UserData');
    figPos = get(hFig, 'Position');
    
    % building gui from the bottom
    h_pbOK = uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'OK', 'Units', 'characters', ...
        'Callback', @OKFcn);
    posPbOK = get(h_pbOK, 'Position');
    posPbOK([1:2]) = [2, 1];
    set(h_pbOK, 'Position', posPbOK);
    
    h_pbCancel = uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Cancel', 'Units', 'characters', ...
        'Callback', @CancelFcn);
    posPbCancel = get(h_pbCancel, 'Position');
    posPbCancel([1:2]) = [2 + posPbOK(3) + 1, 1];
    set(h_pbCancel, 'Position', posPbCancel);
    
    h_cxApplyToAll = uicontrol('Parent', hFig, 'Style', 'checkbox', 'String', 'Apply to all graphs', 'Units', 'characters', ...
        'Tag', 'cxApplyToAll', 'Value', user_data.apply_to_all);
    pos_cxApplyToAll = [posPbCancel(1) + posPbCancel(3) + 5, posPbCancel(2), 30, 1.5];
    set(h_cxApplyToAll, 'Position', pos_cxApplyToAll);

    
    % add panel that contains all gui elements
    hDlgPanel = uipanel('Parent', hFig, 'Title', '', 'Units', 'characters', 'Tag', 'panelDlg');
    
    % smoothing param
    hTextSmoothParam = uicontrol('Parent', hDlgPanel, 'Style', 'text', 'String', 'Smoothing param', 'Units', 'characters', ...
        'HorizontalAlignment', 'left', 'Tag', 'textSmoothParam');
    pos_textSmoothParam = [2, 1, 20, 1.5];
    set(hTextSmoothParam, 'Position', pos_textSmoothParam);

    hEditSmoothParam = uicontrol('Parent', hDlgPanel, 'Style', 'edit', 'String', sprintf('%g', user_data.fit_params.smoothParam), 'Units', 'characters', ...
        'Tag', 'editSmoothParam');
    posEditSmoothParam = [pos_textSmoothParam(1) + pos_textSmoothParam(3) + 1, pos_textSmoothParam(2), 5, pos_textSmoothParam(4)];
    set(hEditSmoothParam, 'Position', posEditSmoothParam);
    
    % unvisible since not used
    set([hTextSmoothParam, hEditSmoothParam], 'Visible', 'off');
    
    % fit fraction
    hTextFitFraction = uicontrol('Parent', hDlgPanel, 'Style', 'text', 'String', '% of peak to fit', 'Units', 'characters', ...
        'HorizontalAlignment', 'left', 'Tag', 'textFitFraction');
    pos_textFitFraction = [pos_textSmoothParam(1), pos_textSmoothParam(2) + pos_textSmoothParam(4) + 0.5, 15, pos_textSmoothParam(4)];
    set(hTextFitFraction, 'Position', pos_textFitFraction);
    
    hEditFitFraction = uicontrol('Parent', hDlgPanel, 'Style', 'edit', 'String', sprintf('%g', user_data.fit_params.fitFraction), 'Units', 'characters', ...
        'Tag', 'editFitFraction', 'HorizontalAlignment', 'right');
    pos_editFitFraction = [posEditSmoothParam(1), pos_textFitFraction(2), 5, pos_textFitFraction(4)];
    set(hEditFitFraction, 'Position', pos_editFitFraction);
    
    % finding range
    if (strcmp(user_data.ev_or_nm, 'eV'))
        sFormat = '%2.4f';
    else
        sFormat = '%4.2f';
    end
        
    hTextFindingRange = uicontrol('Parent', hDlgPanel, 'Style', 'text', 'String', ['Peak finding range (',user_data.ev_or_nm,')'] , 'Units', 'characters', ...
        'HorizontalAlignment', 'left', 'Tag', 'textFindingRange');
    pos_textFindingRange = [posEditSmoothParam(1) + posEditSmoothParam(3) + 5, posEditSmoothParam(2), 23, posEditSmoothParam(4)];
    set(hTextFindingRange, 'Position', pos_textFindingRange);
    
    
    hEditFindingRangeMin = uicontrol('Parent', hDlgPanel, 'Style', 'edit', 'String', sprintf(sFormat, user_data.fit_params.finding_range.min), 'Units', 'characters', ...
        'Tag', 'editFindingRangeMin', 'HorizontalAlignment', 'right');
    pos_editFindingRangeMin = [pos_textFindingRange(1) + pos_textFindingRange(3) + 1, pos_textFindingRange(2), 10, pos_textFindingRange(4)];
    set(hEditFindingRangeMin, 'Position', pos_editFindingRangeMin);
    
    
    hEditFindingRangeMax = uicontrol('Parent', hDlgPanel, 'Style', 'edit', 'String', sprintf(sFormat, user_data.fit_params.finding_range.max), 'Units', 'characters', ...
        'Tag', 'editFindingRangeMax', 'HorizontalAlignment', 'right');
    pos_editFindingRangeMax = [pos_editFindingRangeMin(1) + pos_editFindingRangeMin(3) + 0.5, pos_editFindingRangeMin(2), ...
                               pos_editFindingRangeMin(3:4)];
    set(hEditFindingRangeMax, 'Position', pos_editFindingRangeMax);
    
    
    % method selection combo box
    methods = nmssResetPeakFindingParam('methods');
    h_cbFindingMethod = uicontrol('Parent', hDlgPanel, 'Style', 'popupmenu', 'String', {methods{:,2}}', 'Units', 'characters', ...
        'Tag', 'cbFindingMethod', 'Callback', @On_cbFindingMethod);
    pos_cbFindingMethod = [pos_textFitFraction(1), pos_textFitFraction(2) + pos_textFitFraction(4) + 0.5, 30, pos_editFitFraction(4)];
    set(h_cbFindingMethod, 'Position', pos_cbFindingMethod);
    for i=1:length(get(h_cbFindingMethod, 'String'))
        if(strcmp(methods{i,1}, user_data.fit_params.method))
            set(h_cbFindingMethod, 'Value', i);
            break;
        end
    end
            
            
    
    % fitting range
    hTextFittingRange = uicontrol('Parent', hDlgPanel, 'Style', 'text', 'String', ['Peak fitting range (',user_data.ev_or_nm,')'] , 'Units', 'characters', ...
        'HorizontalAlignment', 'left','Tag', 'textFittingRange');
    pos_textFittingRange = [pos_textFindingRange(1), pos_textFindingRange(2) + pos_textFindingRange(4) + 0.5, pos_textFindingRange(3:4)];
    set(hTextFittingRange, 'Position', pos_textFittingRange);
    
    
    hEditFittingRangeMin = uicontrol('Parent', hDlgPanel, 'Style', 'edit', 'String', sprintf(sFormat, user_data.fit_params.fit_range.min), 'Units', 'characters', ...
        'Tag', 'editFittingRangeMin', 'HorizontalAlignment', 'right');
    pos_editFittingRangeMin = [pos_textFittingRange(1) + pos_textFittingRange(3) + 1, pos_textFittingRange(2), pos_editFindingRangeMin(3:4)];
    set(hEditFittingRangeMin, 'Position', pos_editFittingRangeMin);
    
    
    hEditFittingRangeMax = uicontrol('Parent', hDlgPanel, 'Style', 'edit', 'String', sprintf(sFormat, user_data.fit_params.fit_range.max), 'Units', 'characters', ...
        'Tag', 'editFittingRangeMax', 'HorizontalAlignment', 'right');
    pos_editFittingRangeMax = [pos_editFittingRangeMin(1) + pos_editFittingRangeMin(3) + 0.5, pos_editFittingRangeMin(2), ...
                               pos_editFittingRangeMin(3:4)];
    set(hEditFittingRangeMax, 'Position', pos_editFittingRangeMax);
    
    
    % text: min and max
    hTextMin = uicontrol('Parent', hDlgPanel, 'Style', 'text', 'String', 'min' , 'Units', 'characters', ...
        'HorizontalAlignment', 'left');
    pos_textMin = [pos_editFittingRangeMin(1), pos_editFittingRangeMin(2) + pos_editFittingRangeMin(4), 6, 1];
    set(hTextMin, 'Position', pos_textMin);
    
    hTextMax = uicontrol('Parent', hDlgPanel, 'Style', 'text', 'String', 'max' , 'Units', 'characters', ...
        'HorizontalAlignment', 'left');
    pos_textMax = [pos_editFittingRangeMax(1), pos_editFittingRangeMax(2) + pos_editFittingRangeMax(4), pos_textMin(3:4)];
    set(hTextMax, 'Position', pos_textMax);
    
    % the panel size
    posPanel = get(hDlgPanel, 'Position');
    
    posPanel([1,2]) = [posPbOK(1), posPbOK(2) + posPbOK(4) + 0.5];
    
    hor_size = pos_editFittingRangeMax(1)  + pos_editFittingRangeMax(3);
    posPanel(3) = hor_size + 2;
    
    ver_size = pos_cbFindingMethod(2) + pos_cbFindingMethod(4) + 0.5; % as long the edit control is the most upper element this will always work
    posPanel(4) = ver_size;
    
    set(hDlgPanel, 'Position', posPanel);
    
    
    
    % set edit and popupmenu background color
    hBackgroundControls = findobj(hDlgPanel, 'Type', 'uicontrol', '-and', 'Style', 'edit', '-or', 'Style', 'popupmenu');
    set(hBackgroundControls,'BackgroundColor','white');

    
    % the figure size
    hor_size = posPanel(1)  + posPanel(3) + 0.5;
    figPos(3) = hor_size + 2;
    
    ver_size = posPanel(2) + posPanel(4) + 1; % as long the edit control is the most upper element this will always work
    figPos(4) = ver_size;
    
    set(hFig, 'Position', figPos);
    
    % perform further initialization
    On_cbFindingMethod(h_cbFindingMethod, []);
    
    
function On_cbFindingMethod(src, evnt)

%     h_cbFindingMethod = src;
%     hFig = ancestor(h_cbFindingMethod, 'figure', 'toplevel');
%     
%     methods = nmssResetPeakFindingParam('methods');
%     cur_method = methods{get(h_cbFindingMethod, 'Value'), 1};
%     
%     h_editFitFraction = findobj(hFig, 'Tag', 'editFitFraction');
%     h_textFitFraction = findobj(hFig, 'Tag', 'textFitFraction');
%     
%     if (strcmp(cur_method, 'fit_parabola_on_top_part_of_peak'))
%         set(h_editFitFraction, 'Enable', 'on');
%         set(h_textFitFraction, 'Enable', 'on');
%     else
%         set(h_editFitFraction, 'Enable', 'off');
%         set(h_textFitFraction, 'Enable', 'off');
%     end
    

    
function CancelFcn(src, evnt)

    hFig = ancestor(src, 'figure', 'toplevel');
    CloseFigure(hFig)
    
    
function CloseFigure(src, varargin)
    set(src, 'Visible', 'off');
    
% --- Executes on key press over nmssFigure with no controls selected.
function FigureKeyPressedCallback(hFig, evnt)
    % src    handle to nmssFigure (see GCBO)
    % eventdata  - a structure which contains necessary infromations about the
    % key event. eventdata.Modifier = 'alt', 'ctrl', 'shift' etc..
    % eventdata.Key = the name of the key, that is pressed

    if (strcmp(evnt.Key,'return'))
        OKFcn(hFig, evnt);
    else
%          disp('Key pressed:');
%          disp(evnt);
    end
    
    
%
function OKFcn(src, evnt)
    
    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    param = user_data.fit_params;
    
    % smoothing param
    h_editSmoothParam = findobj(hFig, 'Tag', 'editSmoothParam');
    h_textSmoothParam = findobj(hFig, 'Tag', 'textSmoothParam');
    if (nmssValidateNumericEdit(h_editSmoothParam, get(h_textSmoothParam, 'String')))
        param.smoothParam = str2num(get(h_editSmoothParam, 'String'));
    else
        return;
    end
    
    % fit fraction param
    h_editFitFraction = findobj(hFig, 'Tag', 'editFitFraction');
    h_textFitFraction = findobj(hFig, 'Tag', 'textFitFraction');
    if (nmssValidateNumericEdit(h_editFitFraction, get(h_textFitFraction, 'String')))
        param.fitFraction = str2num(get(h_editFitFraction, 'String'));
    else
        return;
    end
    
    % finding range
    h_editFindingRangeMin = findobj(hFig, 'Tag', 'editFindingRangeMin');
    h_textFindingRange = findobj(hFig, 'Tag', 'textFindingRange');
    if (nmssValidateNumericEdit(h_editFindingRangeMin, [get(h_textFindingRange, 'String'), ' min']))
        param.finding_range.min = str2num(get(h_editFindingRangeMin, 'String'));
    else
        return;
    end
    
    h_editFindingRangeMax = findobj(hFig, 'Tag', 'editFindingRangeMax');
    h_textFindingRange = findobj(hFig, 'Tag', 'textFindingRange');
    if (nmssValidateNumericEdit(h_editFindingRangeMax, [get(h_textFindingRange, 'String'), ' max']))
        param.finding_range.max = str2num(get(h_editFindingRangeMax, 'String'));
    else
        return;
    end
    
    % check if data is reasonable
    if (param.finding_range.max < param.finding_range.min)
        uiwait(errordlg([get(h_textFindingRange, 'String'), ' max must be larger than min']));
        return;
    end
    
    % check if data is in the allowed range
    if (param.finding_range.max > max(user_data.x_axis))
        param.finding_range.max = max(user_data.x_axis);
    end
        
    if (param.finding_range.min < min(user_data.x_axis))
        param.finding_range.min = min(user_data.x_axis);
    end
    
    
    % fitting range
    h_editFittingRangeMin = findobj(hFig, 'Tag', 'editFittingRangeMin');
    h_textFittingRange = findobj(hFig, 'Tag', 'textFittingRange');
    if (nmssValidateNumericEdit(h_editFittingRangeMin, [get(h_textFittingRange, 'String'), ' min']))
        param.fit_range.min = str2num(get(h_editFittingRangeMin, 'String'));
    else
        return;
    end
    
    h_editFittingRangeMax = findobj(hFig, 'Tag', 'editFittingRangeMax');
    h_textFittingRange = findobj(hFig, 'Tag', 'textFittingRange');
    if (nmssValidateNumericEdit(h_editFittingRangeMax, [get(h_textFittingRange, 'String'), ' max']))
        param.fit_range.max = str2num(get(h_editFittingRangeMax, 'String'));
    else
        return;
    end
    
    % check if data is reasonable
    if (param.fit_range.max < param.fit_range.min)
        uiwait(errordlg([get(h_textFittingRange, 'String'), ' max must be larger than min']));
        return;
    end
    
    % check if data is in the allowed range
    if (param.fit_range.max > max(user_data.x_axis))
        param.fit_range.max = max(user_data.x_axis);
    end
        
    if (param.fit_range.min < min(user_data.x_axis))
        param.fit_range.min = min(user_data.x_axis);
    end
    
        
        
    
    
    % peak finding method
    methods = nmssResetPeakFindingParam('methods');
    h_cbFindingMethod = findobj(hFig, 'Tag', 'cbFindingMethod');
    param.method = methods{get(h_cbFindingMethod, 'Value'), 1};
    
    % update dialog data
    user_data.fit_params = param;
    % conversion to eV
    if (~strcmp(user_data.ev_or_nm, 'eV'))
        user_data.fit_params.fit_range.min = 1240 / param.fit_range.max;
        user_data.fit_params.fit_range.max = 1240 / param.fit_range.min;
        user_data.fit_params.finding_range.min = 1240 / param.finding_range.max;
        user_data.fit_params.finding_range.max = 1240 / param.finding_range.min;
    end
    
    % apply to all graphs checkbox
    h_cxApplyToAll = findobj(hFig, 'Tag', 'cxApplyToAll');
    user_data.apply_to_all = get(h_cxApplyToAll, 'Value');
    
    user_data.user_action = 'OK'; % ok function successfully processed

    set(hFig, 'UserData', user_data);
    
    CloseFigure(hFig);
    
    
    