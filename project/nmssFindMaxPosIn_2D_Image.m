function [pos_x, pos_y] = nmssFindExtremalPosIn_2D_Image(img, start_pos_x, start_pos_y, extr_type)
% finds the position of maximum in image starting at start_pos_x,
% start_pos_y. Stops at the first relative maximum.

    
    try
        start_value = img(start_pos_y, start_pos_x);
    catch
        disp('Error! Switched into debug mode');
        keyboard;
    end
    
    if (strcmp(extr_type, 'max'))
        while (1)
            search_area = img(start_pos_y-1:start_pos_y+1, start_pos_x-1:start_pos_x+1);
            [val, col_index] = max(max(search_area));
            [dummy, row_index] = max(search_area(:,col_index));

            col_index = col_index + start_pos_x - 2;
            row_index = row_index + start_pos_y - 2;

            if (val > start_value)
                start_pos_x = col_index;
                start_pos_y = row_index;
                start_value = val;
            else
                pos_x = col_index;
                pos_y = row_index;
                break;
            end

        end
    else
        while (1)
            search_area = img(start_pos_y-1:start_pos_y+1, start_pos_x-1:start_pos_x+1);
            [val, col_index] = min(min(search_area));
            [dummy, row_index] = min(search_area(:,col_index));

            col_index = col_index + start_pos_x - 2;
            row_index = row_index + start_pos_y - 2;

            if (val > start_value)
                start_pos_x = col_index;
                start_pos_y = row_index;
                start_value = val;
            else
                pos_x = col_index;
                pos_y = row_index;
                break;
            end

        end
    end
    
