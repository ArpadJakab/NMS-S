function berg_plot = nmssGetSingleParticleBergPlot( results )
%nmssGetSingleParticleBergPlot - selects the particles with the weakest
%signal. this enables to distinguish between agglomerates (which have a
%brighter signal) and single particles.

% INPUT:
%   results - the results data structure returned retained from the
%   analysis
%
% OUTPUT:
%   berg_plot - the berg plot of the (hopefully) sinlge particles

    num_of_particles = length(results.particle);
    
    peak_max_intensity = zeros(num_of_particles,1);
    
    for i=1:num_of_particles;
        if (results.particle{i}.res_energy == 0)
            continue;
        end
        peak_max_int(i,1) = max(results.particle{i}.graph{1}.normalized(:)); 
    end
    
    med_peak_max_int = median(peak_max_int(find(peak_max_int)));
    
    % single particle range: we define as (median(peak_max_int) - min(peak_max_int)) because the less
    % bright spots are expected to be single particles and these spots are
    % usually more numerous than aggregates
    % WHY HAVE AGGRAGATES OFTEN 10 to 100 times higher intensity whereas
    % the resonance frequency does not vary so much???
    single_particle_range = abs(med_peak_max_int - min(peak_max_int));
    
    
    
    hixt_x_axis = [min(peak_max_int): ...
                  (median(peak_max_int)+single_particle_range-min(peak_max_int)) / 20: ...
                  median(peak_max_int)+single_particle_range];
              
    % now select the single particles
    
    % define a maximum intensity above which we don't consider particles
    max_sing_part_peak_max_int = med_peak_max_int + single_particle_range;
    
    berg_plot = zeros(0,2);
    for i=1:num_of_particles
        if (results.particle{i}.graph{1}.bg_valid == 1)
             if (max(results.particle{i}.graph{1}.normalized(:)) > max_sing_part_peak_max_int)
                 continue;
             end
            if (results.particle{i}.res_energy == 0)
                continue;
            end
            berg_plot = [berg_plot; results.particle{i}.res_energy, results.particle{i}.FWHM];
        end
    end
    
              