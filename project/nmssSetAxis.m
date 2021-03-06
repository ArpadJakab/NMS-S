function figure_axis = nmssSetAxis(unit)
% sets the paramters needed to define the axis units
% unit - the target unit
     global app;
     global doc;
     
     % x-axis
     if (strcmp(unit.x,'micron'))
        figure_axis.scale.current = app.calidata.micron_per_px;
        figure_axis.unit.x = 'micron';
        figure_axis.center.x = size(doc.img,2) / 2.0 * app.calidata.micron_per_px.x;
     elseif (strcmp(unit.x,'nanometer'))
        cur_grating_id = doc.current_job(1).grating;
    
        % scaling information for the current grating
        figure_axis.scale.current.x = app.wavelength_calibration.nm_per_pixel(cur_grating_id);
        figure_axis.unit.x = 'nanometer';
        figure_axis.center.x = doc.current_job(1).central_wavelength;
     else
        % scale = 1 means one pixel correspond to one pixel
        figure_axis.scale.current.x = 1;
        figure_axis.unit.x = 'pixel';
        figure_axis.center.x = size(doc.img,2) / 2.0;
     end
    
     % y-axis
     if (strcmp(unit.y,'micron'))
        figure_axis.scale.current = app.calidata.micron_per_px;
        figure_axis.unit.y = 'micron';
        figure_axis.center.y = size(doc.img,1) / 2.0 * app.calidata.micron_per_px.y;
     elseif (strcmp(unit.y,'nanometer'))
        cur_grating_id = doc.current_job(1).grating;
    
        % scaling information for the current grating
        figure_axis.scale.current.y = 1; % y scaling is by pixels
        figure_axis.unit.y = 'pixel'; % y scaling is by pixels
        figure_axis.center.y = size(doc.img,1) / 2.0;
     elseif (strcmp(unit.y,'pixel'))
        % scale = 1 means one pixel correspond to one pixel
        figure_axis.scale.current.y = 1; 
        figure_axis.unit.y = 'pixel';
        figure_axis.center.y = size(doc.img,1) / 2.0;
     end
    
 