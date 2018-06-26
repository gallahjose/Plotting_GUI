function [ zLim ] = f_zLim( data, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

opt.nth = 0.95; % box 


% user input
[opt] = f_OptSet(opt, varargin);


if opt.nth > 1, opt.nth = opt.nth/100; end
if opt.nth < 0.3, opt.nth = 1 - opt.nth; end

data = data(:);
data = sort(data,1);
data(isnan(data)) = [];
data(isinf(data)) = [];

opt.nth = (1 - opt.nth)/2;
index_limits = ceil([opt.nth*length(data),(1-opt.nth)*length(data)]);
index_limits = index_limits(1):index_limits(2);
if length(data) > length(index_limits)
    zLim = [min(data(index_limits)), max(data(index_limits))];
else
    zLim = [min(data),max(data)];
end

if zLim(1) > 0 
    zLim(1) = zLim(1)/1.2;
else
    zLim(1) = zLim(1)*1.2;
end

if zLim(2) < 0 
    zLim(2) = zLim(2)/1.2;
else
    zLim(2) = zLim(2)*1.2;
end