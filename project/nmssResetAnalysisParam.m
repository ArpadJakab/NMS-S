function analysis = nmssResetAnalysisParam(method)
% nmssResetAnalysisParam - initializes the analysis parameters depending on
% the selected method
% method - options: absolute_maximum, external_threshold, fit_background

    % defines the area where spectra analysis will be performed
    analysis.roi = nmssResetROI();

    % pre-initialization of the analysis structure
    analysis.method = '1st_derivative'; % other options: 0th_derivative
    %analysis.method = 'absolute_maximum'; % options: absolute_maximum, external_threshold, fit_background
    
    % following parameters make only sense if the 'absolute_maximum'
    % analysis method is selected
    analysis.threshold = 0;
    
    analysis.std_weighing = 1; % threshold = mean + weigh * std_dev
    analysis.img_signature = []; % used if method = 'external_threshold'

    analysis.bUseFixedROISize = false;
    analysis.minROISizeX = 1; % the minimum horizontal size of a ROI in pixel
    analysis.minROISizeY = 1; % the minimum vertical size of a ROI in pixel
    analysis.fixROISizeX = 1; % the horizontal size of the ROI in pixel if fixed ROI is used
    analysis.fixROISizeY = 1; % the vertical size of the ROI in pixel if fixed ROI is used
    
    % other settings (can be extended later)
    if (strcmp(method, '1st_derivative'))
        analysis.method = '1st_derivative';
    elseif (strcmp(method, '0th_derivative'))
        analysis.method = '0th_derivative';
    end

