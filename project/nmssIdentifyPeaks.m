function index_of_maximum = nmssIdentifyPeaks(input_data, threshold)
% finds peaks in a vector of data, where there are zeros between the peaks
% input vector looks usually like [0 0 0 50 65 60 1 0 0 0 0 0 0 0 30 70 24]
% input vector can be a column or row vector
% returns the indices of the max position of each peak in a column vector

    if (size(input_data,2) ~= 1)
        input_data = input_data';
    end
    
    % we only consider data above threshold
    % the returned indices correspond to likely peaks. The indices can be grouped into groups of indices. Each
    % group corresponds to a peak
    [row, col] = find(input_data > threshold);
    
    peak_indices = row;
    
    % if no peak has been found (no value above threshold) return.
    % 'index_of_maximum' will be an empty array!
    if (isempty(peak_indices))
        index_of_maximum = zeros(0,0);
        return;
    end
    
    
    
    
    % grouping indices....
    % get the distance between the indices:
    %   if the distance between subsequent indices is larger than one we've
    %   found a new peak. 
    diff_peak_indices = diff(peak_indices);
    % 'peak_starting_indices' contains the indices where a peak starts in
    % vector 'peak_indices'
    [peak_starting_indices dummy] = find(diff_peak_indices > 1);
    % add 1 to the vector of indices which signal the first value of a peak,
    % because diff creates the difference starting at x(2)-x(1).
    peak_starting_indices = [1; peak_starting_indices + 1];
    
    % number of peaks is equal to the size of 'peak_starting_indices'
    num_of_peaks = size(peak_starting_indices,1);
    
    % add a virtual peak to the end of 'peak_starting_indices' so that it
    % can find the last index of the last peak
    peak_starting_indices = [peak_starting_indices; peak_starting_indices(size(peak_starting_indices,1)) + 1];
    
    index_of_maximum = zeros(num_of_peaks,1);
    
    for k=1:num_of_peaks 
        x3s = peak_starting_indices(k);
        x3e = peak_starting_indices(k+1);
        
        % skip peaks with only one pixel width
        %if (x3e-1-x3s <= 1)
        %    continue;
        %end
        try
            peaks.y = peak_indices(x3s:x3e-1);
            index_of_maximum(k) = floor(median(peaks.y) + 0.5);
        catch
            disp(lasterr());
            disp('x3s');
            disp(x3s);
            disp('x3e');
            disp(x3e);
            disp('peak_indices');
            disp(peak_indices);
        end
    end
