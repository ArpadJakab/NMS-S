function [status handles] = nmssStageInit(handles)
% hObject    handle to btnStageMvLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% init nano stage and get its current position

% variable initialization
status = 'ERROR';
handles.stage_dX = 5;
handles.stage_dY = 5;
% handles.stagePosY = 0;
% handles.stagePosX = 0;
hanldes.stageMaxX = 200;
hanldes.stageMinX = 0;
hanldes.stageMaxY = 200;
hanldes.stageMinY = 0;

global app;

disp(['initializng stage: ' int2str(app.hStage)]);

[status val] = nmssPSGetPosX(app.hStage);
if (strcmp(status, 'ERROR')) 
    warndlg(val);
    return;
else
    set(handles.leStagePosX, 'String', num2str(val,'%3.1f'));
end

[status val] = nmssPSGetPosY(app.hStage);
if (strcmp(status, 'ERROR')) 
    warndlg(val);
    return;
else
    set(handles.leStagePosY, 'String', num2str(val,'%3.1f'));
end

status = 'OK';