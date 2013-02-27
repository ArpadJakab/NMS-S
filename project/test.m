function wavelength = test(corr_part)

num_of_particles = length(corr_part)
linestyle_vector = {'r-', 'b--', 'm-', 'c--'};

wavelength = zeros(num_of_particles,1);

for i = 1:num_of_particles
    
    pdata = corr_part(i).pdata;
    
    figure;
    hold on;
    
    num_of_results = length(pdata);
    
    for j=1:num_of_results
        
        plot(pdata{j}.graph.axis.x, pdata{j}.graph.smoothed, linestyle_vector{j});
        
    end
    
end

