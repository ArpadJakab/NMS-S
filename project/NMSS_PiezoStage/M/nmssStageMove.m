function nmssStageMove(handles, hStage, new_X_pos, new_Y_pos)
% hObject    handle to btnStageMove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[status val] = nmssPSGetPosX(hStage);
if (strcmp(status, 'ERROR')) 
    warndlg(val);
    return
else
    stageNewPosX = str2num(get(handles.leStagePosX,'String'));
    [status val] = nmssPSSetPosX(hStage, stageNewPosX);
    if (strcmp(status, 'ERROR')) 
        warndlg(val);
        return
    end
end

[status val] = nmssPSGetPosY(hStage);
if (strcmp(status, 'ERROR')) 
    warndlg(val);
    return
else
    stageNewPosY = str2num(get(handles.leStagePosY,'String'));
    [status val] = nmssPSSetPosY(hStage, stageNewPosY);
    if (strcmp(status, 'ERROR')) 
        warndlg(val);
        return
    end
end
