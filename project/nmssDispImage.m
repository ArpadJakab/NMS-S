function nmssDispImage()
% displays an image in the figure defined by the handle
% uses only one figure. Create if not existing, raise if already
% created
    
    global app;
    global doc;
    
    % activate figure to display the image
    if (isfield(app, 'nmssFigure'))
        if (ishandle(app.nmssFigure))
            figure_handles = guidata(app.nmssFigure);


            full_lim = nmssGetFullImageLimits(doc.figure_axis.unit);

            figure(app.nmssFigure);
            current_limits.x = xlim;
            current_limits.y = ylim;

            nmssPaintImage('refresh', doc.img, app.nmssFigure, figure_handles.canvasFigureAxes, full_lim, current_limits);
            
        else
            nmssFigure();
        end
    else
        nmssFigure();
    end
