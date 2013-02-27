% call:
% nmssSPECInit(handles) - where
% handles - the handles structure of the main application (nmss)
%function specinfo = nmssSPECInit(handles)
function [hSpectrograph specinfo] = nmssSPECInit()

    hSpectrograph = -1;
    specinfo.Name = 'No spectrograph found';
    specinfo.ListOfGratings = {1, 'No Grating'};
    specinfo.CurrentGratingIndex = 1;
    specinfo.CurrentWavelength = 0;
    
    global use_hardware;
    
    % initilaize spectrograph and get the ID-handle and enable or disable the
    % corresponding GUIs
    if (use_hardware)
        [status val] = nmssSPECConnect();
        if (strcmp(status, 'ERROR')) 
            errordlg(val);
            return;
        else
            hSpectrograph = val;
        end

        % get spectrograph identification string (i.e. spectrograph name)
        [status serial_num] = nmssSPECGetSerialNum(hSpectrograph);


        % get the grating information and set the currently acitvated grating
        [status gratings] = nmssSPECGetListOfGratings(hSpectrograph);
        if (strcmp(status, 'ERROR')) 
            warndlg(gratings);
            return;
        else
            number_of_gratings = size(gratings, 1);

            specinfo.ListOfGratings = cell(number_of_gratings, 2);

            for i=1:number_of_gratings

                [status grating_density] = nmssSPECGetGratingDensity(hSpectrograph, gratings(i));
                if (strcmp(status, 'ERROR')) 
                    warndlg(grating_density);
                    return;
                else
                    % if you look it up in the documetation, you'll find, that
                    % a grating density of 1200 lines/mm is a mirror
                    specinfo.ListOfGratings{i, 1} = gratings(i);
                    if (grating_density == 1200)
                        specinfo.ListOfGratings{i, 2} = 'Mirror';
                    else
                        specinfo.ListOfGratings{i, 2} = [num2str(grating_density) ' lines/mm'];
                    end
                end
            end

            %set(handles.cxGratingSelect, 'String', specinfo.ListOfGratings{:,2} );

            % now get the current grating
            [status cur_grating] = nmssSPECGetCurrentGrating(hSpectrograph);
            if (strcmp(status, 'ERROR')) 
                errordlg(cur_grating);
                return;
            else
                % go through all grating
                for i=1:number_of_gratings
                    % find the grating index in the list of gratings
                    if (cur_grating == specinfo.ListOfGratings{i,1})
                        % update pop-up menu (combo box) with setting the
                        % appropriate entry
                        specinfo.CurrentGratingIndex =  i;
                    end
                end
            end


        end

        % set wavelength
        [status wavelength] = nmssSPECGetWavelength(hSpectrograph);
        if (strcmp(status, 'ERROR')) 
            errordlg(wavelength); % in case of error wavelength conatins the error string 
            return;
        else
            specinfo.CurrentWavelength = wavelength;
            %set(handles.editCentralWavelength, 'String', num2str(wavelength, '%4.1f'));
        end

        % get spectrograph identification string (i.e. spectrograph name)
        [status serial_num] = nmssSPECGetSerialNum(hSpectrograph);
        if (strcmp(status, 'ERROR')) 
            warndlg(serial_num);
            return;
        else
            %set(handles.textSpectrograph, 'String', val);
            specinfo.Name = serial_num;
        end
        
        % perform spectrograph initialization sequence
        % change grating
        disp(['Initializing spectrograph']);
        disp(['Step 1']);
        [status wavelength] = nmssSPECSetWavelength(hSpectrograph, wavelength + 10);
        if (strcmp(status, 'ERROR')) 
            errordlg(wavelength); % in case of error wavelength conatins the error string 
            return;
        end
        disp(['Step 2']);
        [status wavelength] = nmssSPECSetWavelength(hSpectrograph, wavelength - 10);
        if (strcmp(status, 'ERROR')) 
            errordlg(wavelength); % in case of error wavelength conatins the error string 
            return;
        end
        disp(['Spectrograph initializing successful']);


    end % end if (use_hardware)
    
    
