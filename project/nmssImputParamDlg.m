function [user_action, new_param] = nmssImputParamDlg( sWindowBar, sParamText, param, varargin )
%nmssImputParamDlg - Opens a modal dialog for a number to be entered
%  sWindowBar = text to be displayed in the window bar
%  sParamText = text that describes the parameter (will be displayed left
%  to the parameter edit box)
%  param = the value to be displayed initially
%  varargin{1} = optional: comment text to explain the prupose of the
%  parameter in more detail

    new_param = param;
    
    % init figure data
    user_data.user_action = 'Cancel';
    user_data.new_param = param;
    user_data.old_param = param;
    
    if (length(varargin) >= 1)
        sComment = varargin{1};
    else
        sComment = ' ';
    end
    
    
    hFig = figure;
    set(hFig, 'Units', 'characters', 'MenuBar', 'none', 'Resize', 'off', 'Name', sWindowBar, ...
        'NumberTitle', 'off', 'WindowStyle', 'modal', 'CloseRequestFcn', @Close);
    % add callback for if user presses a key (for keyboard
    % shortcuts
    set(hFig, 'KeyPressFcn', @FigureKeyPressedCallback);
    set(hFig, 'UserData', user_data); % initialize default user action
        
    figPos = get(hFig, 'Position');
    
    hText = uicontrol('Parent', hFig, 'Style', 'text', 'String', sParamText, 'Units', 'characters', ...
        'HorizontalAlignment', 'left');
    hEdit = uicontrol('Parent', hFig, 'Style', 'edit', 'String', sprintf('%4d', param), 'Units', 'characters');
    % set edit background color
    if ispc
        set(hEdit,'BackgroundColor','white');
    else
        set(hEdit,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end
    
    hCommentText = uicontrol('Parent', hFig, 'Style', 'text', 'String', sComment, 'Units', 'characters', ...
        'HorizontalAlignment', 'left');

    h_pbOK = uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'OK', 'Units', 'characters', ...
        'Callback', @OKFcn);
    h_pbCancel = uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Cancel', 'Units', 'characters', ...
        'Callback', @CancelFcn);
    
    posText = get(hText, 'Position');
    posEdit = get(hEdit, 'Position');
    posCommentText = get(hCommentText, 'Position');
    posPbOK = get(h_pbOK, 'Position');
    posPbCancel = get(h_pbCancel, 'Position');
    
    % set sizes of elements
    % 1st row from below
    posPbOK([1:2]) = [2, 1];
    posPbCancel([1:2]) = [2 + posPbOK(3) + 1, 1];
    % 2nd row from below
    posCommentText([1,2,3,4]) = [2, posPbOK(2) + posPbOK(4) + 0.5, size(char(get(hCommentText, 'String')), 2), ...
        size(char(get(hCommentText, 'String')), 1)];
    % 3rd row from below
    posText([1,2,3]) = [2, posCommentText(2) + posCommentText(4) + 0.5, size(char(get(hText, 'String')), 2)];
    posEdit([1,2]) = [2 + posText(3) + 1, posCommentText(2) + posCommentText(4) + 0.5];
    
    set(h_pbOK, 'Position', posPbOK);
    set(h_pbCancel, 'Position', posPbCancel);
    set(hCommentText, 'Position', posCommentText);
    set(hText, 'Position', posText);
    set(hEdit, 'Position', posEdit);
    
    % the figure size
    hor_size = max([posPbCancel(1)  + posPbCancel(3) + 2, posEdit(1) + posEdit(3) + 2, posCommentText(1) + posCommentText(3)]);
    figPos(3) = hor_size * 1.1;
    
    ver_size = posEdit(2) + posEdit(4); % as long the edit control is the most upper element this will always work
    figPos(4) = ver_size * 1.1;
    
    set(hFig, 'Position', figPos);
    
    % wait until the visibility of the figure property changed to 'off' -
    % this happens in the Close procedure
    waitfor(hFig,'Visible', 'off');
    
    % return new parameter (or the old one is user pressed cancel)
    user_data = get(hFig, 'UserData');
    new_param = user_data.new_param;
    user_action = user_data.user_action;
    
    close(hFig);

    
function CancelFcn(src, evnt)

    hFig = ancestor(src, 'figure', 'toplevel');
    Close(hFig)
    
function OKFcn(src, evnt)

    hFig = ancestor(src, 'figure', 'toplevel');
    hEdit = findobj(hFig, 'Type', 'uicontrol', 'Style', 'edit');
    hText = findobj(hFig, 'Type', 'uicontrol', 'Style', 'text');
    
    if (nmssValidateNumericEdit(hEdit, get(hText, 'String')))
        user_data = get(hFig, 'UserData');
        user_data.new_param = str2num(get(hEdit, 'String'));
        user_data.user_action = 'OK';
        set(hFig, 'UserData', user_data);
        Close(hFig);
    end

 function Close(src, varargin)
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

    