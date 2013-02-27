function [berg_matrix, x_axis, y_axis] = nmssCreateBergMatrix(berg_plot, num_of_datapoints_x, num_of_datapoints_y)
% This function lays a rectangular mesh over the region definied by the
% definition range and the value range of the berg_plot. The number of mesh
% elements can be set by the two input parameters: num_of_datapoints_x,
% num_of_datapoints_y.
%  
% Each matrix element of the output berg_matrix will have the number of the data points
% found in the corresponding mesh element.
% 
% [berg_matrix, x_axis, y_axis] = CreateBergMatrix(berg_plot, num_of_datapoints_x, num_of_datapoints_y)
%
% Input parameters:
% berg_plot           - a m x 2 matrix, where column #1 contains the resonance energy
%                       (x-axis) and column #2 contains the FWHM values (function values)
% num_of_datapoints_x - the number of columns of the matrix
% num_of_datapoints_y - the number of rows of the matrix
%
% Output parameters:
% berg_matrix - the matrix where each matrix element contains the
%               number of data points located in the given rectangular region
% x_axis      - the x-axis of the matrix
% y_axis      - the y-axis of the matrix
%
% You can visualize the output by calling:
% contour(x_axis, y_axis, berg_matrix)

    xmax = max(berg_plot(:,1));
    xmin = min(berg_plot(:,1));
    xstepsize = (xmax - xmin) / (num_of_datapoints_x + 1);
    % starting and end points of the intervalls x-axis
    xout = [xmin:xstepsize:xmax];
    x_axis = zeros(1, num_of_datapoints_x);

    ymax = max(berg_plot(:,2));
    ymin = min(berg_plot(:,2));
    ystepsize = (ymax - ymin) / (num_of_datapoints_y + 1);
    % starting and end points of the intervalls y-axis
    yout = [ymin:ystepsize:ymax];
    y_axis = zeros(1, num_of_datapoints_y);
    
    berg_matrix = zeros(num_of_datapoints_y, num_of_datapoints_x);
    
    for j = 1:num_of_datapoints_x
        
        data_index_in_range_x = find(berg_plot(:,1) >= xout(1,j) ...
                                   & berg_plot(:,1) < xout(1,j+1));
        x_axis(1,j) = (xout(1,j) + xout(1,j+1)) / 2
        
        for i = 1:num_of_datapoints_y
            
            data_index_in_range_y =  find(berg_plot(data_index_in_range_x,2) >= yout(1,i) ...
                                        & berg_plot(data_index_in_range_x,2) < yout(1,i+1));
            
            y_axis(1,i) = (yout(1,i) + yout(1,i+1)) / 2
            berg_matrix(i, j) = length(data_index_in_range_y);
        end
    end
    