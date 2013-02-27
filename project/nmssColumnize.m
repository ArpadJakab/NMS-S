function out_vec = columnize( in_vec)
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
    s = size(in_vec);

    if (s(2) ~= 1)
        out_vec = in_vec';
    else
        out_vec = in_vec;
    end
        