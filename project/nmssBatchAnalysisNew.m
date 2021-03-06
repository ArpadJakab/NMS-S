function [results, particle] = nmssBatchAnalysisNew(real_space_img, list_of_jobs, ...
                                     work_dir, analysis, ...
                                     white_light, measurement_info, roi_in_px, manual_particle_finding)

    results = [];
    global doc;


    % cleaned up spectral analysis
        analysis.roi = roi_in_px;
    
    % FILL UP results STRUCTURE
        results.version = 2.0;
        
        %results.scanning_imaging = doc.scanning_imaging; % info about the scanning parameters
        results.white_light.raw = white_light(:,2)';
        results.white_light.x_axis = white_light(:,1)';
        results.white_light.smooth.param = 50; % use smooth white light if it contains interference pattern
        results.white_light.smooth.spec = smooth(results.white_light.raw, results.white_light.smooth.param)';
        results.white_light.use = 'raw'; % possible values 'raw', 'smooth' - specifies which white light should be used for normalization
        
        results.spec_roi_in_px = roi_in_px; % stores the spectral roi (also the vertical dimension)
        results.measurement_info = measurement_info; % entered by the user
        results.working_dir = work_dir; % may not be in sync if data is moved!!!
        results.date = datestr(now, 'yyyy-mm-dd HH:MM:SS');
        %results.berg_plot = berg_plot; % FWHM [eV] vs peak maximum position [eV]
        results.analysis = analysis;
        % real space image
        results.real_space_img = real_space_img;
        
        % spec data smoothing
        results.spec_smoothing.flag = false; % no smoothing of the spectrum (if 'true' the background corrected spectrum is smoothed)
        results.spec_smoothing.param = 30; % smoothing param
        
        % must be the first graphics related call - it creates the
        % figure!!
        % create figure
        hFig = CreateFigure(results);
        
        user_data = get(hFig, 'UserData');

        
    % 1 - Find particle - find the particle on the reconstructed intensity
    % map (real space image)
    % here we get the
    %   - the intensity map of the scanned area
    %   - particle roi in the intensity map coordinates (upper left and
    %   lower right corner)
    
        particle = GetParticleBoundingRect(results.real_space_img, results.spec_roi_in_px, ...
                            analysis);
    
        if (isempty(particle))
            errordlg('No particle found.');
            return;
        end
        particle = GetAxis(particle, results.spec_roi_in_px);
        
        particle = GetBackgroundBoundingRectangles(particle, results.real_space_img, user_data.doc.bg);
        
        % initalize fit parameters
        for i=1:length(particle(:,1))
            fit_data.fit_x = [];
            fit_data.fit_y = [];
            % initialize the settings for finding the peak
            fit_data.params = nmssResetPeakFindingParam(1240 ./ particle(i,1).graph.axis.x);
            particle(i,1).fit = fit_data;
        end

        [particle, status] = GetSpectrum(hFig, particle, results.white_light, results.spec_roi_in_px, ...
                               results.real_space_img, results.spec_smoothing);
        if (~strcmp(status, 'OK')) error('Can''t get spectrum because the working dialog has changed and the datacube does not correspond to analysis data!'); end;
        
        user_data.results.particle = particle;
        set(hFig, 'UserData', user_data);
        
        
        DisplayFigure(hFig);
        
        
        % select first rectangle
        SelectParticle(hFig, 1);
        
function hSelectedNewRectangle = SelectParticle(hFig, varargin)
% selects given particle or if no particle is specified it selects the next one       
    
        selected_particle_index = 1;
        hRectangle = GetSelectedRectangles(hFig);
        % unselect all selected rectangles
        if (~isempty(hRectangle))
            set(hRectangle, 'Selected', 'off');
        end
        
        % analize input arguments
        if (length(varargin) >= 1)
            selected_particle_index = varargin{1};
        else
            % get the index of the next particle
            if (~isempty(hRectangle))
                particle_index = GetParticleIndex(hRectangle);
                if (particle_index(end) + 1 <= GetNumOfAllParticles(hFig))
                    selected_particle_index = particle_index(end) + 1;
                end
            end
        end
            
        if (length(varargin) >= 2)
            sTag = varargin{2};
        else
            sTag = 'nmssParticleBoundingRect';
        end
        
    
        % select specified rectangle
        hSelectedNewRectangle = findobj(hFig,'Tag', sTag, '-and', ...
                                'UserData', selected_particle_index);
        BoundingRectButtonDownCallback(hSelectedNewRectangle);
%
function num_of_all_particles = GetNumOfAllParticles(hFig)
     
    user_data = get(hFig, 'UserData');
    num_of_all_particles = length(user_data.results.particle);

     
% container for all spectrum extrating functions
function [particle, status] = GetSpectrum(hFig, particle_in, white_light, roi_in_px, real_space_img, spec_smoothing)
    status = 'ERROR';
    particle = particle_in;
    
    if (~CanAccessImgBlock(hFig))
        WarningNoAccessToImgBlock(hFig);
        return;
    end
    
        
    
        particle = GetRawSpectrum(particle_in, real_space_img, spec_smoothing, roi_in_px);
        
        particle = NormalizeWithWhiteLight(particle, white_light, roi_in_px, spec_smoothing);
        
        particle = SmootheNormalized(particle);
        
        particle = NoiseFilterNormalized(particle);
        
        particle = GetPeakParams(particle);
    
    status = 'OK';
    
        
        
