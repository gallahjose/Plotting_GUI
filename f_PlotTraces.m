function h = f_PlotTraces(traces, xAxes, axesName, varargin)
%f_PlotTraces(traces, xAxes, traceLabel, axesName)
%   is coded to update both GUI and Figures, using a linear-log plot for
%   time values. Can auto-detect the xlabel if it is one of preset options,
%   otherwise this can be passed. Two-plots option can be controlled or
%   auto-detected.
%
%   %%Returned Values
%
%   %%Options
%   'Xlabel'            Label for plot x-axis
%                       default = auto detect [Pixel, Time (s), Wavelength (nm)]
%   'Ylabel'            Label for plot y-axis
%                       default = 'm(\DeltaT/T)'
%   'title'             Title for plot
%                       default = 'Un-Named'
%   'reversePlotStyle'  reverses the order of plot styles
%                       default = 1
%   'plot_styles'       colours for plots
%                       default = [0.6196,0.0039,0.2588; 0.8353,0.2431,0.3098; 0.9569,0.4275,0.2627; 0.9922,0.6824,0.3804; 0.6706,0.8667,0.6431; 0.4000,0.7608,0.6471; 0.1961,0.5333,0.7412; 0.3686,0.3098,0.6353];
%   'twoPlots'          plots a liner and log section on the x-axis
%                       default = auto detect [0, 1]
%   'tlin'              rescaler for linear section of plot (time*tlin)
%                       default = auto detect [1E-9, 1E-12]
%   'tscale'            range of the linear plot in two plots
%                       default = auto detect [3, 1]
%   'tlinAxis'          label for linear part in two plots
%                       default = auto detect [time (ns), time (ps)]
%
%   18-04-14 Shyamal - inital updated
%   13-06-14 Shyamal - Added 'opt.hold' and changed axes hold options to
%                      allows for multiple plots to same axes

%% Check input varibales
if ~exist('axesName','var'), axesName = 1; end
if ~exist('xAxes','var'), xAxes = 1:size(traces,2); end


if size(xAxes,1) ~= size(xAxes,1), traces = traces'; end
if size(traces,1) ~= size(xAxes,1), traces = traces'; end

h = axesName;

%% Sets Options
% default options
opt.reversePlotStyle = 1;
opt.onePlotScale = 'linear';
opt.plot_styles = f_ColorPicker( size(traces,2),'type','qualitative');
opt.title = [];
opt.Ylabel = 'm(\DeltaT/T)';
opt.traceLabel = {};
opt.YLimits = [min(min(traces)), max(max(traces))];
opt.XLimits = [min(xAxes), max(xAxes)];
opt.hold = 0;
opt.plotZero = 1;
opt.figTitle = '';
opt.twoPlots = 0;

opt.ZeroColor = [0 0 0];
opt.PointStyle = '.';
opt.LineStyle = '';
opt.LineWidth = 2.5;
opt.MarkerSize = 10;
opt.TickLength = [0.02, 0.02];
opt.TickWidth = 0.5;
opt.DisplayName = 'no_name';

opt.fontSize = 20;
opt.tickScaler = 0.8;
opt.removeXTick = 0;
opt.removeYTick = 0;

%% auto detects type of xAxes, determined xAxis values
if xAxes(1) == 0,
    opt.Xlabel = 'Pixel';
elseif xAxes(1) < 0 || xAxes(end) < 0.01,
    opt.Xlabel = 'Time (s)';
elseif xAxes(end) < 1
    opt.Xlabel = 'Energy (eV)';
else
    opt.Xlabel = 'Wavelength (nm)';
