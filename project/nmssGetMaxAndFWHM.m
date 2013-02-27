% -------------------------------------------------------------------------
% this is gonna be the new shit
function [peak_max, peak_FWHM, peak_max_int, fit_x, fit_y, str_errmsg] = ...
            nmssGetMaxAndFWHM(spec, spec_smoothed, x_axis, peakFindingParams)
% returns the location of the spectrum maximum and Full Width at Half
% Maximum in eV
%
% INPUT:
% spec - a row vector of the background corrected, white light normalized
%           spectrum intensity in eV
% spec_smoothed - a row vector of the smoothed spectrum - useful for
%           determining the full width at half max
% x_axis - a row vector containing the eV values. Its length must
% match that of 'spec'
% peakFindingParams - struct that contains the parameters for finding the
% peak:
%      .peakFindingMethod - defines the method that is being
%      used to find the peak max pos. Possible values:
%      'fit_no_fit_just_smooth' and 'fit_parabola_on_top_part_of_peak'
%
% OUT:
% 
% peak_max - a vector of the max positions of the peak in eV, lowest energy
%               peak comes first
% peak_FWHM - a struct-vector containing the FWHM info of the peaks. It has
%               following fields:
%                   full = the full FWHM
%                   leftside = the index of the left side of the fwhm
%                   rightside = the index of the rigth side of the fwhm
%               lowest energy peak comes first
% peak_max_int - a vector of the max intensities of the peaks, lowest energy
%               peak comes first
% fit_params   - the fit parameters and the fitted curve 
%                   


    % input spec only in eV!
    
    str_errmsg = '';
    peak_FWHM.full = NaN;
    peak_FWHM.leftside = NaN;
    peak_FWHM.rightside = NaN;
    peak_max = NaN;
    peak_max_int = NaN;
    fit_x = [];
    fit_y = [];

    
    % find the maximum position
    % by fitting the top part of the peak with a parabola
    if (strcmp(peakFindingParams.method, 'fit_parabola_on_top_part_of_peak'))
        
        % restrict peak finding on a limited range
        input_fit_range = find(x_axis >= peakFindingParams.fit_range.min &  x_axis <=  peakFindingParams.fit_range.max); %
        spec_to_fit = spec(input_fit_range);
        spec_smoothed_to_fit = spec_smoothed(input_fit_range);
        x_axis_to_fit = x_axis(input_fit_range);
        
        
        
        % peak data that is usable for all peak finding method
        [peak_max_int, max_pos] = max(spec_smoothed_to_fit);

        % get top xx% of the peak
        left_of_peak = spec_smoothed_to_fit(1 : floor(max_pos));
        right_of_peak = spec_smoothed_to_fit(floor(max_pos)+1 : length(spec_smoothed_to_fit));
        
        peak_min_int  = min(spec_smoothed_to_fit);
        peak_max_int_raw = spec_to_fit(floor(max_pos));% find max peak value (just an estimation)

        % fit a parabolic curve into the raw data to get the maximum position
        % of the peak (this is especially useful if the peak is rather noisy)
        peak_min_int = 0; % peaks are backgrouond corrected thus zero is the minimum intensity

%         b = (100 - peakFindingParams.fitFraction) / 100.0;
%         peaktop_index.r = find(right_of_peak > peak_min_int + ...
%                         (peak_max_int_raw - peak_min_int) * b, 1,'last') ...
%                         + max_pos;
%         peaktop_index.l = find(left_of_peak > peak_min_int + ...
%                         (peak_max_int_raw - peak_min_int) * b, 1,'first');
                    
        peak_to_fit_indices = GetTopOfPeak(peakFindingParams.fitFraction, max_pos, spec_to_fit);
        peaktop_index.r = peak_to_fit_indices(end);
        peaktop_index.l = peak_to_fit_indices(1);
                    
        if (isempty(peaktop_index.r) || isempty(peaktop_index.r))
            % no peak in the definition range
            [dummy, max_index]  = max(spec_to_fit);
        else
            % cut out the upper xx% per cent of the peak and fit it
            poly2_fit_range = peaktop_index.l:peaktop_index.r;

            [ERes, FWHM, maxInt, fit_y, fittedindices] = nmssFitPeak(x_axis_to_fit(poly2_fit_range), ...
                                     spec_to_fit(poly2_fit_range), 'poly2');

            if (~isempty(fit_y))
                % successful fitting
                peak_max = ERes;
                peak_max_int = maxInt;
                fit_x = x_axis_to_fit(poly2_fit_range);                                     
                
