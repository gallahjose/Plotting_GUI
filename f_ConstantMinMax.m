
function [res, constant, std] = f_ConstantMinMax(fit, std, varargin)
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
scaleString = [{'*1'}, '*pixel', '*pixel^2', '1/pixel']; %types of scaling being done



%% Generates matrix of positions to check
%finds peaks and troughts
[fitPeak, fitTroughs] = f_PeakPicker(fit);
[stdPeak, stdTroughs] = f_PeakPicker(std);

%Preallocate variables
fitPeaksM = zeros(opt.numPeaks^2,1);
fitTroughsM = zeros(opt.numPeaks^2,1);
stdPeaksM = zeros(opt.numPeaks^2,1);
stdTroughsM = zeros(opt.numPeaks^2,1);

% generates matrix of fit and std compinations, size is opt.numPeaks^2
for n = 1:opt.numPeaks
    for i = 1:opt.numPeaks
        if ~isempty(fitPeak) && ~isempty(stdPeak)
        fitPeaksM(n*opt.numPeaks - opt.numPeaks + i) = fit(fitPeak(n,2));
        stdPeaksM(n*opt.numPeaks - opt.numPeaks + i) = std(stdPeak(i,2));
        end
        if ~isempty(fitTroughs) && ~isempty(stdTroughs)
        fitTroughsM(n*opt.numPeaks - opt.numPeaks + i) = fit(fitTroughs(n,2));
        stdTroughsM(n*opt.numPeaks - opt.numPeaks + i) = std(stdTroughs(i,2));
        end
    end
end


%Final matrix of fit and std offsets
fitMatrix = [fitPeaksM; fitTroughsM];
stdMatrix = [stdPeaksM; stdTroughsM];
fitMatrix(fitMatrix == 0) = [];
stdMatrix(stdMatrix == 0) = [];

%% match first peaks only
fitMatrix = fit(min(fitPeak(:,2)),1);
stdMatrix = std(min(stdPeak(:,2)),1);
clear fitPeaksM fitTroughsM stdPeaksM stdTroughsM fitPeak fitTroughs stdPeak stdTroughs

%% Calculates Residual at each offset pair

%Preallocate variables
resM = zeros(1,length(stdMatrix));
absSummary = zeros(size(fit,1),length(stdMatrix));
scaleType = cell(length(stdMatrix),1);
stdPixel = zeros(size(std,1),length(stdMatrix));

for n = 1 : length(stdMatrix)
    absorption = zeros(size(fit,1),length(scaleString));
    residuals = zeros(size(fit,1),length(scaleString));
    resSum = ones(length(scaleString),1).*10000000;
    
    stdW = std(:,1) - stdMatrix(n) + fitMatrix(n); %offsets index so the max/min at zero
    fitW = fit(:,1); %- fitMatrix(n); %offsets index so the max/min at zero
    
    absorptionO = interp1q(stdW, std(:,2), fitW); % linear interp to match indexes
    absorptionO(isnan(absorptionO)) = 0;
    stdPixel(:,n) = stdW(:,1);
    
    %Linear scaled absorption
    scaler = absorptionO\fit(:,2);
    absorption(:,1) = absorptionO; %.*scaler;
    residuals(:,1) = absorption(:,1) - fit(:,2);
    resSum(1) = sum(residuals(:,1).^2);
%     %absorption scalled by pixel
%     absorptionW = absorptionO.*(fit(:,1)+1);
%     scaler = absorptionW\fit(:,2);
%     absorption(:,2) = absorptionW.*scaler;
%     residuals(:,2) = absorption(:,2) - fit(:,2);
%     resSum(2) = sum(residuals(:,2).^2);
%     %absorption scalled by pixel^2
%     absorptionW = absorptionO.*((fit(:,1)+1).^2);
%     scaler = absorptionW\fit(:,2);
%     absorption(:,3) = absorptionW.*scaler;
%     residuals(:,3) = absorption(:,3) - fit(:,2);
%     resSum(3) = sum(residuals(:,3).^2);
%     %absortion scalled by 1/pixel
%     absorptionW = absorptionO./(fit(:,1)+1);
%     scaler = absorptionW\fit(:,2);
%     absorption(:,4) = absorptionW.*scaler;
%     residuals(:,4) = absorption(:,4) - fit(:,2);
%     resSum(4) = sum(residuals(:,4).^2);
    
    %adds minimum res to resM
    [resM(1,n) minIndex]= min(resSum);
    %saves minimum absorption spectra and scaling type
    absSummary(:,n) = absorption(:,minIndex);
    scaleType(n) = scaleString(minIndex);
    
    if opt.plotD > 0 %plots all scaled abosrption values for each offset pair
    f_PlotTraces([absorption(:,:),fit(:,2)], fit(:,1),  opt.plotD + n,...
        'traceLabel',[scaleString, {'Data'}], ...
        'title',['Comparison of MinMax fit res:',num2str(resM(1,n))], ...
        'Xlabel','Pixel');
    %figure(opt.plotD + 1); plot(resSum);
    pause(1)
    end
        
end

[res, minIndex] = min(resM);
constant = - stdMatrix(minIndex) + fitMatrix(minIndex);
std(:,1) = stdPixel(:, minIndex);
%constant = constant*-1;

%% Plotting if needed
if opt.plotR > 0
    f_PlotTraces([absSummary(:,minIndex),fit(:,2)], fit(:,1), opt.plotR,...
        'traceLabel',{['Reference',scaleType{minIndex}], 'Data'}, ...
        'title', ['Comparison of MinMax fit res:',num2str(res)],...
        'Xlabel','Pixel',...
        'plot_styles', [20,20,255; 0,0,0]./255);
    %figure(opt.plotR+1); scatter(fit(:,1),absSummary(:,minIndex) - fit(:,2));
    pause(.5);
end

end
