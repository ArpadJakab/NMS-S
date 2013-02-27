function single_part_indices = nmssGetSingleParticles( results )
%nmssGetSingleParticles returns the array indices of single particles in
%the results structure

%  Detailed explanation goes here


    num_of_particles = length(results.particle);
    
    peak_max_intensity = zeros(num_of_particles,1);
    
    for i=1:num_of_particles;
        if (results.particle(i).res_energy == 0)
            continue;
        end
        peak_max_int(i,1) = max(results.particle(i).graph.normalized(:)); 
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
    
    single_part_indices = zeros(0,1);
    for i=1:num_of_particles
        if (results.particle(i).graph.bg_valid == 1)
             if (max(results.particle(i).graph.normalized(:)) > max_sing_part_peak_max_int)
                 continue;
             end
             
             single_part_indices = [single_part_indices, i];
        end
    end
