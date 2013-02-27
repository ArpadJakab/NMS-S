function measurement_info = nmssResetMeasurementInfo()
% Initializes measurement_info struct
    measurement_info.project = '';
    measurement_info.sample = '';
    measurement_info.medium = '';
    measurement_info.remarks = '';
    measurement_info.ir_filter_used = 0;
    measurement_info.objective = '<no objective selected>';
    
