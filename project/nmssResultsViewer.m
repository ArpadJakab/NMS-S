function particle_indices_taken = nmssResultsViewer( results, varargin )
%nmssResultsViewer - loops through the particle spectra and plots the
%spectra for each particle on the same graph

    no_of_particles = size(results.particle,1);
    no_of_spectra = size(results.particle,2);
    if (no_of_particles == 1) % we have old style results struct
        for i = 1:no_of_spectra
            for k = 1:no_of_particles
                res_new.particle(i,k) = results.particle(k,i);
            end
        end
        results = res_new;
    end
    no_of_particles = size(results.particle,1);
    no_of_spectra = size(results.particle,2);
        

    col_no = 1;
    if (length(varargin) >= 1)
        if (isinteger(varargin{1}))
            % user wants the x-th spectrum of the particle (like if
            % multiple scan has been performed)
            col_no = varargin{1};
        end
    end
            

    particle_indices_taken = [];
    
    % loop over alla particles contained in the results struct
    for i=1:no_of_particles
        f1 = figure;
        spec = smooth(results.particle(i,col_no).graph.normalized, 30);
        subplot(2,1,1);
        
        if (results.particle(i,col_no).graph.bg_valid == 1)
            color = 'b';
        else
            color = 'r';
        end
        
        plot(results.particle(i,col_no).graph.axis.x, spec, color);
        title(['Particle #', num2str(i)]);
        hold on;
        
        subplot(2,1,2);
        plot(results.particle(i,col_no).graph.axis.x, results.particle(i,col_no).graph.bg, 'b');
        title(['Particle #', num2str(i), ' Background']);
        
        legendstr = ['Data #1'];
        % a particle can have many spectra originating from multiple scans
        for k =2:no_of_spectra
            subplot(2,1,1);
            spec = smooth(results.particle(i,k).graph.normalized, 30);
            plot(results.particle(i,k).graph.axis.x, spec, 'r');
            legendstr = strvcat(legendstr, ['Data #', num2str(k)]);
        end
        subplot(2,1,1);
        legend(legendstr);
            
        
        user_resp = menu('Take this particle?', 'Yes', 'No', 'Quit');
        
        if (user_resp == 3)
            break;
        end
        
        if (user_resp == 1)
            particle_indices_taken = [particle_indices_taken, i];
        end
        
        delete(gcf);
    end
