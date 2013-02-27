function [corr_part_blue, corr_part_red] = nmssMultiPeakSeparator(corr_part, peak_valley_pos_nm)
    corr_part_blue = corr_part;
    corr_part_red = corr_part;

    l_corr_part = length(corr_part_blue);
    for i=1:l_corr_part
        p = corr_part_blue(i);
        
        l_pdata = length(p.pdata);
        
        % loop through all graphs and find max
        for j=1:l_pdata
            pd = p.pdata{j};
            x = pd.graph.axis.x;
            % vector indices corresponding to the blue and red part of the
            % spectrum
            ix_blue_peak = find(x < peak_valley_pos_nm);
            
            graph = pd.graph;
            graph.normalized = pd.graph.normalized(ix_blue_peak);
            graph.particle = pd.graph.particle(ix_blue_peak);
            graph.bg = pd.graph.bg(ix_blue_peak);
            graph.smoothed = pd.graph.smoothed(ix_blue_peak);
            graph.axis.x = pd.graph.axis.x(ix_blue_peak);
            
            [peak_max, peak_FWHM, peak_max_int, fit_x, fit_y, str_errmsg] = ...
                nmssGetMaxAndFWHM(pd.graph.normalized(ix_blue_peak), ...
                                  pd.graph.smoothed(ix_blue_peak), ...
                                  pd.graph.axis.x(ix_blue_peak), 0);            
            
            corr_part_blue(i).pdata{j}.graph = graph;
            corr_part_blue(i).pdata{j}.res_energy = peak_max;
            corr_part_blue(i).pdata{j}.FWHM = peak_FWHM;
            corr_part_blue(i).pdata{j}.max_intensity = peak_max_int;
            corr_part_blue(i).pdata{j}.fit_x = fit_x;
            corr_part_blue(i).pdata{j}.fit_y = fit_y;
            
        end
        
        
    end
    
    l_corr_part = length(corr_part_red);
    for i=1:l_corr_part
        p = corr_part_red(i);
        
        l_pdata = length(p.pdata);
        
        % loop through all graphs and find max
        for j=1:l_pdata
            pd = p.pdata{j};
            x = pd.graph.axis.x;
            % vector indices corresponding to the blue and red part of the
            % spectrum
            ix_red_peak = find(x >= peak_valley_pos_nm);
            
            graph = pd.graph;
            
            graph.normalized = pd.graph.normalized(ix_red_peak);
            graph.particle = pd.graph.particle(ix_red_peak);
            graph.bg = pd.graph.bg(ix_red_peak);
            graph.smoothed = pd.graph.smoothed(ix_red_peak);
            graph.axis.x = pd.graph.axis.x(ix_red_peak);
            
            corr_part_red(i).pdata{j}.graph = graph;
            
            [peak_max, peak_FWHM, peak_max_int, fit_x, fit_y, str_errmsg] = ...
                nmssGetMaxAndFWHM(pd.graph.normalized(ix_red_peak), ...
                                  pd.graph.smoothed(ix_red_peak), ...
                                  pd.graph.axis.x(ix_red_peak), 0);            
            
            corr_part_red(i).pdata{j}.graph = graph;
            corr_part_red(i).pdata{j}.res_energy = peak_max;
            corr_part_red(i).pdata{j}.FWHM = peak_FWHM;
            corr_part_red(i).pdata{j}.max_intensity = peak_max_int;
            corr_part_red(i).pdata{j}.fit_x = fit_x;
            corr_part_red(i).pdata{j}.fit_y = fit_y;
            
            
        end
    end