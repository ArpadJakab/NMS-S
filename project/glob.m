function abs_paths = glob(root_dir, we_look_for_this_file )
% starting from the <root_dir> this command searches for the given file in all subdirectories
% and returns an array of paths, where the file has been found
%  Detailed explanation goes here
    abs_paths = GetPaths(root_dir, we_look_for_this_file)



function path = GetPaths(root_dir, we_look_for_this_file)    
    
    % get all files in the directory
    files = dir(root_dir);
    path = '';
    
    % got through the list of files and find directories and
    % 'results.mat'-s
    for i=1:length(files)
        fil = files(i);
        if (fil.isdir && ~(strcmp(fil.name,'.') || strcmp(fil.name,'..')))
            sub_dir = fullfile(root_dir, fil.name);
            tmp_paths = GetPaths(sub_dir, we_look_for_this_file);
            if (~isempty(tmp_paths))
                path = strvcat(path ,tmp_paths);
            end
        elseif (strcmp(fil.name, we_look_for_this_file))
            path = strvcat(path, fullfile(root_dir, fil.name));
        end
    end
    

