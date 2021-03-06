function nmssResultsViewerPopupMenu( src, evnt, PopupCallName, particle_index, hFig )
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
%     particle_index = varargin{1};
%     hFig = varargin{2};
    
    if (strcmp(PopupCallName , 'SmoothGraph'))
        PopupMenuItem_SmoothGraph(hFig, particle_index)
    elseif (strcmp(PopupCallName , 'UnSmoothGraph'))
        PopupMenuItem_UnSmoothGraph(hFig, particle_index);
    elseif (strcmp(PopupCallName , 'ShowBackground'))
        PopupMenuItem_ShowBackground(hFig, particle_index);
    
    elseif (strcmp(PopupCallName , 'ShowRaw'))
        PopupMenuItem_ShowRaw(hFig, particle_index);
    elseif (strcmp(PopupCallName , 'ShowRawMinusBg'))
        PopupMenuItem_ShowRawMinusBg(hFig, particle_index);
    elseif (strcmp(PopupCallName , 'ShowFit'))
        PopupMenuItem_ShowFit(hFig, particle_index);
    
    elseif (strcmp(PopupCallName , 'ShoweV'))
        PopupMenuItem_ShoweV(hFig, particle_index);
    elseif (strcmp(PopupCallName , 'ShowData'))
        PopupMenuItem_ShowData(hFig, particle_index);
    elseif (strcmp(PopupCallName , 'ShowNoiseFiltered'))
        PopupMenuItem_ShowNoiseFiltered(hFig, particle_index);
    
    elseif (strcmp(PopupCallName , 'Zoom'))
        PopupMenuItem_Zoom(hFig, particle_index);
    elseif (strcmp(PopupCallName , 'ShowInRealSpaceImg'))
        PopupMenuItem_ShowInRealSpaceImg(hFig, particle_index);
    elseif (strcmp(PopupCallName , 'CorrelatedSpectra'))
        PopupMenuItem_CorrelatedSpectra(hFig, particle_index);
    end
    
