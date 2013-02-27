function [ ERes FWHM maxInt lorentz_curve] = nmssLorentzFit( energy, intensity , n, varargin)
% IN:
%   energy      - the x-axis of the data series (energy in eV)
%   intensity   - the data values (intensity)
%   n           - unknown parameter

    maxInt = NaN;
    ERes = NaN;
    FWHM = NaN;
    lorentz_curve = [];

    if (length(varargin) == 0)
        [ ERes FWHM maxInt lorentz_curve] = nmssLorentzFit1( energy, intensity , n);
    elseif (length(varargin) == 2)
        maximum = varargin{1};
        fit_index_range = varargin{2};
%         if (length(maximum) > 2)
%             errordlg('More than 2 maxima found, no fit is possible!')
%             return;
%         end
        
        [ ERes FWHM maxInt lorentz_curve] = nmssLorentzFit2( energy, intensity , n, maximum, fit_index_range);
    else
        error('Too many input parameters (more than 4)!');
    end

% -------------------------------------------------------------------------
function [ ERes FWHM maxInt lorentz_curve] = nmssLorentzFit2( energy, intensity , n, maximum, fit_index_range)

    
    % IN:
    % energy - the energy (x-axis) of the peak
    % intensity - the spectrum intensity 
    % n - an unused parameter
    % maximum - vector with the indices of maxima
    % fit_index_range - vector of indices of that part of the curve that
    % have to be fitted

    l = length(maximum);

    % cut the inter-band-transitions out of spectrum before fitting with a lorentz-function:
    % it cuts of the high energy tail of the peak, where the high energy
    % tail is steadily growing to higher energies
    %    lowCutOff = energy( min(intensity(energy>maxEnergy)) == intensity );
    %    filter = energy<lowCutOff;
        filter = energy>0;
    
    % define the handle to the lorentz function
    hLorentz = @Lorentz;
    
    % set of parameters used for the lorentz function (these are the
    % starting parameters)
    par1 = [intensity(maximum(:))', energy(maximum(:))', ...
                            ones(l,1) * 0.05, zeros(l,1)];
                        
    min_int = min(intensity(fit_index_range));
    max_int = max(intensity(fit_index_range));
                            
    % lower and upper bound for the fitting parameters
    lb1 = ones(size(par1));
    ub1 = ones(size(par1));
    lb1(:,1) = par1(:,1) * 0.8;
    lb1(:,2) = par1(:,2)*0.95;
    lb1(:,3) = ones(l,1) * 0.01;
    lb1(:,4) = zeros(l,1) - max_int * 0.01;
%     if (min_int < 0)
%         lb1(:,4) = min_int - (max_int - min_int) * 0.1 ;
%     end
    
    ub1(:,1) = par1(:,1) *1.5;
    ub1(:,2) = par1(:,2)*1.05;
    ub1(:,3) = ones(l,1) * 0.8;
    %ub1(:,4) = min_int + (max_int - min_int) * 0.01;
    ub1(:,4) = max_int * 0.01;
                        

    par = par1;
    lb = lb1;
    ub = ub1;
    
        options = optimset('MaxFunEvals',1000,'TolFun',1e-10,'TolX',1e-10);
    % do fit
    try
        [parFit,resnorm] = lsqcurvefit(hLorentz, par , energy(fit_index_range), intensity(fit_index_range), lb, ub, options);
    catch
        disp(lasterr());
        keyboard;
    end

    num_of_lorentz_funcs = size(par,1);
    for i=1:num_of_lorentz_funcs;
        maxInt(i) = parFit(i,1);
        ERes(i) = parFit(i,2);
        FWHM(i) = 2*parFit(i,3);
    end


    % create lorentz curve
        %energySmooth = linspace(min(energy),max(energy),1000);
        %lorentz_curve = lorentz(parFit, energySmooth);
    lorentz_curve = hLorentz(parFit, energy);
    
    
    
    
% -------------------------------------------------------------------------
function [ ERes FWHM maxInt lorentz_curve] = nmssLorentzFit1( energy, intensity , n)


global ENABLEDEBUG;
global Npart;

% define an added linear function which is superimposed over the lorentz
% curve
    % slope
    m = (intensity(end) - intensity(1))/(energy(end)-energy(1));
    % vertical offset
    c = intensity(1) - m * energy(1);

  
