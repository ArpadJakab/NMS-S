function [status val] = getImg(hCam)

% acquire an image with 10ms expsure time
[status val] = nmssCAMGetImage(hCam,1,1,1340,400,1,1,10,1);

disp (status);

if (strcmp(status, 'ERROR'))
    % display error message
    disp(val);
else
    % display image (needs to be transposed before displaying)
    hold off;
    % autoscale image color palette
    colormap 'gray';
    hold on;

    imagesc(val');
end

