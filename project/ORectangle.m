function [ oRectangle_out ] = ORectangle( varargin)
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

    if (nargin == 0)
        % upper left corner
        oRectangle_out.x1 = 0; 
        oRectangle_out.y1 = 0;
        
        % bottom right corner
        oRectangle_out.x2 = 0;
        oRectangle_out.y2 = 0;
        
    elseif (isstruct(varargin{1}))
        
        if (isfield(varargin{1}, 'x1') && isfield(varargin{1}, 'y1') ...
            && isfield(varargin{1}, 'x2') && isfield(varargin{1}, 'y2'))
        
            oRectangle_out = varargin{1};
        end
        
    elseif (length(varargin) == 4)
        
        % upper left corner
        oRectangle_out.x1 = varargin{1}; 
        oRectangle_out.y1 = varargin{2};
        
        % bottom right corner
        oRectangle_out.x2 = varargin{3};
        oRectangle_out.y2 = varargin{4};
        
    end
        
        