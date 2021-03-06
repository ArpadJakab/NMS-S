function fig = nmssPlotGraph(graph_or_particle, figname, varargin)
% plots graph with blue if background could be identified and with red if
% backgrouond couldn't be identified
% graph - the graph structure
% figname - this string will be copied into the figure window title
% varargin - can have following values: 
%            normalized: the normalized particle spectrum is plotted
%            particle: the original uncorrected particle spectrum is plotted
%            bg: the background is plotted


    if (~iscell(graph_or_particle))
        tmp_graph_or_particle = graph_or_particle;
        graph_or_particle = cell(1,1);
        graph_or_particle{1,1} = tmp_graph_or_particle;
    end
    
    graph_field_varnames = 'normalized';
    if (length(varargin) >= 1)
        graph_field_varnames = varargin{1};
        if (~iscell(graph_field_varnames))
           graph_field_varnames = {graph_field_varnames};
        end
    end
    
    % the maximum number of particle displayed in one figure
    size_of_graph = length(graph_or_particle);
    
    number_of_max_subplots.x = 3;
    number_of_max_subplots.y = 3;
    if (length(varargin) >= 2)
        number_of_max_subplots.x = varargin{2}(1);
        number_of_max_subplots.y = varargin{2}(2);
    else
        if (size_of_graph > 6)
            number_of_max_subplots.x = 3;
            number_of_max_subplots.y = 3;
        elseif (size_of_graph > 4)
            number_of_max_subplots.x = 3;
            number_of_max_subplots.y = 2;
        elseif (size_of_graph > 2)
            number_of_max_subplots.x = 2;
            number_of_max_subplots.y = 2;
        elseif (size_of_graph == 2)
            number_of_max_subplots.x = 2;
            number_of_max_subplots.y = 1;
        else
            number_of_max_subplots.x = 1;
            number_of_max_subplots.y = 1;
        end
    end
    
    

    
        
    figure_index = 1;
    for k=1:size_of_graph
        % plot 9 graphs in a figure, open a new figure after every 9th
        % plot
        if (mod(k-1,number_of_max_subplots.x*number_of_max_subplots.y) == 0)
            %figure(figure_index);
            fig(figure_index) = figure('Name', figname);
            figure_index = figure_index + 1;
        end
        
        % get the graph strucutre which will be plotted
        job_number = 0; % stores the number of the job containing the particle's spectrum
        if (isfield(graph_or_particle{k}, 'num'))
            % we have a particle structure!
            gr = graph_or_particle{k}.graph;
            p = graph_or_particle{k};
            job_number = graph_or_particle{k}.num;
        else
            gr = graph_or_particle{k};
            p = [];
        end
        
        % show x-th subplot
        current_subplot_number = mod(k-1,number_of_max_subplots.x*number_of_max_subplots.y) + 1;
        subplot(number_of_max_subplots.y, number_of_max_subplots.x, current_subplot_number);
        
        
        % plot peak in the given representation: particle, bg, smoothed,
        % etc.
        num_of_graphs_in_the_same_plot = length(graph_field_varnames);
        for graph_field_varname_index = 1:num_of_graphs_in_the_same_plot
            graph_field_varname = graph_field_varnames{graph_field_varname_index};
        
            % get smoothed spectrum for further analysis
            if (isfield(gr, 'smoothed'))
                spec_smoothed = gr.smoothed; % new feature due to elaborated smoothing procedure we store the smoothed spectrum
            else
                spec_smoothed = nmssSmoothGraph(graph2plot);
            end

            % get the spectrum which will be plotted
            data_name = 'raw data ';
            if (strcmp(graph_field_varname,'particle') | ...
                strcmp(graph_field_varname,'bg'))
                graph2plot = getfield(gr, graph_field_varname);
            elseif (strcmp(graph_field_varname,'smoothed'))
                data_name = 'smoothed data ';
                graph2plot = spec_smoothed;
            else
                data_name = 'normalized data ';
                graph2plot = gr.normalized;
            end


            if (gr.bg_valid == 1)
                % plot normalized graphs with blue line
                graph_color = 'b';
                data_name = strcat(data_name, ' bg corrected');
            else
                % plot un-normalized graphs with red line
                graph_color = 'r';
            end
            plot(gr.axis.x, graph2plot, 'Color', graph_color, 'DisplayName', data_name);
            hold on;
        
        end % end for
        
        str_errmsg = '';
        max_int = NaN;
        peak_max = NaN;
        peak_FWHM = NaN;
        fit_x = [];
        fit_y = [];
        
        if (strcmp(gr.axis.unit.x, 'pixel'))
            
            [max_int, peak_max] = max(gr.particle);
            peak_max_nm_str = num2str(gr.axis.x(peak_max));

            
        else
            x_axis_nm = gr.axis.x;
            % initialize the settings for finding the peak
            peakFindingParams = nmssResetPeakFindingParam(1240 ./ x_axis_nm);
            
            % get characteristic information of the peak (Q, max position)
            if (isempty(p))
                [x_axis_eV, spec_ev] =  nmssConvertGraph_nm_2_eV(x_axis_nm, graph2plot);
                [x_axis_eV, spec_smooth_ev] =  nmssConvertGraph_nm_2_eV(x_axis_nm, spec_smoothed);
                [peak_max peak_FWHM max_int, fit_x, fit_y, str_errmsg] = ...
                    nmssGetMaxAndFWHM(spec_ev, spec_smooth_ev, x_axis_eV, peakFindingParams);
                disp(str_errmsg);
            else
                if (isfield(p, 'fit'))
                    fit_x = p.fit.fit_x;
                    fit_y = p.fit.fit_y;
                else
                    fit_x = p.fit_x;
                    fit_y = p.fit_y;
                end
                
                
            end

                [fit_x_nm, fit_y_nm] = nmssConvertGraph_eV_2_nm(fit_x, fit_y);

            % plot  fit
            if (length(fit_y_nm) == length(fit_x_nm))
                plot(fit_x_nm, fit_y_nm, 'Color', 'g', 'DisplayName', 'peak fit');
            end
            
            x_axis_nm = gr.axis.x;
            
            if (~isempty(str_errmsg))
                disp({'Error while retrieving Maximum and FWHM: '; str_errmsg});
            end

            % let's see what peak did we found
            if (isnan(peak_max(1)))
               peak_max_nm_str = ' not found';
               peak_max = 0;
            else
               peak_max_nm_str = [num2str(1240 / peak_max(1), '%.1f')];
            end

        end
        
        
        if (~isempty(str_errmsg))
            disp({'Error while retrieving Maximum and FWHM: '; str_errmsg});
        end
        
        
        title(['Particle #', num2str(job_number)]);
        xlabel(['y= ',num2str(floor(gr.roi.particle.y + gr.roi.particle.wy * 0.5)), ...
                '; Max= ', num2str(max_int(1), '%.3g'), '; Max Pos= ', peak_max_nm_str]);
            
        hold off;
        
    end
