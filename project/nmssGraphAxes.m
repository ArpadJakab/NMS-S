function hAxes = nmssGraphAxes(hParentFig)
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
% IN:
%   hParentFig   = the handle of the parent figure

    % init user data

    user_data.display.particle = false;
    user_data.display.particle_color = 'b';
    user_data.display.bg = false;
    user_data.display.bg_color = 'k';
    user_data.display.raw_bg_corr = false;
    user_data.display.raw_bg_corr_color = 'k';
    user_data.display.smoothed_raw_bg_corr = false;
    user_data.display.smoothed_raw_bg_corr_color = 'r';
    user_data.display.normalized = false;
    user_data.display.normalized_color = 'b';
    user_data.display.fit = false;
    user_data.display.fit_color = 'g';
    
    user_data.display.max = false;
    
    
    
    user_data.hDisplayGraphFcn = @DisplayGraph;
    
    % create axes
    hAxes = axes('Parent', hParentFig);
    set(hAxes, 'UserData', user_data);
    
    
    
% sets graph axes parameters    
function SetGraphAxesParams(h, sTag, sTitle)
    
    set(h, 'Tag', sTag);
    axes(h);
    title(sTitle);
    
    
function DisplayGraph(hAxes, p)

    user_data = get(hAxes, 'UserData');
    sTag = get(hAxes, 'Tag');
    hTitle = get(hAxes, 'Title');
    sTitle = get(hTitle, 'String');
    %context_menu = get(hAxes, 'UIContextMenu');
    %handles = guihandles(hAxes);
    
    axes(hAxes);
    if (user_data.display.particle)
        plot(hAxes, p.graph.axis.x, p.graph.particle, user_data.display.particle_color);
        hold(hAxes, 'on');
    end
    
    if (user_data.display.bg)
        plot(hAxes, p.graph.axis.x, p.graph.bg, user_data.display.bg_color);
        hold(hAxes, 'on');
    end
    
    if (user_data.display.raw_bg_corr)
        plot(hAxes, p.graph.axis.x, p.graph.raw_bg_corr, user_data.display.raw_bg_corr_color);
        hold(hAxes, 'on');
    end
    
    if (user_data.display.smoothed_raw_bg_corr)
        plot(hAxes, p.graph.axis.x, p.graph.smoothed_raw_bg_corr, user_data.display.smoothed_raw_bg_corr_color);
        hold(hAxes, 'on');
    end
    
    
    
    if (user_data.display.normalized)
        plot(hAxes, p.graph.axis.x, p.graph.normalized, user_data.display.normalized_color);
        hold(hAxes, 'on');
    end
    
    if (user_data.display.fit)
        plot(hAxes, 1240 ./ p.fit.fit_x, p.fit.fit_y, user_data.display.fit_color, ...
            'LineWidth', 2);
        hold(hAxes, 'on');
    end
    
    % NO PLOT command after this point!
    %
    
    axis_x_limits = xlim(hAxes);
    axis_y_limits = ylim(hAxes);
    
    if (user_data.display.fit)
        res_wl = 1240 / p.res_energy;
        line([res_wl, res_wl], ...
             [axis_y_limits(1), axis_y_limits(2)], ...
             'LineWidth', 1, 'Color', 'k', 'LineStyle', '--');
        
        left_size_of_axis = res_wl - axis_x_limits(1);
        right_size_of_axis = axis_x_limits(2) - res_wl;
        if (right_size_of_axis > left_size_of_axis)
            xTextPos = res_wl + right_size_of_axis * 0.2;
        else
            xTextPos = res_wl - left_size_of_axis * 0.9;
        end
        text(xTextPos, ...
            axis_y_limits(1) + 0.85 * (axis_y_limits(2) - axis_y_limits(1)), ...
            {sprintf('%4.1f nm', res_wl); sprintf('%1.3f eV', p.FWHM)});
        
    end
    
    
    text(axis_x_limits(1) + diff(axis_x_limits) * 0.9,  ...
     axis_y_limits(1) + diff(axis_y_limits) * 0.9, ...
     [sprintf('%4d', p.num)], 'EdgeColor', 'k', 'BackgroundColor', 'w');


    % disable mouse hit test for the graph lines (so that the context menu
    % appears even if the user clicks over the graph lines and not over the
    % axes surface)
    hLines = findobj(hAxes, 'Type', 'line');
    set(hLines, 'HitTest', 'off');
    
    hold(hAxes, 'off');
    set(hAxes, 'Tag', sTag);
    title(sTitle);
    set(hAxes, 'UserData', user_data);
    %set(hAxes, 'UIContextMenu', context_menu);
    
    
    
    
