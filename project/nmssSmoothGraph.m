function spec_smoothed = nmssSmoothGraph( spec, varargin )
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
    spec_smoothed = spec;

    if (length(varargin) == 2)
        if (strcmp(varargin{1},'arpad'))
            smooth_param = varargin{2};

            spec_leftshifted = spec;
            spec_rightshifted = spec;
            
            smooth_range = ceil(smooth_param / 2);
            for i = 1:smooth_range;
                spec_rightshifted = ShiftVectorRight(spec_rightshifted);
                spec_leftshifted = ShiftVectorRight(spec_leftshifted);
                spec_smoothed = spec_smoothed + spec_leftshifted + spec_rightshifted;
            end
            spec_smoothed = spec_smoothed / (2*smooth_range);
        end
    else
        if (exist('smooth'))
            % reduce the influence of strong outliers
            %spec_smoothed = smooth(spec, 31, 'rlowess')';
            spec_smoothed = smooth(spec, 41)';
        end
    end
    
    
function shifted_vec = ShiftVectorRight(vec)
    isrow = true;
    % if not a row vector transpose it to get a row vector
    if (size(vec,2) == 1)
        vec = vec';
        isrow = false;
    end

    shifted_vec = [vec(1), vec(1:end-1)];
    
    if (~isrow)
        shifted_vec = shifted_vec';
    end
    
function shifted_vec = ShiftVectorLeft(vec)
    isrow = true;
    % if not a row vector transpose it to get a row vector
    if (size(vec,2) == 1)
        vec = vec';
        isrow = false;
    end

    shifted_vec = [vec(2:end), vec(end)];
    
    if (~isrow)
        shifted_vec = shifted_vec';
    end
    
