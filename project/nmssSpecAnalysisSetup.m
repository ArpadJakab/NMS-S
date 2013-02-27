function [ img_signature, threshold ] = nmssSpecAnalysisSetup( img, analysis )
% nmssSpecAnalysisSetup Summary of this function goes here
%  Detailed explanation goes here

    img_signature = zeros(size(img,1));
    threshold = 0;
    
    method = analysis.method;
    if (~strcmp(method, '0th_derivative') & ~strcmp(method, '1st_derivative'))
        disp(['Unknown peak identification method: ', method]);
        return;
    end
        
    
    threshold = analysis.threshold;
    img_signature = analysis.img_signature;
    if (isempty(img_signature))
        errordlg({'Error using ==> nmssSpecAnalysis'; ...
            'Isufficient number of arguments: ''external_threshold'' defined but no additional parameters provided'; ...
            'Usage: nmssSpecAnalysis(.., ''external_threshold'', threshold, img_signature), '; ...
            'where threshold is a numeric value, img_signature is a vector used to find peaks.'});
        return;
    end
    
    