end
%% Detects if two plots are needed
[opt] = f_OptSet(opt, varargin);
opt.twoPlots = 0;
if (xAxes(1) < 0 || xAxes(end) < 0.01) && max(abs(xAxes)) < 10
    opt.figTitle = 'Kinetic';
    opt.twoPlots = 1;
    [~,xAxesMinIndex] = min(abs(xAxes));
    if xAxes(1) > 0
        opt.twoPlots = 0;
        opt.onePlotScale = 'log';
    end
    
    if log10((xAxes(end))/(xAxes(xAxesMinIndex+1)-xAxes(xAxesMinIndex))) < 2.5
        opt.twoPlots = 0;
        opt.onePlotScale = 'linear';
    else
        opt.twoPlots = 1;
    end
    
else
    opt.figTitle = 'Spectra';
end
%% sets default scaling for fs and ps pump data
[~,zeroIndex] = min(abs(xAxes));
if zeroIndex > length(xAxes)-2, zeroIndex = zeroIndex - 2; end

if xAxes(zeroIndex+2)-xAxes(zeroIndex+1) > 200E-15 %checks the minimum spacing between time points is greater than 200 fs
    opt.tlin = 1E-9;
    opt.tscale = 2.5;
    opt.tlinAxis = 'Time (ns)';
else
    opt.tlin = 1E-12;
    opt.tscale = 1;
    opt.tlinAxis = 'Time (ps)';
end

%& user input (after autodetection to allow user options)
[opt] = f_OptSet(opt, varargin);

if opt.tlin == 1E-12 && xAxes(end) > 1E-6;
    linLogFraction = 0.15;
else
    linLogFraction = 0.2;
end

