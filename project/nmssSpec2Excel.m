function excel_file_path = nmssSpec2Excel( spec, varargin )
%excel_file_path = nmssSpec2Excel( spec, target_file_path) - converts spec structure to an excel file
% the spec structure comes from the function nmssExtractNormalizedSpectra.
%  Returns the saved file path or an ampty string if the save was
%  unsuccessful

    excel_file_path = '';
    target_file_path = '';
    
    if (length(varargin) == 1)
        % get root directoy
        target_file_path = varargin{1};
        if (exist(target_file_path) ~= 0)
            error(['File: "', target_file_path, '" already exists! Please provide a different file name or file path!']);
            return;
        end
    else
        [filename, dirname] = uiputfile({'*.xls','Excel Worksheet(*.xls)'}, 'Export spectrum in Excel file', 'spec.xls');

        if (filename ~= 0) % user pressed OK in file save dialog

            % save berg plot matrix
            target_file_path = fullfile(dirname, filename);
        else
            return; % user pressed cancel
        end
    end

    % now it's time to save the excel file
    for i=1:length(spec)
        sheet_name = ['run ', num2str(i)];
        warning off MATLAB:xlswrite:AddSheet

        % assemble the matrix
        num_of_specs = size(spec(i).normalized,2);
        title_row = {'nm'};

        for k=1:num_of_specs
            title_row{end + 1} = ['Particle ' ,num2str(k)];
        end
        xlswrite(target_file_path, title_row, sheet_name, 'A1');
        
        data = [spec(i).axis.x, spec(i).normalized];
        disp(['Saving file: ', target_file_path, ' sheet: ', sheet_name] );
        xlswrite(target_file_path, data, sheet_name, 'A2');
        
    end

    excel_file_path = target_file_path;
    
    