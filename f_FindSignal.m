function [ data, remove ] = f_FindSignal(data, time, presignal, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

opt.signalThreshold = 5E-4;
opt.bounds = [];
opt.StripData = 0;
% user input (after autodetection to allow user options)
[opt] = f_OptSet(opt, varargin);

[~, Ineg1ps] = min(abs(time - presignal));
preZeroData = data(1:Ineg1ps,:);
noiseLevel = std(preZeroData);
noiseLevel = smooth(noiseLevel);

remove = noiseLevel > opt.signalThreshold;

if ~isempty(opt.bounds)
    startNaN = remove(2:end) - remove(1:end-1);
    endNaN = find(startNaN == -1);
    startNaN = find(startNaN == 1)+1;
    if ~isempty(startNaN) && ~isempty(endNaN)
        if startNaN(1) > endNaN(1), startNaN = [1;startNaN]; end
        if length(endNaN) < length(startNaN), endNaN = [endNaN; size(data,2)]; end
        inBound = startNaN(2:end) - endNaN(1:end-1)<opt.bounds;
        startNaN([false;inBound]) = [];
        endNaN([inBound;false]) = [];
        if startNaN(1) < opt.bounds, startNaN(1) = 1; end
        if endNaN(end) >  size(data,2) - opt.bounds, endNaN(end) =  size(data,2); end
        remove = [];
        for n = 1 : length(startNaN)
            remove = [remove, startNaN(n):endNaN(n)];
        end
    end
end

if opt.StripData
    data(:,remove) = [];
else
    data(:,remove) = NaN;
end
end

