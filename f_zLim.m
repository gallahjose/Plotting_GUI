function [ zLim ] = f_zLim( data, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

opt.nth = 10;

% user input
[opt] = f_OptSet(opt, varargin);

data = sort(data(:),1);

if opt.nth < 1
    
    pct = opt.nth;
    if pct > 0.5
       pct = 1 - pct; 
    end
    
    zLim = [prctile(data,pct*100),prctile(data,(1-pct)*100)];
    
    if zLim(2) < 0, zLim(2) = zLim(2)*1.2; else zLim(2) = zLim(2)/1.2; end
    if zLim(1) < 0, zLim(1) = zLim(1)*1.2; else zLim(1) = zLim(1)/1.2; end

elseif size(data,1) > opt.nth
    
    
    zLim = [min(data(opt.nth,:)), max(data(end-opt.nth+1,:))*1.2];
    
    if zLim(1) < 0, zLim(1) = zLim(1)*1.2; else zLim(1) = zLim(1)/1.2; end
    
else
    zLim = [min(data),max(data)];
end

