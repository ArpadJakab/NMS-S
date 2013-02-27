function [ particle ] = nmssFindParticle( res, varargin )
%nmssFindParticle - returns an array of particle data 
%  This function plots the real space image and displays the particles
%  provided in the res{}. Thus enables the user aided correlation of
%  particles, which may slightly moved sudring the multiple exposure

    % initialize the return variables
    pindex = [];
    particle = [];

    % exit if data is not available
    for i=1:length(res)
        if (~isfield(res{i}, 'real_space_img') || ...
            ~isfield(res{i}.real_space_img, 'x_min') || ...
            ~isfield(res{i}.real_space_img, 'x_max') || ...
            ~isfield(res{i}.real_space_img, 'y_min') || ...
            ~isfield(res{i}.real_space_img, 'y_max'))
            return;
        end
    end
    
    num_of_res = length(res);
    
    % work variables
    corr_particles = [];
        
    
    
    % maximum number of user interaction (if multiple but unknown number of selection is
    % intended)
    max_num_of_user_interactions = 1000;
    
    fig = 0;
    marker_char = [];
    if (length(varargin) > 0)
        fig = varargin{1};
        max_num_of_user_interactions = varargin{2};
        figure(fig);
    else
        [fig, marker_char] = DisplayRealSpaceImage(res);
        %InitializeFigure(fig);
    end
    
