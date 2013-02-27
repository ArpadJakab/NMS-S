function [maxima minima] = nmssFindExtrema(spec, smooth_factor)
% IN:
% spec - spectrum to be analysed
% smooth_factor - the degree of smoothing. defines the number of points
% used to smooth with moving average
%
% OUT:
% maxima - a vector with the maxima indices
% minima - a vector with the minima indices

    maxima = [];
    minima = [];

% 1. smooth the spec
    %tmp_spec = [ones(1,10) * spec(1), spec, ones(1,10) * spec(end)]
    %tmp_sm = smooth(tmp_spec, smooth_factor)';
    %sm = tmp_sm(11:end-10);
    %sm = smooth(spec, smooth_factor)';
    sm = smooth(spec, smooth_factor,'rlowess')'; % reduce the influence of strong outliers
    sm2 = smooth(sm, smooth_factor)'; % even smoother
    

% 2. find extrema
    dsm = smooth(diff(sm2), smooth_factor)' ;
    dsm2 = smooth(dsm, smooth_factor)' ;
    i = 1;
    ext_index = 1;
    extr = [];
    
    % find extrema
    if (dsm2(1) > 0) % maximum is coming first (starting from the left side)
        while true
            e = find(dsm2(ext_index:end) <= 0, 1, 'first');
            if (isempty(e)) % break down condition
                break;
            end
            ext_index = ext_index - 1 + e;
            maxima(i) = ext_index;
            %disp([num2str(i), ': max= ', num2str(maxima(i))]);
            
            e = find(dsm2(ext_index:end) >= 0, 1, 'first');
            if (isempty(e)) % break down condition
                break;
            end
            ext_index = ext_index - 1 + e;
            minima(i) = ext_index;
            %disp([num2str(i), ': min= ', num2str(minima(i))]);
            
            if (i > 10) break; end; % no more than 10 extrema
            
            i = i+1;
        end
    else
        % minimum is coming first (starting from the left side)
        while true
            e = find(dsm2(ext_index:end) >= 0, 1, 'first');
            if (isempty(e)) % break down condition
                break;
            end
            ext_index = ext_index - 1 + e;
            minima(i) = ext_index;
            %disp([num2str(i), ': min= ', num2str(minima(i))]);
            
            
            e = find(dsm2(ext_index:end) <= 0, 1, 'first');
            if (isempty(e)) % break down condition
                break;
            end
            ext_index = ext_index - 1 + e;
            maxima(i) = ext_index;
            %disp([num2str(i), ': max= ', num2str(maxima(i))]);
            
            
            %disp([num2str(i), ': max= ', num2str(maxima(i)), ' min= ', num2str(minima(i))]);
            
            if (i > 10) break; end; % no more than 10 extrema
            
            i = i+1;
        end
    end





