function res_wl = AR2ResWLn1_33( AR, n )
%AR2ResWLn1_33 uses a loop up table to get the resonance wavlength of a
%silver nanorod for a given aspect ratio
%
% AR    : the aspect ratio
% n     : the index of refraction

%     res_wl_table = [500.0 500.0 500.0 500.0 500.0 500.0 509.2 526.1 545.2 566.8 584.8, ...
%               603.1 624.4 645.5 665.2 684.7 704.3 723.7 742.8 761.9 781.6 801.6, ...
%               821.4 840.4 859.0 877.5 896.3 915.6 935.2 954.9 974.5 993.9 1012.8, ...
%               1031.3 1049.3 1067.0 1084.3 1101.5 1118.6 1135.8];
% 
% 
%     AR_table = [1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3, ...
%               2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.0, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, ...
%               3.8, 3.9, 4.0, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9];
    
    res_wl_table = [500.0 509.2 526.1 545.2 566.8 584.8, ...
              603.1 624.4 645.5 665.2 684.7 704.3 723.7 742.8 761.9 781.6 801.6, ...
              821.4 840.4 859.0 877.5 896.3 915.6 935.2 954.9 974.5 993.9 1012.8, ...
              1031.3 1049.3 1067.0 1084.3 1101.5 1118.6 1135.8];


    AR_table = [1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3, ...
              2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.0, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, ...
              3.8, 3.9, 4.0, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9];

    if (n > 1.33)
        error('AR2ResWLn1_33 works currently only for n=1.33');
        return;
    end
    
    res_wl = zeros(1, length(AR));
    
    for i=1:length(AR)

        if (AR(i) < 1)
            error('AR can not be smaller than 1');
            return;
        end

        if (AR(i) > AR_table(end))
            disp(['WARNING: AR larger than ', sprintf('%f', AR_table(end)), ' . For values above this limit extrapolation is being used!']);
        end

        i2 = find(AR_table > AR(i), 1, 'first');
        i1 = i2  - 1;

        if (isempty(i2))
            % slope of the line between the two points
            b = (res_wl_table(end) - res_wl_table(end-1)) / (AR_table(end) - AR_table(end-1));
            % anchor point
            res_wl1 = res_wl_table(end);
            AR1 = AR_table(end);
        elseif (i1 < 1)
            % slope of the line between the two points
            b = (res_wl_table(i2+1) - res_wl_table(i2)) / (AR_table(i2+1) - AR_table(i2));
            % anchor point
            res_wl1 = res_wl_table(i2);
            AR1 = AR_table(i2);
        else
            % slope of the line between the two points
            b = (res_wl_table(i2) - res_wl_table(i1)) / (AR_table(i2) - AR_table(i1));
            % anchor point
            res_wl1 = res_wl_table(i1);
            AR1 = AR_table(i1);
        end
        
        
        res_wl(i) = res_wl1 + b*(AR(i)-AR1);
    end
    