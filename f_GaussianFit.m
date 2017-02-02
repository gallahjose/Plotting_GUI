function [mu, FWHM, scaler, dataPred, z] = f_GaussianFit(y, x, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% y = ax^2 + bx %parabola

opt.plotR = 0;
opt.fitParabola = 0;
opt.plotD = 0;
opt.name = 'none';

if size(x,2) > 1, x = x'; end
if size(y,2) > 1, y = y'; end


% user input (after autodetection to allow user options)
[opt] = f_OptSet(opt, varargin);

yWorking = y - min(y);
[maxY, muIndex] = max(yWorking);
mu = x(muIndex);

[~,FWHMmin] = min(abs(maxY/2-yWorking(1:muIndex)));
[~,FWHMmax] = min(abs(maxY/2-yWorking(muIndex:end)));
FWHMmax = FWHMmax + muIndex - 1;

FWHM = abs((x(FWHMmax) - x(FWHMmin)));


VariableScaler = [min(x),max(x); 0.4*FWHM, 2*FWHM];

if opt.fitParabola
   [minY, minIndexY] = min(y);
   minX = x(minIndexY);
   a = ((minY-y(1))*(x(1)-x(end)) + (y(end)-y(1))*(minX - x(1)))/((x(1)-x(end))*(minX^2-x(1)^2) + (minX-x(1))*(x(end)^2-x(1)^2));
   b = ((minY - y(1)) - a*(minX^2 - x(1)^2)) / (minX -x(1));  
z0 = [mu; FWHM;a;b];
VariableScaler = [VariableScaler; -10,10;-max(x),max(x)];
else
z0 = [mu; FWHM];
end

z0(isnan(z0)) = 0;
[z0] = f_FittingScaler(z0, VariableScaler, 1);

LB = -0.5*ones(length(z0),1);
UB = 0.5*ones(length(z0),1);

[z] = lsqcurvefit(@guassian, z0, x, y, LB, UB, ...
    optimset('Algorithm', 'trust-region-reflective', 'FinDiffType', 'central', 'TolFun', 1E-8, 'Display', 'off'),...
    y, VariableScaler, opt.plotD);

[z] = f_FittingScaler(z, VariableScaler, 0);
mu = z(1);
FWHM = z(2);
[ gaussian ] = f_Gaussian( x, z(2), z(1), 1);

if length(z) == 4
    [ parabola ] = z(3)*x.^2 + z(4)*x;
else
    parabola = [];
end

xShapes = [gaussian, parabola];

scaler = [xShapes, ones(size(xShapes,1),1)]\y;

dataPred = [xShapes, ones(size(xShapes,1),1)]*scaler;

if opt.plotR
    f_Plot([dataPred,y], x, opt.plotR, 'Title', 'Gaussian fitting',...
        'FigureTitle', ['Gaussian Fit of ',opt.name], 'Legend', [{'Fit'}, 'data'], 'TwoPlots', 0,'LineStyle','-');
    pause(0.5)
end
end



function [dataPred] = guassian(z, x, data, VariableScaler, plotD)

[z] = f_FittingScaler(z, VariableScaler, 0);

[ gaussian ] = f_Gaussian( x, z(2), z(1), 1);

if length(z) == 4
    parabola  = z(3)*(x-z(4)).^2;
else
    parabola = [];
end

xShapes = [gaussian, parabola];

weights = [xShapes, ones(size(xShapes,1),1)]\data;

dataPred = [xShapes, ones(size(xShapes,1),1)]*weights;

if plotD
    f_PlotTraces([data,dataPred],x,plotD);
end

end