% define Lorentz-Function
    lorentz = @(par,x) par(1)./( 1 + ((x-par(2))./par(3) ).^2 );
    % lorentz plus a line
    %lorentz = @(par,x) par(1)./( 1 + ((x-par(2))./par(3) ).^2 ) + m*x + c ;

% calc basic parameters of spectrum
    maxEnergy = energy( intensity == max(intensity) );
    if maxEnergy==find(energy==min(energy)) || isempty(find(energy>maxEnergy, 1))
        disp('WARNING: maximum out of range - Setting results to NaN.');
        maxInt = NaN;
        ERes = NaN;
        FWHM = NaN;
        return
    end

% cut the inter-band-transitions out of spectrum before fitting with a lorentz-function:
    lowCutOff = energy( min(intensity(energy>maxEnergy)) == intensity );
    filter = energy<lowCutOff;
% set start parameters for fit + lower/upper bound
    par = [ max(intensity) maxEnergy 0.05 ];
    lb =  [ max(intensity)   maxEnergy*0.7 0.01];
    ub =  [ max(intensity)*3 maxEnergy*1.3 0.5];
    options = optimset('MaxFunEvals',10000,'TolFun',1e-10,'TolX',1e-10);
% do fit
    [parFit,resnorm] = lsqcurvefit(lorentz, par , energy(filter), intensity(filter), lb, ub, options);

% estimate reliability of fit
    filter2 = (energy<parFit(2)+1.5*parFit(3)) & (energy>parFit(2)-1.5*parFit(3));
    errSum = sqrt( sum( ( intensity(filter2) - lorentz(parFit,energy(filter2)) ).^2 ./ ( intensity(filter2).^2 ) ) )./length(energy((filter2)));
    if (errSum > 0.05) ||  (parFit(2) < min(energy) )
        disp('WARNING: fit-error greater than 0.05 or maximum out of range - Setting results to NaN.');
        maxInt = NaN;
        ERes = NaN;
        FWHM = NaN;
    else
    %    set output-variables
            maxInt = parFit(1);
            ERes = parFit(2);
            FWHM = 2*parFit(3);
    end
    
% create lorentz curve
    %energySmooth = linspace(min(energy),max(energy),1000);
    %lorentz_curve = lorentz(parFit, energySmooth);
    lorentz_curve = lorentz(parFit, energy);
    
% DEBUG plot
    if ENABLEDEBUG>0
       figure(Npart+n+3);clf;
            energySmooth = linspace(min(energy),max(energy),1000);
            h(1) = plot(energy,intensity,'r.');
            hold on
%             h(3) = plot(energy(filter2),intensity(filter2),'ko');
            h(2) = plot(energySmooth,lorentz(parFit,energySmooth));
            plot([ERes ERes], [0 maxInt],'r-')
            plot([ERes-FWHM/4 ERes+FWHM/4], [maxInt/4 maxInt/4],'k-')
%             h(4) = plot([lowCutOff lowCutOff], [0 2*intensity(energy==lowCutOff)],'k-','LineWidth',2);
            xlabel('Energy [ev]');
            ylabel('C_{sca}');
            if (errSum > 0.05)  |  (parFit(2) < min(energy) ) %#ok<OR2>
                set(gca,'Color',[1 0.7 0.7]);
            end
            %legend(h,'original Data','Lorentz-Fit','Used to test fit','Cutoff energy for fit','Location','NW')

    end    
    
% -------------------------------------------------------------------------
% this is the definition of the lorentz function (or arbritrary numbers of
% sums of it)
function y = Lorentz(par, x)
% this is the definition of the lorentz function plus a const. offset

    num_of_lorentz_funcs = size(par,1);
    %disp(['num_of_lorentz_funcs ', num2str(num_of_lorentz_funcs)]);
    
    y = 0;
    
    for i=1:num_of_lorentz_funcs
        intensity = par(i,1);
        energy = par(i,2);
        hwhm = par(i,3);
        offset = par(i,4);

        %y = y + intensity./( 1 + ((x-energy)./hwhm ).^2 );
        y = y + intensity./( 1 + ((x-energy)./hwhm ).^2 ) + offset;
    end
    
        
    