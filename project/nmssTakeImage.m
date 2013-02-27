
function [status camera_image] = nmssTakeImage(hCam, expTime, num_of_exposures, waitbar_handle)
% performs an image acquisition
% returns the image
% input parameters:
%    hCam - the handle of the camera (it is an integer number)
%    expTime - the time of exposure in ms
    
    if (expTime < 5)
        errordlg('Please enter a number greater than 5!');
        return;
    end
    
    camera_image = zeros(1340,400,'uint16');

    % (multiple) exposure
    for i=1:num_of_exposures
    
    
        %pause(0.05);
        [status tmp_image] = nmssCAMGetImage(hCam, 1,1,1340,400,1,1,expTime,0);
        
        
        if (strcmp(status, 'ERROR')) 
            errordlg(tmp_image);
            return;
        end
        
%         if (length(camera_image) == 0)
%             camera_image = cast(zeros(size(tmp_image)), 'uint32');
%         end

        % add up images - this overcomes the saturation problem of the
        % CCD-camera
        %camera_image = camera_image + cast(tmp_image,'uint32');
        camera_image = camera_image + cast(tmp_image/num_of_exposures, 'uint16');
        
        if (waitbar_handle ~= -1)
            waitbar(i/num_of_exposures, waitbar_handle);
        end
        
    end
    
    camera_image = fliplr(camera_image);
    
