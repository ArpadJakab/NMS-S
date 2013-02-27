function [ particles ] = nmssShowParticleSpectrum( result )
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
    x_min = result.real_space_image.x_min;
    x_max = result.real_space_image.x_max;
    y_min = result.real_space_image.y_min;
    y_max = result.real_space_image.y_max;
    
    fig = figure();
    imagesc([x_min, x_max], [y_min, y_max], result.real_space_image.data);
    colormap gray;
    brighten(0.6);
    hold on;

    for k=1:length(result)
        nmssMarkParticles(result, fig, '.');
    end
    
    particles = '';
    
    results{1} = result;
    while 1
        user_response = menu('Please select a particle!','OK','Cancel');
        if (user_response == 2)
            break;
        end
        
        particles = nmssFindParticle( results, fig, 1 );
        if (~isempty(particles))
            if (~isempty(particles{1}.pdata))
                particles{1}.pdata{1}
                if (~isempty(particles{1}.pdata{1}.graph))
                    nmssPlotGraph(particles{1}.pdata{1}.graph{1});
                end
            end
        end
        
        
    end