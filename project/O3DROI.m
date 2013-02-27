function [ oROIout ] = ORectangle( varargin)
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

    if (nargin == 0)
        % upper left corner
        oROIout.x1 = 0; 
        oROIout.y1 = 0;
        oROIout.s1 = 0; % spectal dimension
        
        % bottom right corner
        oROIout.x2 = 0;
        oROIout.y2 = 0;
        oROIout.s2 = 0; % spectal dimension
        
    elseif (isstruct(varargin{1}))
        
        if (isfield(varargin{1}, 'x1') && isfield(varargin{1}, 'y1') ...
            && isfield(varargin{1}, 'x2') && isfield(varargin{1}, 'y2') ...
            && isfield(varargin{1}, 's1') && isfield(varargin{1}, 's2'))
        
            oROIout = varargin{1};
        end
        
    elseif (length(varargin) == 6)
        
        % upper left corner
        oROIout.x1 = varargin{1}; 
        oROIout.y1 = varargin{2};
        oROIout.s1 = varargin{3};
        
        % bottom right corner
        oROIout.x2 = varargin{4};
        oROIout.y2 = varargin{5};
        oROIout.s2 = varargin{6};
        
        % z-coordinate
        
    end
        
        