if ~isempty(traces)
    
    %% Checks Options
    if opt.YLimits(1) == opt.YLimits(2), opt.YLimits = [opt.YLimits(1)*0.8, opt.YLimits(1)*1.2]; end
    if opt.XLimits(1) == opt.XLimits(2), opt.XLimits = [opt.XLimits(1)*0.8, opt.XLimits(1)*1.2]; end
    if sum(abs(opt.YLimits)) == 0 , opt.YLimits = [-1,1]; end
    if sum(abs(opt.XLimits)) == 0 , opt.XLimits = [-1,1]; end
    
    opt.YLimits = sort(opt.YLimits);
    opt.XLimits = sort(opt.XLimits);
    
    if iscell(opt.title), opt.title = opt.title{1}; end
    
    if isempty(opt.Xlabel), opt.tlinAxis = []; end
    
    %% selects the correct axis, either in the GUI or a new FIGURE
    if ~ishandle(axesName(1)) || ~strcmp('axes', get(axesName(1),'type')) %if given figure or invalid handle
        axesName = floor(axesName(1));
        figTitle = strfind(opt.title, opt.figTitle);
        figTitle = opt.title(1:figTitle-2);
        if opt.twoPlots
            h  = f_MultiLinLogAxes( 1, axesName, 'rowStyles', {'LinLog'}, 'title', opt.title, 'figTitle', [opt.figTitle,': ',figTitle],'titleSize',opt.fontSize,'linLogFraction',linLogFraction);
        else
            h  = f_MultiLinLogAxes( 1, axesName, 'rowStyles', {'Linear'}, 'title', opt.title, 'figTitle', [opt.figTitle,': ',figTitle],'titleSize',opt.fontSize);
        end
    else % loads the axes handles into variables
        if opt.twoPlots && length(axesName) > 2
            opt.twoPlots = 0;
        end
        h = axesName;
    end
    
    %% Sets up colors for plots
    if opt.reversePlotStyle
        index = abs(linspace(-1*size(opt.plot_styles, 1),-1,size(opt.plot_styles,1)));
        opt.plot_styles = opt.plot_styles(index, :);
    end
    
    
    if length(h) < 2, opt.twoPlots = 0; end
    
    %% Sets Generic Axes properties
    if ~opt.hold
        %options for each axis
        for n = 1 : length(h)
            cla(h(n),'reset')
            hold(h(n),'on')
            box(h(n), 'on');
            grid(h(n), 'on');
            set(h(n), 'ColorOrder', opt.plot_styles, 'YLim', opt.YLimits, 'TickLength',opt.TickLength, 'LineWidth', opt.TickWidth, 'FontSize', opt.fontSize*opt.tickScaler);
        end
        ylabel(h(1), opt.Ylabel, 'fontsize',opt.fontSize)
        xlabh = xlabel(h(end), opt.Xlabel,'fontsize',opt.fontSize);
        %options if there are two plots
        if opt.twoPlots %%
            set(h(2),'YTickLabel','',...
                'XLim', [opt.tlin*opt.tscale, opt.XLimits(end)], ...
                'xscale', 'log');
            set(h(1),'XTick',-1*opt.tscale:opt.tscale/2:3, ...
                'XTickLabel',{num2str(-1*opt.tscale),'', '0', '', ''}, ...
                'XLim', [-1*opt.tscale, opt.tscale],...
                'xscale', 'linear');
            xlabh2 = xlabel(h(1), opt.tlinAxis,'fontsize',opt.fontSize);
            set(xlabh2,'Position', get(xlabh,'Position'));
        else
            set(h(1), 'XLim', opt.XLimits, ...
                'xscale', opt.onePlotScale);
        end
    else
        for n = 1 : length(h)
            hold(h(n),'on')
            set(h(n), 'ColorOrder', opt.plot_styles);
        end
    end
    
    %% twoPlots first linear second log
    if opt.twoPlots
        %find indcies of linear time range
        [~,lin_index_min] = min(abs(-1*opt.tlin*opt.tscale-xAxes));
        [~,lin_index_max] = min(abs( opt.tlin*opt.tscale-xAxes));
        
        %add extra data point at each end of linear plot
        if lin_index_min > 1
            lin_index_min = lin_index_min - 1;
        end
        if lin_index_max < length(xAxes)
            lin_index_max = lin_index_max + 1;
        end
        
        %Linear plot
        plot(h(1), xAxes(lin_index_min:lin_index_max)/opt.tlin, traces((lin_index_min:lin_index_max),:), [opt.PointStyle opt.LineStyle],...
            'linewidth', opt.LineWidth, 'markersize', opt.MarkerSize)
        %Log plot
        plot(h(2),xAxes(lin_index_max-2:end), traces((lin_index_max-2:end),:), [opt.PointStyle opt.LineStyle],...
            'linewidth', opt.LineWidth, 'markersize', opt.MarkerSize,'DisplayName',opt.DisplayName)
        if ~isempty(opt.traceLabel), legend(h(end), opt.traceLabel, 'location', 'Best'); end
    else % one plot
        plot(h(end), xAxes, traces, [opt.PointStyle opt.LineStyle],...
            'linewidth', opt.LineWidth, 'markersize', opt.MarkerSize,'DisplayName',opt.DisplayName)
        if ~isempty(opt.traceLabel), legend(h(1), opt.traceLabel); end
    end
    
    %% turns off axees hold, and plotZero line if needed
    for n = 1 : length(h)
        if opt.removeYTick, set(h(n), 'YTickLabel',''); end
        if opt.removeXTick, set(h(n), 'XTickLabel',''); end
        if opt.plotZero
            xLimits = get(h(n), 'Xlim');
            yLimits = get(h(n), 'Ylim');
            zh = plot(h(n),xLimits,zeros(1,length(xLimits)),'color', opt.ZeroColor, 'linewidth', opt.TickWidth);
            uistack(zh,'bottom')
            set(get(get(zh, 'Annotation'), 'LegendInformation'), ...
                'IconDisplayStyle', 'off')
            zh = plot(h(n),[0,0],yLimits,'color', opt.ZeroColor, 'linewidth', opt.TickWidth);
            uistack(zh,'bottom')
            set(get(get(zh, 'Annotation'), 'LegendInformation'), ...
                'IconDisplayStyle', 'off')
        end
        hold(h(n),'off')
    end
end