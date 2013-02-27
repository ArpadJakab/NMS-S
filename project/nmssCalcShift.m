function [res_en, dres_en, wavelength, dwavelength, int] = nmssCalcShift(particle, varargin)

    res_en_tmp = zeros(1, length(particle));
    dres_en_tmp = zeros(1, length(particle));
    dwavelength_tmp = zeros(1, length(particle));
    wavelength_tmp = zeros(1, length(particle));
    int = [];
    
    if (length(varargin) == 0)
        [res_en_tmp, dres_en_tmp, wavelength_tmp, dwavelength_tmp, int] = CalcShiftBeforeAfter(particle);
    end
    if (length(varargin) >= 1)
        if (strcmp(varargin{1},'maxshift'))
            [dres_en_tmp, dwavelength_tmp] = CalcMaxShift(particle);
        elseif (strcmp(varargin{1},'before_after'))
            [res_en_tmp, dres_en_tmp, wavelength_tmp, dwavelength_tmp] = CalcShiftBeforeAfter(particle);
        end
    end
    
%     dres_en = dres_en_tmp(find(dres_en_tmp));
%     dwavelength = dwavelength_tmp(find(dwavelength_tmp));
%     wavelength = wavelength_tmp(find(wavelength_tmp));
    res_en = res_en_tmp;
    dres_en = dres_en_tmp;
    dwavelength = dwavelength_tmp;
    wavelength = wavelength_tmp;






function [res_en, dres_en, wavelength, dwavelength, int] = CalcShiftBeforeAfter(particle)

    dres_en = zeros(1, length(particle));
    dwavelength = zeros(1, length(particle));
    res_en = zeros(1, length(particle));
    wavelength = zeros(1, length(particle));
    int = zeros(1, length(particle));

    % loop over all selected particles
    figure;
    title('Blue = before, Green = after');
    k = 1;
    for i=1:length(particle)
        part = particle(i);
        
        res_en(i) = part.pdata{1}.res_energy;
        dres_en(i) = part.pdata{2}.res_energy - part.pdata{1}.res_energy;
        dwavelength(i) = 1240.0 / part.pdata{2}.res_energy - 1240.0 / part.pdata{1}.res_energy;
        wavelength(i) = 1240.0 / part.pdata{1}.res_energy;
        int(i) = part.pdata{1}.max_intensity;
        
        subplot(3,3,k);
        k = k+1;
        
        plot(part.pdata{1}.graph.axis.x, part.pdata{1}.graph.normalized );
        hold on;
        plot(part.pdata{2}.graph.axis.x, part.pdata{2}.graph.normalized, 'g');
        xlabel('\lambda (nm)');
        
        if (k == 10)
            figure;
            k =1;
        end

    end
    
    


function [dres_en, dwavelength] = CalcMaxShift(particle)
% nmssCalcMaxResVariation 
    
    

    % matrix containing the difference in resonance energy between two
    % positions of the analizer
    dres_en = zeros(1, length(particle));
    dwavelength = zeros(1, length(particle));

    % loop over all selected particles
    for i=1:length(particle)
        
        
        
        part = particle(i);
        
        % find max difference between the resonance energies
        dres_max = 0;
        dres_min = 0;
        for k=1:length(part.pdata)
            if (~isempty(part.pdata{k}))
                if (~isnan(part.pdata{k}.res_energy))
                    dres_max = part.pdata{k}.res_energy;
                    dres_min = part.pdata{k}.res_energy;
                    break;
                end
            end
        end
        
        for k=1:length(part.pdata)
            if (~isempty(part.pdata{k}))
                if (~isnan(part.pdata{k}.res_energy))
                    if (part.pdata{k}.res_energy > dres_max)
                        dres_max = part.pdata{k}.res_energy;
                        % don't waste time to check the second condition as
                        % it can not be fulfilled
                        continue; 
                    end
                    if (part.pdata{k}.res_energy < dres_min)
                        dres_min = part.pdata{k}.res_energy;
                    end
                end
            end
        end
        
        dres_en(i) = dres_max - dres_min;
        if (dres_en(i) ~= 0)
            dwavelength(i) = abs(1240/dres_max - 1240/dres_min);
        end
    end
    
