function nanometer = nmssPixel_2_NanoMeter(pixel)
    figure_axis_px = nmssSetAxis('pixel');
    figure_axis_um = nmssSetAxis('micron');
    nanometer = (pixel - figure_axis_px.center.x) * figure_axis_um.scale.current.x + figure_axis_um.center.x;

