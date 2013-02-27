function [yClean, Noisestart] = noisefilter(x, Int, FilterThres, debug)
% NOISEFILTER removes noise from data.
% Filter a spectrum to remove noise by fourier transforming 
% it and cut values below a certain threshold.
%
% The filter should work fine for most cases where a underlying peak is
% visible to the eye. However, if the noise is  to strong the filtering
% might lead to corrupt data.
%
% Input: 
% yClean = noisefilter(x, Int, FilterThres); 
% yClean = noisefilter(x, Int, FilterThres, debug);
%
% yClean = noisefilter(x, Int, FilterThres) 
% If noisefilter is called using x, Int and FilterThres = 'auto' an
% automatic filtering is done. The initial decay in the power spectrum is
% detected and the rest of the power spectrum is set to 0 (= eliminating
% 'high' frequency fluctuations in the spectrum).                              
% 
% It is also possible to give a certain threshold (Filterthres) manually. 
% The manual threshold is the wavelength of the oscillation to be filtered. 
% The threshold should be choosed 1nm bigger than the oscillation to 
% filter, e.g. if there is a small oscillation of 10nm wavelength in a peak
% then the threshold should be at least at 11nm. All faster oscialltions 
% will be filtered from power spectrum. This manual filter option should be 
% quite intuitive nowis now...
%
% yClean = noisefilter(x, Int, FilterThres, debug)
% debug - set to 1 if you want to see the figures... else it's 0.
%         
% If "noisefilter" is called without any input arguments a sample data set
% will be generated and shown. 
% 
% Now working with data, that contains NaN-values. The values will be
% removed from the data before perfoming the fft and afterwards the
% original vector is rebuilt by putting back the NaN. 
% 
% 27.04.2009 Andreas Henkel
% $Revision 1.5 $ $8:00 $
% $Revision 2.0 $ 14.10.2009 $ 11:00 $ 
% $Revision 3.0 $ 21.05.2010 $ 10:46 $ Changed the manual filter option to
%                                      a meaningful procedure... (thanks to
%                                      Arpad for the suggestion)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
debug_out = false; % if set to true it prints debug info in command prompt


% check input arguments
if (nargin == 0)
    testfilter    % runs sample
else
    % check input arguments
    if (nargin < 4)
        debug    = 0; 
    end;
    if (ischar(FilterThres))
        if (debug_out) disp('automatic filtering'); end
        Switcher = 'auto';
    else
        Switcher = 'manual';
    end;
    
    NaNcatch = 0; 
    if (isnan(mean(Int))) 
        warning('found NaN´s, removing them for calculation of FFT...'); 
        NaNcatch    = 1;
        Intorigin   = Int;                              % copy input
        PosOfNaN    = find(isnan(Int));                 % find NaN      
        PosOfNumber = find(isnan(Int) == 0); 
        Int(PosOfNaN) = [];                             % remove NaN
    end
        
    warning('off')
    Y           = fft(Int);                             % calculate fourier transform
    Pyy         = Y.* conj(Y) ./ length(Y);             % calculate power spect
    f           = (0:length(Pyy)/2-1)./length(Pyy);     % generate x-scale for power spect
    f2           = (0:length(Pyy)-1)./length(Pyy);      % generate full x-scale for power spect
    Pyyclean    = Pyy;                                  % copy power spect

    % switch automatic filter and manual filter
    switch Switcher
        case 'manual'
            if (debug_out) disp(['choosed manual... Oszillation to filter has ' num2str(FilterThres) 'nm']); end