% --------------------------------------------------------------------    
% popup menu item: CorrelatedSpectra 
function PopupMenuItem_CorrelatedSpectra(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');

    % create a N x M subplot, where N, M <= 5
    num_of_corr_views = size(user_data.results.particle,2);
    
    p = user_data(particle_index,:);
    
    handle_fig = figure('Name', ['Particle #', num2str(particle_index)], 'Tag', 'nmssResultsViewerFigure_CorrPartView');
        
        
        % number of axes
        if (num_of_corr_views <= 5)
            num_of_axes_x = num_of_corr_views;
        else
            num_of_axes_x = 5;
        end
        
        num_of_axes_y = ceil(num_of_corr_views / 5);
        
        i = 1;
        j = 1;
        for pi=1:num_of_corr_views
            handle_axes(j, i) = subplot(num_of_axes_y, num_of_axes_x, pi);
            user_data.PlotGraphCallback(handle_axes(j, i), p(pi));
            
            i = i+1;
            if (i == 5)
                j = j+1;
                i = 1;
            end
        end
        
    nmssResizeFigure_cm(handle_fig, num_of_axes_x * 6, num_of_axes_y * 5);
        
    
    
    
    % display graphs in each subplot
    
    % maybe allow context menus (priority 2)
    
    
    

% --------------------------------------------------------------------    
% popup menu item: ShowRawMinusBg
function PopupMenuItem_ShowRawMinusBg(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');
    
    cur_view_level = user_data.current_view_level;
    p = user_data.results.particle(particle_index ,cur_view_level);
    
    figure('Tag', 'nmssResultsViewerFigure_ShowRawMinusBg', 'Name', ['Particle #',num2str(particle_index),' Raw minus Background']);
    plot(p.graph.axis.x, p.graph.particle - p.graph.bg);
    xlabel('Wavelength (nm)');
    ylabel('Intensity (a.u.)');


% --------------------------------------------------------------------    
% popup menu item: ShowRaw
function PopupMenuItem_ShowRaw(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');
    
    cur_view_level = user_data.current_view_level;
    p = user_data.results.particle(particle_index ,cur_view_level);
    
    figure('Tag', 'nmssResultsViewerFigure_ShowRaw', 'Name', ['Particle #',num2str(particle_index),' Raw Graph']);
    plot(p.graph.axis.x, p.graph.particle);
    xlabel('Wavelength (nm)');
    ylabel('Intensity (a.u.)');

% --------------------------------------------------------------------    
% popup menu item: ShowBackground
function PopupMenuItem_ShowBackground(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');
    
    cur_view_level = user_data.current_view_level;
    p = user_data.results.particle(particle_index ,cur_view_level);
    
    figure('Tag', 'nmssResultsViewerFigure_ShowBackground', 'Name', ['Particle #',num2str(particle_index),' Background']);
    plot(p.graph.axis.x, p.graph.bg);
    xlabel('Wavelength (nm)');
    ylabel('Intensity (a.u.)');

% --------------------------------------------------------------------    
% popup menu item: ShowSmoothGraph
function PopupMenuItem_SmoothGraph(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');
    
    cur_view_level = user_data.current_view_level;
    p = user_data.results.particle(particle_index ,cur_view_level);
    
    figure('Tag', 'nmssResultsViewerFigure_SmoothGraph', 'Name', ['Particle #',num2str(particle_index),' Smooth Graph']);
    plot(p.graph.axis.x, p.graph.smoothed);
    xlabel('Wavelength (nm)');
    ylabel('Intensity (a.u.)');

% --------------------------------------------------------------------    
% popup menu item: UnShowSmoothGraph
function PopupMenuItem_UnSmoothGraph(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');
    
    cur_view_level = user_data.current_view_level;
    p = user_data.results.particle(particle_index ,cur_view_level);
    
    figure('Tag', 'nmssResultsViewerFigure_UnSmoothGraph', 'Name', ['Particle #',num2str(particle_index),' Unsmoothed graph']);
    plot(p.graph.axis.x, p.graph.normalized);
    xlabel('Wavelength (nm)');
    ylabel('Intensity (a.u.)');


% --------------------------------------------------------------------    
% popup menu item: ShowInRealSpaceImg
% shows the location of the selected particle
function PopupMenuItem_ShowInRealSpaceImg(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');
    
    cur_view_level = user_data.current_view_level;
    p = user_data.results.particle(particle_index ,cur_view_level);

    % check if we have real space image present in the data structure
    if (~isfield(user_data.results, 'real_space_img'))
        return;
    end
    
    img.x_min = user_data.results.real_space_img.x_min;
    img.x_max = user_data.results.real_space_img.x_max;
    img.y_min = user_data.results.real_space_img.y_min;
    img.y_max = user_data.results.real_space_img.y_max;
    
    hFigure = findobj('Tag', 'nmssResultsViewerFigure_RealSpace');
    if (isempty(hFigure) || ~ishandle(hFigure))
        % display real space image scaled to its physical coordinates
        hFigure = figure('Name', 'Real Space Image', 'Tag', 'nmssResultsViewerFigure_RealSpace');
        
        imagesc([img.x_min, img.x_max], ...
                [img.y_min, img.y_max], ...
                user_data.results.real_space_img.img);
    else
        figure(hFigure);
    end
    hold on;
    
    % create context menu for the axes. the conext menu can contain
    % different menu entries to react on the user's mouse click
    % the menu entries will be filled up later in this function
    % 'Parent' is the figure which is the same parent as for the axes
    context_menu = uicontextmenu('Parent', hFigure);
    % link axes with the context menu
    % set(handles.canvasFigureAxes, 'UIContextMenu', context_menu); 
    
    % get handle of the image
    hImage = findobj(hFigure, 'Type', 'Image');
    % link image with the context menu
    set(hImage, 'UIContextMenu', context_menu); 
    cb = @RealspaceImageContextMenu;
    uimenu(context_menu,  'Label', 'Delete All Markers', 'Callback', cb);    
    
    
    % get the x-position (this is the frame number)
    %x_pos = p.data.pos.x;
    x_pos = p.position.x;
    
    % get the y-position (this is the y-coord of the pixel of the particle)
    wy = p.graph.roi.particle.wy
    if (isfield(p, 'position'))
        y_pos = p.position.y;
    else
        y_pos = floor(p.graph.roi.particle.y + wy * .5);
    end
    
    if (p.res_energy ~= 0)
        particle_color = nmssWavelength2RGB( 1240 / p.res_energy);
    else
        particle_color = [0, 0, 0];
    end

            
    % create context menu for the axes. the conext menu can contain
    % different menu entries to react on the user's mouse click
    % the menu entries will be filled up later in this function
    % 'Parent' is the figure which is the same parent as for the axes
    context_menu = uicontextmenu('Parent', hFigure);
    % link axes with the context menu
    % set(handles.canvasFigureAxes, 'UIContextMenu', context_menu); 
    
    % link image with the context menu
    set(hImage, 'UIContextMenu', context_menu); 
    cb = @RealspaceImageContextMenu;
    uimenu(context_menu,  'Label', 'Delete All Markers', 'Callback', cb);    
        
    
    % indicate particle on image
    hParticlePos = plot(x_pos , y_pos, 'o', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', particle_color, ...
                       'MarkerSize',5); % big white background
    set(hParticlePos,'Tag','particle_on_image');
    
    hParticleText = text(x_pos + 3, y_pos + 2, num2str(particle_index), 'BackgroundColor', 'w', 'Tag', 'nmssParticleTextOnImage');
    
    % link particle marker with the context menu
    set([hParticlePos, hParticleText], 'UIContextMenu', context_menu); 
    cb = @ParticleIndicatorContextMennu;
    uimenu(context_menu,  'Label', 'Delete Marker', 'Callback', cb, 'UserData', [hParticlePos, hParticleText]);    
    
%     hParticlePos = plot(x_pos , y_pos, '.', 'Color', particle_color); % the particle with the spectral color
%     set(hParticlePos,'Tag','particle_on_image');
%     
    
function ParticleIndicatorContextMennu(varargin)

    % get the handle of the menu
    hCallerObject = varargin{1};
    
    % get the handles of the marker and the text
    hCorrespondingObjects = get(hCallerObject, 'UserData');
        delete(hCorrespondingObjects);

    
function RealspaceImageContextMenu(varargin)

    hFigure = findobj('-regexp','Tag', 'nmssResultsViewerFigure_RealSpace');
    hParticlePos = findobj(hFigure, 'Tag', 'particle_on_image');
    delete(hParticlePos);
    
    hParticleText = findobj(hFigure, 'Tag', 'nmssParticleTextOnImage');
    delete(hParticleText);
    



% --------------------------------------------------------------------    
% popup menu item: Show fit
function PopupMenuItem_ShowFit(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');
    
    cur_view_level = user_data.current_view_level;
    p = user_data.results.particle(particle_index ,cur_view_level);
    
    figure('Tag', 'nmssResultsViewerFigure_NoiseFiltered', 'Name', ['Particle #',num2str(particle_index),' Fitted peak view']);
    
    spec_nm = p.graph.normalized;
    smoothed_spec_nm = p.graph.smoothed;
    x_nm = p.graph.axis.x;
    
    if (isfield(p, 'fit_x') && isfield(p, 'fit_y'))
        [fit_x, fit_y] = nmssConvertGraph_eV_2_nm(p.fit_x, p.fit_y);
        figure('Tag', 'nmssResultsViewerFigure_Fit'); 
        plot(x_nm, spec_nm);
        xlabel('\lambda (nm)');
        hold on;
        plot(fit_x, fit_y,  'g' );

        [max_val, max_pos] = max(fit_y);
        title(['Max pos: ', num2str(fit_x(max_pos)), ' nm (', num2str(1240 / fit_x(max_pos)),' eV)', ' Max val:' , num2str(max_val)]);

    else
        msgbox('No fit available for this graph!','Display Fit','error');
    end
    
    
    


% --------------------------------------------------------------------    
% popup menu item: Show eV
function PopupMenuItem_ShoweV(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');
    
    cur_view_level = user_data.current_view_level;
    p = user_data.results.particle(particle_index ,cur_view_level);
    
    figure('Tag', 'nmssResultsViewerFigure_eV', 'Name', ['Particle #',num2str(particle_index),' eV View']);
    
    x_axis_ev = 1240 ./ p.graph.axis.x ;
    plot(x_axis_ev, p.graph.smoothed);
    xlabel('res. Energy (eV)');
    
% --------------------------------------------------------------------    
% popup menu item: Show Noise Filtered
function PopupMenuItem_ShowNoiseFiltered(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');
    
    cur_view_level = user_data.current_view_level;
    p = user_data.results.particle(particle_index ,cur_view_level);
    
    figure('Tag', 'nmssResultsViewerFigure_NoiseFiltered', 'Name', ['Particle #',num2str(particle_index),' Low Pass filtered']);
    
    x_axis_ev = 1240 ./ p.graph.axis.x ;
    plot(x_axis_ev, p.graph.normalized, 'b');
    hold on;
    plot(x_axis_ev, p.graph.noise_filtered, 'r');
    xlabel('res. Energy (eV)');
    



% --------------------------------------------------------------------    
% popup menu item: Show Data
function PopupMenuItem_ShowData(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');
    
    cur_view_level = user_data.current_view_level;
    p = user_data.results.particle(particle_index ,cur_view_level);
    
            
    msg_text = {['Resonance Wavelength: ', num2str(1240 / p.res_energy), ' nm ']; ...
                ['Resonance Energy: ', num2str(p.res_energy), ' eV ']; ...
                ['FWHM: ', num2str(p.FWHM), ' eV ']; ...
                ['X-pos (frame): ', num2str(p.position.x)]; ...
                ['Y-pos: ', num2str(p.position.y)]};
            
    msgbox(msg_text, 'Graph Data');
    
    
% --------------------------------------------------------------------    
% popup menu item: Zoom
% open small graph in a separate figure
function PopupMenuItem_Zoom(hFig, particle_index)  
    
    user_data = get(hFig, 'UserData');
    
    cur_view_level = user_data.current_view_level;
    p = user_data.results.particle(particle_index ,cur_view_level);
    
    handle_fig = figure('Name', ['Particle #', num2str(particle_index)], 'Tag', 'nmssResultsViewerFigure_Graph');
    handle_axes = axes();
    
    user_data.PlotGraphCallback(handle_axes, p);
    






