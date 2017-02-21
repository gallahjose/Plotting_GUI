function [ fittedParameters,  fittedCurve, outlier, usedData, resSquared, OrigDM] = f_PolyFit( X,Y,degPoly,varargin)
%UNTITLED3 Summary of this function goes here
%   Fits polynomial (degree:degPoly)

opt.fitConstant = 1;
opt.maxRuns = 100;
opt.designMatrix = [];
opt.bounds = 0;
opt.critValue = 5;
if size(Y,2) > 1, Y = Y'; end
if size(X,2) > 1, X = X'; end


% user input
[opt] = f_OptSet(opt, varargin);

%% Sorts X and Y
[X, index] = sort(X, 'ascend');
Y = Y(index);

%% build design matrix [x^degPoly, x^degPoly-1, ...,  constant]
if isempty(opt.designMatrix)
    [ designMatrix ] = f_PolyFitDM( X, degPoly, opt );
else
    designMatrix = opt.designMatrix;
end

%% Zero NaN values
keep = ~isnan(Y).*~any(isnan(designMatrix),2);
Y(~keep) = 0;
designMatrix(~keep) = 0;

%% Build Hat matrix
hatMatrix = designMatrix/(designMatrix'*designMatrix)*designMatrix'; %H = hat matrix, X = design matrix
hatMatrixDiag = diag(hatMatrix);
OrigDM = designMatrix;

%% Fits to design matrix while removing outlers
X_1 = [];
outlier_X = [];
outlier_Y = [];
runs = 0;
while length(X_1) ~= length(X) && runs <= opt.maxRuns
    % fits to design matrix
    %fittedParameters = lsqnonneg(designMatrix,Y);
    fittedParameters = designMatrix\Y;
    % makes fitted curve
    fittedCurve = designMatrix*fittedParameters;
    % Calculates cooks distance (for outliers)
    resSquared = (fittedCurve - Y).^2;
    MSE = sum(resSquared)/length(resSquared);
    cooksD = (resSquared/(size(designMatrix,2)*MSE)) .* (hatMatrixDiag./(1-hatMatrixDiag).^2);
    
    % Reject outliers based on cooks distance
    X_1 = X;
    Y_1 = Y;
    critValue = opt.critValue/length(X_1);
    critValue = max([critValue,max(cooksD)*0.9]);
    rejected = cooksD > critValue;
    if any(opt.bounds > 0)
        I = find(rejected);
        I = arrayfun(@(x) x-opt.bounds(1):x+opt.bounds(end),I,'UniformOutput',0); %rejects values +/- opt.bounds of index of rejected shots
        I = unique([I{:}])';
        I(I<1) = [];
        I(I>length(X_1)) = [];
        rejected(I) = true;
    end
    X = X_1(~rejected);
    Y = Y_1(~rejected);
    outlier_X = [outlier_X; X_1(rejected)];
    outlier_Y = [outlier_Y; Y_1(rejected)];
    designMatrix = designMatrix(~rejected,:);
    hatMatrixDiag = hatMatrixDiag(~rejected);
    runs = runs +1;
    
    %% make designMatrix equal zero
end

fittedCurve = OrigDM*fittedParameters;
outlier = [outlier_X, outlier_Y];
usedData = [X,Y];

end

