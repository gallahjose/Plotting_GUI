function [mu, FWHM, scaler, dataPred, z] = f_GaussianFit(y, x, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% y = ax^2 + bx %parabola

opt.plotR = 0;
opt.fitParabola = 0;
opt.plotD = 0;
opt.name = 'none';
opt.constant = ones(length(x),1);
opt.mu = [];
opt.nonNeg = 0;
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
    z0 = [mu; FWHM*3];
end

if ~isempty(opt.mu)
    z0 = z0(2:end);
    VariableScaler = VariableScaler(2:end,:);
end

z0(isnan(z0)) = 0;
[z0] = f_FittingScaler(z0, VariableScaler, 1);

LB = -1*ones(length(z0),1);
UB = 1*ones(length(z0),1);

if ~isempty(opt.mu)
    LB = LB*4;
    UB = UB*4;
end

[z,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = lsqcurvefit(@guassian, z0, x, y, LB, UB, ...
    optimset('Algorithm', 'trust-region-reflective', 'FinDiffType', 'central', 'TolFun', 1E-8, 'Display', 'off', 'TolX',1E-3),...
    y, VariableScaler, opt.plotD, opt.mu, opt.constant,opt.nonNeg);



[z] = f_FittingScaler(z, VariableScaler, 0);
if ~isempty(opt.mu)
    z = [opt.mu; z];
end

mu = z(1);
FWHM = z(2);
[ gaussian ] = f_Gaussian( x, z(2), z(1), 1);

if length(z) == 4
    [ parabola ] = z(3)*x.^2 + z(4)*x;
else
    parabola = [];
end

xShapes = [gaussian, parabola, opt.constant];

if opt.nonNeg
    %w = lsqnonneg(C,d) then C*w = d
    scaler = lsqnonneg(xShapes,y);
else
    scaler = xShapes\y;
end
dataPred = xShapes*scaler;

if opt.plotR
    yMax = max([dataPred,y]);
    yMin = min([dataPred,y]);
    if yMax < 0, yMax = 0; end
    if yMin > 0, yMin = 0; end
    
    h = f_Plot(dataPred, x, opt.plotR,'title', ['Gaussian Fit of ',opt.name], 'PlotStyles', [0.8,0,0],...
        'twoPlots', 0,'LineStyle','-', 'YLim', [yMin, yMax],'PointStyle','','YLabel','Int');
    
    h = f_Plot(y, x, h,'hold',1, 'Legend', [{'Fit'}, 'data'], 'PlotStyles', [0,0,0.8], 'twoPlots', 0,'LineStyle','');
    pause(0.5)
    
    txt_str = {
        ['mu =',num2str(mu)]
        ['FWHM =',num2str(FWHM)]
        ['Scalar =',num2str(scaler(1))]
        };
    dim = [.2 .5 .3 .3];
    ah= annotation('textbox',dim,'String',txt_str,'FitBoxToText','on');   
    
end
end



function [dataPred] = guassian(z, x, data, VariableScaler, plotD, mu,constant,nonNeg)

[z] = f_FittingScaler(z, VariableScaler, 0);


if ~isempty(mu)
    z = [mu; z];
end

[ gaussian ] = f_Gaussian( x, z(2), z(1), 1);

if length(z) == 4
    parabola  = z(3)*(x-z(4)).^2;
else
    parabola = [];
end

xShapes = [gaussian, parabola, constant];

if nonNeg
    %w = lsqnonneg(C,d) then C*w = d
    scaler = lsqnonneg(xShapes,data);
else
    scaler = xShapes\data;
end
dataPred = xShapes*scaler;

if plotD
    f_Plot([data,dataPred],x,plotD,'twoPlots',0,'onePlotScale','linear');
    pause(0.5)
end

end