%             Pyyclean(abs(Pyyclean)<FilterThres) = 0;            % clean power spect
            Noisestart              = find(f > 1/FilterThres,1);
            Noiseend                = find(f2 > 1-1/FilterThres,1); 
            Pyyclean(Noisestart:Noiseend) = 0;         % clean power spect
            
        case 'auto'
            dPyy                    = gradient(Pyy); % calculate derivatives
            ddPyy                   = gradient(dPyy);
            Noisestart              = find(dPyy >= 0 | abs(dPyy) < 1/50*max(Pyy),1,'first'); % find "start" of noise
            Noiseend                = find(dPyy <= 0 | abs(dPyy) < 1/50*max(Pyy),1,'last'); % find "end" of noise
            Pyyclean(Noisestart:Noiseend) = 0;         % clean power spect
    end

    yCleantmp   = real(fliplr(fft(Pyyclean./conj(Y))));       % transform back   
    
    if (NaNcatch == 1); 
        %% rebuilding original vector
        yClean      = zeros(size(Intorigin)); 
        yClean(PosOfNaN) = NaN; 
        yClean(PosOfNumber) = yCleantmp; 
    else
        yClean = yCleantmp;
    end
    
    if (debug == 1)
        
        scrsz = get(0, 'ScreenSize');
        fig1 = figure;
        subplot(3,1,1); hold all; 
        plot(x, Int,'.');
        plot(x, yClean,...
            'linewidth',2,...
            'Color', [1 .3 .2]);
        xlabel('nm'); 
        ylabel('I');
        legend('starting spectrum', 'filtered spectrum');
        legend('boxoff'); 
        title('Spectra')
        set(gca, 'box','on',...
            'YLim', [-0.1 1.1.*max(Int)],...
            'linewidth',2);

        subplot(3,1,2);  hold all;
        plot(f, Pyy(1:length(Pyy)/2)); 
        plot(f, Pyyclean(1:length(Pyyclean)/2),'linewidth',2);
        legend('raw power spectrum', 'filtered power spect'); 
        legend('boxoff'); xlabel('1/nm')
        title('Power spectra')
        set(gca, 'box','on',...
            'linewidth',2,'YScale','log');
        %            'YLim', [0 2*mean(Pyy)],...

        subplot(3,1,3); hold all;
        plot(x, (yClean-Int),'-', 'linewidth',1); 
        plot([x(1) x(end)], [mean(yClean-Int) mean(yClean-Int)],...
            'Color', [.9 .3 .3],...
            'linewidth',2);
        xlabel('nm'); 
        ylabel('I');
        legend(['Error = I_{orig} - I_{filtered}'],...
            ['Mean = ' num2str(mean(yClean-Int))] );
        legend('boxoff'); 
        title('Extracted noise')
        set(gca, 'box','on',...
            'YLim', [1.1.*min((yClean-Int)) 1.1.*max((yClean-Int))],...
            'linewidth',2);
        
%         set(fig1, 'Position', [scrsz(1)+10 scrsz(2)+10 scrsz(3)-20 scrsz(4)-20]);
    end
    warning('on')
end


    function testfilter
        warning('off')
        x = 400:1:900;                                  % nm-Scale
        y = exp(-1/2 * ((x-700).^2./100.^2) );           % generate Peak at 700nm

        noisefact   = 2e-1;
%         yNoise      = y+ noisefact.*randn(1,length(x)); % add noise
        yNoise      = y+noisefact*cos(2*pi./10.*x);
        NoiseThres  = 2e-1;

        Y                       = fft(yNoise);          % calculate fourier transform
        Pyy                     = Y.* conj(Y) ./ length(Y); % calculate power spect
        dPyy                    = gradient(Pyy(1:length(Pyy))); % calculate derivative
        ddPyy                   = gradient(Pyy(1:length(Pyy)));
%         Noisestart              = find(dPyy >= 0 | abs(dPyy) < 0.01,1,'first'); % find "start" of noise
%         Noiseend                = find(dPyy <= 0 | abs(dPyy) < 0.01,1,'last');

% keyboard
        f                       = (0:length(Pyy)-1)./length(Pyy); % generate x-scale for power spect
        f2                       = 1./((x-min(x))./abs(x(1) - x(end))) ;
        Noisestart              = find(f > 1/15,1);
        Noiseend                = find(f > 1-1/15,1); 
