function [ fit, func, P ] = f_ExpDecay_fit( x, y , plot_window)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if nargin == 2 ,
    plot_window = 0;
end

% Define exponential function
func = @(x,p) p(1) + p(2)*exp(-x./p(3));

% Error function.
errfh = @(p,x,y) sum((y(:)-func(x(:),p)).^2);

% an initial guess of the exponential parameters
p0 = [mean(y) (max(y)-min(y)) (max(x) - min(x))/4];

% search for solution
P = fminsearch(errfh,p0,[],x,y);



fit = func(x,P);

%plot the result
if plot_window
    if ishandle(plot_window)
        figure(plot_window)
        clf
    end
    color_options = [{'qual'},'Set1'];
    col = f_Colorbrewer(3, color_options{1}, color_options{2});
    h = f_Plot(y, x, plot_window, 'MarkerSize', 6, 'PlotStyles', col(1,:));
    f_Plot(fit, x, h, 'PointStyle', '', 'LineStyle', '-', 'PlotStyles', [0.2,0.2,0.2], 'Hold', 1);
    
%     figure(plot_window)
%     plot(x,y,'bo',x,func(x,P),'r-')
    
end

end