%
function DisplayBoundingRectangles(hFig, particle, real_space_img, roi_in_px)
    
            hImgAx = findobj(hFig, 'Tag', 'nmssScanImageAxes');
            axes(hImgAx);

    
            % CONTEXT MENU
            % the context menu that will be shown when the user clicks on a
            % bounding ractangle
            context_menu = uicontextmenu('Parent', hFig);
            MenuSharedBoundingRect(context_menu);
            ContextMenuBoundingRect(context_menu);

            num_of_particles = length(particle);


            % draw a rectangle around the particle spot. The size of the rectangle
            % corresponds to the threshold limit
            p = cell2mat({particle.('p')}'); % get all elements of the filed 'p' and oreder into a matrix
            if (isempty(p)) return; end
            
            hBoundingRectangles = nmssDrawRectBetween2Points([p(:,1), p(:,2) + roi_in_px.y - 1], ...
                                                             [p(:,4), p(:,5) + roi_in_px.y - 1], ...
                                       2, 'r');
            for i=1:num_of_particles
                hGR = hggroup('UserData', i, 'Parent', hImgAx, 'Tag', 'nmssRectangleGroup');
                hBR = hBoundingRectangles(i);
                set(hBR, 'Parent', hGR);
                set(hBR, 'Tag', 'nmssParticleBoundingRect');
                set(hBR, 'UserData', i);
                set(hBR, 'ButtonDownFcn', @BoundingRectButtonDownCallback);
                set(hBR, 'SelectionHighlight', 'on'); % highlight edges if user clicks rectangle
                
                set(hBR, 'UIContextMenu', context_menu);
                
                text(p(i,1), p(i,2) + roi_in_px.y - 1, num2str(particle(i,1).num), 'Color', 'w', ...
                    'Tag', 'nmssParticleNumberText', 'UserData', i, 'Parent', hGR, 'Clipping', 'on');
            end

            % draw the background rectangle around the particle spot. The size of the rectangle
            % corresponds to the threshold limit
            bg = cell2mat({particle.('bg')}'); % get all elements of the field 'p' and oreder into a matrix
            if (isempty(bg)) return; end;
            
            hRectangles = nmssDrawRectBetween2Points([bg(:,1), bg(:,2) + roi_in_px.y - 1], ...
                                                     [bg(:,4), bg(:,5) + roi_in_px.y - 1], ...
                                                      1, 'r');
            for i=1:num_of_particles
                hGR = findobj(hImgAx, 'Type', 'hggroup', '-and', 'UserData', i);
                hBR = hRectangles(i);
                set(hBR, 'Parent', hGR);
                
                set(hBR, 'Tag', 'nmssParticle_BG_Rect');
                set(hBR, 'UserData', i);
                set(hBR, 'ButtonDownFcn', @BGRectButtonDownCallback);
                set(hBR, 'SelectionHighlight', 'on'); % highlight edges if user clicks rectangle
                
                set(hBR, 'UIContextMenu', context_menu);
            end
            
            % enable or disable rectangle groups
            for i=1:num_of_particles
                if (particle(i,1).valid)
                    EnableRectangleGroup(hBoundingRectangles(i));
                else
                    DisableRectangleGroup(hBoundingRectangles(i));
                end
            end
                        
       
function hFig = CreateFigure(results)
    % display real space image scaled to its physical coordinates
    global doc;


    hFig = figure('Tag', 'nmssScanImageAnalysisFigure');

    % store particle data in figure (we don't have to take care of
    % it furthermore since it is globally accessible as long the
    % figure exists)
    user_data.results = results;

    % flag that indicates if actions can be perfromed that access
    % the global data cube (doc.img_block)
    user_data.canAccessImgBlock = true;


    % display real space image scaled to its physical coordinates
    set(hFig, 'NumberTitle', 'on'); % prints "Figure <fig_handle>" in the window title bar
    %short_work_dir = nmssCreateShortDirPath( results.working_dir, 1, 2);
    set(hFig, 'Name', ['Scan Analysis Dialog: ', results.working_dir]);

    set(hFig, 'Units', 'character');
    fig_pos = get(hFig, 'Position');
    % initialize figure size and position
    fig_pos(3) = 140;
    fig_pos(4) = 30;
    fig_pos(1) = 10;
    set(hFig, 'Position', fig_pos);

    set(hFig,'ResizeFcn', @ResizeScanImageFigure);
    set(hFig,'CloseRequestFcn', @CloseRequestScanImageFigure);

    set(hFig,'SelectionHighlight', 'off');
    %set(hFig,'HitTest', 'off');
    set(hFig,'DockControls', 'off');
    set(hFig,'MenuBar', 'none');

    % from here now the figure!s units are charater units
    set(hFig, 'Units', 'characters');

    % initialize user_data
    % ----------------------------------------------------
    % GUI related stuff
    user_data.gui.yaxis_label_width = 8; % characters
    user_data.gui.xaxis_label_height = 2; % characters
    user_data.gui.figure_title_height = 2;
    user_data.gui.image_zoom_value = 1;
    user_data.gui.window_pos = fig_pos;
    user_data.gui.window_min_width = 140; % characters
    user_data.gui.window_min_height = 30; % characters
    
    % some other parameters
        bg.voffset = 0; % the number of pixels used to define the vertical size of the background rectangle in realtion to the particle bounding rectangle
        bg.hoffset = 2; % the number of pixels used to define the horizontal size of the background rectangle in realtion to the particle bounding rectangle

    user_data.doc.bg = bg; % the number of pixels used to define the vertical size of the background rectangle in realtion to the particle bounding rectangle

    % store initial data in figure user data
    set(hFig, 'UserData', user_data);

    
function DisplayFigure(hFig)
    
    user_data = get(hFig, 'UserData');
    fig_pos = get(hFig, 'Position');
    fig_units = get(hFig, 'Units');


    figure(hFig);
    hImage = imagesc([user_data.results.real_space_img.x_min, user_data.results.real_space_img.x_max], ...
                     [1, size(user_data.results.real_space_img.img,1)], user_data.results.real_space_img.img);
    hold on;
    set(hImage,'ButtonDownFcn', @ButtonDownInImage);

    % the axes of the image and its dimensions
    hImgAx = gca;
    num_of_particles = length(user_data.results.particle);
    set(hImgAx, 'Units', fig_units, 'Tag', 'nmssScanImageAxes', ...
        'Title', text('String',['Scanned Image (', num2str(num_of_particles), ' particles)']));

    
    colormap(gray(2^8));
    brighten(0.6);

    %image_context_menu = uicontextmenu('Parent', hFig);
    %MenuView(image_context_menu);
    %set(hImage, 'UIContextMenu', image_context_menu);

    % MENU BAR
    % add new item to the menu bar
    menuData = uimenu(hFig,  'Label', 'Data');
    menuView = uimenu(hFig,  'Label', 'View');
    menuBoundingRect = uimenu(hFig,  'Label', 'Rectangle');
    menuSpectrum = uimenu(hFig,  'Label', 'Spectrum');

    % fill menus with items
    MenuData(menuData);
    MenuView(menuView);

    MenuSharedBoundingRect(menuBoundingRect);
    MenuBoundingRectBar(menuBoundingRect);

    MenuSpectrum(menuSpectrum);


    % add callback for if user presses a key (for keyboard
    % shortcuts
    set(hFig, 'KeyPressFcn', @FigureKeyPressedCallback);

    % display bounding rectangles
    DisplayBoundingRectangles(hFig, user_data.results.particle, user_data.results.real_space_img, user_data.results.spec_roi_in_px);   


    % the graph containing the measured particle and background spectrum
    hGraph1Axs = nmssGraphAxes(hFig)
    set(hGraph1Axs,'Units', fig_units);
    set(hGraph1Axs, 'Visible', 'off');
    SetGraphAxesParams(hGraph1Axs, 'nmssScanImageGraph1Axes', 'Measured Spectra');

    % the graph containing the background corrected spectrum
    hGraph2Axs = nmssGraphAxes(hFig)
    set(hGraph2Axs,'Units', fig_units);
    %hGraph2Axs = axes('Units', fig_units);
    set(hGraph2Axs, 'Visible', 'off');
    SetGraphAxesParams(hGraph2Axs, 'nmssScanImageGraph2Axes', 'Normalized Spectrum');

    % create a narrow panel in the bottom part of the figure
    % (below the axes)
    hBottomPanel = uipanel('Parent', hFig, 'Tag', 'nmssScanImageBottomPanel', 'Units', fig_units, 'Title', 'Particle Navigation');
    set(hBottomPanel, 'Position', [1,1, 30, 4]);

        % buttons to select the next and the previous particles
        hpbSelectPrevParticle = uicontrol('Parent', hBottomPanel, 'Style', 'pushbutton', 'Tag', 'pbSelectPrevParticle', ...
            'Callback', @OnPBSelectPrevParticle, 'String', '<', 'Units', fig_units);
        pos_pbSelectPrevParticle = [1, 1, 5, 1.5];
        set(hpbSelectPrevParticle, 'Position', pos_pbSelectPrevParticle);

        hpbSelectNextParticle = uicontrol('Parent', hBottomPanel, 'Style', 'pushbutton', 'Tag', 'pbSelectNextParticle', ...
            'Callback', @OnPBSelectNextParticle, 'String', '>', 'Units', fig_units);
        pos_pbSelectNextParticle = [pos_pbSelectPrevParticle(1) + pos_pbSelectPrevParticle(3) + 1, 1, 5, 1.5];
        set(hpbSelectNextParticle, 'Position', pos_pbSelectNextParticle);

        % checkbox that controls whether only enabled or also the
        % disabled particles should be selected with the buttons above
        hcbSelectOnlyEnabled = uicontrol('Parent', hBottomPanel, 'Style', 'checkbox', 'Tag', 'cbSelectOnlyEnabled', ...
            'String', 'Select only enabled rectangles', 'Units', fig_units);
        pos_cbSelectOnlyEnabled = [pos_pbSelectNextParticle(1) + pos_pbSelectNextParticle(3) + 1, 1, 35, 1.5];
        set(hcbSelectOnlyEnabled, 'Position', pos_cbSelectOnlyEnabled);

        % checkbox that controls whether the currently selected particle should
        % be zoomed
        hcbZoomSelected = uicontrol('Parent', hBottomPanel, 'Style', 'checkbox', 'Tag', 'cbZoomSelected', ...
            'String', 'Zoom Selected', 'Units', fig_units);
        pos_cbZoomSelected = [pos_cbSelectOnlyEnabled(1) + pos_cbSelectOnlyEnabled(3) + 1, 1, 25, 1.5];
        set(hcbZoomSelected, 'Position', pos_cbZoomSelected);



% LAST CALL!!!!            
    SetScanImageFigureElementSizes(hFig);
            
%
% callback of the pbSelectPrevParticle button
function OnPBSelectPrevParticle(src, evnt)
    hFig = ancestor(src, 'figure', 'toplevel');
    
    hRectangle = GetSelectedRectangles(hFig);
    particle_index = get(hRectangle(1), 'UserData');
    sTag = get(hRectangle(1), 'Tag');
    new_particle_index = particle_index;
    num_of_all_particles = GetNumOfAllParticles(hFig);
    
    
    
    % find the next enabled rectangle that has the same tag
    for i=particle_index-1:-1:1
        hNewRect = findobj(hFig, 'UserData', i, 'Tag', sTag);
        if (isempty(hNewRect)) % there are no more particles left to select
            new_particle_index = particle_index;
            break;
        end
        if (get(findobj(hFig, 'Tag', 'cbSelectOnlyEnabled'), 'Value'))
            if (strcmp(get(hNewRect, 'LineStyle'), '-'))
                new_particle_index = i;
                break;
            end
        else
            new_particle_index = i;
            break;
        end
    end
    
    % unselect particles
    set(hRectangle, 'Selected', 'off');
    
    hSelRectangle = SelectParticle(hFig, new_particle_index);
    
    xpos = get(hSelRectangle, 'XData');
    ypos = get(hSelRectangle, 'YData');

    cur_mouse_point = [(xpos(1)+xpos(3)) / 2, (ypos(1)+ypos(3)) / 2];

    hAxis = findobj(hFig, 'Tag', 'nmssScanImageAxes');
    if (get(findobj(hFig, 'Tag', 'cbZoomSelected'), 'Value'))
        zoom_level = 4;
    else
        zoom_level = 1;
    end
    ZoomValueImage(hFig, hAxis, cur_mouse_point, zoom_level);
    
% callback of the pbSelectNextParticle button
function OnPBSelectNextParticle(src, evnt)
    hFig = ancestor(src, 'figure', 'toplevel');
    
    hRectangle = GetSelectedRectangles(hFig);
    particle_index = get(hRectangle(1), 'UserData');
    sTag = get(hRectangle(1), 'Tag');
    new_particle_index = particle_index;
    num_of_all_particles = GetNumOfAllParticles(hFig);
    

    % find the next enabled rectangle that has the same tag
    for i=particle_index+1:num_of_all_particles
        hNewRect = findobj(hFig, 'UserData', i, 'Tag', sTag);
        if (isempty(hNewRect)) % there are no more particles left to select
            new_particle_index = particle_index;
            break;
        end
        if (get(findobj(hFig, 'Tag', 'cbSelectOnlyEnabled'), 'Value'))
            if (strcmp(get(hNewRect, 'LineStyle'), '-'))
                new_particle_index = i;
                break;
            end
        else
            new_particle_index = i;
            break;
        end
    end
    
    % unselect particles
    set(hRectangle, 'Selected', 'off');
    
    hSelRectangle = SelectParticle(hFig, new_particle_index);
    
    xpos = get(hSelRectangle, 'XData');
    ypos = get(hSelRectangle, 'YData');
    
    cur_mouse_point = [(xpos(1)+xpos(3)) / 2, (ypos(1)+ypos(3)) / 2];
    
    hAxis = findobj(hFig, 'Tag', 'nmssScanImageAxes');
    if (get(findobj(hFig, 'Tag', 'cbZoomSelected'), 'Value'))
        zoom_level = 4;
    else
        zoom_level = 1;
    end
    ZoomValueImage(hFig, hAxis, cur_mouse_point, zoom_level);
    
             
%
function ButtonDownInImage(varargin)

    hImage = varargin{1};
    hFig = ancestor(hImage, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    mouse_pointer = get(hFig, 'Pointer');
    % don't do anything if in rubberband drawing mode (mouse changes to
    % crosshair)
    if (strcmp(mouse_pointer, 'crosshair')) return; end;
    
    hAxis = gca;
    cur_mouse_point = get(hAxis, 'CurrentPoint');
    
    % returns selection type (mouse click in combination with any keyboard
    % modifier key
    sSelectionType = get(hFig, 'SelectionType');
    
    zoom_factor = 1.5;
    
    if (strcmp(sSelectionType, 'normal'))
        image_zoom_value = user_data.gui.image_zoom_value * zoom_factor;
    elseif (strcmp(sSelectionType, 'alt'))
        image_zoom_value = user_data.gui.image_zoom_value / zoom_factor;
    elseif (strcmp(sSelectionType, 'open'))
        image_zoom_value = 1;
    end
    
    if (image_zoom_value < 1) image_zoom_value = 1; end;
    ZoomValueImage(hFig, hAxis, cur_mouse_point, image_zoom_value);
    
%
function ZoomValueImage(hFig, hAxis, cur_mouse_point, image_zoom_value)
    user_data = get(hFig, 'UserData');
    
    max_lim_x = user_data.results.real_space_img.x_max;
    max_lim_y = user_data.results.real_space_img.y_max;
    min_lim_x = user_data.results.real_space_img.x_min;
    min_lim_y = user_data.results.real_space_img.y_min;
%     max_lim_x = size(get(hImage, 'CData'), 2);
%     max_lim_y = size(get(hImage, 'CData'), 1);
    

    new_width = abs(max_lim_x - min_lim_x) / image_zoom_value;
    new_height = abs(max_lim_y - min_lim_y) / image_zoom_value;
    
    if (new_width > max_lim_x) new_width = max_lim_x; end
    if (new_height > max_lim_y) new_height = max_lim_y; end
    
    new_axis = [cur_mouse_point(1, 1) - new_width / 2, ... 
                cur_mouse_point(1, 1) + new_width / 2, ...
                cur_mouse_point(1, 2) - new_height / 2, ...
                cur_mouse_point(1, 2) + new_height / 2];
    % limit new axes to the boundaries of the image - if necessary
    if (new_axis(1) < min_lim_x) new_axis(1) = min_lim_x; new_axis(2) = min_lim_x + new_width; end
    if (new_axis(3) < min_lim_y) new_axis(3) = min_lim_y; new_axis(4) = min_lim_y + new_height; end
    if (new_axis(2) > max_lim_x) new_axis(2) = max_lim_x; new_axis(1) = max_lim_x - new_width; end
    if (new_axis(4) > max_lim_y) new_axis(4) = max_lim_y; new_axis(3) = max_lim_y - new_height; end
    axis(hAxis, new_axis);
    
    user_data.gui.image_zoom_value = image_zoom_value;
    
    %disp('mouse button pressed in scan image');
    set(hFig, 'UserData', user_data);
             
% called upon close request
function CloseRequestScanImageFigure(varargin)

    hFig = gcf;
    
    button = questdlg('Do you want to close scan analysis window','Scan Analysis','Yes','No','No');
    
    if (strcmp(button, 'Yes'))
        delete(hFig);
    end
             
%  Sets the sizes and positions of the axes that are displayed in this figure          
function SetScanImageFigureElementSizes(hFigure)
    user_data = get(hFigure, 'UserData');

    
    hImgAx = findobj(hFigure, 'Tag', 'nmssScanImageAxes');
    if (isempty(hImgAx) || ~ishandle(hImgAx)) return; end;
    hGraph1Axs = findobj(hFigure, 'Tag', 'nmssScanImageGraph1Axes');
    if (isempty(hGraph1Axs) || ~ishandle(hGraph1Axs)) return; end;
    hGraph2Axs = findobj(hFigure, 'Tag', 'nmssScanImageGraph2Axes');
    if (isempty(hGraph2Axs) || ~ishandle(hGraph2Axs)) return; end;
    hBottomPanel = findobj(hFigure, 'Tag', 'nmssScanImageBottomPanel');
    if (isempty(hBottomPanel) || ~ishandle(hBottomPanel)) return; end;
    
    set(hFigure, 'Units', 'character');
    fig_units = get(hFigure, 'Units');
    
    fig_pos = get(hFigure, 'Position');
    
    % set minimum size of the figure
    % width
    if (fig_pos(3) < user_data.gui.window_min_width)
        fig_pos(3) = user_data.gui.window_min_width;
        if (fig_pos(1) ~= user_data.gui.window_pos(1))
            % left side was resized
            fig_pos(1) = user_data.gui.window_pos(1);
        end
    end
    
    % height
    if (fig_pos(4) < user_data.gui.window_min_height)
        fig_pos(4) = user_data.gui.window_min_height;
        if (fig_pos(2) ~= user_data.gui.window_pos(2))
            % bottom side was resized
            fig_pos(2) = user_data.gui.window_pos(2);
        end
    end
    set(hFigure, 'Position', fig_pos);
    
    % save the window position
    user_data.gui.window_pos = fig_pos;
    
    % define position of the bottom panel
    pos_nmssScanImageBottomPanel = get(hBottomPanel, 'Position');
    pos_nmssScanImageBottomPanel(3) = fig_pos(3) - 2;
    set(hBottomPanel, 'Units', fig_units, 'Position', pos_nmssScanImageBottomPanel);
    pos_bottom_panel = get(hBottomPanel, 'Position');
    
    % define the position of the bottom panel
    img_axes_pos = [user_data.gui.yaxis_label_width, pos_bottom_panel(2) + pos_bottom_panel(4) + user_data.gui.xaxis_label_height, ...
        fig_pos(3) * 0.65, ...
        fig_pos(4) - user_data.gui.xaxis_label_height - user_data.gui.figure_title_height - pos_bottom_panel(2) - pos_bottom_panel(4)];
    
    % ensure that no negative width or height is used
    if ~isempty(find(img_axes_pos(3:4) <= 0)) return; end;
        
    set(hImgAx, 'Units', fig_units, 'Position', img_axes_pos, ...
        'Tag', 'nmssScanImageAxes');
    
    
    img_axes_pos = get(hImgAx, 'Position');

    % the graph containing the measured particle and background spectrum
    graph1_axes_pos = img_axes_pos;
    graph1_axes_pos(1) = img_axes_pos(1) + img_axes_pos(3) + user_data.gui.yaxis_label_width;
    graph1_axes_pos(2) = img_axes_pos(2) + img_axes_pos(4) / 2 + user_data.gui.xaxis_label_height;
    graph1_axes_pos(3) = fig_pos(3) - img_axes_pos(3) - img_axes_pos(1) - 2 * user_data.gui.yaxis_label_width;
    graph1_axes_pos(4) = img_axes_pos(4) / 2 - user_data.gui.xaxis_label_height;
    set(hGraph1Axs, 'Units', fig_units, 'Position', graph1_axes_pos, ...
        'Tag', 'nmssScanImageGraph1Axes', 'Visible', 'on');

    % the graph containing the background corrected spectrum
    graph2_axes_pos = img_axes_pos;
    graph2_axes_pos(1) = img_axes_pos(1) + img_axes_pos(3) + user_data.gui.yaxis_label_width;
    graph2_axes_pos(2) = img_axes_pos(2);
    graph2_axes_pos(3) = fig_pos(3) - img_axes_pos(3) - img_axes_pos(1) - 2 * user_data.gui.yaxis_label_width;
    graph2_axes_pos(4) = img_axes_pos(4) / 2 - user_data.gui.xaxis_label_height;
    set(hGraph2Axs, 'Units', fig_units, 'Position', graph2_axes_pos, ...
         'Tag', 'nmssScanImageGraph2Axes','Visible', 'on');
    
    
    
    % find the maximum string length that fits into the figure
    k = 1;
    l = 1;
    increase_k = true;
                  
    while (true)
        
       [short_work_dir, max_num_of_dir_parts] = nmssCreateShortDirPath( user_data.results.working_dir, l, k);
       length_Text = length(short_work_dir);
       
       
       figure_name = ['Scan Analysis Dialog: ', short_work_dir];
       fig_pos = get(hFigure, 'Position');
       fig_length = fig_pos(3) * 0.7 - 25; % the charcater size is often much larger than the number of charactes, because
       % true type fonts have different sizes. Plus the wondow bar contains
       % the text: "Figure 2:"
       
       if (length_Text < fig_length) 
           % figure name fits into the window bar of the figure
           set(hFigure, 'Name', figure_name);
%            disp([num2str(length_Text), ' ', num2str(fig_length), ...
%                 ' l=', num2str(l), ' k=', num2str(k), ' - ', figure_name]);
       else
           % figure name is larger than the window bar of the figure: EXIT
           break;
       end
       
       % full path could be displayed so we can leave the loop
       if (k+l > max_num_of_dir_parts)
           break;
       end
       
       % increase the left side and the right side number of displayed path
       % elements alternatevly. First it indreases the right side then the
       % left side.
       if (increase_k)
           k = k+1;
       else
           l = l+1;
       end
       
       increase_k = ~increase_k;
    end
    
    set(hFigure, 'UserData', user_data);
             
% Called upon resizing the figure window   
function ResizeScanImageFigure(varargin)

    SetScanImageFigureElementSizes(varargin{1});  
    
    
    
             
            
            
            
% --- Executes on key press over nmssFigure with no controls selected.
function FigureKeyPressedCallback(hFig, evnt)
    % src    handle to nmssFigure (see GCBO)
    % eventdata  - a structure which contains necessary infromations about the
    % key event. eventdata.Modifier = 'alt', 'ctrl', 'shift' etc..
    % eventdata.Key = the name of the key, that is pressed

    if (strcmp(evnt.Key,'d'))
        % disable current rectangle
        MenuBoundingRectCallback_Disable();
        SelectParticle(hFig)
    elseif (strcmp(evnt.Key,'e'))
        % enable current rectangle
        hRectangle = GetSelectedRectangles(hFig);
        if (length(hRectangle) ~= 1) return; end;

        MenuBoundingRectCallback_Edit(hRectangle, []);
    elseif (strcmp(evnt.Key,'r'))
        % resize selected rectangle
        
        hRectangle = GetSelectedRectangles(hFig);
        if (length(hRectangle) ~= 1) return; end;

        MenuBoundingRectCallback_ResetSize(hRectangle, []);
        
    elseif (strcmp(evnt.Key,'m'))
        % recenter selected rectangle and corresponding other rectangle,
        % works only if just one rectangle is selected
        
        hRectangle = GetSelectedRectangles(hFig);
        if (length(hRectangle) ~= 1) return; end;

        MenunBoundingRectCallback_MoveSelected(hRectangle, []);
        
    elseif (strcmp(evnt.Key,'c'))
        % recenter selected rectangle and corresponding other rectangle,
        % works only if just one rectangle is selected
        
        hRectangle = GetSelectedRectangles(hFig);
        if (length(hRectangle) ~= 1) return; end;

        MenuBoundingRectCallback_ReCenterRectAndBG(hRectangle, []);
        
    elseif (strcmp(evnt.Key,'space'))
        hRectangle = GetSelectedRectangles(hFig);
        
        hDisabledRect = findobj(hRectangle, 'LineStyle', ':');
        hEnabledRect = findobj(hRectangle, 'LineStyle', '-');
        
        EnableRectangleGroup(hDisabledRect);
        DisableRectangleGroup(hEnabledRect);
        
        particle_index = get(hRectangle(1), 'UserData');
        SelectParticle(hFig, particle_index);
        
    elseif (strcmp(evnt.Key,'rightarrow'))
        OnPBSelectNextParticle(hFig, []);
    elseif (strcmp(evnt.Key,'leftarrow'))
        OnPBSelectPrevParticle(hFig, []);
    else
%          disp('Key pressed:');
%          disp(evnt);
    end
%
function MenuData(parent)
    %uimenu(parent,  'Label', 'Save Results', 'Callback', {@MenuSaveResultsAs,gcf()});
    uimenu(parent,  'Label', 'View All Results', 'Callback', @MenuData_ViewResults);
    uimenu(parent,  'Label', 'View Enabled Results', 'Callback', @MenuData_ViewEnabledResults);
    uimenu(parent,  'Label', 'Save Results As...', 'Callback', @MenuData_SaveResultsAs);
    uimenu(parent,  'Label', 'Load Marker', 'Callback', @MenuData_LoadMarker, ...
        'Separator', 'on');
    uimenu(parent,  'Label', 'Save Marker As...', 'Callback', @MenuData_SaveMarker);
    
%
function MenuSpectrum(parent)

    uimenu(parent,  'Label', 'Analysis Settings', 'Callback', @MenuSpectrum_AnalysisSettings);
    uimenu(parent,  'Label', 'Peak Analysis', 'Callback', @MenuSpectrum_CurveAnalysis);
    uimenu(parent,  'Label', 'Recalculate', 'Callback', @MenuSpectrum_Recalculate, ...
        'Separator', 'on');
    hMenuSmoothing = uimenu(parent,  'Label', 'Smoothing');
    uimenu(hMenuSmoothing,  'Label', 'Smooth Backgr. Corr.', 'Callback', @MenuSpectrum_SmoothBGCorr);
    uimenu(hMenuSmoothing,  'Label', 'Smooth White Light', 'Callback', @MenuSpectrum_SmoothWhiteLight);
    
    uimenu(parent,  'Label', 'Show White Light', 'Callback', @MenuSpectrum_ShowWhiteLight);
    uimenu(parent,  'Label', 'Show Berg Plot', 'Callback', @MenuSpectrum_BergPlot, ...
        'Separator', 'on');
    
    

%    
function MenuSpectrum_SmoothWhiteLight(src, evnt)
    hMenu = src;
    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');

%     results.white_light.smooth.param = 30; % use smooth white light if it contains interference pattern
%     results.white_light.smooth.spec = smooth(results.white_light.raw, results.white_light.smooth.param)';
%     results.white_light.use = 'raw'; % possible values 'raw', 'smooth' - specifies which white light should be used for normalization
    white_light = user_data.results.white_light;
    
    % smoothing on or off
    if (~strcmp(white_light.use,'smooth'))
        set(hMenu, 'Checked', 'on');
        % open smoothing param dialog
        [user_action, new_param] = nmssImputParamDlg('Set Smoothing Param', 'Smoothing parameter for White Light: ', ...
            white_light.smooth.param);
        if (strcmp(user_action, 'OK'))
            white_light.smooth.param = new_param;
            white_light.use = 'smooth';
            set(hMenu, 'Checked', 'on');
        else
            white_light.use = 'raw';
            set(hMenu, 'Checked', 'off');
        end
        
    else
        white_light.use = 'raw';
        set(hMenu, 'Checked', 'off');
    end
    user_data.results.white_light = white_light;
    set(hFig, 'UserData', user_data);    
    
% switch smoothing on and off
function MenuSpectrum_SmoothBGCorr(src, evnt)
    
    hMenu = src;
    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    % smoothing on or off
    if (~user_data.results.spec_smoothing.flag)
        set(hMenu, 'Checked', 'on');
        % open smoothing param dialog
        [user_action, new_param] = nmssImputParamDlg('Set Smoothing Param', 'Smoothing parameter for BG corr. spec: ', ...
            user_data.results.spec_smoothing.param);
        if (strcmp(user_action, 'OK'))
            user_data.results.spec_smoothing.param = new_param;
            user_data.results.spec_smoothing.flag = true;
            set(hMenu, 'Checked', 'on');
        else
            user_data.results.spec_smoothing.flag = false;
            set(hMenu, 'Checked', 'off');
        end
        
    else
        set(hMenu, 'Checked', 'off');
        user_data.results.spec_smoothing.flag = false;
    end
    set(hFig, 'UserData', user_data);    
    
    
%
function MenuSpectrum_Recalculate(src, evnt)
    
    hFig = ancestor(src, 'figure', 'toplevel');
%     if (~CanAccessImgBlock(hFig))
%         WarningNoAccessToImgBlock(hFig);
%         return;
%     end
    
    UpdateParticles(hFig);
    
    RecalculateSpectrum(hFig);

% menu item: show white light
function MenuSpectrum_ShowWhiteLight(src, evnt)
    
    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    roi_in_px = user_data.results.spec_roi_in_px;
    
    % select which whit light to use
    if (strcmp(user_data.results.white_light.use, 'smooth'))
        white_light_roi = user_data.results.white_light.smooth.spec(roi_in_px.x:roi_in_px.x+roi_in_px.wx - 1);
        white_light = user_data.results.white_light.smooth.spec;
    else
        white_light_roi = user_data.results.white_light.raw(roi_in_px.x:roi_in_px.x+roi_in_px.wx - 1);
        white_light = user_data.results.white_light.raw;
    end
    x_axis = user_data.results.white_light.x_axis;
    x_axis_roi = user_data.results.white_light.x_axis(roi_in_px.x:roi_in_px.x+roi_in_px.wx - 1);
    
    % display white light
    hWL = figure;
    plot(x_axis, white_light, 'r', 'DisplayName', 'White Light');
    hAx = findobj(hWL, 'Type', 'axes');
    hold(hAx, 'on');
    plot(x_axis_roi, white_light_roi, 'b', 'DisplayName', 'White Light in ROI');
    title('White Light used for normalization');
    legend(hAx, 'show');
    
    
%    
function MenuView(parent)

    uimenu(parent,  'Label', 'Zoom', 'Callback', @MenuView_Zoom);
    uimenu(parent,  'Label', 'Contrast/Brightness', 'Callback', @MenuView_ContrastBrightness,  ...
        'Separator', 'on');
    %uimenu(parent,  'Label', 'Zoom Out', 'Callback', @MenuView_ZoomOut);
    
%    
function MenuView_Zoom(varargin)
    
    hMenu = varargin{1};
    hMenuBar = get(hMenu, 'Parent');
    hFigure = get(hMenuBar, 'Parent');
    
    isChecked = get(hMenu, 'Checked');
    if (strcmp(isChecked,'on'))
        zoom(hFigure, 'off');
        set(hMenu, 'Checked', 'off');
    else
        zoom(hFigure, 'on');
        set(hMenu, 'Checked', 'on');
    end

function MenuView_ContrastBrightness(src, evnt)
    
    hFig = ancestor(src, 'figure', 'toplevel');


    hDlg = nmssImageEnhancementDlg();
    dlg_user_data = get(hDlg, 'UserData');
    %set(hDlg, 'WindowStyle', 'modal')
    dlg_user_data.targetFigure  = hFig;
    
    set(hDlg, 'UserData',dlg_user_data);
    
    %start dialog
    dlg_user_data.hFigInitFcn(hDlg);
    

%
function MenuView_ZoomOff(varargin)

    hMenu = varargin{1};
    hMenuBar = get(hMenu, 'Parent');
    hFigure = get(hMenuBar, 'Parent');
    zoom(hFigure, 'off');

    
% menu that is displayed both on right click on a bounding rectangle and on
% the menu entry in the menu bar
%function BoundingRectMenuBar(parent)
function MenuBoundingRectBar(parent)
    uimenu(parent,  'Label', 'Select All', 'Callback', @MenuBoundingRectCallback_Select_All, ...
        'Separator', 'on');
    uimenu(parent,  'Label', 'Select Region', 'Callback', @MenuBoundingRectCallback_SelectRegion);
    uimenu(parent,  'Label', 'Select by number', 'Callback', @MenuBoundingRectCallback_SelectByNumber);
    uimenu(parent,  'Label', 'Unselect All', 'Callback', @MenuBoundingRectCallback_Unselect_All);
    uimenu(parent,  'Label', 'Move Selected', 'Callback', @MenunBoundingRectCallback_MoveSelected, ...
        'Separator', 'on');
    uimenu(parent,  'Label', 'Recenter Selected And ... (C)', 'Callback', @MenuBoundingRectCallback_ReCenterRectAndBG);
    hMenuBackground = uimenu(parent,  'Label', 'Background...', 'Separator', 'on');
    uimenu(hMenuBackground,  'Label', 'Set Vertical Offset', 'Callback', @MenuRectangle_VOffset);
    uimenu(hMenuBackground,  'Label', 'Set Horizontal Offset', 'Callback', @MenuRectangle_HOffset);
    uimenu(hMenuBackground,  'Label', 'Resize All Backgrounds', 'Callback', @MenuRectangle_BGResizeAll);
    uimenu(hMenuBackground,  'Label', 'Resize Selected Backgrounds', 'Callback', @MenuRectangle_BGResizeSel);
    
% callback for 'Set Vertical Offset'
function MenuRectangle_VOffset(src, evnt)
    
    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    [user_action, new_param] = nmssImputParamDlg('Set Vertical Offset', 'Enter offset in pixel: ', ...
        user_data.doc.bg.voffset, {'The offset is added above and below to the'; ...
             ' particle bounding rectangle'});
    if (strcmp(user_action, 'OK'))
        if (new_param < 0)
            errordlg('Please enter a number larger than 0');
            return;
        end
        user_data.doc.bg.voffset = new_param;
        set(hFig, 'UserData', user_data);
    end

% callback for 'Set Horizontal Offset'
function MenuRectangle_HOffset(src, evnt)
    
    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    [user_action, new_param] = nmssImputParamDlg('Set Horizontal Offset', 'Enter offset in pixel: ', ...
        user_data.doc.bg.hoffset, {'The offset is added left and right to the'; ...
             ' particle bounding rectangle'});
    if (strcmp(user_action, 'OK'))
        if (new_param < 0)
            errordlg('Please enter a number larger than 0');
            return;
        end
        user_data.doc.bg.hoffset = new_param;
        set(hFig, 'UserData', user_data);
    end
    
%
% Resizes all backgorund rectangles according to the defined values
function MenuRectangle_BGResizeSel(src, evnt)
    
    hFig = ancestor(src, 'figure', 'toplevel');
    hRectangle = GetSelectedRectangles(hFig);
    hBGRectangle = findobj(hRectangle, 'Tag', 'nmssParticle_BG_Rect');
    ResizeBGRectangles(hFig, hBGRectangle);
%
% Resizes all backgorund rectangles according to the defined values
function MenuRectangle_BGResizeAll(src, evnt)
    
    hFig = ancestor(src, 'figure', 'toplevel');
    hRectangle = GetAllRectangles(hFig);
    hBGRectangle = findobj(hRectangle, 'Tag', 'nmssParticle_BG_Rect');
    ResizeBGRectangles(hFig, hBGRectangle);

%
% Resize rectangles
function ResizeBGRectangles(hFig, hBGRectangle)
    
    user_data = get(hFig, 'UserData');
    
    hPRectangles = GetCorrespondingOtherRectangle(hBGRectangle);
    
    pos_x = get(hPRectangles, 'XData');
    if (iscell(pos_x)) pos_x = cell2mat(pos_x); end;
    
    pos_y = get(hPRectangles, 'YData');
    if (iscell(pos_y)) pos_y = cell2mat(pos_y); end;
    
    % s-dimension is meaningless now and here
    pos = [pos_x(:,1) - user_data.doc.bg.hoffset, pos_y(:,1) - user_data.doc.bg.voffset, ones(size(pos_x,1),1), ...
           pos_x(:,3) + user_data.doc.bg.hoffset, pos_y(:,3) + user_data.doc.bg.voffset, ones(size(pos_x,1),1)];
       

    roi = FitRoiIntoImage(pos, user_data.results.real_space_img);           


    MoveRectangle(hBGRectangle, roi(:,1), roi(:,2), roi(:,4), roi(:,5));

    num_of_moved_particles = length(hBGRectangle);
    for i=1:num_of_moved_particles
        k = get(hBGRectangle(i), 'UserData');
        user_data.results.particle(k,1).bg([1,2,4,5]) = roi(i,[1,2,4,5]);
    end
    
    set(hFig, 'UserData', user_data);
    
    UpdateParticles(hFig);
    
    RecalculateSpectrum(hFig);
    
    
    


function ContextMenuBoundingRect(parentmenu)
    uimenu(parentmenu,  'Label', 'Edit', 'Callback', @MenuBoundingRectCallback_Edit, ...
        'Separator', 'on');
    uimenu(parentmenu,  'Label', 'Recenter (C)', 'Callback', @MenuBoundingRectCallback_ReCenterRectAndBG);
    uimenu(parentmenu,  'Label', 'Reset Size', 'Callback', @MenuBoundingRectCallback_ResetSize);


function MenuSharedBoundingRect(parent)

    uimenu(parent,  'Label', 'Disable (Space)', 'Callback', @MenuBoundingRectCallback_Disable);
    uimenu(parent,  'Label', 'Enable (Space)', 'Callback', @MenuBoundingRectCallback_Enable);
%
function MenuBoundingRectCallback_Edit(src, evnt)
    
    % get the current bounding rectangle
    if (strcmp(get(src,'Tag'),'nmssParticle_BG_Rect') || ...
        strcmp(get(src,'Tag'),'nmssParticleBoundingRect'))
        hRect = src;
    else
        hRect = gco();
    end
    
    sTag = get(hRect, 'Tag');
    
    hFig = ancestor(hRect,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
    
    [point1, point2] = GetNewRectangleFromMouse(hFig);
    
    particle_index = get(hRect, 'UserData');
    pOld = user_data.results.particle(particle_index,1);
    
    new_roi = [point1(1), point1(2), pOld.p(3), point2(1), point2(2), pOld.p(6)];
    new_roi = SnapToPixels(new_roi, user_data.results.real_space_img);
    new_roi = FitRoiIntoImage(new_roi, user_data.results.real_space_img)    
    

    MoveRectangle(hRect, new_roi(1), new_roi(2), new_roi(4), new_roi(5));
        
    if (strcmp(sTag, 'nmssParticleBoundingRect'))
        %pOld.p = [point1(1), point1(2), pOld.p(3), point2(1), point2(2), pOld.p(6)]; 
        pOld.p = new_roi; 
    else
        %pOld.bg = [point1(1), point1(2), pOld.bg(3), point2(1), point2(2), pOld.bg(6)];
        pOld.bg = new_roi;
    end

    
    [pNew, status] = GetSpectrum(hFig, pOld, user_data.results.white_light, user_data.results.spec_roi_in_px, ...
                        user_data.results.real_space_img, user_data.results.spec_smoothing);
    if (~strcmp(status, 'OK')) return; end;
                    
    
    user_data.results.particle(particle_index,1) = pNew;
    
    set(hFig, 'UserData', user_data);
    
    DisplayGraphs(hFig, particle_index);
    
    SelectParticle(hFig, particle_index, sTag);
    

function MenuBoundingRectCallback_SelectByNumber(src, evnt)
% callback for menu item: Select by number
% user may select the particle by entering its number
    
    hMenu = src;
    hFig = ancestor(src, 'figure', 'toplevel');
    hRect = GetSelectedRectangles(hFig);
    
    if (~isempty(hRect))
        selected_particle_number = get(hRect(1), 'UserData');
    else
        selected_particle_number = 1;
    end
    
    % open parameter entry dialog
    [user_action, new_param] = nmssImputParamDlg('Select particle by number', 'Enter particle number: ', ...
        selected_particle_number);
    if (strcmp(user_action, 'OK'))
        selected_particle_number = new_param;
    end
    
    % check if entered value is in the allowed range
    num_of_all_particles = GetNumOfAllParticles(hFig);
    if (selected_particle_number > num_of_all_particles)
        uiwait(errordlg(['Please enter a number smaller or equal ', sprintf('%4d',num_of_all_particles)]));
        return;
    end
    if (selected_particle_number < 1)
        uiwait(errordlg('Please enter a number greater or equal 1'));
        return;
    end
        
    % select desired particle
    SelectParticle(hFig, selected_particle_number);
    
    
    
function MenuBoundingRectCallback_SelectRegion(src, evnt)
% callback for menu item: Select Region
% user can select particles by selecting a region
    
    hFig = ancestor(src, 'figure', 'toplevel');
    
    % draw rubberband
    [point1, point2] = GetNewRectangleFromMouse(hFig)
    
    % select rectangles inside of the rubberband
    hRectangles = GetAllRectangles(hFig);
    
    pos_x = get(hRectangles, 'XData');
    if (iscell(pos_x)) pos_x = cell2mat(pos_x); end;
    
    pos_y = get(hRectangles, 'YData');
    if (iscell(pos_y)) pos_y = cell2mat(pos_y); end;
    
    pos = [pos_x(:,1), pos_y(:,1), pos_x(:,3), pos_y(:,3)];
    
    % find particles that are inside of the rubberband
    rect_in_region_index = intersect(intersect(find(pos(:,3)' >= point1(1)), find(pos(:,4)' >= point1(2))), ...
                                     intersect(find(pos(:,3)' <= point2(1)), find(pos(:,4)' <= point2(2))));
    
    hRectToSelect = hRectangles(rect_in_region_index);
    set(hRectToSelect, 'Selected', 'on');
    
    
%
function MenuBoundingRectCallback_ResetSize(src, evnt)
% resets the background rectangle to the default relative size
    
    % get the current bounding rectangle
    if (strcmp(get(src,'Tag'),'nmssParticle_BG_Rect') || ...
        strcmp(get(src,'Tag'),'nmssParticleBoundingRect'))
        hRect = src;
    else
        hRect = gco();
    end
    
    if (~strcmp(get(hRect, 'Type'), 'line')) return; end;
    
    hFig = ancestor(hRect,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
%     if (~CanAccessImgBlock(hFig))
%         WarningNoAccessToImgBlock(hFig);
%         return;
%     end
    
    sTag = get(hRect, 'Tag');
    particle_index = get(hRect, 'UserData');
    oldParticle = user_data.results.particle(particle_index,1);
    
    % particle bounding rectangle
    if (strcmp(sTag,'nmssParticleBoundingRect'))
%         particle_out = GetParticleBoundingRect(user_data.results.real_space_img, user_data.results.spec_roi_in_px, ...
%                                                user_data.results.analysis);
%                                            
%         newRect = particle_out(particle_index,1).p;
%         oldParticle.p = newRect;
    % particle background rectangle
        return;
    elseif (strcmp(sTag,'nmssParticle_BG_Rect'))
        particle_out = GetBackgroundBoundingRectangles(oldParticle, user_data.results.real_space_img, ...
                        user_data.doc.bg);
        
        newRect = particle_out(1,1).bg;
        oldParticle.bg = newRect;
        
    else
        return;
    end
    
    MoveRectangle(hRect, newRect(1), newRect(2), newRect(4), newRect(5));
    [newParticle, status] = GetSpectrum(hFig, oldParticle, user_data.results.white_light, ...
                              user_data.results.spec_roi_in_px, user_data.results.real_space_img, ...
                              user_data.results.spec_smoothing);
    if (~strcmp(status, 'OK')) return; end;
                          
                              
    user_data.results.particle(particle_index,1) = newParticle;
    
    % save changed data in figure
    set(hFig, 'UserData', user_data);
    
    % refresh figure
    DisplayGraphs(hFig, particle_index);
    
    SelectParticle(hFig, particle_index, sTag);
    
        
    
    
%
function [p1, p2] = GetNewRectangleFromMouse(hFig)
    old_units = get(hFig, 'Units');
    set(hFig, 'Units', 'Pixels');

    % edit dimension and position of the
    old_cursor_pointer = get(hFig,'Pointer');

        set(hFig,'Pointer','crosshair')
        k = waitforbuttonpress;
        point1 = get(gca,'CurrentPoint');    % button down detected
        finalRect = rbbox();                   % return figure units
        point2 = get(gca,'CurrentPoint');    % button up detected
        
        % top left
        p1 = [min(point1(1,1), point2(1,1)), min(point1(1,2), point2(1,2))];              % extract x and y
        % bottom right
        p2 = [max(point1(1,1), point2(1,1)), max(point1(1,2), point2(1,2))];              % extract x and y

    % must be the last command
    set(hFig, 'Units', old_units);
    set(hFig,'Pointer', old_cursor_pointer);
        
    
% moves the specified nmssRectangle to a new position given by the
% coordinates of the top left and bottom right corner
function MoveRectangle(hRect, new_x1, new_y1, new_x2, new_y2)

    new_x = [new_x1, new_x2, new_x2, new_x1, new_x1];
    new_y = [new_y1, new_y1, new_y2, new_y2, new_y1];
    
    num_of_rects = length(hRect);
    for i=1:num_of_rects
        set(hRect(i), 'XData', new_x(i,:));
        set(hRect(i), 'YData', new_y(i,:));
    end
    
    

function MenuBoundingRectCallback_Select_All(src, evnt)
    
    hFig = ancestor(src, 'figure', 'toplevel');
    

    hRectangle = GetAllRectangles(hFig);
    
    set(hRectangle, 'Selected', 'on');



function MenuBoundingRectCallback_Unselect_All(src, evnt)
    hFig = ancestor(src, 'figure', 'toplevel');

    hRectangle = GetSelectedRectangles(hFig);
    
    set(hRectangle, 'Selected', 'off');
                    

%
function hCorrRectangle = GetCorrespondingOtherRectangle(hRectangle)
    
    hGR = get(hRectangle, 'Parent');
    if (iscell(hGR)) hGR = cell2mat(hGR); end;
    
    hCorrRectangle = [];
    % find recangles that balong to the same particle but have a different
    % tag than the selected rectangle
    for i=1:length(hRectangle)
%         ix = get(hRectangle(i), 'UserData');
        sTag = get(hRectangle(i), 'Tag');
        %h = findobj(hFig, 'UserData', ix, '-not', 'Tag', sTag, 'Type', 'line');
        h = findobj(hGR(i), '-not', 'Tag', sTag, 'Type', 'line');
        if (~isempty(h))
            hCorrRectangle(i) = h;
        end
    end
    

function MenuBoundingRectCallback_Enable(src, evnt)
        
    hFig = ancestor(src, 'figure', 'toplevel');
    hRectangle = GetSelectedRectangles(hFig);
    hCorrRectangle = GetCorrespondingOtherRectangle(hRectangle);
    
    EnableRectangle(hRectangle);
    EnableRectangle(hCorrRectangle);
    
    set(hRectangle, 'Selected', 'on');
    
function EnableRectangleGroup(hRectangle)
    hGR = get(hRectangle, 'Parent');
    if (iscell(hGR)) hGR = cell2mat(hGR); end;
    hRectangles = findobj(hGR, 'Type', 'line');
    EnableRectangle(hRectangles);
    
    hText = findobj(hGR, 'Type', 'text');
    set(hText, 'Color', [1,1,1]);

function EnableRectangle(hRectangle)
    
    set(hRectangle, 'LineStyle', '-');
    set(hRectangle, 'Color', 'r');
%     particleIndex = get(hRectangle, 'UserData');
%     hFig = ancestor(hRectangle,'figure','toplevel');
% 
%     hTexts = findobj(hFig, 'Tag', 'nmssParticleNumberText');
%     hText = findobj(hTexts, 'UserData', particleIndex);
%     set(hText, 'Color', [1,1,1]);
    
function DisableRectangleGroup(hRectangle)
    hGR = get(hRectangle, 'Parent');
    if (iscell(hGR)) hGR = cell2mat(hGR); end;
    hRectangles = findobj(hGR, 'Type', 'line');
    DisableRectangle(hRectangles);
    
    hText = findobj(hGR, 'Type', 'text');
    set(hText, 'Color', [0.5, 0.5, 0.5]);

    
function DisableRectangle(hRectangle)
    
    set(hRectangle, 'LineStyle', ':');
    set(hRectangle, 'Color', [0.5 0 0]);
%     particleIndex = get(hRectangle, 'UserData');
%     hFig = ancestor(hRectangle,'figure','toplevel');
% 
%     hTexts = findobj(hFig, 'Tag', 'nmssParticleNumberText');
%     hText = findobj(hTexts, 'UserData', particleIndex);
%     set(hText, 'Color', [0.5, 0.5, 0.5]);
    
function MenuBoundingRectCallback_Disable(src, evnt)
    hFig = ancestor(src, 'figure', 'toplevel');
    hRectangle = GetSelectedRectangles(hFig);
    DisableRectangleGroup(hRectangle);
    
%     hCorrRectangle = GetCorrespondingOtherRectangle(hRectangle);
%     
%     DisableRectangle(hRectangle);
%     DisableRectangle(hCorrRectangle);
    
    set(hRectangle, 'Selected', 'on');
    
function hRectangle = GetAllRectangles(varargin)

    if (length(varargin) >= 1)
        hFig = varargin{1};
    else
        hFig = ancestor(varargin{1}, 'figure', 'toplevel');
    end
    
    % regular expression search: \d* = any number of digits
    hRectangle = findobj(hFig, 'Tag', 'nmssParticleBoundingRect', ...
                         '-or', 'Tag', 'nmssParticle_BG_Rect');
    
function hRectangle = GetSelectedRectangles(varargin)
    
    if (length(varargin) >= 1)
        hFig = varargin{1};
    else
        hFig = ancestor(varargin{1}, 'figure', 'toplevel');
    end


    hAllRectangle = GetAllRectangles(hFig);

    hRectangle = findobj(hAllRectangle, 'Selected', 'on');

        
function BGRectButtonDownCallback(varargin)

    RectButtonDownCallback(varargin{:});

function BoundingRectButtonDownCallback(varargin)

    RectButtonDownCallback(varargin{:});

function RectButtonDownCallback(varargin)
% executed if user presses mouse button over the bounding rectangle
    
    if (nargin == 1 && ishandle(varargin{1}))
        h = varargin{1};
    else
        h = gcbo(); % get handle of the object whose callback is being executed
    end
    hParentFig = ancestor(h, 'figure', 'toplevel');
    
    % returns selection type (mouse click in combination with any keyboard
    % modifier key
    sSelectionType = get(hParentFig, 'SelectionType');
    
    % Select (or deselect) the rectangle that has been clicked
    isSelected = get(h, 'Selected');
    hSelectedRectangles = GetSelectedRectangles(hParentFig);    
    if (strcmp(isSelected,'on'))
        if (strcmp(sSelectionType, 'extend') && length(hSelectedRectangles) > 1) % user pressed shift during selection
            set(h, 'Selected', 'off');
        end
    else
%         if (strcmp(sSelectionType, 'alt'))
%             % if right mouse click: don't select
%             set(h, 'Selected', 'off');
%         else
%             set(h, 'Selected', 'on');            
%         end        
            set(h, 'Selected', 'on');            
    end
    
    % if left mouse click without pressing 'shift' button for multiple
    % selection, delete all previus selections
    if (strcmp(sSelectionType, 'normal'))
        
        hOldSelectedRectangles = hSelectedRectangles(find(hSelectedRectangles ~= h));
        set(hOldSelectedRectangles, 'Selected', 'off');
    end
    
    particle_index = get(h, 'UserData');
    
    DisplayGraphs(hParentFig, particle_index);
    
    

% displays the particle spectrum in the graphs    
function DisplayGraphs(hParentFig, particle_index)

    user_data = get(hParentFig, 'UserData');
    p = user_data.results.particle(particle_index,1);
    
    % displays graphs
    hGraph1 = findobj(hParentFig, 'Tag', 'nmssScanImageGraph1Axes');
    hGraph2 = findobj(hParentFig, 'Tag', 'nmssScanImageGraph2Axes');
    
    axes1_user_data = get(hGraph1, 'UserData');
    axes1_user_data.display.particle = true;
    axes1_user_data.display.bg = true;
    set(hGraph1, 'UserData', axes1_user_data);
    
    % calling the display routine: DisplayGraph of the nmssGraphAxes module
    axes1_user_data.hDisplayGraphFcn(hGraph1, p);
    
    
    axes2_user_data = get(hGraph2, 'UserData');
    if (user_data.results.spec_smoothing.flag)
        axes2_user_data.display.smoothed_raw_bg_corr = true;
    else
        axes2_user_data.display.smoothed_raw_bg_corr = false;
    end
    axes2_user_data.display.raw_bg_corr = false; % don't display the background corrected but NOT normalized graph
    axes2_user_data.display.normalized = true;
    axes2_user_data.display.fit = true;
    axes2_user_data.display.max = true;
    set(hGraph2, 'UserData', axes2_user_data);
    
    % calling the display routine: DisplayGraph of the nmssGraphAxes module
    axes2_user_data.hDisplayGraphFcn(hGraph2, p);
    
    
    
% sets graph axes parameters    
function SetGraphAxesParams(h, sTag, sTitle)
    
    set(h, 'Tag', sTag);
    axes(h);
    title(sTitle);



    
%    
function particle_out = GetParticleBoundingRect(real_space_img, roi_in_px, ...
                                     analysis)
                                 
                                     
        real_space_img_spec_roi = real_space_img;
        real_space_img_spec_roi.img = real_space_img.img([roi_in_px.y : roi_in_px.y + roi_in_px.wy - 1],:);
        
                                     
        % MARK or FIND PARTICLES on the real space image
            threshold = 0;

        % select jobs, which contain maximum intensity of particle images
            [max_pos_x, max_pos_y, top_left_x, top_left_y, bottom_right_x, bottom_right_y, threshold] = ...
                nmssFindBrightSpots( real_space_img_spec_roi.img, analysis);

    % At this point we have identified all particles that could be found
    % according to the analysis parameters
    num_of_particles = length(max_pos_x);

    if (num_of_particles == 0)
        errordlg('No particle found.');
        return;
    end
    
    % asserting that the roi sizes fit into the image
    img_width = size(real_space_img.img, 2);
    img_height = size(real_space_img.img, 1);

    max_pos_x(find(max_pos_x < 1)) = 1;
    max_pos_y(find(max_pos_y < 1)) = 1;

    max_pos_x(find(max_pos_x > img_width)) = img_width;
    max_pos_y(find(max_pos_y > img_height)) = img_height;

    top_left_x(find(top_left_x < 1)) = 1;
    top_left_x(find(top_left_x > img_width)) = img_width;
    bottom_right_x(find(bottom_right_x < 1)) = 1;
    bottom_right_x(find(bottom_right_x > img_width)) = img_width;

    top_left_y(find(top_left_y < 1)) = 1;
    top_left_y(find(top_left_y > img_height)) = img_height;
    bottom_right_y(find(bottom_right_y < 1)) = 1;
    bottom_right_y(find(bottom_right_y > img_height)) = img_height;
    
    for i=1:num_of_particles
        particle_out(i,1) = nmssResetParticle();
        particle_out(i,1).valid = 1;
        particle_out(i,1).num = i;
        
        % setting up ROI for the particles (the spectral dimension - s - is
        % also referred to as x-dimension if the scanning context is not
        % important (like in cases of curve graph display and similar
        % situations)
        roi_px = [top_left_x(i), top_left_y(i), roi_in_px.x, ...
                  bottom_right_x(i), bottom_right_y(i), roi_in_px.x + roi_in_px.wx - 1];
        roi_real = TransformRoiPx2Real(roi_px, real_space_img);
        
        particle_out(i,1).p = roi_real;
                           
        particle_out(i,1).max_pos_xy = [max_pos_x(i), max_pos_y(i)]; 
                           
    end
% 
% Each particle can have up to four regions that can be considered as
% background source. These four regions lie above, right to, below, and
% left to the particle bounding rectangle. In certain cases one, or more of
% these background rectangles can not be set.
function particle_out = GetBackgroundBoundingRectangles(particle_in, real_space_img, bg)

    % we need:
    
    % ESSENTIALLY
    % -  initial definition of the bg rectangles (size and position)
    % -  check if these bg rectangles are within the image area, disable them if
    % not
    
    particle_out = particle_in;
    num_of_particles = length(particle_in);
    
    bg_width_param = bg.hoffset; % pixel
    bg_height_param = bg.voffset; % pixel
    
    img_width = size(real_space_img.img, 2);
    img_height = size(real_space_img.img, 1);
    
        
    for i=1:num_of_particles
        
        prtcl_roi = TransformRoiReal2Px(particle_in(i,1).p, real_space_img);
        
        %create the background area by extending the particle roi
        bg = [prtcl_roi(1) - bg_width_param, prtcl_roi(2) - bg_height_param, prtcl_roi(3), ...
              prtcl_roi(4) + bg_width_param, prtcl_roi(5) + bg_height_param, prtcl_roi(6)];
          
        % adjust rois to fit into the data cube
        if (bg(1) < 1) bg(1) = 1; end
        if (bg(2) < 1) bg(2) = 1; end
        if (bg(4) > img_width) bg(4) = img_width; end
        if (bg(5) > img_height) bg(5) = img_height; end
        
        particle_out(i,1).bg = TransformRoiPx2Real(bg, real_space_img);
    end
    

    
    
    % OPTIONALLY
    % -  check if the bg rectangle of one particle intersects the bounding
    % rectangle of another particle
    
% gets the spectrum of the particle and related    
function particle_out = GetRawSpectrum(particle, real_space_img, spec_smoothing, spec_roi_in_px)

    global doc;

        particle_out = particle;
        num_of_particles = length(particle);
        
        waitbar_handle = waitbar(0,'Getting Raw Spectrum...');
        
        
        for i=1:num_of_particles
            
            waitbar(i/num_of_particles, waitbar_handle);
            
            % particle
            p_roi = TransformRoiReal2Px(particle(i,1).p, real_space_img);
            p_roi(3) = spec_roi_in_px.x;
            p_roi(6) = spec_roi_in_px.x + spec_roi_in_px.wx - 1;
            
            
                % the 1st dimension of the data cube is the spectral dimension = s
                % the 2nd dimension is the vertical spatial axis = y
                % the 3rd dimension is the horizontal spatial axis (the scanning
                % dimension) = x
                % BUT
                % the roi_vector is (x1, y1, s1, x2, y2, s2), where x1 is the 
                % x-coordinate of one corner and x2 the diagonally
                % opposite corner of the cube shaped 3d roi. y, s are defined in an
                % analog way.
                try
                p_spec_3d = doc.img_block(p_roi(3):p_roi(6), p_roi(2):p_roi(5), p_roi(1):p_roi(4));
                p_spec_2d = sum(p_spec_3d, 3)';
                p_spec = sum(p_spec_2d, 1);
                catch
                    disp(lasterr());
                    keyboard;
                end

            % bg (may fully or partially include the particle roi)
            bg_roi = TransformRoiReal2Px(particle(i,1).bg, real_space_img);
            bg_roi(3) = spec_roi_in_px.x;
            bg_roi(6) = spec_roi_in_px.x + spec_roi_in_px.wx - 1;
            
            
            
                % roi that is defined the smallest possible volume that
                % contains the particle and the background roi
                bgp_roi = [min([p_roi(1), bg_roi(1)]), min([p_roi(2), bg_roi(2)]), min([p_roi(3), bg_roi(3)]), ...
                           max([p_roi(4), bg_roi(4)]), max([p_roi(5), bg_roi(5)]), max([p_roi(6), bg_roi(6)])];

                try
                    bgp_spec_3d = doc.img_block(bgp_roi(3):bgp_roi(6), bgp_roi(2):bgp_roi(5), bgp_roi(1):bgp_roi(4));
                catch
                    disp(lasterr());
                    keyboard;
                end
                % all data that belongs to the particle is set to zero, so they don't 
                % contribute to the background spectrum. now we have to
                % adjust the coordinates to the relative coordinates of
                % this cube
                bgp_spec_3d(1:end, p_roi(2) - bgp_roi(2) + 1: p_roi(5) - bgp_roi(2) + 1, ...
                                   p_roi(1) - bgp_roi(1) + 1: p_roi(4) - bgp_roi(1) + 1) = 0; 

                % now get the spectrum
                bg_spec_2d = sum(bgp_spec_3d, 3)';
                bg_spec = sum(bg_spec_2d, 1);
                
                % correction factors in relation to the different volume sizes:
                p_vol = prod(size(p_spec_3d));
                bg_vol = prod(size(bgp_spec_3d)) - p_vol;
                if (bg_vol <= 0) bg_vol = 1; end;
                
            % initialize struct that contains spectra graph data
            pp = particle(i,1);
            pp.graph.bg_valid = 1;
            pp.p([3,6]) = p_roi([3,6]);
            pp.bg([3,6]) =  bg_roi([3,6]);
                
            % normalize and store results
            pp.graph.particle = p_spec;
            pp.graph.bg = bg_spec / bg_vol * p_vol;
            raw_bg_corr = pp.graph.particle  - pp.graph.bg;
            pp.graph.raw_bg_corr = raw_bg_corr;
            % smoothed
            pp.graph.smoothed_raw_bg_corr = smooth(raw_bg_corr, spec_smoothing.param)';
            
            particle_out(i,1) = pp;
            
        end
        
        if (~isempty(waitbar_handle) && ishandle(waitbar_handle))
            delete(waitbar_handle);
        end

% transforms pixel defined roi to real space coordinates (only for the x
% and y axis, since the s-axis (spectral) remains the same and is taken care of in a
% different context
function roi_real = TransformRoiPx2Real(roi_px, real_space_img)
    
    img_width = size(real_space_img.img, 2);
    img_height = size(real_space_img.img, 1);
    
    px_to_real_x = (real_space_img.x_max - real_space_img.x_min) / (img_width - 1);
    px_to_real_y = (real_space_img.y_max - real_space_img.y_min) / (img_height - 1);
    
    roi_real = [real_space_img.x_min + (roi_px(:,1)-1) * px_to_real_x, ...
                real_space_img.y_min + (roi_px(:,2)-1) * px_to_real_y, ...
                roi_px(:,3), ...
                real_space_img.x_min + (roi_px(:,4)-1) * px_to_real_x, ...
                real_space_img.y_min + (roi_px(:,5)-1) * px_to_real_y, ...
                roi_px(:,6)];
            
% transforms real space coordinates roi to pixel coordinates (only for the x
% and y axis, since the s-axis (spectral) remains the same and is taken care of in a
% different context
function roi_px = TransformRoiReal2Px(roi_real, real_space_img)
    
    img_width = size(real_space_img.img, 2);
    img_height = size(real_space_img.img, 1);
    
    px_to_real_x = (real_space_img.x_max - real_space_img.x_min) / (img_width - 1);
    px_to_real_y = (real_space_img.y_max - real_space_img.y_min) / (img_height- 1);
    
    roi_px = [round((roi_real(:,1) - real_space_img.x_min) / px_to_real_x) + 1, ...
              round((roi_real(:,2) - real_space_img.y_min) / px_to_real_y) + 1, ...
              roi_real(:,3), ...
              round((roi_real(:,4) - real_space_img.x_min) / px_to_real_x) + 1, ...
              round((roi_real(:,5) - real_space_img.y_min) / px_to_real_y) + 1, ...
              roi_real(:,6)];
    
%
%
function particle_out = GetAxis(particle, roi_in_px)

    [axis_x, unit_x] = nmssGetXAxis();
    
    roi_axis_x = axis_x(roi_in_px.x : roi_in_px.x + roi_in_px.wx - 1);
    
    particle_out = particle;
    
    num_of_particles = length(particle);
    for i=1:num_of_particles
        
        particle_out(i,1).graph.axis.x = roi_axis_x;
        particle_out(i,1).graph.axis.unit.x = unit_x;
        
    end
    
%
% performs the white light normalization
function particle_out = NormalizeWithWhiteLight(particle, white_light, roi_in_px, spec_smoothing)

    num_of_particles = length(particle);
    particle_out = particle;
    
    % select which whit light to use
    if (strcmp(white_light.use, 'smooth'))
        white_light_roi = white_light.smooth.spec(roi_in_px.x:roi_in_px.x+roi_in_px.wx - 1);
    else
        white_light_roi = white_light.raw(roi_in_px.x:roi_in_px.x+roi_in_px.wx - 1);
    end
    
    waitbar_handle = waitbar(0,'Normalizing Spectrum...');
    
    for i=1:num_of_particles
        waitbar(i/num_of_particles, waitbar_handle);
        if (spec_smoothing.flag)
            particle_out(i,1).graph.normalized = particle(i,1).graph.smoothed_raw_bg_corr ./ white_light_roi;
        else
            particle_out(i,1).graph.normalized = particle(i,1).graph.raw_bg_corr ./ white_light_roi;
        end
        particle_out(i,1).graph.graph.offset_x_px = roi_in_px.x;
    end
    
    delete(waitbar_handle);
    
%
% performs the white light normalization
function particle_out = SmootheNormalized(particle)

    num_of_particles = length(particle);
    particle_out = particle;
    
    waitbar_handle = waitbar(0,'Creating smoothed spectrum...');
    for i=1:num_of_particles
        waitbar(i/num_of_particles, waitbar_handle);
        particle_out(i,1).graph.smoothed = nmssSmoothGraph(particle_out(i,1).graph.normalized);
    end
    delete(waitbar_handle);
    
%
% performs the white light normalization
function particle_out = NoiseFilterNormalized(particle)

    num_of_particles = length(particle);
    particle_out = particle;
    
    waitbar_handle = waitbar(0,'Creating noise filtered spectrum...');
    for i=1:num_of_particles
        waitbar(i/num_of_particles, waitbar_handle);
%         particle_out(i,1).graph.noise_filtered = ...
%              noisefilter(particle_out(i,1).graph.axis.x, particle_out(i,1).graph.normalized, 50); % max period of the filtered frequency components 50 nm
        particle_out(i,1).graph.noise_filtered = particle_out(i,1).graph.normalized;
    end
    delete(waitbar_handle);
    
    
%
function particle_index = GetParticleIndex(hRectangle)
    
    particle_index_cell = get(hRectangle, 'UserData');
    if (iscell(particle_index_cell))
        particle_index = cell2mat(particle_index_cell);
    else
        particle_index = particle_index_cell;
    end
    
function MenuSpectrum_AnalysisSettings(src, eventdata)
% src    handle of the object calling this callback
% eventdata  reserved - to be defined in a future version of MATLAB

    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');

% --- Executes on menu press in Peak Analysis.
function MenuSpectrum_CurveAnalysis(src,eventdata)
% src    handle of the object calling this callback
% eventdata  reserved - to be defined in a future version of MATLAB

    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    % get selected particles
    hSelRectangles = GetSelectedRectangles(hFig);
    pIndex = GetParticleIndex(hSelRectangles);
    % compact vector
    particle_index = unique(pIndex); % removes multiple occurances of the same index
    
    %particle_index = find([user_data.results.particle(:).valid]);
    p = user_data.results.particle(particle_index,1);
%     for i=1:length(particle_index)
%         p(i).num = particle_index(i); % needed to identify the particle when returning from the dialog
%     end
    
    % OPEN dialog
    hDlg = nmssCurveAnalysisDlg();
    
    % give focus to the recently opened dialog
    figure(hDlg);
    %set(hDlg, 'WindowStyle', 'modal');
    nmssCurveAnalysisUserData = get(hDlg, 'UserData');
    
    if (isfield(user_data, 'nmssCurveAnalysisDlg_Data'))
        nmssCurveAnalysisUserData.Dlg_Data = user_data.nmssCurveAnalysisDlg_Data;
    else
        % init nmssCurveAnalysisDlg_Data here:
        
        % flag to indicate if the smoothed curve should be displayed
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.smoothed = true;
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.unsmoothed = true;
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.fittedcurve = true;
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.max = true;
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.peak_finding_range = true;
        nmssCurveAnalysisUserData.Dlg_Data.showCurves.noise_filtered = true;
        
        % flag to indicate if the fitting should be performed on the raw
        % data or on the denoised data
        nmssCurveAnalysisUserData.Dlg_Data.use_denoised_data_to_fit = false;
        
        % the unit of the x-axis of the displayed curves
        nmssCurveAnalysisUserData.Dlg_Data.graphXAxisUnit = 'eV';
        
    end
    
    % copy particle data structure into the particle variable
    %nmssCurveAnalysisUserData.Dlg_Data.selected_particle_index = particle_index;
    if (isempty(particle_index))
        errordlg('Please select at least one graph!')
        return;
    end
    
    nmssCurveAnalysisUserData.Dlg_Data.current_graph_index = 1;
    
    % copy particle struct to the analysis dialog particle struct
    nmssCurveAnalysisUserData.particle = p;
    
    % register callback function that is called whane user closes the
    % dialog with pressing OK
    nmssCurveAnalysisUserData.OKFunction = @CurveAnalysisDlg_OKFunction;
    nmssCurveAnalysisUserData.CallerFigHandle = hFig;
    
    % set dialog data
    set(hDlg, 'UserData', nmssCurveAnalysisUserData);
    
    % init dialog
    nmssCurveAnalysisUserData.hFigInitFcn(hDlg);
    
    
%    
function  CurveAnalysisDlg_OKFunction(hDlg)
    dlg_user_data = get(hDlg, 'UserData');
    hFig = dlg_user_data.CallerFigHandle;
    user_data = get(hFig, 'UserData');
    
    num_of_dialog_particle = length(dlg_user_data.particle);
    for i=1:num_of_dialog_particle
        % index magic
        pNum = dlg_user_data.particle(i,1).num; % get particle index in respect to the results viewer dialog
        pNewNum = find([user_data.results.particle(:,1).num] == pNum);
        
        %new_num = user_data.results.particle(pIndex,1).num; % get particle index in respect to the scan image analysis dialog
        user_data.results.particle(pNewNum,:) = dlg_user_data.particle(i,:);
        
        hRect = findobj(hFig, 'UserData', pNum, '-and', 'Tag', 'nmssParticleBoundingRect');
        if (user_data.results.particle(pNewNum,1).valid == 1)
            EnableRectangleGroup(hRect);
        else
            DisableRectangleGroup(hRect);
        end
    end
    
    % retrieve dialog data and store parent!s dialog data
    user_data.nmssCurveAnalysisDlg_Data = dlg_user_data.Dlg_Data;
    
    set(hFig, 'UserData', user_data);
    
    % refresh GUI
    % get selected particles
    hSelRectangles = GetSelectedRectangles(hFig);
    pIndex = GetParticleIndex(hSelRectangles);
    if (~isempty(pIndex))
        SelectParticle(hFig, pIndex(1));
    else
        SelectParticle(hFig, 1);
    end
    
%
function particle_out = GetPeakParams(particle_in)

    num_of_particles = length(particle_in);
    particle_out = particle_in;
    
    waitbar_handle = waitbar(0,'Fitting peaks and getting FWHM and max position...');
    for i=1:num_of_particles
            waitbar(i/num_of_particles, waitbar_handle);
            [graph_berg_plot, fit_param, warning_txt] = nmssCreateBergPlot(particle_in(i));
    %         if (~isempty(warning_txt))
    %             disp(['Berg plot analysis status report for particle #', num2str(k),]);
    %             disp(warning_txt);
    %             disp('');
    %         end

            particle_out(i,1).res_energy = graph_berg_plot(1);
            particle_out(i,1).FWHM = graph_berg_plot(2);
            particle_out(i,1).max_intensity = graph_berg_plot(3);
            particle_out(i,1).fit = fit_param;
    end
    delete(waitbar_handle);


% called to save results struct
function MenuData_SaveResultsAs(src,eventdata,arg1)
    
    hMenu = src;
    hMenuBar = get(hMenu, 'Parent');
    hFig = get(hMenuBar, 'Parent');

    user_data = get(hFig, 'UserData');
    results.particle = user_data.results.particle;
    
    results = user_data.results;
    hRectangle = findobj(hFig, 'Tag', 'nmssParticleBoundingRect');
    
    % set valid flag to true for enabled rectangles
    hEnabledRectangle = findobj(hRectangle, 'LineStyle', '-');
    enabled_particle_indices = GetParticleIndex(hEnabledRectangle);
    for i=1:length(enabled_particle_indices)
        results.particle(enabled_particle_indices(i)).valid = 1;
    end
    
    % set valid flag to false for disabled rectangles
    hDisabledRectangle = findobj(hRectangle, 'LineStyle', ':');
    diasbled_particle_indices = GetParticleIndex(hDisabledRectangle);
    for i=1:length(diasbled_particle_indices)
        results.particle(diasbled_particle_indices(i)).valid = 0;
    end
    
    if (isfield(user_data,'results'))
        
        % save analysis settings as they were used during this analysis
        global doc;
        results.spec_analysis.roi = doc.roi;
        results.spec_analysis.analysis = doc.analysis;
        results.spec_analysis.white_light_corr = doc.white_light_corr;
        
        SaveResultsAs(results);
    end
    
%
function SaveResultsAs(results)
    
        nmssSaveResults(results, results.working_dir);
    

% opens results viewer dialog and shows results spectrum for the valid
% particles
function MenuData_ViewEnabledResults(src, evnt)
    % get parent figure
    hMenu = src;
    hMenuBar = get(hMenu, 'Parent');
    hFig = get(hMenuBar, 'Parent');
    
    % synchonizes enabled rectangle and particle.valid variable
    UpdateParticles(hFig);

    % get particle data
    user_data = get(hFig, 'UserData');
    
    iValidParticleIndices = find([user_data.results.particle.valid]);
    
    results = user_data.results;
    results.particle = user_data.results.particle(iValidParticleIndices);
    
    OpenResultsViewerDlg(hFig, results);
    

% opens results viewer dialog and shows results spectrum for all particles
function MenuData_ViewResults(src,eventdata)
    
    % get parent figure
    hMenu = src;
    hMenuBar = get(hMenu, 'Parent');
    hFig = get(hMenuBar, 'Parent');
    
    UpdateParticles(hFig);

    % get particle data
    user_data = get(hFig, 'UserData');
    OpenResultsViewerDlg(hFig, user_data.results)
    
    
%
function OpenResultsViewerDlg(hFig, results)
    
    % OPEN DIALOG:
    hResultsViewerDlg = nmssResultsViewerDlg();
    
    user_data_ResultsViewerDlg = get(hResultsViewerDlg, 'UserData');
    
    % register export data function
    user_data_ResultsViewerDlg.hExportFcn = @SaveResultsAs;
    
    % register OK button function
    user_data_ResultsViewerDlg.hOKFcn = @ResultsViewerDlg_OKFcn;
    
    % register the cacller figure handle
    user_data_ResultsViewerDlg.CallerFigHandle = hFig;
    
    user_data_ResultsViewerDlg.results = results;
    %user_data_ResultsViewerDlg.work_results = user_data.results;

    set(hResultsViewerDlg, 'UserData', user_data_ResultsViewerDlg);
    
    user_data_ResultsViewerDlg.hFigInitFcn(hResultsViewerDlg);
    
%
function user_canceled = ResultsViewerDlg_OKFcn(hDlg)
% called if user clicks OK in Results Viewer dialog
    user_canceled = true;

    button = questdlg({'Only particles with selected graphs will be enabled in the analysis window!';...
            'Do you really want to proceed?'},'Closing Results Viewer Dialog with OK','OK', 'Cancel', 'Cancel');

    if (strcmp(button, 'Cancel')) return; end;
    
    %hFig = nmssCurveAnalysisDlg_Data.CallerFigHandle;
    dlg_user_data = get(hDlg, 'UserData');
    hFig = dlg_user_data.CallerFigHandle;
    user_data = get(hFig, 'UserData');
    

    
    
    num_of_dialog_particle = length(dlg_user_data.results.particle);
    for i=1:num_of_dialog_particle
        pNum = dlg_user_data.results.particle(i,1).num;
        pNewNum = find([user_data.results.particle(:,1).num] == pNum);
        
        user_data.results.particle(pNewNum,:) = dlg_user_data.results.particle(i,:);
        hRect = findobj(hFig, 'UserData', pNewNum, '-and', 'Tag', 'nmssParticleBoundingRect');
        if (user_data.results.particle(pNewNum,1).valid == 1)
            EnableRectangleGroup(hRect);
        else
            DisableRectangleGroup(hRect);
        end
    end
    
    set(hFig, 'UserData', user_data);
    
    hRect = GetSelectedRectangles(hFig);
    if (~isempty(hRect))
        pIndex = GetParticleIndex(hRect(1));
    else
        pIndex = 1;
    end
    SelectParticle(hFig, pIndex);
    
    % user didn!t cancel the action
    user_canceled = false;
    
    
%
function UpdateParticles(hFig)
    
    % get user data
    user_data = get(hFig, 'UserData');
    num_of_all_particles = GetNumOfAllParticles(hFig);
    hRectangle = findobj(hFig, 'Tag', 'nmssParticleBoundingRect');
    
    % set valid flag to true for enabled rectangles
    hEnabledRectangle = findobj(hRectangle, 'LineStyle', '-');
    enabled_particle_indices = GetParticleIndex(hEnabledRectangle);
    for i=1:length(enabled_particle_indices)
        user_data.results.particle(enabled_particle_indices(i)).valid = 1;
    end
    
    % set valid flag to false for disabled rectangles
    hDisabledRectangle = findobj(hRectangle, 'LineStyle', ':');
    disabled_particle_indices = GetParticleIndex(hDisabledRectangle);
    for i=1:length(disabled_particle_indices)
        user_data.results.particle(disabled_particle_indices(i)).valid = 0;
    end
    
    set(hFig, 'UserData', user_data);
    
%
function MenuData_SaveMarker(src,eventdata)
    
    % get parent figure
    hMenu = src;
    hFig = ancestor(hMenu,'figure','toplevel');
    UpdateParticles(hFig);
    
    user_data = get(hFig, 'UserData');
    particle = user_data.results.particle;
    
%     lNumOfParticles = size(user_data.results.particle,1);
%     
%     for i=1:lNumOfParticles
% 
%         particle_out(i,1).p
%         % get top left corner
%         pos.x1 = pos_x(1);
%         pos.y1 = pos_y(1);
% 
%         % get bottom right corner
%         pos.x2 = pos_x(3);
%         pos.y2 = pos_y(3);
% 
%         marker(i).pos = pos;
% 
%         marker(i).color = get(hRectangle(i), 'Color');
%         marker(i).linewidth = get(hRectangle(i), 'LineWidth');
%         marker(i).linestyle = get(hRectangle(i), 'LineStyle');
%     end
    
    current_dir = pwd();
    cd(user_data.results.working_dir);
    
    [filename, dirname, filterIndex] = uiputfile({'*.mat', 'Save particle positions as Mat-File...';}, 'Save results', 'particle.mat');
    cd(current_dir);
        
    % user hit cancel button
    if (filename == 0) return; end;
    
    hW = waitbar(1, 'Please Wait, Data storage is under way! It can take some seconds...');

    filepath = fullfile(dirname, filename);
    save(filepath, 'particle');
    
    delete(hW);
    
    
%
function MenuData_LoadMarker(src,eventdata)
    
    % get parent figure
    hMenu = src;
    hFig = ancestor(hMenu,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    
%     if (~CanAccessImgBlock(hFig))
%         WarningNoAccessToImgBlock(hFig);
%         return;
%     end
    
    current_dir = pwd();
    cd(user_data.results.working_dir);
    [filename, dirname] = uigetfile({'*.mat', 'Mat-File (*.mat)'}, 'Load marker positions - Select File');
    cd(current_dir);
    
    if (filename == 0) % user pressed cancel
        return;
    end
    
    file_path = fullfile(dirname, filename);
    [pathstr_dummy,name_dummy,extension] = fileparts(file_path);    
    
    load(file_path); % loads pos_xy
    
    % extract particle data from regular results file
    if (~exist('particle') && exist('results'))
        if (isfield(results, 'version') && results.version >= 2)
            particle = results.particle;
        else
            hErrDlg = errordlg('This version of results file does not contain the particle marker data');
            set(hErrDlg, 'WindowStyle', 'modal');
            return;
        end
    end
    
    if (exist('particle'))
        
        % reset fit parameters since it doesn!t necessary belong to marker
        % info
        for i=1:length(particle(:,1))
            fit_data.fit_x = [];
            fit_data.fit_y = [];
            % initialize the settings for finding the peak
            fit_data.params = nmssResetPeakFindingParam(1240 ./ particle(i,1).graph.axis.x);
            particle(i,1).fit = fit_data;
        end
        
        user_data.results.particle = particle;
        set (hFig, 'UserData', user_data);
        
        RecalculateSpectrum(hFig);
        
    else
        errordlg('This .mat file doesn!t contain particle position data!');
    end
    
%
function RecalculateSpectrum(hFig)
    
    user_data = get(hFig, 'UserData');
    
    particle = GetAxis(user_data.results.particle, user_data.results.spec_roi_in_px);
% 
%     particle = GetBackgroundBoundingRectangles(particle, user_data.results.real_space_img);

    [particle, status] = GetSpectrum(hFig, particle, user_data.results.white_light, user_data.results.spec_roi_in_px, ...
                           user_data.results.real_space_img, user_data.results.spec_smoothing);
    if (~strcmp(status, 'OK')) return; end;
                       
    num_of_particles = length(particle);
    user_data.results.particle = particle;
    set (hFig, 'UserData', user_data);
    
    % select first rectangle
    hSelectedRectangles = GetSelectedRectangles(hFig);
    if (isempty(hSelectedRectangles))
        pIndex = 1;
    else
        pIndex = get(hSelectedRectangles(1), 'UserData');
    end

    delete(findobj(hFig, 'Type', 'hggroup', 'Tag', 'nmssRectangleGroup'));
%         hText = findobj(hFig, 'Tag', 'nmssParticleNumberText');
%         delete(hText);

    hImgAx = findobj(hFig, 'Tag', 'nmssScanImageAxes');
    set(hImgAx, 'Tag', 'nmssScanImageAxes');
    %set(hImgAx, 'Title', text('String',['Scanned Image (', num2str(num_of_particles), ' particles)']));


    % display bounding rectangles
    DisplayBoundingRectangles(hFig, user_data.results.particle, ...
        user_data.results.real_space_img, user_data.results.spec_roi_in_px);

    SelectParticle(hFig, pIndex);
        
    
%
function MenunBoundingRectCallback_MoveSelected(src,eventdata)

    % get parent figure
    hMenu = src;
    hFig = ancestor(hMenu,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    particle = user_data.results.particle;
    
%     if (~CanAccessImgBlock(hFig))
%         WarningNoAccessToImgBlock(hFig);
%         return;
%     end
    
    hRectangles = GetSelectedRectangles(hFig);
    hParticleRect = findobj(hRectangles, 'Tag', 'nmssParticleBoundingRect');
    hBGRect = findobj(hRectangles, 'Tag', 'nmssParticle_BG_Rect');
    
    
    [pos1, pos2] = DrawMoveVector();
    
    % use vector data and relocate all markers
    shift = [pos2(1)- pos1(1), pos2(2)- pos1(2)]; % 1 = x, 2 = y
    
    MoveRectangles(hParticleRect, hBGRect, hFig, shift);
    
    particle_index = get(hRectangles(1), 'UserData');
    DisplayGraphs(hFig, particle_index);
    
    
function MoveRectangles(hParticleRect, hBGRect, hFig, shift)
    
    user_data = get(hFig, 'UserData');
    particle = user_data.results.particle;
    % get all particle bouding rectangles arrange them into a matrix and
    % perform shift
    moved_particle_index = GetParticleIndex(hParticleRect);
    if (~isempty(moved_particle_index))

        newP = UserMoveSelectedRectangles(cell2mat({particle(moved_particle_index).p}'), user_data.results.real_space_img, shift);

        MoveRectangle(hParticleRect, newP(:,1), newP(:,2), newP(:,4), newP(:,5));

        num_of_moved_particles = length(moved_particle_index);
        for i=1:num_of_moved_particles
            k = moved_particle_index(i);
            particle(k,1).p = newP(i,:);

            % move text, too
            hText = findobj(hFig, 'Tag', 'nmssParticleNumberText', '-and', 'UserData', k);
            oldTextPos = get(hText, 'Position');
            newTextPos = oldTextPos;
            newTextPos([1,2]) = oldTextPos([1,2]) + shift;
            set(hText, 'Position', newTextPos);
        end
    end
    % get all background rectangles arrange them into a matrix and
    % perform shift
    moved_bg_index = GetParticleIndex(hBGRect);
    if (~isempty(moved_bg_index))
        newBG = UserMoveSelectedRectangles(cell2mat({particle(moved_bg_index).bg}'), user_data.results.real_space_img, shift);

        MoveRectangle(hBGRect, newBG(:,1), newBG(:,2), newBG(:,4), newBG(:,5));

        num_of_moved_bg = length(moved_bg_index);
        for i=1:num_of_moved_bg
            k = moved_bg_index(i);
            particle(k,1).bg = newBG(i,:);
        end
    end
    
    
    
    
    % get particle indices of those that have been modified
    modified_pIndex = sort([moved_particle_index(:)', moved_bg_index(:)']); % rowvectorizing
    
    % delete duplicates
    modified_pIndex_simplified = unique(modified_pIndex);
    
    [pNew, status] = GetSpectrum(hFig, particle(modified_pIndex_simplified,1), user_data.results.white_light, user_data.results.spec_roi_in_px, ...
                       user_data.results.real_space_img, user_data.results.spec_smoothing);
    if (~strcmp(status, 'OK')) return; end;
                   
    num_of_modified_particles = length(modified_pIndex_simplified);
    
    for i = 1:num_of_modified_particles
        k = pNew(i).num;
        particle(k,:) = pNew(i,:);
    end
    
    user_data.results.particle = particle;
    set(hFig, 'UserData', user_data);
%
%

function MenuBoundingRectCallback_ReCenterRectAndBG(src,eventdata)
% Moves the particle bounding rectangle and its corresponding background to
% a new spot that is defined by the user clicking to indicate the new
% center of the particle bounding rectangle
    
    % get parent figure
    hMenu = src;
    hFig = ancestor(hMenu,'figure','toplevel');
    user_data = get(hFig, 'UserData');
    particle = user_data.results.particle;
    
%     if (~CanAccessImgBlock(hFig))
%         WarningNoAccessToImgBlock(hFig);
%         return;
%     end
    
    hRectangles = GetSelectedRectangles(hFig);
    if (length(hRectangles) ~= 1) return; end;
    hOtherRectangle = GetCorrespondingOtherRectangle(hRectangles);
    
    hRect = findobj([hRectangles, hOtherRectangle], 'Tag', 'nmssParticleBoundingRect');
    hBGRect = findobj([hRectangles, hOtherRectangle], 'Tag', 'nmssParticle_BG_Rect');
    
    % position 1 is the center of the particle bounding rectangle
    xpos = get(hRect, 'XData');
    ypos = get(hRect, 'YData');
    pos1 = [(xpos(3) + xpos(1))/2, (ypos(3) + ypos(1))/2];
    
    % new position can be selected with the mouse
    [xPos2, yPos2] = ginput(1);
    pos2 = [xPos2, yPos2];   
    
    % use vector data and relocate all markers
    shift = [pos2(1)- pos1(1), pos2(2)- pos1(2)]; % 1 = x, 2 = y
    
    MoveRectangles(hRect, hBGRect, hFig, shift);
    
    particle_index = get(hRect, 'UserData');
    DisplayGraphs(hFig, particle_index);
    
    
%
function [pos1, pos2] = DrawMoveVector()

    % allow user to define shift vector manually by drawing a vector line
    [xPos1, yPos1] = ginput(1);

    hCross1 = nmssDrawCross(xPos1, yPos1, 3, 3);

    [xPos2, yPos2] = ginput(1);

    % draw line
    hLine = line([xPos1; xPos2], [yPos1; yPos2], 'Color','m','LineWidth',2);
    
    % delete cross_1, it was intended only for the user to know, where he
    % clicked the mouse button first
    delete(hCross1);
    
    % draw a rectangle at the end of the line, so that it looks like an
    % arrow
    hArrowHead = nmssDrawRectAroundCenter(xPos2, yPos2, 2, 2, 'nmss_arrow_head');
    set(hArrowHead, 'Color', 'm');
    
    drawnow();
    
    delete(hArrowHead);
    delete(hLine);
    
    pos1 = [xPos1, yPos1];
    pos2 = [xPos2, yPos2];
    
%
function newPositions = UserMoveSelectedRectangles(oldPositions, real_space_img, shift)
    
    
    %selected_particle_index = GetParticleIndex(hRectangles);
    
    % use vector data and relocate all markers
    shift_x = shift(1);
    shift_y = shift(2);
    
    % update particle position data
    newPositions = oldPositions;
%     newPositions(:,[1, 4]) = round(oldPositions(:,[1, 4]) + shift_x);
%     newPositions(:,[2, 5]) = round(oldPositions(:,[2, 5]) + shift_y);
    newPositions(:,[1, 4]) = (oldPositions(:,[1, 4]) + shift_x);
    newPositions(:,[2, 5]) = (oldPositions(:,[2, 5]) + shift_y);
    
    newPositions = SnapToPixels(newPositions, real_space_img);
    % ensure that the new rectangles fit into the image
    newPositions = FitRoiIntoImage(newPositions, real_space_img);
    
    % yes, we're done

%
% checks if the user has access to the image block aka data cube
function hasAccess = CanAccessImgBlock(hFig)
    hasAccess = true;
    user_data = get(hFig, 'UserData');
    global doc;
    
    if (~strcmp(user_data.results.working_dir, doc.workDir))
        hasAccess = false;
    end

%
function  WarningNoAccessToImgBlock(hFig)
    
    dialog_name = 'Scan Analysis Dialog';
    h = errordlg({'Can''t perform requested action because the working dialog has changed!';'';...
                    ['This instance of ', dialog_name, ' has no access to the spectra data cube anymore!']});
    set(h, 'WindowStyle', 'modal');
                
% displays the berg plot of the selected particles
function MenuSpectrum_BergPlot(src, eventdata)
    
    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    UpdateParticles(hFig);
    
    particle = user_data.results.particle(find([user_data.results.particle(:).valid]),1);
    global nmssViewBergPlotGraph_Data;
    %selected_particle_index = find(nmssResultsViewerDlg_Data.particle_selected == 1);
    
    % copy selected results into the berg plot variable
    nmssViewBergPlotGraph_Data.particle = particle;
    % call berg plotter
    nmssViewBergPlotGraphMenu();
    
    
% ensures that rois are inside of the image boundary. It is mandatory that
% rois be defined in the coordinate system of the image axis (no pixel
% coordinates)
function real_roi_out = FitRoiIntoImage(real_roi_in, real_space_img)
    real_roi_out = real_roi_in;
    
    real_roi_out(find(real_roi_out(:,1) < real_space_img.x_min),1) = real_space_img.x_min;
    real_roi_out(find(real_roi_out(:,2) < real_space_img.y_min),2) = real_space_img.y_min;
    real_roi_out(find(real_roi_out(:,4) < real_space_img.x_min),4) = real_space_img.x_min;
    real_roi_out(find(real_roi_out(:,5) < real_space_img.y_min),5) = real_space_img.y_min;
    
    real_roi_out(find(real_roi_out(:,1) > real_space_img.x_max),1) = real_space_img.x_max;
    real_roi_out(find(real_roi_out(:,2) > real_space_img.y_max),2) = real_space_img.y_max;
    real_roi_out(find(real_roi_out(:,4) > real_space_img.x_max),4) = real_space_img.x_max;
    real_roi_out(find(real_roi_out(:,5) > real_space_img.y_max),5) = real_space_img.y_max;

% Snaps given roi to pixels of real space image (that is necessary since
% one pixel in image can have different sizes in real space coordinates
% This function can be important if you wanna snap graphic objects to image
% pixels that they look nice
function real_roi_out = SnapToPixels(real_roi_in, real_space_img)
    
    old_roi_px = TransformRoiReal2Px(real_roi_in, real_space_img);
    new_roi_px = [round(old_roi_px(:,[1:2])), old_roi_px(:,3), round(old_roi_px(:,[4:5])), old_roi_px(:,6)]; % rounding only in pixel mode!!!
    real_roi_out = TransformRoiPx2Real(new_roi_px, real_space_img);
    

 
    
    
