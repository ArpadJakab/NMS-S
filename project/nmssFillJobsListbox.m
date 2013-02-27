function list_box_entry = nmssFillJobsListbox( listbox_handle, list_of_jobs)
%nmssFillJobsListbox creates string that is displayed in the list of jobs
%listbox

% Wrapper to create and format the strong, that will be displayed in the list of jobs
% listbox

    % this will be displayed in the list box
    success_indicator = {'  ', 'OK'};
    
    num_of_jobs = length(list_of_jobs);
    list_box_entry = cell(num_of_jobs,1);
    
    % create list of jobs
    for k=1:num_of_jobs
        % this will be displayed in the list box
        no = Num2StrFormat(k, 3, 0);
        
        pos_x = Num2StrFormat(list_of_jobs(k).pos.x, 7, 3);
        
        pos_y = Num2StrFormat(list_of_jobs(k).pos.y, 7, 3);
        
        file_name = list_of_jobs(k).filename;
        
        exec_status = success_indicator{list_of_jobs(k).status + 1};
        
        % this is the formatted text which will be displayed in the list of
        % jobs listbox on the main window
        list_box_entry{k} = [no, ' ', exec_status,' ',pos_x,' ', pos_y,' ',file_name];
    end
    set(listbox_handle, 'String', list_box_entry);
    set(listbox_handle, 'Value', 1);
    
    
%    
function str = Num2StrFormat(num, string_max_length, num_of_decimal_digits)
    % insert blanks to the front of the string, so that the decimal points are positioned
    % above each other
    
    format_str = ['%.',num2str(num_of_decimal_digits),'f'];
    number = num2str(num,format_str);

    % calculate the number of blanks to be put in front of the number to
    % reach the desired string length
    blank = [1:string_max_length - size(number,2)];
    blank(:) = ' ';
    str = [char(blank),  number];

