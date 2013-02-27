function [ x_eV, y_eV ] = nmssConvertGraph_nm_2_eV( x_nm, y)
%nmssConvertGraph_nm_2_eV Converts graph from eV to nm representation
%  Detailed explanation goes here



    % use the photonic energy-momentum dispersion relation in vacuum to calculate photon
    % energies from the wavelength
    x_eV = 1240 ./ x_nm;
    % ordering x-axis to have low energy at low vector indices
    if (size(x_eV, 1) ~= 1) 
        x_eV = x_eV'; 
    end
    x_eV = fliplr(x_eV);
    
    % adjusting the spectra to the flipped x-axis
    if (size(y, 1) ~= 1) 
        y = y'; 
    end
    y_eV = fliplr(y);


