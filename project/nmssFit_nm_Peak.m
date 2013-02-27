function [fit_x_nm, fit_y_nm] = nmssFit_nm_Peak( x_nm, spec, spec_smoothed )
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

    [peak_max peak_FWHM max_int, fit_x, fit_y, str_errmsg] = nmssGetMaxAndFWHM(spec, spec_smoothed, x_nm, 0);

    [fit_x_nm, fit_y_nm] = nmssConvertGraph_eV_2_nm(fit_x, fit_y);