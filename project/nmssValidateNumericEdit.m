function valid = nmssValidateNumericEdit(handle_edit, edit_name)
% returns false if edit window content is not a number

% stops script execution and rejects every user interactions (exept the
% error dialog itself until pressing OK or x

    %disp(handle_edit);
    number = str2double(get(handle_edit,'String'));
    % proceed only if a valid numeric value has been entered
    valid = true;

     if (isnan(number))
         hErrdlg = errordlg(['Please enter a valid number for ' edit_name '!'])
         set(hErrdlg,'WindowStyle','modal')
         uiwait(hErrdlg);
         
         valid = false;
         uicontrol(handle_edit);
     end

