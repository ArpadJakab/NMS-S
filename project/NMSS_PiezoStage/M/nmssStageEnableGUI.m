function nmssStageEnableGUI(handles, bEnable)
if (bEnable == true)
    set(handles.btnStageMvBack,'Enable','on');
    set(handles.btnStageMvLeft,'Enable','on');
    set(handles.btnStageMvRight,'Enable','on');
    set(handles.btnStageMvFront,'Enable','on');
    set(handles.leStageStepSize,'Enable','on');
    set(handles.leStagePosX,'Enable','on');
    set(handles.leStagePosY,'Enable','on');
    set(handles.btnStageMove,'Enable','on');
else
    set(handles.btnStageMvBack,'Enable','off');
    set(handles.btnStageMvLeft,'Enable','off');
    set(handles.btnStageMvRight,'Enable','off');
    set(handles.btnStageMvFront,'Enable','off');
    set(handles.leStageStepSize,'Enable','off');
    set(handles.leStagePosX,'Enable','off');
    set(handles.leStagePosY,'Enable','off');
    set(handles.btnStageMove,'Enable','off');
end


