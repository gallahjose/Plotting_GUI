
function [res, constant, std] = f_ConstantMinMax_IR(fit, std, varargin)
%[res, constant] = f_ConstantMinMax(fit, std)
%   Fits data to horizontal (xAxis) offset by matching min/max from fit and
%   std. Scales fit based on xAxis values in a number of ways
%
%   %%Returned Values
%   res                sum((std-fit)^2)
%   constant           offset applied to fit to match std
%
%   %%Options
%   'numPeaks'          Number of peaks and troughts to check
%                       default = 3
%   'plotD'             Plots details of absorption scalling on figure(plotD)
%                       default = 0
%   'plotR'             Plots details of best fit on figure(plotR)
%                       default = 0
%
%   inital update 30-03-14 - Shyamal

%% Check input varibales

%% Sets Options
% default options
opt.numPeaks = 5;
opt.plotD = 0;
opt.plotR = 0;

% user input
[opt] = f_OptSet(opt, varargin);

%% Variables


%% Generates matrix of positions to check
%finds peaks and troughts
[fitPeak] = f_PeakPicker(fit);
[stdPeak] = f_PeakPicker(std);

[~, I] = sort(fitPeak(:,2),1);
fitPeak = fitPeak(I,:);
[~, I] = sort(stdPeak(:,2),1);
stdPeak = stdPeak(I,:);

constant =  fit(min(fitPeak(:,2)),1) - std(min(stdPeak(:,2)),1);
std(:,1) = std(:,1) + constant; %offsets index so the max/min at zero

res = std(stdPeak(:,2),1) - fit(fitPeak(:,2),1);
res = sum(res.^2);

if opt.plotR > 0
    global h
    if isempty(h) || ~ishandle(h(end))
    h = f_Plot(std(:,2), std(:,1), opt.plotR,...
        'Legend',{'Reference'}, ...
        'Title', ['Comparison of MinMax'],...
        'XLabel','Pixel');
    else
    f_Plot(std(:,2), std(:,1), h,...
        'Legend',{'Reference'}, ...
        'Title', ['Comparison of MinMax'],...
        'XLabel','Pixel');
    end
    %title(h, ['Fit res:',num2str(res)])
    f_Plot(fit(:,2), fit(:,1), h, 'hold', 1);
    pause(0.1);
    %figure(opt.plotR+1); scatter(fit(:,1),absSummary(:,minIndex) - fit(:,2));
    %pause(5);
end
end
