function [peak_max_pos, peak_FWHM, peak_max_int] = nmssMultiPeakAnalizer(corr_part, peak_valley_pos_nm)
    peak_max_pos.b = [];
    peak_max_pos.r = [];
    peak_FWHM.b = [];
    peak_FWHM.r = [];
    peak_max_int.b = [];
    peak_max_int.r = [];

    l_corr_part = length(corr_part);
    for i=1:l_corr_part
        p = corr_part(i);
        
        l_pdata = length(p.pdata);
        
        % loop through all graphs and find max
        for j=1:l_pdata
            pd = p.pdata{j};
            x = pd.graph.axis.x;
            % vector indices corresponding to the blue and red part of the
            % spectrum
            ix_blue_peak = find(x < peak_valley_pos_nm);
            ix_red_peak = find(x >= peak_valley_pos_nm);
            
            % let's take the blue peak
            [b_peak_max, b_peak_FWHM, b_peak_max_int, fit_x, fit_y, str_errmsg] = ...
                nmssGetMaxAndFWHM(pd.graph.normalized(ix_blue_peak), ...
                                  pd.graph.smoothed(ix_blue_peak), ...
                                  pd.graph.axis.x(ix_blue_peak), 0);
            
            % let's take the red peak
            [r_peak_max, r_peak_FWHM, r_peak_max_int, fit_x, fit_y, str_errmsg] = ...
                nmssGetMaxAndFWHM(pd.graph.normalized(ix_red_peak), ...
                                  pd.graph.smoothed(ix_red_peak), ...
                                  pd.graph.axis.x(ix_red_peak), 0);
                              
            peak_max_pos.b(i,j) = b_peak_max;
            peak_max_pos.r(i,j) = r_peak_max;
            
            peak_FWHM.b(i,j) = b_peak_FWHM;
            peak_FWHM.r(i,j) = r_peak_FWHM;
            
            peak_max_int.b(i,j) = b_peak_max_int;
            peak_max_int.r(i,j) = r_peak_max_int;
            
%             peak_data(i).peak_max(j).b = b_peak_max;
%             peak_data(i).peak_max(j).r = r_peak_max;
%             peak_data(i).peak_FWHM(j).b = b_peak_FWHM;
%             peak_data(i).peak_FWHM(j).r = r_peak_FWHM;
%             peak_data(i).peak_max_int(j).b = b_peak_max_int;
%             peak_data(i).peak_max_int(j).r = r_peak_max_int;
            
        end
    end