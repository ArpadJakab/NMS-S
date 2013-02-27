function  user_canceled = nmssSaveResults(results, varargin)
    user_canceled = true;

    %global nmssDataEvaluationDlg_Data;
    global doc;
    
    % save results file
    
    % get old working directory
    old_current_dir = pwd;
    
    if (length(varargin) >= 1)
        save_dir = varargin{1};
    else
        save_dir = doc.workDir;
    end

    %change to nmss working directory (which is not the same as the
    %matlab working directory)
    cd(save_dir);

    [filename, dirname] = uiputfile({'*.mat','Matlab data (*.mat)'}, 'Save results', 'results.mat');
    cd(old_current_dir);

    if (filename ~= 0) % user pressed OK in file save dialog
        
        % save berg plot matrix
        filepath = fullfile(dirname, filename)
        try
            save(filepath, 'results', '-mat');
        catch
            errordlg(lasterr());
        end
    else
        return;
    end
    
    user_canceled = false;
    
    
