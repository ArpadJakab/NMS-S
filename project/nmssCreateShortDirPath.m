function [output_dir, num_of_dir_parts]  = nmssCreateShortDirPath( input_dir, num_of_up_levels, num_of_low_levels )
% nmssCreateShortDirPath - creates a chortened version of a directory path
%
% IN:
%   input_dir - the directory that has to be shortened
%   num_of_up_levels - number of directory levels to be displayed starting
%   from root
%   num_of_low_levels - number of directory levels to be displayed from the
%   last one back

    fileSep = filesep(); % path separator string
    
    sepIndex = find(input_dir == fileSep);
    
    num_of_dir_parts = length(sepIndex);
    
    if (num_of_up_levels + num_of_low_levels > num_of_dir_parts)
        output_dir = input_dir;
    else
        output_dir = [input_dir(1:sepIndex(num_of_up_levels)),'...',input_dir(sepIndex(end - num_of_low_levels + 1):end)];
    end
    
    


