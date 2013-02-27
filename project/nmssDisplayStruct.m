function nmssDisplayStruct(strukt)
% Displays a struct recursively
% strukt - the struct to be displayed


    parent = [''];
    nmssDisplayStructTab(strukt, parent)

function nmssDisplayStructTab(strukt, parent)
% assistant function for nmssDisplayStruct

    fnames = fieldnames(strukt);
    fnames_size = size(fnames,1);
    
    for fn_index = (1:fnames_size)
        fname = fnames{fn_index}; 
        
        disp({[parent, '.', fname ,':']});
        
        field = getfield(strukt, fname);
        if (isstruct(field))
            % call recursively this current function if we encounter another struct
            nparent = [parent, '.', fname];
            nmssDisplayStructTab(field, nparent);
        else
            num_of_rows = size(field,1);
            num_of_cols = size(field,2);
            % if data is a large matrix don't print it!
            if (num_of_rows > 10)
                disp(['array ', num2str(num_of_rows), 'x', num2str(num_of_cols)]);
            else
                disp(field);
            end
        end
        
        
    end