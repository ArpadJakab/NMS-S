function nmssColorizeParticles( result, fig, marker )
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

    my_colormap = zeros(1000, 3);
    tmp_colormap = flipud(colormap(hsv(ceil(250 * 1.3))));
    % insert the rainbow clormap into my colormap
    my_colormap(401:650,:) = tmp_colormap(1:250,:);
    % the first part of my colormap (until 400) is violet
    my_colormap(1:400, 1) = tmp_colormap(1, 1);
    my_colormap(1:400, 2) = tmp_colormap(1, 2);
    my_colormap(1:400, 3) = tmp_colormap(1, 3);
    % the last part of my colormap (from 651) is dark red 
    my_colormap(651:end, 1) = tmp_colormap(250, 1);
    my_colormap(651:end, 2) = tmp_colormap(250, 2);
    my_colormap(651:end, 3) = tmp_colormap(250, 3);
    
    
    for i=1:length(result.particle)
        x = result.particle(i).data.pos.x;
        y = floor(result.particle(i).graph{1}.roi_particle.y + result.particle(i).graph{1}.roi_particle.wy * 0.5);
        if (isnan(result.particle(i).res_energy))
            continue;
        end
        wl = 1240 / result.particle(i).res_energy;
        %plot(x, y, '.', 'Color', my_colormap(ceil(wl),:)); % draw markers where particles have been found
        %lot(x, y, '.y'); % draw markers where particles have been found
    end
    