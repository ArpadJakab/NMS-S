function [x_axis, ens ] = nmssCreateEnsemble( results )
% calculates ensemble spectrum from single particle measurements
% INPUT:
% results - the results structure as crated by NMSS
%
% OUTPUT:
% ??? undecided

    num_of_jobs = length(results.job);

    specs = [];
    spec_length = length(results.job{1}.graph{1}.normalized);
    x_axis = results.job{1}.graph{1}.axis.x;
    for k=1:num_of_jobs
        
        job = results.job{k};
        if (isempty(job))
            continue;
        end
        
        num_of_graphs = length(job.graph);
        
        for i=1:num_of_graphs
            if (job.graph{i}.bg_valid)
                if (length(job.graph{i}.normalized) ~=  spec_length);
                    error(['Job #', num2str(k), ' ,graph #', num2str(i), ' has the size: ', num2str(length(job.graph{i}.normalized)), ...
                           ' which is different than the expected graph size: ', num2str(spec_length), ' ( the size of job{1}.graph{1}.normalized).']);
                    return;
                end
                specs = [specs; job.graph{i}.normalized];
            end
        end
    end
    
    
    % specs is a matrix with each row containing the normalized spectra of
    % a particle
    % Now we sum the values in each column and we get a row vector, the
    % spectrum of the ensemble
    ens = sum(specs,1)
        
