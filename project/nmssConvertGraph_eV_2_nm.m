function [ x_nm, y_nm ] = nmssConvertGraph_nm_2_eV( x_eV, y)
%nmssConvertGraph_nm_2_eV Converts graph from eV to nm representation
%  Detailed explanation goes here



    % use the photonic energy-momentum dispersion relation in vacuum to calculate photon
    % energies from the wavelength
    x_nm = 1240 ./ x_eV;
    % ordering x-axis to have low energy at low vector indices
    if (size(x_nm, 1) ~= 1) 
        x_nm = x_nm'; 
    end
    x_nm = fliplr(x_nm);
    
    % adjusting the spectra to the flipped x-axis
    if (size(y, 1) ~= 1) 
        y = y'; 
    end
    y_nm = fliplr(y);


