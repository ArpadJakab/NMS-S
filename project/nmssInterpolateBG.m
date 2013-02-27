function bg_less_img = nmssInterpolateBG( img, hFigure )
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
    bg_less_img = img;

    menu_txt = {'Press ''Add Point'' to mark pixels on the real space image'; ...
                'which should be treated as background. The final background is'; ...
                'interpolated using the marked points as fix points of the interpolation';; ...
                'Press ''Finish'' when finished marking'};
            
    if (menu(menu_txt, 'Add Point', 'Finish') == 1)
        % use mouse to mark points
    end
    
    % create background surface z=f(x,y) and subtract it from the image
    