%     user_data.res = res;
%     set(fig, 'UserData', user_data);
    
    correlated_particle_index = 0;
    hConnectingLine = {};
    hRectangleLine = {};
    
    
    % loop over 1000 steps (to avoid infinite loops)
    for n=1:max_num_of_user_interactions
        % wait until user has pressed a (mouse) button 
        menutext{1} = 'Select a region with corresponding particles';
        for i=1:length(res)
            menutext{i+1} = [ marker_char(i), ' = ', res{i}.source_dir];
        end
        
        switch menu(menutext ,'Select', 'Auto Select', 'Auto Select All', 'Deselect', 'Quit and Save')
            % select particles
            case 1
                pdata = {};
                pindex = [];
                pxpos = [];
                pypos = [];
                disp([num2str(n),' Particles found:']);
                disp('-----------------------------------');
                % loop over the imported result structs
                bAllParticlesFound = true;
                for k=1:length(res)
                    buttonpress = waitforbuttonpress;

                    p1 = get(gca,'CurrentPoint');    % button down detected
                    p2 = get(gca,'CurrentPoint');    % button up detected

                    point1 = p1(1,1:2);              % extract x and y
                    point2 = p2(1,1:2);

                    try
                        [pd, pi, px, py] = Search4NearestParticle(res{k}, point1, 20, fig);
                        pdata{k} = pd;
                        pindex(k) = pi;
                        pxpos(k) = px;
                        pypos(k) = py;
                        
                        % indicator if a particle could be found in all
                        % result set
                        if (isnan(px) || isnan(py))
                            bAllParticlesFound = false;
                        end
                        
                        disp(['Correlating Point #', num2str(k),': (', num2str(pxpos(k)),', ',num2str(pypos(k)),')']);
                    catch
                        disp(lasterr);
                    end
                end
                
                if (~bAllParticlesFound) continue; end
                    
                correlated_particle_index = correlated_particle_index + 1;
                corr_particles(correlated_particle_index).pdata = pdata;
                

                hConnectingLine{j} = ...
                    line(pxpos,pypos,'Color', 'c','LineWidth', 3, 'LineStyle', '--', 'Tag', 'ConncetingLine', ...
                    'UserData', correlated_particle_index);
                hRectangleLine{j} = ...
                    nmssDrawRectBetween2Points([pxpos(1)-1,pypos(1)-1], [pxpos(end)+1,pypos(end)+1], ...
                                                1, 'c', '--');
                set(hRectangleLine{j}, 'Tag', 'GroupingRectangle', 'UserData', correlated_particle_index);
                                            
            case 2
                pdata = {};
                pindex = [];
                pxpos = [];
                pypos = [];
                disp([num2str(n),' Particles found:']);
                disp('-----------------------------------');
                % loop over the imported result structs
                bAllParticlesFound = true;
                buttonpress = waitforbuttonpress;

                p1 = get(gca,'CurrentPoint');    % button down detected
                p2 = get(gca,'CurrentPoint');    % button up detected

                point1 = p1(1,1:2);              % extract x and y
                point2 = p2(1,1:2);
                
                for k=1:length(res)

                    try
                        [pd, pi, px, py] = Search4NearestParticle(res{k}, point1, 30, fig);
                        pdata{k} = pd;
                        pindex(k) = pi;
                        pxpos(k) = px;
                        pypos(k) = py;
                        
                        % indicator if a particle could be found in all
                        % result set
                        if (isnan(px) || isnan(py))
                            bAllParticlesFound = false;
                        end
                        
                        disp(['Correlating Point #', num2str(k),': (', num2str(pxpos(k)),', ',num2str(pypos(k)),')']);
                    catch
                        disp(lasterr);
                    end
                end
                
                if (~bAllParticlesFound) continue; end
                    
                correlated_particle_index = correlated_particle_index + 1;
                corr_particles(correlated_particle_index).pdata = pdata;
                

                hConnectingLine{j} = ...
                    line(pxpos,pypos,'Color', 'c','LineWidth', 3, 'LineStyle', '--', 'Tag', 'ConncetingLine', ...
                    'UserData', correlated_particle_index);
                hRectangleLine{j} = ...
                    nmssDrawRectBetween2Points([pxpos(1)-1,pypos(1)-1], [pxpos(end)+1,pypos(end)+1], ...
                                                1, 'c', '--');
                set(hRectangleLine{j}, 'Tag', 'GroupingRectangle', 'UserData', correlated_particle_index);
                                
            % undo last selection (this can be repeated subsquently)
            case 3
            
                pdata = {};
                pindex = [];
                pxpos = [];
                pypos = [];
                disp([num2str(n),' Particles found:']);
                disp('-----------------------------------');
                
                num_of_particles = length(res{1}.particle);
                
                for jj=1:num_of_particles
                
                    point1 = res{1}.particle(jj).max_pos_xy;

                    % loop over the imported result structs
                    bAllParticlesFound = false;
                    
                    for k=1:num_of_res

                        try
                            [pd, pi, px, py] = Search4NearestParticle(res{k}, point1, 30, fig);
                            if (~pd.valid) break; end; % if one of particles is invalid exit this loop
                            
                            pdata{k} = pd;
                            pindex(k) = pi;
                            pxpos(k) = px;
                            pypos(k) = py;

                            % indicator if a particle could be found in all
                            % result set
                            if (~isnan(px) && ~isnan(py))
                                bAllParticlesFound = true;
                                disp(['Correlating Point #', num2str(k),': (', num2str(pxpos(k)),', ',num2str(pypos(k)),')']);
                            end

                        catch
                            disp(lasterr);
                        end
                    end

                    % couldn't find all particles? continue with the next
                    % one
                    if (~bAllParticlesFound) continue; end
                    
                    correlated_particle_index = correlated_particle_index + 1;
                    corr_particles(correlated_particle_index).pdata = pdata;
                    
                    line(pxpos,pypos,'Color', 'c','LineWidth', 3, 'LineStyle', '--', 'Tag', 'ConncetingLine', ...
                        'UserData', correlated_particle_index);
                    hRectangleLine =nmssDrawRectBetween2Points([pxpos(1)-1,pypos(1)-1], [pxpos(end)+1,pypos(end)+1], ...
                                                    1, 'c', '--');
                    set(hRectangleLine, 'Tag', 'GroupingRectangle', 'UserData', correlated_particle_index);
                end
            % undo last selection (this can be repeated subsquently)
            case 4
                buttonpress = waitforbuttonpress;

                p1 = get(gca,'CurrentPoint');    % button down detected
                p2 = get(gca,'CurrentPoint');    % button up detected

                point1 = p1(1,1:2);              % extract x and y
                point2 = p2(1,1:2);
                
                % find particle in the vicinity of the mouse click
                hConnectingLine = findobj(fig, 'Tag', 'ConncetingLine');
                x = get(hConnectingLine, 'XData');
                y = get(hConnectingLine, 'YData');
                
                if (iscell(x)) x = cell2num(x); end;
                if (iscell(y)) y = cell2num(y); end;
                
                xn = find(abs( x(:,1) - point1(1) ) < 30 || abs(x(:,2) - point1(1))  < 30);
                %yn = find(abs( y(:,1) - point1(2) ) < 30 || abs(y(:,2) - point1(2))  < 30);
                (closest_y, yn) = min(y(xn));
                % if no particle found close enough to the mouse click
                % position do nothing
                if (isempty(closest_y)) continue; end;
                
                hClosestLine = hConnectingLine(xn(yn));
                delete_index = get(hClosestLine, 'UserData');
                
                correlated_particle_index = correlated_particle_index([1:delete_index-1,  delete_index:end]);
                
                % delete connection line the last correlated particle group
                delete(hClosestLine);
                delete(findobj(fig, 'Tag', 'GroupingRectangle', 'UserData', delete_index);
                
            otherwise
                n = max_num_of_user_interactions; % loop exit condition
                break;
                
        end
        
    end;
    
    % return variable
    particle = corr_particles(1:correlated_particle_index);
    
    
function InitializeFigure(hFig)

        % MENU BAR
        % add new item to the menu bar
        menuData = uimenu(hFig,  'Label', 'Correlate');
        uimenu(menuData,  'Label', 'Manual Select/Deselect', 'Callback', @MenuCorrelate_Manual);
        uimenu(menuData,  'Label', 'Auto Select/Deselect', 'Callback', @MenuCorrelate_AutoSelectParticle);
        uimenu(menuData,  'Label', 'Auto Select All', 'Callback', @MenuCorrelate_AutoSelectAll);
        uimenu(menuData,  'Label', 'Save Correlated Data As...', 'Callback', @MenuCorrelate_SaveCorrDataAs,...
                          'Separator', 'on');
                      
        %set(hFig, 'ButtonDownFcn', @MouseButtonDown);
        hImage = findobj(hFig, 'Tag', 'RealSpaceImage');
        set(hImage,'ButtonDownFcn', @MouseButtonDownInImage);
        
function MouseButtonDownInImage(src, evnt)        

    hImage = src;
    hFig = ancestor(hImage, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    
    % left click or right click?
    
    % returns selection type (mouse click in combination with any keyboard
    % modifier key
    sSelectionType = get(hFig, 'SelectionType');
    
    if (strcmp(sSelectionType,'normal'))
        % left click: select
        if (strcmp(user_data.correlation_method,'manual'))
            Correlate_Manual(hFig);
        end
        
        
    elseif (strcmp(sSelectionType,'alt'))
        % right click: deselect
    end
    
function MenuCorrelate_Manual(src, evnt)

    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    user_data.correlation_method = 'manual';
    set(hFig, 'UserData', user_data);
    
function MenuCorrelate_AutoSelectParticle(src, evnt)

    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    user_data.correlation_method = 'autoselect_deselect';
    set(hFig, 'UserData', user_data);
    
function MenuCorrelate_AutoSelectAll(src, evnt)

    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');
    user_data.correlation_method = 'autoselect_all';
    set(hFig, 'UserData', user_data);
    
function MenuCorrelate_SaveCorrDataAs(src, evnt)
    
    hFig = ancestor(src, 'figure', 'toplevel');
    user_data = get(hFig, 'UserData');


%
% switches on the manual correlation method (left mouse click = select
% nearest particle, right click = deselect nearest particle)
function Correlate_Manual(hFig)

    user_data = get(hFig, 'UserData');
    

    
    
function [fig, marker_char] = DisplayRealSpaceImage(res)
        marker_char_set = ['.', '+', 'o', '*', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h', ...
                           '.', '+', 'o', '*', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'];
        marker_char = marker_char_set;

        % check if we have enough marker types for displaying the particle
        % positions for each result
        lres = length(res);
        if (lres > length(marker_char_set))
            error(['Max number of results ', num2str(length(marker_char_set)), ...
                   ' reached! Please reduce the number of results!']);
            return;
        end
        marker_char = marker_char_set(1:lres);

        % get real space image sizes
        x_min = res{1}.real_space_img.x_min;
        x_max = res{1}.real_space_img.x_max;
        y_min = res{1}.real_space_img.y_min;
        y_max = res{1}.real_space_img.y_max;
        
        % display the real space image
        fig = figure;
        hImage = imagesc([x_min, x_max], [y_min, y_max], res{1}.real_space_img.img);
        set(hImage, 'Tag', 'RealSpaceImage');
        colormap gray;
        brighten(0.6);
        hold on;
        
        
        % show particles
        for k=1:lres
            for i=1:length(res{k}.particle)
                particle_color = nmssWavelength2RGB( 1240 / res{k}.particle(i).res_energy);
                if (isfield(res{k}.particle(i), 'max_pos_xy') || res{k}.version == 2.0)
                    % new version of results structure
                    x = res{k}.particle(i).max_pos_xy(1);
                    y = res{k}.particle(i).max_pos_xy(2);
                else
                    x = res{k}.particle(i).data.pos.x;
                    y = floor(res{k}.particle(i).graph.roi.particle.y + res{k}.particle(i).graph.roi.particle.wy * 0.5);
                end
        
                % draw markers with the given wavelength where particles have been found
                
                if (isfield(res{k}.particle(i), 'valid'))
                    if (res{k}.particle(i).valid)
                        plot(x, y, marker_char(k), 'Color', particle_color);
                    end
                else
                    % old results and particle data structure
                    plot(x, y, marker_char(k), 'Color', particle_color);
                end
            end
        end
        
    
function [particle, pindex, pxpos, pypos] = Search4NearestParticle(results, point, range_px, fHandle)
% Search4NearestParticle - finds the nearest particle to the point given
% results - the structure returned from the plasmoscope analysis software
% point - the [x, y] coordinates of the point where the particle should be
% searched for

    % initalize return variables
    particle = -1;
    pindex = -1;
    pxpos = NaN;
    pypos = NaN;
    
    % get real space image sizes
    x_min = results.real_space_img.x_min;
    x_max = results.real_space_img.x_max;
    y_min = results.real_space_img.y_min;
    y_max = results.real_space_img.y_max;
    

    if (isfield(results.particle(1), 'max_pos_xy') || results.version == 2.0)
        % new version of results structure
        for i=1:length(results.particle)
            particle_x_pos(i) = results.particle(i).max_pos_xy(1);
            particle_y_pos(i) = results.particle(i).max_pos_xy(2);
        end
    else
        for i=1:length(results.particle)
            particle_x_pos(i) = results.particle(i).data.pos.x;
            particle_y_pos(i) = floor(results.particle(i).graph.roi.particle.y +  results.particle(i).graph.roi.particle.wy / 2);
        end
    end

    % look for points in a growing rectangle around the given point
    % the rectangle grows to 40 pixel in size in both directions (x and y)
    hLine = -1;
    for d=0:1:range_px
        % delete line handle
        if (ishandle(hLine))
            delete(hLine);
        end
        
        dx = d*.5;
        dy = d;
        
        x_pos_lolimit = ceil(point(1)-dx);
        if (x_pos_lolimit < x_min) 
            x_pos_lolimit = x_min;
        end
        
        x_pos_hilimit = floor(point(1)+dx);
        if (x_pos_hilimit > x_max)
            x_pos_hilimit = x_max;
        end
        
        y_pos_lolimit = point(2)-d;
        if (y_pos_lolimit < y_min)
            y_pos_lolimit = y_min;
        end
        
        y_pos_hilimit = point(2)+d;
        if (point(2)+d > y_max)
            y_pos_hilimit = y_max;
        end
        
        %y_pos_lolimit = point(2)-d;
        %y_pos_hilimit = point(2)+d;
        
        
        
        % find particles which lie in the range of <mouse click point|x> - d
        % to <mouse click point|x> + d
        pindex_in_xrange = find(particle_x_pos >= x_pos_lolimit & particle_x_pos <= x_pos_hilimit);
        
        % get the y-coordinates of the found particles
        particles_in_xrange = particle_y_pos(pindex_in_xrange);
        % use this narrowed set of particles and find those which lie in the 
        % range of <mouse click point|y> - d to <mouse click point|y> + d
        pindex_in_yrange = find(particles_in_xrange >= y_pos_lolimit & particles_in_xrange <= y_pos_hilimit);
        
        % indices particles which are in the rectangle with the size 2d around
        % the mouose click points
        pindex_in_range = pindex_in_xrange(pindex_in_yrange);
        
        % draw the search area rectangle
        hLine = nmssDrawRectBetween2Points([x_pos_lolimit, y_pos_lolimit],[x_pos_hilimit, y_pos_hilimit], ...
              2, 'r', '-');
        
        pause(0.025);
              
        % check if a particle has been found
        if (length(pindex_in_range) >= 1)
            % so we've found a particle, store the results and leave the
            % loop
            pindex = pindex_in_range(1);
            particle = results.particle(pindex);
            pxpos = particle_x_pos(pindex);
            pypos = particle_y_pos(pindex);
            
            break;
        end
        
    end
    % delete line handle
    if (ishandle(hLine))
        delete(hLine);
    end


%
function [particle, pindex] = FindParticleInRect(results, corner_top_left, corner_bottom_right)
    % initialize the return variables
    pindex = NaN;
    particle = [];
    
    particle_x = [];
    particle_y = [];
    
    % loop through results.particle
    for i=1:length(results.particle)
        % find particles which have the correct x-coordinate
        if (results.particle(i).data.pos.x >= corner_top_left(1) & ...
            results.particle(i).data.pos.x < corner_bottom_right(1))
            particle_x = [particle_x, i];
        end
    end
        
    % now, take the particles which have the right x-coordinates and find the first particle which has the correct y-coordinate
    for k=1:length(particle_x)
        i = particle_x(k);
        
        if (results.particle(i).graph.roi.particle.y >= corner_top_left(2) & ...
            (results.particle(i).graph.roi.particle.y +  results.particle(i).graph.roi.particle.wy - 1) <= corner_bottom_right(2))
        
            particle_x = results.particle(i).data.pos.x;
            particle_y = floor(results.particle(i).graph.roi.particle.y +  results.particle(i).graph.roi.particle.wy / 2);
            disp(['particle coord.: (', num2str(particle_x), ',' num2str(particle_y),')']);
            pindex = i;
            particle = results.particle(i);
            break;
        end
    end
    
    