function color = nmssWavelength2RGB(Wavelength)
%     nmssWavelength2RGB - Calculate RGB values given the wavelength of visible light.
% 
%     INPUT:
%     * Wavelength:  Wavelength in nm.  Scalar real value.
% 
%     Returns:
%     3-element array of RGB values for the input wavelength.  The
%      values are scaled from 0 to 1, where 0 is the
%      lowest intensity and 1 is the highest.
% 
%     Visible light is in the range of 380-780 nm.  Outside of this
%     range or if Wavelength is NaN the returned RGB triple is [0,0,0]. 
% 
%     Based on code by Earl F. Glynn II at:
%        http://www.efg2.com/Lab/ScienceAndEngineering/Spectra.htm
%     See also:
%        http://www.physics.sfasu.edu/astro/color/spectra.html
%     whose code is what Glynn's code is based on.
% 
%     Example:
%       coming soon...
%
% Copyright (c) 2003 by Johnny Lin.  For licensing, distribution 
% conditions, contact information, and additional documentation see
% the URL http://www.johnny-lin.com/pylib.html.
% Translated (2008) into matlab by Arpad Jakab (arpad.jakab@yahoo.de)
%=======================================================================

    %- Set RGB values (normalized in range 0 to 1) depending on
    %  heuristic wavelength intervals:
    if(isnan(Wavelength))
        color = [0, 0, 0];
        return;
    end
        
        
    
    %if ((Wavelength >= 380.0) & (Wavelength < 440.0))
    if ((Wavelength < 440.0))
        Red   = -(Wavelength - 440.) / (440. - 380.);
        Green = 0.0;
        Blue  = 1.0;
    elseif ((Wavelength >= 440.0) & (Wavelength < 490.0))
        Red   = 0.0;
        Green = (Wavelength - 440.) / (490. - 440.);
        Blue  = 1.0;
    elseif ((Wavelength >= 490.0) & (Wavelength < 510.0))
        Red   = 0.0;
        Green = 1.0;
        Blue  = -(Wavelength - 510.) / (510. - 490.);
    elseif ((Wavelength >= 510.0) & (Wavelength < 580.0))
        Red   = (Wavelength - 510.) / (580. - 510.);
        Green = 1.0;
        Blue  = 0.0;
    elseif ((Wavelength >= 580.0) & (Wavelength < 645.0))
        Red   = 1.0;
        Green = -(Wavelength - 645.) / (645. - 580.);
        Blue  = 0.0;
    %elseif ((Wavelength >= 645.0) & (Wavelength <= 780.0))
    elseif ((Wavelength >= 645.0))
        Red   = 1.0;
        Green = 0.0;
        Blue  = 0.0;
    else
        Red   = 0.0;
        Green = 0.0;
        Blue  = 0.0;
    end


    %- Let the intensity fall off near the vision limits:
    Factor = 1.0;
% 
%     if ((Wavelength >= 380.0) & (Wavelength < 420.0))
%         Factor = 0.3 + 0.7*(Wavelength - 380.) / (420. - 380.);
%     elseif ((Wavelength >= 420.0) & (Wavelength < 701.0))
%         Factor = 1.0;
%     elseif ((Wavelength >= 701.0) & (Wavelength <= 780.0))
%         Factor = 0.3 + 0.7*(780. - Wavelength) / (780. - 700.);
%     else
%         Factor = 0.0;
%     end


    %- Adjust and scale RGB values to 0 to 1:

    R = Adjust_and_Scale(Red,   Factor);
    G = Adjust_and_Scale(Green, Factor);
    B = Adjust_and_Scale(Blue,  Factor);


    %- Return 3-element array value:
    color = [R, G, B];





%--------------------------- Helper Function ---------------------------

function result = Adjust_and_Scale (Color, Factor)
%         Gamma adjustment.

%         Arguments:
%         * Color:  Value of R, G, or B, on a scale from 0 to 1, inclusive,
%           with 0 being lowest intensity and 1 being highest.  Floating
%           point value.
%         * Factor:  Factor obtained to have intensity fall off at limits 
%           of human vision.  Floating point value.
% 
%         Returns an adjusted and scaled value of R, G, or B, on a scale 
%         from 0 to 1
% 
%         Since this is a helper function I keep its existence hidden.
%         See http://www.efg2.com/Lab/ScienceAndEngineering/Spectra.htm and
%         http://www.physics.sfasu.edu/astro/color/spectra.html for details.
        Gamma = 0.80;

        if (Color <= 0.0)
            result = 0;
        else
            result = realpow(Color * Factor, Gamma);
            if (result < 0)
                result = 0;
            elseif (result > 1)
                result = 1;
            end
        end





