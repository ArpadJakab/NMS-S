function particle = nmssResetParticle()
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

            particle.data = nmssResetJob();
            particle.valid = 0;
            particle.graph = nmssResetGraph();

            particle.res_energy = 0;
            particle.FWHM.full = 0;
            particle.FWHM.leftside = 0;
            particle.FWHM.rightside = 0;
            particle.max_intensity = 0;
            
            particle.position = nmssResetPosition();
            particle.res_en_vs_pos = [];
            
            particle.fit.fit_x = [];
            particle.fit.fit_y = [];
            particle.fit.params = nmssResetPeakFindingParam();
            
            particle.p = []; % stores the particle roi (6 element vector)
            particle.max_pos_xy = []; % stores the position (px) of the maximum of the particle intensity (2 element vector)
            particle.num = 0; % the number of particle in the sequence of the initial analyis, this helps to correlate
            % the spectra in ResultsViewer and the particle in ScanAnalysis
            

