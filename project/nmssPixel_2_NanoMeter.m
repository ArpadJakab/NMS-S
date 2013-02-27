function nanometer = nmssPixel_2_NanoMeter(pixel)
    figure_axis_px = nmssSetAxis('pixel');
    figure_axis_nm = nmssSetAxis('nanometer');
    nanometer = (pixel - figure_axis_px.center.x) * figure_axis_nm.scale.current.x + figure_axis_nm.center.x;

