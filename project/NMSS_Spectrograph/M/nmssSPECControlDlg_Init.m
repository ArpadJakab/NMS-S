% call:
% nmssSPECInit(handles) - where
% handles - the handles structure of the main application (nmss)
function specinfo = nmssSPECControlDlg_Init(handles)


% initilaize spectrograph and get the ID-handle and enable or disable the
% corresponding GUIs
specinfo.hSpectrograph = 0;
specinfo.Name = 'No spectrograph found';
specinfo.ListOfGratings = {};
specinfo.CurrentGratingIndex = 0;
specinfo.CurrentWavelength = 0;


    disp(['Spectrograph controller handle: ' int2str(specinfo.hSpectrograph)]);    
    
    
    % get spectrograph identification string (i.e. spectrograph name)
    [status val] = nmssSPECGetSerialNum(specinfo.hSpectrograph);
    if (strcmp(status, 'ERROR')) 
        warndlg(val);
    else
        %set(handles.textSpectrograph, 'String', val);
        specinfo.Name = val;
    end
    
    % get the grating information and set the currently acitvated grating
    [status gratings] = nmssSPECGetListOfGratings(specinfo.hSpectrograph);
    if (strcmp(status, 'ERROR')) 
        warndlg(gratings);
        return;
    else
        number_of_gratings = size(gratings);
        
        specinfo.ListOfGratings = cell(number_of_gratings, 2);
        
        for i=1:number_of_gratings
            
            [status grating_density] = nmssSPECGetGratingDensity(specinfo.hSpectrograph, gratings(i));
            if (strcmp(status, 'ERROR')) 
                warndlg(grating_density);
                return;
            else
                % if you look it up in the documetation, you'll find, that
                % a grating density of 1200 lines/mm is a mirror
                specinfo.ListOfGratings{i, 1} = gratings(i);
                if (grating_density == 1200)
                    specinfo.ListOfGratings{i, 2} = {'Mirror'};
                else
                    specinfo.ListOfGratings{i, 2} = {[num2str(grating_density) ' lines/mm']};
                end
            end
        end
        
        %set(handles.cxGratingSelect, 'String', specinfo.ListOfGratings{:,2} );
        
        % now get the current grating
        [status cur_grating] = nmssSPECGetCurrentGrating(specinfo.hSpectrograph);
        if (strcmp(status, 'ERROR')) 
            errordlg(cur_grating);
            return;
        else
            specinfo.CurrentGratingIndex = cur_grating;
%             % go through all grating
%             for i=1:number_of_gratings
%                 % find the grating index in the list of gratings
%                 if (cur_grating == gratings(i))
%                     % update pop-up menu (combo box) with setting the
%                     % appropriate entry
%                     set(handles.cxGratingSelect, 'Value', i );
%                 end
%             end
        end
        
        
    end
    
    % set wavelength
    [status wavelength] = nmssSPECGetWavelength(specinfo.hSpectrograph);
    if (strcmp(status, 'ERROR')) 
        errordlg(wavelength);
        return;
    else
        specinfo.CurrentWavelength = wavelength;
        %set(handles.editCentralWavelength, 'String', num2str(wavelength, '%4.1f'));
    end
    


