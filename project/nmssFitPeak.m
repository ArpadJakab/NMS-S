function [Eres, FWHM, maxInt, fitcurve, fittedindices] = nmssFitPeak(x_axis, values, fittype)
% fittedindices -  the indices of the values in 'values' which have been
% fitted
% fittype - 'poly2' for a parabola fitting of the peak
%           'lorentz' for a lorentz fitting of the peak
    fitcurve = [];
    fittedindices = [];
    Eres = NaN;
    maxInt = NaN;
    FWHM = NaN;

    if (size(x_axis,2) ~= 1) 
        x_axis = x_axis'; % make it to a column vector
    end;
    
    if (size(values,2) ~= 1) 
        values = values'; % make it to a column vector
    end;
    

    if (strcmp(fittype, 'poly2'))
        [Eres, maxInt, fitcurve, fittedindices] = FitPoly2(x_axis, values);
        % No FWHM, will be dermnined later
    elseif (strcmp(fittype, 'lorentz'))
        [Eres, FWHM, maxInt, lorentz_curve] = nmssLorentzFit( x_axis, values , n);
        fitcurve = lorentz_curve;
        fittedindices = [1:length(values)];
    end



% fit top of the peak with a parabola
function [Eres, maxInt, fitcurve, fittedindices] = FitPoly2(x_axis_eV, spec_eV)
    fitcurve = [];
    fittedindices = [];
    Eres = NaN;
    maxInt = NaN;
    
    fittedindices = 1:length(spec_eV);

    if (length(fittedindices) > 3)
        fittedcurve = spec_eV;
        fit_x = x_axis_eV;
        
        try 
            fittedcurve(find(isinf(fittedcurve))) = 0; % is inf value is in the data set it to zero (it won't affect the fit more than leaving it inf)
            f = fit(fit_x, fittedcurve, 'poly2'); % poly2 = parabolic curve (polynome 2nd order)
            fitcurve = f(fit_x);
        catch
            disp(lasterr());
            keyboard;
        end
        
        % get polynom parameters
        % f(x) = p1*x^2 + p2*x + p3 = y
        p3 = f(0);
        
        % using arguments 1 and -1 to have two equations to find p1 and p2
        p1 = (f(1) + f(-1) - 2*p3) / 2;
        p2 = (f(1) - f(-1)) / 2;
        
        % maximum of the parabola is where the first derivative is zero
        % f'(X) = 2*p1*x + p2 = 0
        % thus Eres = x0 = -p2 / (2*p1), if p1 < 0 
        if (p1 <= 0)
            Eres = -p2 / (2*p1);
        else
            [dummy, i] = max(fitcurve);
            Eres = x_axis_eV(i);
        end
        
        maxInt = f(Eres);
    end
    

    




