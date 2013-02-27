function [results_file_path, results] = nmssLoadResults(workDir)
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

    results_file_path = [];
    results = [];
    old_work_dir = pwd();
    cd(workDir);
    
    [filename, dirname] = uigetfile({'*.mat','Matlab data file (*.mat)'}, 'Load results - Select file');
    
    cd(old_work_dir);
    
    if (filename == 0) % user pressed cancel
        return;
    end
    
    results_file_path = fullfile(dirname, filename);
    
    load(results_file_path ); % load struct called: results
    
    % see if results or results selected has been loaded
    if (exist('results'))
        old_results = results;
    elseif (exist('results_selected'))
        old_results = results_selected;
    else
        errordlg('No results data structure found!');
        return;
    end
    
    lParticle = length(results.particle);
    
    results = rmfield(old_results, 'particle');;
    
    
    % migrate old data structures into the current (some additional
    % fieldnames may be added)
    for i=1:lParticle
            particleOld = old_results.particle(i);
            particleNew = particleOld;
%            particleNew = nmssResetParticle();
%             
%             fieldnamesPOld = fieldnames(particleOld);
%             fieldnamesPNew = fieldnames(particleNew);
%             
%             lOld = length(fieldnamesPOld);
%             lNew = length(fieldnamesPNew);
%             
%             % get old particle struct field values
%             for o=1:lOld
%                 for n=1:lNew
%                     if (strcmp(fieldnamesPOld(o), fieldnamesPNew(n)))
%                         particleNew = setfield(particleNew, fieldnamesPNew(n), getfield(particleOld, fieldnamesPOld(o)));
%                     end
%                 end
%             end
            
            % initialize new fields
            
            % num
            if (~isfield(particleOld, 'num'))
                particleNew.num = i;
            end
            
            % FWHM
            if (~isstruct(particleOld.FWHM))
                fwhm.full = particleOld.FWHM;
                fwhm.leftside = NaN;
                fwhm.rightside = NaN;
                particleNew.FWHM = fwhm;
            end
                
            
            results.particle(i,1) = particleNew;
        
    end
    
%     % see if new or old style FWHM parameter was read
%     if(~isstruct(results.particle(1)))
%         particles = cell(lParticle,1);
% 
%         % we need to 
%         for i=1:lParticle
%             particles{i} = results.particle(i);
%             rmfield(particles{i},'FWHM');
% 
%             fwhm.full = results.particle(i).FWHM;
%             fwhm.leftside = NaN;
%             fwhm.rightside = NaN;
% 
%             particles{i}.FWHM = fwhm;
%         end
%         % now set up particle struct array again, but with the new FWHM struct
%         rmfield(results, 'particle');
%         
%         for i=1:lParticle
%             particleOld = particles{i};
%             particleNew = nmssResetParticle();
%             
%             fieldnamesPOld = fieldnames(particleOld);
%             fieldnamesPNew = fieldnames(particleNew);
%             
%             lOld = length(fieldnamesPOld);
%             lNew = length(fieldnamesPNew);
%             
%             for o=1:lOld
%                 for n=1:lNew
%                     if (strcmp(fieldnamesPOld(o), fieldnamesPNew(n))
%                         particleNew = setfield(particleNew, fieldnamesPNew(n), getfield(particleOld, fieldnamesPOld(o)));
%                     end
%                 end
%             end
%             
%             results.particle(i) = particleNew;
%         end
%     end
%     
    
    
    
    
