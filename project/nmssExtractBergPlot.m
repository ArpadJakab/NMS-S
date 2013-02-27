function berg = nmssExtractBergPlot(varargin)
% extracts the berg_plot data from the results structures which are located 
% in subdirectories of a given root directory. The results.mat
% is created by NMSS analysis and contains all necessary informations about
% the particle peaks and the berg plot as well.
%
% INPUT:
% root_dir          - the directory from which the search for results.mat should be
%                     started. If left empty a directory selection dialog pops up.
% plotgraphs        - if 1, berg plot and res. wavelength histogram will be
%                     displayed, if 0 no figures are displayed. Default: 0
% file_to_look_for  - the name of the .mat file containing the results
%                     (usually: results.mat or selected_results.mat)
% 
%
% OUTPUT:
% berg - a m x 4 matrix containing the accumulated berg plots where: 
%        1st column = resonance energy in eV
%        2nd column = FWHM in eV
%        3rd column = max intensity
%        4th column = resonance wavlength in nm

    root_dir = tempdir;
    if (length(varargin) >= 1)
        % get root directoy
        root_dir = varargin{1};
        if (exist(root_dir) ~= 7)
            error(['Directory: "', root_dir, '" does not exist!']);
            return;
        end
    else
        root_dir = uigetdir();
        if (root_dir == 0)
            return;
        end
    end
    
    % get user parameter: switch for figure output
    if (length(varargin) >= 2)
        plotgraphs = varargin{2};
    else
        plotgraphs = 0;
    end
    
    % get user parameter: file name conatining the results struct
    we_need_this_file = 'results_selected.mat';
    if (length(varargin) >= 3)
        res_file_name = varargin{3};
    end
    
    
    
    berg = zeros(0,4); % contains the berg_plots one cell one scan
    disp('Result files found:');
    
    % collect all directories containing results.mat files
    results_path = glob(root_dir, we_need_this_file)
    
    for k=1:size(results_path,1)
        results.particle = [];
        load('-mat', results_path(k,:));
        
        % in case the loaded variable is not called 'results' but 'results_selected'
        if (exist('results_selected'))
            results = results_selected;
        end
        
        berg_plot = zeros(0,4);
        n = 1;
        for i=1:length(results.particle)
            if (~isempty(results.particle(i)))
                if ((results.particle(i).valid == 1) & (results.particle(i).res_energy ~= 0))
                    berg_plot(n,1) = results.particle(i).res_energy;
                    berg_plot(n,2) = results.particle(i).FWHM;
                    berg_plot(n,3) = results.particle(i).max_intensity;
                    berg_plot(n,4) = 1240/results.particle(i).res_energy;
                    n = n + 1;
                end
            end
        end
        berg = [berg; berg_plot];
    end
    
    
    % remove NaNs
    berg = berg(find(~isnan(berg(:,1))),:);

    if (plotgraphs ~= 0)
        % get screen size to be able to position the particles
        set(0, 'Units', 'inches');
        screen_size = get(0,'ScreenSize');
        x = screen_size(3);
        y = screen_size(4);
        
        figure('Name', 'Berg Plot');
        set(gcf, 'Units', 'inches');
        set(gcf, 'Position', [0, y-2, 3, 2]);
        title('FWHM vs Res. Energy');
        plot(berg(:,1), berg(:,2),'.');
        xlabel('Res. Energy (eV)');
        ylabel('FWHM (eV)');
        
        
        figure('Name', 'Res. WL histogram');
        set(gcf, 'Units', 'inches');
        set(gcf, 'Position', [0, y-4, 3, 2]);
        title('Res. Wavelength distribution');
        hist(berg(:,4));
        xlabel('Res. Wavelength (nm)');
    end
        
    
    
%    
function results_path = GetPaths(root_dir, we_need_this_file)    
    
    % get all files in the directory
    files = dir(root_dir);
    results_path = '';
    
    % got through the list of files and find directories and
    % 'results.mat'-s
    for i=1:length(files)
        fil = files(i);
        if (fil.isdir && ~(strcmp(fil.name,'.') || strcmp(fil.name,'..')))
            sub_dir = fullfile(root_dir, fil.name);
            tmp_paths = GetPaths(sub_dir);
            if (~isempty(tmp_paths))
                results_path = strvcat(results_path ,tmp_paths);
            end
        elseif (strcmp(fil.name, we_need_this_file))
            results_path = strvcat(results_path, fullfile(root_dir, fil.name));
        end
    end
    
