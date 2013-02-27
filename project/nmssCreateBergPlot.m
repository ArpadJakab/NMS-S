function [berg_plot, fit_data, warning_txt] = nmssCreateBergPlot(particle)
    
    berg_plot = zeros(1,3);
%     fit_data.fit_x = [];
%     fit_data.fit_y = [];
%     % initialize the settings for finding the peak
%     fit_data.params = nmssResetPeakFindingParam(graph.axis.x);
    warning_txt = '';
    fit_data = particle.fit;
    
    % the minimum FWHM which will be still considered as acceptable peak
    min_FWHM = 0.03; % [eV]
    max_FWHM = 1.5; % [eV]

        if (particle.graph.bg_valid == 1)

            % in case the user didn't switch to nm units at the x-axis
            if (strcmp(particle.graph.axis.unit.x, 'pixel'))
                unit.x = 'nanometer';
                unit.y = 'pixel';
                particle.graph.axis.x = nmssPixel_2_Unit(particle.graph.axis.x, 0, unit);
            end

            
            % smooth particle.graph
            if (isfield(particle.graph, 'smoothed'))
                spec_smoothed = particle.graph.smoothed;
            else
                spec_smoothed = nmssSmoothGraph(particle.graph.normalized);
            end
            
            
            % convert spec into eV picture
            [x_eV, spec_eV] = nmssConvertGraph_nm_2_eV(particle.graph.axis.x, particle.graph.normalized);
            [x_eV, spec_smooth_eV] = nmssConvertGraph_nm_2_eV(particle.graph.axis.x, spec_smoothed);
            
            % get FWHM and peak max positions in eV
            [peak_max_pos, peak_FWHM, peak_max_int, fit_x, fit_y, str_errmsg] = ...
                nmssGetMaxAndFWHM(spec_eV, spec_smooth_eV, x_eV, fit_data.params);
            
            fit_data.fit_x = fit_x;
            fit_data.fit_y = fit_y;
            

            % no peak found
            if (isnan(peak_max_pos))
                warning_txt = cellstr(strvcat(warning_txt, ['No maximum could be found!'], char(str_errmsg)));
            end
            
            % FWHM found?
                if (isnan(peak_FWHM.full))
                    % no FWHM :-((( what should we do?
                    warning_txt = cellstr(strvcat(char(warning_txt), ...
                        ['No FWHM could be found! Check the FWHM selection rules in the function nmssGetMaxAndFWHM'], ...
                        char(str_errmsg)));
                else
                    % OK, we have FWHM, let's see if there are some problems
                    % FWHM is too large
                    if (peak_FWHM.full > max_FWHM)
                        warning_txt = cellstr(strvcat(char(warning_txt), ...
                                              ['FWHM ', num2str(peak_FWHM.full), ' is larger than ', num2str(max_FWHM)]));
                    elseif (peak_FWHM.full < min_FWHM)
                        warning_txt = cellstr(strvcat(char(warning_txt), ...
                                              ['FWHM ', num2str(peak_FWHM.full),' is smaller than ', num2str(min_FWHM)]));
                    else
                        if (peak_FWHM.full ~= 0)
                            Q = peak_max_pos / peak_FWHM.full;
                        else
                            % FWHM is too small
                            Q = 0;
                        end
                    end
                end

            berg_plot(1) = peak_max_pos; 
            berg_plot(2) = peak_FWHM.full; 
            berg_plot(3) = peak_max_int; 

        end
        