%                 [fit_max_int fit_max_index] = max(fit_y);
% 
%                 max_index = input_fit_range(1) + peaktop_index.l + fit_max_index - 1 - 1;
%                 
%                 % get the mean value of the raw spectra around the fit max
%                 % position
%                 lgth = length(spec);
%                 if (max_index >= 2 && max_index <= lgth-1)
%                     peak_max_int = mean([spec(max_index-1), spec(max_index), spec(max_index + 1)]);
%                 elseif (max_index == 1 && max_index <= lgth-1)
%                     peak_max_int = mean([spec(max_index), spec(max_index + 1)]);
%                 elseif (max_index >= 2 && max_index == lgth)
%                     peak_max_int = mean([spec(max_index-1), spec(max_index)]);
%                 else
%                     peak_max_int = spec(max_index);
%                 end
                
            else
                % fitting failed, use max of the smoothed spec
                [peak_max_int, max_index]  = max(spec_smoothed);
                peak_max = x_axis(max_index);
            end
        end

        
        % find the FWHM and LHM_pos and RHM_pos (left side of FWHM position and
        % right side FWHM position)
        % FINDING FWHM HERE:
        % look for data at half maximum left and right to the peak
        FWHM_index.r = find(right_of_peak < peak_min_int + (peak_max_int - peak_min_int)/2.0, 1,'first') + floor(max_pos);
        FWHM_index.l = find(left_of_peak < peak_min_int + (peak_max_int - peak_min_int)/2.0, 1,'last');


        % found anything? if not return as the paek analysis can not be
        % performed
        if (isempty(FWHM_index.r))
            FWHM_index.r = NaN;
            FWHM_wl_r = NaN;
        else
            % higher end index of the peak
            try
                FWHM_wl_r = x_axis(FWHM_index.r);
            catch
                disp(lasterr);
                keyboard;
            end
            fwhm.rightside = abs( FWHM_wl_r - peak_max);
        end
        if (isempty(FWHM_index.l))
            FWHM_index.l = NaN;
            FWHM_wl_l = NaN;
        else
            % lower end index of the peak
            FWHM_wl_l = x_axis(FWHM_index.l);
            fwhm.leftside = abs( FWHM_wl_l - peak_max);
        end


        fwhm.full = abs(FWHM_wl_r - FWHM_wl_l);
        
    elseif (strcmp(peakFindingParams.method, 'fit_with_1_lorentz'))
    % here we use the Lorentz function to fit the peak
        
        % restrict peak finding on a limited range
        fit_index_range = find(x_axis >= peakFindingParams.fit_range.min &  x_axis <=  peakFindingParams.fit_range.max); %
        
        smoothparam = peakFindingParams.smoothParam;
        if (peakFindingParams.smoothParam > length(spec))
            smoothparam = length(spec);
        end
        % find the number of maxima
        [tmp_maxima, tmp_minima] = nmssFindExtrema(spec(fit_index_range), smoothparam);
        if (isempty(tmp_maxima)) [dummy, tmp_maxima] = max(spec(fit_index_range)); end;
        if (isempty(tmp_minima)) [dummy, tmp_minima] = min(spec(fit_index_range)); end;
        maxima = fit_index_range(1) + tmp_maxima -1;
        minima = fit_index_range(1) + tmp_minima -1;
        
        % sort out those maxima which are lower than 10% of the largest
        % maximum
        usable_maxima = maxima(find( spec_smoothed(maxima) > max(spec_smoothed(maxima)) * 0.1));
        if (isempty(usable_maxima))
            usable_maxima = maxima;
        end
        
        % this is used just for the Ag seed high energy shoulder fit
        %high_en_shoulder_index = find(x_axis > 1240/410, 1, 'first');
        %usable_maxima = [usable_maxima, high_en_shoulder_index];
        
        lnm = length(usable_maxima);
        disp(['Number of max: ', num2str(lnm)]);
        for nm = 1:lnm
            disp(['Max ',num2str(nm),': ',num2str(1240/x_axis(usable_maxima(nm))), ' nm']);
        end
    
        spec2fit = spec;
        
        [dummy, idummy] = max(spec2fit(usable_maxima));
        
        peak_to_fit_indices = GetTopOfPeak(peakFindingParams.fitFraction, usable_maxima(idummy), spec2fit);
        peaktop_index.r = peak_to_fit_indices(end);
        peaktop_index.l = peak_to_fit_indices(1);
        
        %spec2fit(lower10pc_ix) = nofitthreshold_intensity;
        [ERes FWHM maxInt lorentz_curve] = nmssLorentzFit( x_axis, spec2fit , 1, usable_maxima(idummy), peak_to_fit_indices);
        
        %disp(['ERes=',num2str(ERes), ' FWHM=', num2str(FWHM), ' maxInt=', num2str(maxInt)]);
        
        [dummy, max_peak_index] = max(maxInt);
        % create sophisticated FWHM info
        mmm = find(x_axis >= ERes(max_peak_index), 1, 'first');
        if (~isempty(mmm))
            max_index = mmm;
        else
            max_index = length(x_axis);
        end

        fwhm_left_index = find(x_axis >= ERes(max_peak_index) - FWHM(max_peak_index)/2.0, 1, 'first');
        if (isempty(fwhm_left_index))
            fwhm_left_index = NaN;
        end
        fwhm_right_index = find(x_axis >= ERes(max_peak_index) + FWHM(max_peak_index)/2.0, 1, 'first');
        if (isempty(fwhm_right_index))
            fwhm_right_index = NaN;
        end

        fwhm.full = FWHM(max_peak_index);
        fwhm.leftside = fwhm_left_index;
        fwhm.rightside = fwhm_right_index;
        peak_max_int = maxInt(max_peak_index);

        
        fit_x = x_axis;
        fit_y = lorentz_curve;
        peak_max = x_axis(max_index); % max index may deviate from max_pos!
        peak_max_int = spec(max_index);
        
    elseif (strcmp(peakFindingParams.method, 'fit_no_fit_just_smooth'))
        error(['Peak finding method: ', peakFindingParams.method, ' is currently disabled!']);
        return;
        
        
        [maxima minima] = nmssFindExtrema(spec, peakFindingParams.smoothParam);
        
        max_index = maxima(1);
        peak_max_int = spec(max_index);
        peak_max = x_axis(max_index); % max index may deviate from max_pos!
        
        
    else
        % work simply on the smoothed curve
        error(['Peak finding method: ', peakFindingParams.method, ' is currently disabled!']);
         peak_min_int  = min(spec_smoothed);
         fit_x = [];
         fit_y = [];

    end
    
%     %tmp =  x_axis(max_index);
%     if (~isempty(max_index))
%         peak_max = x_axis(max_index); % max index may deviate from max_pos!
%         peak_max_int = spec(max_index);
%     else
%         peak_max  = NaN;
%         peak_max_int  = NaN;
%     end
    

    % set return variables
    peak_FWHM = fwhm;
    
function peak_to_fit_indices = GetTopOfPeak(fitFraction, max_pos, spec)
        
        % get top fitFraction * 100% of the peak
        b = (100 - fitFraction) / 100.0;
        
        max_val = spec(max_pos);
        % find the closest data point to the peak maximum, that is lower
        % than the treshold
        % to the right
        ir = find(spec(max_pos:end) > max_val * b, 1,'last') + max_pos - 1;
        if (isempty(ir))
            ir = length(spec);
        end
        % to the left
        il = find(spec(1:max_pos) <= max_val * b, 1,'last');
        if (isempty(il))
            il = 1;
        end
        peak_to_fit_indices = il:ir;
