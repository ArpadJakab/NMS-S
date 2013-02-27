function peakFindingParams = nmssResetPeakFindingParam(varargin)
% if     nmssResetPeakFindingParam is called with the argument 'methods',
% it returns a cell array of method names, that can be used to to quera all
% methods

    sMethods = {'fit_parabola_on_top_part_of_peak', 'Fit with parabola'; 'fit_with_1_lorentz', 'Fit with Lorentz curve'};
    
    if (length(varargin) == 0)
        x_axis_eV = [0, inf];
    elseif (length(varargin) == 1)
        if (strcmp(varargin{1}, 'methods'))
            peakFindingParams = sMethods;
            return;
        else
            x_axis_eV = varargin{1};
        end
    else
        error('Too many input arguments for nmssResetPeakFindingParam');
    end

    % if x_axis_eV happens not to be stored as eV, let's transform it into
    % eV
    if (x_axis_eV(1) > 20)
        x_axis_eV = 1240 ./ x_axis_eV;
    end
    
    % init peak parameters finding method
        % specifies the method to find the peak max position and value
        % other possible values:
        % -  fit_no_fit_use_manual_settings - is the user wants to enter
        %    peak parameters manually
        % -  fit_no_fit_just_smooth - the peak is not fitted just smoothed.
        %    good to use if the signal is smooth anyways
        % -  fit_with_1_lorentz - uses lorentz function to fit the peak
        % -  fit_with_2_lorentz - uses the addition of two lorentz functions to fit the peak
    peakFindingParams.method = sMethods{1,1};
    
        % the fraction of the peak
        % which is not used for the fit. The higher it is less points are
        % taken in account. use a low value (min = 0) if the peak is
        % narrow and use a high value (around 40) if you have a broader
        % or noisy peak, in this case more data pints are taken into
        % account for the fitting
    peakFindingParams.fitFraction = 20; % in percent
    
        % the number of points used for the moving average smoothing
    peakFindingParams.smoothParam = 41;
    
    
    % these parameters are always defined in eV as well as the fitting is
    % performed in eV picture
    peakFindingParams.fit_range.min = min(x_axis_eV); % defines the range over which the fitting will be performed
    peakFindingParams.fit_range.max = max(x_axis_eV); % defines the range over which the fitting will be performed
    peakFindingParams.finding_range.min = min(x_axis_eV); % defines the range in which the peak finding will be performed (if the peak lies outside
                                             % of the range, the peak pos
                                             % (res_energy) will be set to NAN
    peakFindingParams.finding_range.max = max(x_axis_eV);

    
    