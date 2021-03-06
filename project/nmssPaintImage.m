function [ output_args ] = nmssPaintImage( task, img, fig_handle, fig_axes, full_limits, current_limits )
% task - 'new' paints the image provided in img
%        'refresh' re-paints the image maintaining the colormap setting
% full_limits - struct containing full_limits.x and full_limit.y
%               full_limits.x - a row vector containing the lower and upper
%               limit of the x-axis which corresponds to the full image
%               full_limits.y - a row vector containing the lower and upper
%               limit of the y-axis which corresponds to the full image.
%               These limits can be definied in abitrary units, in our case
%               it is either pixels of microns or nanometers
% current_limits - struct containing current_limits.x and current_limits.y
%               current_limits.x - a row vector containing the lower and upper
%               limit of the x-axis which corresponds to the current view
%               of the image (can be equal to full_limits.x) 
%               current_limits.y - a row vector containing the lower and upper
%               limit of the y-axis which corresponds to the current view
%               of the image (can be equal to full_limits.y) 
%               These limits can be definied in abitrary units, but have to
%               match the units of full_limits
    if (strcmp(task, 'new'))
        nmssPaintNewImage(img, fig_handle, fig_axes, full_limits, current_limits);
    end

    if (strcmp(task, 'refresh'))
        nmssRefreshImage(img, fig_handle, fig_axes, full_limits, current_limits);
    end


end

function nmssPaintNewImage(img, fig_handle, fig_axes, full_limits, current_limits)
% paints image with the standard gray-scale colormap
    %colormap(gray(2^10));
    colormap('gray');
    nmssRefreshImage(img, fig_handle, fig_axes, full_limits, current_limits);
end
    
function nmssRefreshImage(img, fig_handle, fig_axes, full_limits, current_limits)
    
    nmssRefreshImage_method(img, fig_handle, fig_axes, full_limits, current_limits );
end

    
%function nmssRefreshImage_method(img, fig_handle, fig_axes, scaling_factor )
function nmssRefreshImage_method(img, fig_handle, fig_axes, full_limits, current_limits )
% refreshes image displayed in figure    
    figure(fig_handle);
    
    if (size(img,2) <= 1)
        text(10, 10, 'No image to display');
    else

        % get current colormap
        cmp = colormap;
        
        % find image in the axes
        hImage = findobj(fig_axes, 'Type', 'image', 'Tag', 'camera_image');
        
        % display new image
        if (ishandle(hImage))
            % if image object is already present, just replace the data
            set(hImage, 'CData', img);
        else
            % if no image object present: create it!
            hImage = imagesc(full_limits.x, full_limits.y , img);
            
            % tag the image, so we can diwtinguish from other images
            set(hImage, 'Tag', 'camera_image');
        end
         
        xlim(fig_axes, current_limits.x);
        ylim(fig_axes, current_limits.y);

        colormap(cmp);
        
        % remember the durrently displayed image
        global doc;
        doc.img = img;
    end
    
end