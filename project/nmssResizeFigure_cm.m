function ResizeFigure_cm( hFigure, width_cm, height_cm )
%ResizeFigure_cm - resizes figure with to the given size 

    set(hFigure, 'Units', 'centimeters');
    
    pos = get(hFigure, 'Position');
    
    pos(3) = width_cm;
    pos(4) = height_cm;
    
    set(hFigure, 'Position', pos );
