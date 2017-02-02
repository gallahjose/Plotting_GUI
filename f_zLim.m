function [ zLim ] = f_zLim( data, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

opt.nth = 10;

% user input
[opt] = f_OptSet(opt, varargin);

data = sort(data,1);
if size(data,1) > opt.nth
    zLim = [min(data(opt.nth,:)), max(data(end-opt.nth+1,:))*1.2];
    if zLim(1) < 0, zLim(1) = zLim(1)*1.2; else zLim(1) = zLim(1)/1.2; end
else
    zLim = [min(data),max(data)];
end

