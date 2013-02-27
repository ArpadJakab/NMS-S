function pixel = nmssNanoMeter_2_Pixel(nanometer)
    figure_axis_px = nmssSetAxis('pixel');
    figure_axis_um = nmssSetAxis('micron');
    pixel = (nanometer - figure_axis_um.center.x) / figure_axis_um.scale.current.x + figure_axis_px.center.x;