%         keyboard
        find(f> 11)
        Pyyclean                = Pyy;                  % copy power spect
        Pyyclean(abs(Pyyclean)<NoiseThres) = 0;         % clean power spect
        Pyyclean2               = Pyy;                  % copy power spect
        Pyyclean2(Noisestart:Noiseend) = 0;         % clean power spect
        yClean                  = fliplr(fft(Pyyclean./conj(Y)));   % transform back   
        yClean2                 = fliplr(fft(Pyyclean2./conj(Y)));   % transform back   
        firsthalf               = Pyy(1:length(Pyy)/2);
        secondhalf              = Pyy(length(Pyy)/2+1:length(Pyy));
        Temp                    = fliplr(secondhalf); 
        flippedsecondhalf(1)    = NaN; 
        flippedsecondhalf(2:length(Temp)+1)    = Temp; 
        SymmetricPyy(1:length(Pyy)/2) = secondhalf; 
        SymmetricPyy(length(Pyy)/2+1 : length(Pyy)) = firsthalf; 
        % modelG = @(par,x)par(1).*exp(-1/2.*(x-par(2)).^2/par(3).^2);
        % par = [10 0 .01];
        % lb = [];
        % ub = [];
        % parFit = lsqcurvefit(modelG, par, f, Pyy(1:length(Pyy)/2));
        % myGaussfit = modelG(parFit, f); 
        % PGauss = myGaussfit;
        % PGauss(length(PGauss)+1:length(PGauss)+length(myGaussfit)) = fliplr(myGaussfit);
        % yGauss  = fft(myGaussfit.*conj(Y(1:length(Y))));

        % figure(3); 
        % plot(-length(Pyy)/2+1:length(Pyy)/2, SymmetricPyy); 

        % plot
        figure;clf
        subplot(3,1,1); hold all; 
        plot(x, yNoise,'.');
        xlabel('nm'); 
        ylabel('I');
        ylim([-0.1 1.5]);
        title('Starting spectrum')

        subplot(3,1,2); hold all; 
        plot(f, Pyy(1:length(Pyy)),'.'); 
        % plot(f, Pyyclean(1:length(Pyyclean)));
        plot(f, Pyyclean2(1:length(Pyyclean2)),'linewidth',2);
        set(gca,'YScale','log')
        xlabel('wavelength'); 
%         xlim([0 f(round(length(f)/2))])
        % plot(f, myGaussfit); 
%         ylim([0 .5])
        legend('raw power spectrum', 'filtered power spect','location','best'); legend('boxoff')
        title('Power spectra')

        subplot(3,1,3); 
        % plot(x, yClean,'.')
        plot(x, yClean2,'.')
        % plot(x, yGauss);
        xlabel('nm'); 
        ylabel('I');
        ylim([-0.1 1.5]);
        title('filtered spectrum')

        figure; clf; 
        subplot(3,1,1); hold all; 
        plot(x, yNoise,'.'); 
        % plot(x, yClean); 
        plot(x, yClean2, 'linewidth',2, 'Color', 'r'); 
        xlabel('nm'); 
        ylabel('I');
        ylim([-0.1 1.5]);
        legend('starting spectrum', 'filtered spectrum','location','best'); legend('boxoff')

        subplot(3,1,2); hold all; 
        plot(x, y); 
        % plot(x, yClean); 
        plot(x, yClean2); 
        xlabel('nm'); 
        ylabel('I');
        ylim([-0.1 1.5]);
        legend('original signal without noise', 'filtered spectrum','location','best'); legend('boxoff')

        subplot(3,1,3); hold all; 
        % plot(x, (yClean-y).^2); 
        plot(x, (yClean2-y).^2); 
        xlabel('nm'); 
        ylabel('I');
        legend('Error = (filtered spectrum - original spectrum)^2','location','best'); legend('boxoff')
        warning('on')