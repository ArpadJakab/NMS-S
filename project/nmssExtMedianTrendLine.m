function [res_energy, fwhm] = nmssExtMedianTrendLine(berg_plot, start_eV, num_of_datapoints, stepsize_eV, percent_of_data_below_trend_line)
% creates a trendline for a berg plot by apporaching the data distribution
% from below. the trend line is created at the y-boundary, where the number of
% data points below the trend line is in average <percent_of_data_below_median> percent
% of the data points above the trend line. In case:
% percent_of_data_below_median == 50, then it reproduces the median!
%
% INPUT:
% berg_plot                 - the berg plot for which the trend line has to
%                             be calculated
% ** the next three parameters define the x-axis of the trend line
% start_eV                  - the starting energy
% num_of_datapoints         - number of data points on the x-axis
% stepsize_eV               - the size of the steps
%
% ** the next parameter defines the tolerance of the trend line
% percent_of_data_below_trend_line - the percent of data points below the
%                                    trend line.
%
% usage: 
% [x_axis, fwhm] = nmssExtMedianTrendLine(berg_plot, 1.65, 6, 0.05, 10)
%     this creates the trend line with x-values of 1.65, 1.7, 1.75, 1.8,
%     1.85, 1.9
%
% OUTPUT:
% x_axis                    - is the x_axis (definition range) of the function
% fwhm                      - the FWHM

    % ensure that we don't acces vector out of range
    if (percent_of_data_below_trend_line < 0.01)
        percent_of_data_below_trend_line = 0.01
    elseif (percent_of_data_below_trend_line > 100)
        percent_of_data_below_trend_line = 100
    end
    
    res_en_min = start_eV;
    res_en_max = res_en_min + (num_of_datapoints - 1) * stepsize_eV;
    
    % init return variables
    res_energy = zeros(1, num_of_datapoints);
    fwhm = zeros(1, num_of_datapoints);
    
    for k=1:num_of_datapoints
        trend_line_work.res_energy_min = res_en_min - stepsize_eV/2 + (k-1) * stepsize_eV;
        trend_line_work.res_energy_max = trend_line_work.res_energy_min + stepsize_eV;
        
                        
        % center of the interval
        res_energy(1,k) = (trend_line_work.res_energy_min + trend_line_work.res_energy_max) / 2;
        % the data in the interval
        data_in_range = berg_plot(find(berg_plot(:,1) >= trend_line_work.res_energy_min ...
                            & berg_plot(:,1) < trend_line_work.res_energy_max), 2);
                        
        if (~isempty(data_in_range))
            if (length(data_in_range) > 1)
                % find the contour line from below, where the number of
                % particles below the contour line is 10% of the particles
                % above the contour line
                
                data_in_range = sort(data_in_range);
                fwhm(1,k) = data_in_range(ceil(length(data_in_range) * percent_of_data_below_trend_line / 100));
                
            else
                fwhm(1,k) = data_in_range(1,1);
            end
        else
            fwhm(1,k) = NaN;
        end
        
    end
    
    % Now we deal with intervals where no data point has been found. here
    % we will interpolate or in case of the first or the last element
    % extrapolate
    
    % first value is a NaN
    if (isnan(fwhm(1,1)))
        for k=2:num_of_datapoints
            if (~isnan(fwhm(1,k)))
                fwhm(1,1) = fwhm(1,k);
                break;
            end
        end
    end
    
    % last value is a NaN
    tmp = fliplr(fwhm);
    if (isnan(tmp(1,1)))
        for k=2:num_of_datapoints
            if (~isnan(tmp(1,k)))
                fwhm(1,end) = tmp(1,k);
                break;
            end
        end
    end
    
    % if values in between are NaN(s)
    for k=2:num_of_datapoints - 1
        k_min = k-1;
        if (isnan(fwhm(1,k)))
            % find the next number which is not NaN
            k_max = k + find(~isnan( fwhm(1,k+1:end)));
            % get the weighted mean of the valid neighbouring values
            fwhm(1,k) = fwhm(1,k_min) * (k_max - k) / (k_max - k_min) + ...
                      + fwhm(1,k_max) * (k - k_min) / (k_max - k_min);
        end
    end
    
    %figure; plot(res_energy, fwhm, '.');
    
