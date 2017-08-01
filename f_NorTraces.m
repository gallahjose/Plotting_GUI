function [ traces, normFactor] = f_NorTraces( traces, varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if size(traces,1) == 1
    traces = traces';
    transpose_trace = 1;
else
    transpose_trace = 0;
end
opt.poly_bounds = [];
opt.windowSize = 20;
opt.forwardAve = round(size(traces,1)*0.005);
opt.backwardAve = round(size(traces,1)*0.005);
opt.threshold = 0.5;
opt.normOneTrace = 0;
opt.StartIndex = 1;
opt.onlyPositive = 0;
opt.var_method = 0;
% user input (after autodetection to allow user options)
[opt] = f_OptSet(opt, varargin);


OrigTraces = traces;
traces = traces(opt.StartIndex:end,:);

nStart = 1;
nEnd = size(traces,2);
if opt.normOneTrace
    nStart = opt.normOneTrace(end);
    nEnd = opt.normOneTrace(end);
end
runVar = zeros(size(traces,1),1);
normFactor = zeros(1, nEnd-nStart+1);

    
for n = nStart : nEnd
    if ~isempty(opt.poly_bounds)
        opt.poly_bounds = sort(opt.poly_bounds);
        y_fit = traces(opt.poly_bounds(1):opt.poly_bounds(2),n);
        %y_fit = smooth(y_fit,round(length(y_fit)/200));
        degPoly = 6;
        %y_fit = smooth(y_fit);
        scaler = max(y_fit);
        y_fit = y_fit./scaler;
        warning ('off','all'); % can be poorly scaled - don't need warning
        [fittedParameters,  ~, outlier, usedData, ~, ~,polyopt] = f_PolyFit( [1:length(y_fit)]',y_fit,degPoly);
        warning ('on','all');
        high_res_wave = [min(1):0.0005:max(length(y_fit))]';
        [ designMatrix ] = f_PolyFitDM( high_res_wave, degPoly, polyopt);
        fittedCurve = designMatrix*fittedParameters;
        fittedCurve = fittedCurve*scaler;
        [valuesCheck,locs] = findpeaks(fittedCurve);
        [~,I] = max(valuesCheck);
        locs = locs(I);
        valueIndex = round(high_res_wave(locs))+opt.poly_bounds(1)-1;
    else
        if opt.var_method
            %% Calculates the variance over the +/- window range
            for j = opt.windowSize + 1 : (size(traces,1) - opt.windowSize)
                runVar(j) = var(traces(j-opt.windowSize:j+opt.windowSize,n));
            end
            %% Looks for max in regions where variance is below opt.threshold*meanVar
            meanVar = nanmean(runVar);
            stdVar = nanstd(runVar);
            valuesCheck = traces( runVar < opt.threshold*stdVar + meanVar, n );
        else
            trace_smooth = smooth(traces(:,n),10,'sgolay',2);
            residual = traces(:,n) - trace_smooth;
            index_nan = isnan(residual);
            z_score = ones(length(residual),1)*4;
            z_score(~index_nan) = zscore(residual(~index_nan));
            valuesCheck = traces( abs(z_score) < 3,n);
        end
        maxValue = max(abs(valuesCheck));
        if isempty(valuesCheck)
            [~, valueIndex] = max(abs(traces(:,n)));
        else
            [~, valueIndex] = min(abs(abs(traces(:,n)) - maxValue ));
        end
    end
    
    if valueIndex+opt.forwardAve > size(traces,1), valueIndex = size(traces,1)-opt.forwardAve; end
    if valueIndex-opt.backwardAve < 1, valueIndex = 1 + opt.backwardAve; end
    
    %% Calculates normalization averaging over the windows opt.backwardAve <- max -> opt.forwardAve 
    normFactor(n) = nanmean(traces(valueIndex-opt.backwardAve:valueIndex+opt.forwardAve,n));
    
end

if length(normFactor) ~= size(traces,2)
    normFactor = normFactor(end)*ones(1,size(traces,2));
end

if ~opt.onlyPositive
    normFactor = abs(normFactor);
end

%% Divides each trace by its normalization factor
traces = bsxfun(@rdivide,OrigTraces,normFactor);
% 
% for n = 1 : size(traces,2)
%     [~, index] = max(abs(traces(:,n)));
%     traces(:,n) = traces(:,n).*sign(traces(index,n));
% end

if transpose_trace
    traces = traces';
end
