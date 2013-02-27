function hLines = nmssDrawRectBetween2Points(point1, point2, line_width, color, varargin)
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
% point1 - N x 2 dim array containing the top left corner coordinates (x,y)
% point2 - N x 2 dim array containing the bottom right corner coordinates (x,y)
    hLines = [];
    
    line_style = '-';
    tagline = 'nmss_rectangle';
    
    if (length(varargin) >= 1)
        line_style = varargin{1};
    end
    if (length(varargin) >= 2)
        tagline = varargin{2};
    end

    for i=1:size(point1,1)

        line_coord_x = [point1(i,1); point2(i,1); point2(i,1); point1(i,1); point1(i,1)];
        line_coord_y = [point1(i,2); point1(i,2); point2(i,2); point2(i,2); point1(i,2)];

        hLines(i) = line(line_coord_x,line_coord_y,'Color', color,'LineWidth', line_width, 'LineStyle', line_style, 'Tag', tagline);
    
    end
%     for i=1:size(point1,1)
%         
%         x = point1(i,1);
%         y = point1(i,2);
%         
%         w = point2(i,1) - x + 1;
%         h = point2(i,2) - y + 1;
%         
%         hLines(i) = rectangle('Position', [x, y, w, h], ...
%             'EdgeColor', color,'LineWidth', line_width, 'LineStyle', line_style, 'Tag', tagline);
%     
%     end
