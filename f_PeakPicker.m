function [peakValues, troughsValues] = f_PeakPicker(data, varargin)
%[peakValues, troughsValues] = f_peakPicker(data, varargin)
%   Returnes a sorted by abs intensity matrix of peak and trough intensity
%   and there index [intensity,index] from inputed data.
%
%   %%Returned Values
%   peakValues          nxm matrix of intensity values
%   troughsValues       mx1 row of wavelengths (or pixel)
%
%   %%Options
%   'stepSize'          number of elements away to chekc if gradient has
%                       changed size
%                       default = 10
%   'checkRange'        range of looking for min or max 
%                       [location +/- checkRange]
%                       default = 3
%   'xaxis'             Axis for calculating gradient
%                       default = 1 to data length with spacing of 1
%
%   inital updated 29-03-14 - Shyamal
%% Check input varibales

%% Sets Options
% default options
opt.stepSize = 1;                                       %number of elements away to check change in gradient
opt.checkRange = 3;                                     %+/- range for scanning for actual min or max value
opt.xaxis = linspace(1, size(data,1), size(data,1))';   %spacing for gradient calculation
% user input
if ~exist('varargin','var')
    [opt] = f_OptSet(opt, varargin);
end

%% Checks inputs are correct
if size(data,1) > 1
    opt.xaxis = data(:,1);
    data = data(:,2);
end
if size(opt.xaxis,1) ~= size(data,1)
    opt.xaxis = linspace(1, size(data,1), size(data,1))';
end

%% Sets values derived from data
grad = gradient(data, opt.xaxis);

peakValues = [];
troughsValues = [];

%% Determins where peaks and troughs are
negativeIndex = grad < 0; % boolean location of negative gradients
positiveIndex = grad > 0; % boolean location of positive gradients
troughIndex = positiveIndex(1+opt.stepSize:end) + negativeIndex(1:end-opt.stepSize); %value is 2 close to trough, comparing change from negative to positive gradient
peakIndex = positiveIndex(1:end-opt.stepSize) + negativeIndex(1+opt.stepSize:end);   %value is 2 close to trough, comparing change from positive to negative gradient

% steps through each index and if peak or trough searches +/-
% opt.checkRange for the min or max
for n = 1:size(peakIndex,1)
    % chekcs if peak first
    if peakIndex(n) == 2
        % handles cases where n+/-opt.checkRange falls outside of data
        if n - opt.checkRange >= 1 && n + opt.checkRange <= size(data,1)
            [maxValue, maxIndex] = max(data(n-opt.checkRange:n + opt.checkRange));
            peakValues = [peakValues; [maxValue, n - opt.checkRange - 1 + maxIndex]];
        elseif n - opt.checkRange < 1 && n + opt.checkRange <= size(data,1)
            [maxValue, maxIndex] = max(data(1:n + opt.checkRange));
            peakValues = [peakValues; [maxValue, maxIndex]];
        elseif n - opt.checkRange >= 1 && n + opt.checkRange > size(data,1)
            [maxValue, maxIndex] = max(data(n-opt.checkRange:end));
            peakValues = [peakValues; [maxValue, n - opt.checkRange - 1 + maxIndex]];
        end
    % if not peak checks if trough
    elseif troughIndex(n) == 2
        % handles cases where n+/-opt.checkRange falls outside of data
        if n - opt.checkRange >= 1 && n + opt.checkRange <= size(data,1)
            [minValue, minIndex] = min(data(n-opt.checkRange:n + opt.checkRange));
            troughsValues = [troughsValues; [minValue, n - opt.checkRange - 1 + minIndex]];
        elseif n - opt.checkRange < 1 && n + opt.checkRange <= size(data,1)
            [minValue, minIndex] = min(data(1:n + opt.checkRange));
            troughsValues = [troughsValues; [minValue, minIndex]];
        elseif n - opt.checkRange >= 1 && n + opt.checkRange > size(data,1)
            [minValue, minIndex] = min(data(n-opt.checkRange:end));
            troughsValues = [troughsValues; [minValue, n - opt.checkRange - 1 + minIndex]];
        end
    end 
    
end

%% Sorts peaks and troughs by absolute intensity
[~, I] = sort(abs(peakValues(:,1)),1,'descend');
peakValues = peakValues(I,:);
if ~isempty(troughsValues)
[~, I] = sort(abs(troughsValues(:,1)),1,'descend');
troughsValues = troughsValues(I,:);
end
end

