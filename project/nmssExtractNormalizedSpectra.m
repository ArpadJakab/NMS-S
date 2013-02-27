function spec = nmssExtractNormalizedSpectra( root_dir, varargin)
% nmssExtractNormalizedSpectra( root_dir, start_wavelength, end_wavelength)
% returns the an array of spec structure, where spec.axis contains the
% x-axis data, and spec.normalized conatins the normalized particle spectrum
% start_wavelength - sets the lowest wavelength for the spectrum 
% end_wavelength - sets the highest wavelength for the spectrum 

    results_path = glob(root_dir, 'results.mat');
    lenght_of_results_path = size(results_path,1);
    
    spec(1).axis.x = [];
    spec(1).axis.unit = 'nm';
    spec(1).normalized = [];
    
    for k=1:lenght_of_results_path
        results.particle = [];
        
        % load results.mat --> the variable loaded is called: results
        load(results_path(k,:));
        index_x_axis_particles = 0;
        
        % get the x-axis
        for i=1:length(results.particle)
            if (~isempty(results.particle(i)))
                if ((results.particle(i).valid == 1) & (results.particle(i).graph.bg_valid == 1))
                    
                    x_axis = results.particle(i).graph.axis.x';
                    
                    if (length(varargin) >= 1 & isnumeric(varargin{1}) & varargin{1} > x_axis(1))
                        start_wl = varargin{1};
                    else
                        start_wl = x_axis(1);
                    end
                    
                    if (length(varargin) >= 2 & isnumeric(varargin{2}) & varargin{2} < x_axis(end))
                        end_wl = varargin{2};
                    else
                        end_wl = x_axis(end);
                    end
                    
                    
                    % take the first valid particle's x-axis (with the provided boundaries)
                    index_x_axis_particles = find(x_axis >= start_wl & x_axis <= end_wl);
                    spec(k).axis.x = x_axis(index_x_axis_particles);
                    spec(k).axis.unit = results.particle(i).graph.axis.unit;
                    break;
                end
            end
        end
        
        length_of_spec = length(spec(k).axis.x);
        
        % get the indices of valid normalized specrta
        valid_norm_spec_indices = [];
        for i=1:length(results.particle)
            if (~isempty(results.particle(i)))
                if ((results.particle(i).valid == 1) & (results.particle(i).graph.bg_valid == 1))
                    % increaswe the counter for valid normalized spectra
                    valid_norm_spec_indices = [valid_norm_spec_indices, i];
                end
            end
        end
        
        % no valid spectra, take the next results struct
        if (isempty(valid_norm_spec_indices))
            continue;
        end
        
        % allocate array to contain normalized spectra
        normalized_spec = zeros(length(valid_norm_spec_indices), length(spec(k).axis.x));
        
        
        % get the valid normalized specrta
        for i=1:length(valid_norm_spec_indices)
            
            part_ind = valid_norm_spec_indices(i);
            normalized_spec(i,:) = smooth(results.particle(part_ind).graph.normalized(index_x_axis_particles), 50);
        end
        
        
        spec(k).normalized = normalized_spec';
    end
    
    
