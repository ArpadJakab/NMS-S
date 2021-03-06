function [user_action, doc_out] = nmssResultsViewFilterDlg( doc_in, varargin )
% doc = struct to contain input parameters

    % init figure data
    user_data.user_action = 'Cancel';
    user_data.doc = doc_in;
    
    hFig = figure;
    set(hFig, 'Units', 'characters', 'MenuBar', 'none', 'Resize', 'off', 'Name', 'Results Filter', ...
        'NumberTitle', 'off', 'CloseRequestFcn', @CloseFigure);
    
    set(hFig, 'WindowStyle', 'modal');
    
    % add callback for if user presses a key (for keyboard
    % shortcuts
    set(hFig, 'KeyPressFcn', @FigureKeyPressedCallback);
    set(hFig, 'UserData', user_data); % initialize default user action
    
    % SOMETHING HAPPENS HERE!
    % create gui here
    
    CreateFigure(hFig);

    % wait until the visibility of the figure property changed to 'off' -
    % this happens in the CloseFigure procedure
    waitfor(hFig,'Visible', 'off');
    
    % return new parameter (or the old one is user pressed cancel)
    user_data = get(hFig, 'UserData');
    doc_out = user_data.doc;
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
    
    % add radiobutton group that controls the selection method
    %  replace : the filter results replace the old selection
    %  extend  : the filter results extend the old selection
    h_panelSelectionMethod = uibuttongroup('Parent', hFig, 'Title', '', 'Units', 'characters', 'Tag', 'panelSelectionMethod', ...
        'BorderType', 'none');
    
        h_rbReplaceCurrentSel = uicontrol('Parent', h_panelSelectionMethod, 'Style', 'radiobutton', 'String', 'Replace current selection', ...
            'Units', 'characters', 'Tag', 'rbReplaceCurrentSelection');
        posReplaceCurrentSel = [2, 1, 40, 1.5];
        set(h_rbReplaceCurrentSel, 'Position', posReplaceCurrentSel);
        
        h_rbExtendCurrentSel = uicontrol('Parent', h_panelSelectionMethod, 'Style', 'radiobutton', 'String', 'Extend current selection', ...
            'Units', 'characters', 'Tag', 'rbExtendCurrentSelection');
        posExtendCurrentSel = [posReplaceCurrentSel(1), posReplaceCurrentSel(2) + posReplaceCurrentSel(4), posReplaceCurrentSel(3), 1.5];
        set(h_rbExtendCurrentSel, 'Position', posExtendCurrentSel);
        
        h_rbRemoveFromCurrentSel = uicontrol('Parent', h_panelSelectionMethod, 'Style', 'radiobutton', 'String', 'Remove from current selection', ...
            'Units', 'characters', 'Tag', 'rbRemoveFromCurrentSel');
        posRemoveFromCurrentSel = [posExtendCurrentSel(1), posExtendCurrentSel(2) + posExtendCurrentSel(4), posExtendCurrentSel(3), 1.5];
        set(h_rbRemoveFromCurrentSel, 'Position', posRemoveFromCurrentSel);
        
        % initialize radiobuttons
        if (strcmp(user_data.doc.selection_method, 'replace'))
            set(h_rbReplaceCurrentSel, 'Value', 1);
            set(h_rbExtendCurrentSel, 'Value', 0);
            set(h_rbRemoveFromCurrentSel, 'Value', 0);
        elseif (strcmp(user_data.doc.selection_method, 'remove'))
            set(h_rbReplaceCurrentSel, 'Value', 0);
            set(h_rbExtendCurrentSel, 'Value', 0);
            set(h_rbRemoveFromCurrentSel, 'Value', 1);
        else
            set(h_rbReplaceCurrentSel, 'Value', 0);
            set(h_rbExtendCurrentSel, 'Value', 1);
            set(h_rbRemoveFromCurrentSel, 'Value', 0);
        end
    
    posPanelSelectionMethod = [posPbOK(1), posPbOK(2) + posPbOK(4), max([posRemoveFromCurrentSel(3), posRemoveFromCurrentSel(3)]), ...
                               posRemoveFromCurrentSel(2) + posRemoveFromCurrentSel(4)];
    set(h_panelSelectionMethod, 'Position', posPanelSelectionMethod);
        
    % add filter container panel
    hPanel(1) = Panel(hFig, 'Resonance Wavelength Range', 'panelResonanceWavelengthRange', ...
        user_data.doc.res_wl, 'nooperator');
    PanelCXCallback(findobj(hPanel(1), 'Tag', 'cxEnable'), []);
    hPanel(2) = Panel(hFig, 'FWHM Range', 'panelFWHMRange', user_data.doc.fwhm);
    PanelCXCallback(findobj(hPanel(2), 'Tag', 'cxEnable'), []);
    hPanel(3) = Panel(hFig, 'Peak Intensity', 'panelPeakIntensity', user_data.doc.peak_int);
    PanelCXCallback(findobj(hPanel(3), 'Tag', 'cxEnable'), []);
        
    % panel positions
    posPanel = zeros(length(hPanel),4);
    posPanel(end,:) = get(hPanel(end), 'Position');
    posPanel(end,[1,2]) = [posPanelSelectionMethod(1), posPanelSelectionMethod(2) + posPanelSelectionMethod(4) + 0.5];
    set(hPanel(end), 'Position', posPanel(end,:));
    for i=length(hPanel)-1:-1:1
        posPanel(i,:) = get(hPanel(i), 'Position');
        posPanel(i,[1,2]) = [posPanel(i+1,1), posPanel(i+1,2) + posPanel(i+1,4) + 0.5];
        set(hPanel(i), 'Position', posPanel(i,:));
    end
    
    
    
    
    % the figure size
    hor_size = max([posPbCancel(1)  + posPbCancel(3) + 2, posPanel(1, 1) + posPanel(1, 3)]);
    figPos(3) = hor_size + 2;
    
    ver_size = posPanel(1, 2) + posPanel(1, 4) + 1; % as long the edit control is the most upper element this will always work
    figPos(4) = ver_size;
    
    set(hFig, 'Position', figPos);
    
    
% creating a panel containing the filter elements 
function hPanel = Panel(hParentFig, sName, sTag, filter_param, varargin)    

    enable = filter_param.use;
    val_min = filter_param.min;
    val_max = filter_param.max;
    not_operator = filter_param.not;
    operation = filter_param.operation;

    hPanel = uipanel('Parent', hParentFig, 'Title', sName, 'Units', 'characters', 'Tag', sTag);
    hTextMin = uicontrol('Parent', hPanel, 'Style', 'text', 'String', 'min', 'Units', 'characters', ...
        'HorizontalAlignment', 'left');
    posTextMin = [2, 1, 6, 1.5];
    set(hTextMin, 'Position', posTextMin);
    
    hEditMin = uicontrol('Parent', hPanel, 'Style', 'edit', 'String', sprintf('%g', val_min), 'Units', 'characters', ...
        'Tag', 'editMin');
    posEditMin = [posTextMin(1) + posTextMin(3) + 1, posTextMin(2), 10, posTextMin(4)];
    set(hEditMin, 'Position', posEditMin);
    
    hTextMax = uicontrol('Parent', hPanel, 'Style', 'text', 'String', 'max', 'Units', 'characters', ...
        'HorizontalAlignment', 'left');
    posTextMax = [posEditMin(1) + posEditMin(3) + 3, posTextMin(2), posTextMin(3), posTextMin(4)];
    set(hTextMax, 'Position', posTextMax);
    
    hEditMax = uicontrol('Parent', hPanel, 'Style', 'edit', 'String', sprintf('%g', val_max), 'Units', 'characters', ...
        'Tag', 'editMax');
    posEditMax = [posTextMax(1) + posTextMax(3) + 1, posTextMin(2), posEditMin(3), posEditMin(4)];
    set(hEditMax, 'Position', posEditMax);
    
    hCXEnable = uicontrol('Parent', hPanel, 'Style', 'checkbox', 'String', 'Enable', 'Units', 'characters', ...
        'Tag', 'cxEnable');
    posCXEnable = [posTextMin(1), posTextMin(2) + 2, 12, posTextMin(4)];
    set(hCXEnable, 'Position', posCXEnable);
    
    hCBOperation = uicontrol('Parent', hPanel, 'Style', 'popupmenu', 'String', {'AND'; 'OR'}, 'Units', 'characters', ...
        'Tag', 'cbOperation');
    posCBOperation = [posCXEnable(1) + posCXEnable(3) + 3, posCXEnable(2), 10, posCXEnable(4)];
    set(hCBOperation, 'Position', posCBOperation);

    hCXNot = uicontrol('Parent', hPanel, 'Style', 'checkbox', 'String', 'NOT', 'Units', 'characters', ...
        'Tag', 'cxNOT', 'Max', 1, 'Min', 0);
    posCXNot = [posCBOperation(1) + posCBOperation(3) + 3, posCBOperation(2), 10, posCBOperation(4)];
    set(hCXNot, 'Position', posCXNot);
    
    % arrange gui elements
    posPanel = get(hPanel, 'Position');
    
    % the panel size
    hor_size = max([posEditMax(1)  + posEditMax(3), posCXNot(1) + posCXNot(3)]);
    posPanel(3) = hor_size + 2;
    
    ver_size = posCXEnable(2) + posCXEnable(4) + 2; % as long the edit control is the most upper element this will always work
    posPanel(4) = ver_size;
    
    set(hPanel, 'Position', posPanel);
    
    % register some action callbacks and initalize GUI elements
    set(hCXEnable, 'Callback', @PanelCXCallback, 'Value', enable);
    
    % combobox:
        % set operator selection combobox invisible, if it is requested
        if (length(varargin) >= 1 && strcmp(varargin{1},'nooperator'))
            set(hCBOperation, 'Visible', 'off');
        end
        % activate operation method
        sOperationList = get(hCBOperation, 'String');
        for i=1:length(sOperationList)
            if (strcmp(operation, sOperationList(i)))
                set(hCBOperation, 'Value', i);
                break;
            end
        end
    
    set(hCXNot, 'Value', not_operator);
    
    % set edit and popupmenu background color
    hBackgroundControls = findobj(hPanel, 'Type', 'uicontrol', '-and', 'Style', 'edit', '-or', 'Style', 'popupmenu');
    set(hBackgroundControls,'BackgroundColor','white');
    
    
    
    
function PanelCXCallback(src, evnt)
    hCXEnable = src;
    hPanel = ancestor(hCXEnable, 'uipanel');
    
    bgColorEnabled = 'white';
    bgColorDisabled = [0.8, 0.8, 0.8]; % some sort of grey
    
    
    if (get(hCXEnable, 'Value'))
        hUIControls = findobj(hPanel, 'Type', 'uicontrol');
        hUIControlsToProcess = hUIControls(find(hUIControls ~= hCXEnable));
        set(hUIControlsToProcess, 'Enable', 'on');
         set(findobj(hUIControlsToProcess, 'Style', 'edit'), 'BackgroundColor', bgColorEnabled);
   else
        hUIControls = findobj(hPanel, 'Type', 'uicontrol');
        hUIControlsToProcess = hUIControls(find(hUIControls ~= hCXEnable));
        set(hUIControlsToProcess, 'Enable', 'off');
        set(findobj(hUIControlsToProcess, 'Style', 'edit'), 'BackgroundColor', bgColorDisabled);
    end
        
        
    
        
function CancelFcn(src, evnt)

    hFig = ancestor(src, 'figure', 'toplevel');
    CloseFigure(hFig)
    
function OKFcn(src, evnt)
    
    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    
    hPanel(1) = findobj(hFig, 'Tag', 'panelResonanceWavelengthRange');
    [res_wl, error] = GetPanelParams(hPanel(1), user_data.doc.res_wl);
    if (error) return; end;
    user_data.doc.res_wl = res_wl;
    
    hPanel(2) = findobj(hFig, 'Tag', 'panelFWHMRange');
    [fwhm , error] = GetPanelParams(hPanel(2), user_data.doc.fwhm);
    if (error) return; end;
    user_data.doc.fwhm = fwhm;
    
    hPanel(3) = findobj(hFig, 'Tag', 'panelPeakIntensity');
    [peak_int , error] = GetPanelParams(hPanel(3), user_data.doc.peak_int);
    if (error) return; end;
    user_data.doc.peak_int = peak_int;
    
    % selection method radio buttons
    h_rbReplaceCurrentSel = findobj(hFig, 'Tag', 'rbReplaceCurrentSelection');
    h_rbExtendCurrentSelection = findobj(hFig, 'Tag', 'rbExtendCurrentSelection');
    if (get(h_rbReplaceCurrentSel, 'Value'))
        user_data.doc.selection_method = 'replace';
    elseif (get(h_rbExtendCurrentSelection, 'Value'))
        user_data.doc.selection_method = 'extend';
    else
        user_data.doc.selection_method = 'remove';
    end
    
    user_data.user_action = 'OK'; % ok function successfully processed

    set(hFig, 'UserData', user_data);
    
    CloseFigure(hFig);

function [param, error] = GetPanelParams(hPanel, old_param)

    error = true;
    param = old_param;

    hEditMin = findobj(hPanel, 'Tag', 'editMin');
    if (nmssValidateNumericEdit(hEditMin, 'min'))
        param.min = str2num(get(hEditMin, 'String'));
    else
        return;
    end
    
    hEditMax = findobj(hPanel,'Tag', 'editMax');
    if (nmssValidateNumericEdit(hEditMax, 'max'))
        param.max = str2num(get(hEditMax, 'String'));
    else
        return;
    end
    
    hCXEnable = findobj(hPanel, 'Tag', 'cxEnable');
    param.use = get(hCXEnable, 'Value');
    
    hCBOperation = findobj(hPanel, 'Tag', 'cbOperation');
    sOperations = get(hCBOperation, 'String');
    param.operation = sOperations{get(hCBOperation, 'Value')};

    hCXNot = findobj(hPanel, 'Tag', 'cxNOT');
    param.not = get(hCXNot, 'Value');
    
    error = false;
    
    

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

