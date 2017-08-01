function [h, opt_plot, tickH, fh, legHand] = f_Plot( data, xAxes, axesName, varargin)
%f_Plot(traces, xAxes, axesName, options) - gives traces
%[h, opt, tickH, fh, lh] = f_Plot( data, xAxes, axesName, varargin) - gives surface
%Produces plots of data minimizing user input
%
%   %%Inputed Values
%   'data'              data to be plotted
%   'xAxes (time)'      trace axes (time for surface)
%   'wave'              wave axes [surface only]
%   'axesName'          figure or axes handle to plot to
%
%   %%Returned Values
%   'h'                 handle of axes plotted
%   's'                 handle of surface/plot created
%
%   %%Options
%   'Title'             Title (above all axes)
%                       default = [] (NONE)
%   'FigureTitle'       Title of window (in title bar)
%                       default = [] (NONE)
%   'AxesTitle'         Title above each axes (cented above indivdual axes)
%                       default = [] (NONE)
%
%   %%Funtions called
%   f_OptSet
%   f_ColorPicker
%   f_Round
%   f_MultiLinLogAxes
%   f_JetBar


%% Logic behind axes names
%xAxes is always time
%yAxes is always wavelength/pixel
%This is used to auto determine options for linlog and lin plot and what
%labels to use for time or wavelength/pixel

%% Check input varibales
if ~exist('data','var'), data = random('norm',2,160,[160]); end
if ~exist('xAxes','var'), xAxes =(exp(linspace(0, 10, size(data,1)))-2).*1E-12; end
if ~exist('axesName','var'), axesName = 100000000; end

%% Replace inf with nan
data(isinf(data)) = nan;

%% Determines if user wants a surface or plot
opt.JetType = 'Jet';
opt.JetSymmetric = 0;
if any(length(axesName) == size(data)') && ~isempty(varargin) && ~ischar(varargin{1})
    %Surface Plot
    
    yAxes = axesName;
    axesName = varargin{1};
    if size(yAxes,1) ~= length(yAxes), yAxes = yAxes'; end
    if size(xAxes,1) ~= length(xAxes), xAxes = xAxes'; end
    if size(xAxes,1) ~= size(data,1), data = data'; end
    if length(varargin) > 1
        varargin  = varargin(2:end);
    else
        varargin = [];
    end
    
    if max(data(:)) > 100
        %opt.JetType = 'TRPL';
        opt.JetSymmetric = 0;
    end
    
    plotSurf = 1;
    useTime = 1;
    xRightOffset = 80;
    xPadding = 90;
    
    
    varargin = [varargin,{'TickWidth'},0.5];
else
    if size(xAxes,2) ~= 1, xAxes = xAxes'; end
    if size(data,1) ~= size(xAxes,1), data = data'; end
    if size(data,1) ~= size(xAxes,1)
        warning('Trace length and Axes length do not match');
    end
    
    if xAxes(1) < 0 || xAxes(end) < 0.01 % use xAxes to plot (trace is time)
        yAxes = [1,1000];
        useTime = 1;
        v2 = 270;
    else % use yAxes to plot (trace in wavelength/pixel)
        yAxes = xAxes;
        xAxes = ones(size(data,2),1);
        useTime = 0;
    end
    varargin(strcmpi(varargin,'YLim')) = {'ZLim'};
    varargin(strcmpi(varargin,'YLabel')) = {'ZLabel'};
    varargin(strcmpi(varargin,'addspacingY')) = {'addspacingZ'};
    
    plotSurf = 0;
    xRightOffset = 30;
    xPadding = 110;
end

%% Sets Options
% default options
opt.Title = [];
opt.FigureTitle = [];
opt.AxesTitle = [];

opt.ZLabel = '\DeltaT/T'; %Intensity label
opt.XLabel = 'Time (s)';
opt.YLabel = 'Wavelength (nm)';

opt.ZLim = [min(data(:)), max(data(:))]; %Color bar limits
opt.YLim = [min(yAxes) max(yAxes)];
opt.XLim = [min(xAxes) max(xAxes)];

opt.ps_time = 1;
opt.Hold = 0;

opt.clear_marker = 0;

% logically determined
opt.TwoPlots = 1;
opt.LinearBound = [];
opt.LinearLabel = [];
opt.LinearFraction = [];
opt.OnePlotScale = 'linear';

% Aesthetics
opt.PlotZero = 1;
opt.RelabelY = 0;
opt.RelabelX = 0;
opt.DualX = 0;
opt.RescaleData = 1;
opt.SI_Scalar = 0;
opt.IntegerIntensity = 0;
opt.ZeroColor = [0 0 0];
opt.TickLength = [0.02, 0.02];
opt.TickWidth = 1.5;
opt.RemoveXTick = 0;
opt.RemoveXLabel = [];
opt.RemoveYTick = 0;
opt.FontSize = 20;
opt.FontScaler = 1;
opt.RemoveLegend = 0;
opt.SqueezeZlim = 1;
opt.addspacingZ = 0;
opt.addspacingX = 0;
opt.addspacingY = 0;
opt.FlipX = 0;
opt.ShrinkAxes = 1;
opt.colorShrink = 2;
% Surface Only Options
opt.V1 = 0;
opt.V2 = 270; %set this to 90 to flip wavelength
opt.DownSample = 0;
opt.ColorBar = 1;
opt.JetBar = 1;
opt.OverlayAxis = 1;
opt.ShadingType = 'interp';
% Trace Only Opitons
opt.PointStyle = {'s','^','o','d'};
opt.LineStyle = '';
opt.LineWidth = 2.5;
if size(data,1) < 200
    opt.MarkerSize = 5;
else
    opt.MarkerSize = 3;
end
opt.PlotStyles = [];
opt.DisplayName = 'xAxes';
opt.Legend = [];
opt.LegendLocation = 'best';
% Pass through options
opt.FigureOptions = {};
opt.ColorOptions = [{'hue'},'blue','type','qualitative','reverse',1];

opt.patch = [];
opt.patch_color = [0.8,0.8,0.8];

%
opt.log_scale = 0;

tickH = [];

%% Logically Determins Options

% if max(xAxes) > 10E-9
%     opt.LinearBound = 2E-9;
%     opt.ps_time = 0;
% else
%     opt.LinearBound = 1E-12;
% end

[~,zeroIndex] = min(abs(xAxes));
if zeroIndex + 2 <= length(xAxes)
    if xAxes(zeroIndex+2)-xAxes(zeroIndex+1) > 200E-15 %checks the minimum spacing between time points is greater than 200 fs
        opt.LinearBound = 2E-9;
    else
        opt.LinearBound = 1E-12;
    end
else
    opt.LinearBound = 1E-12;
end

%Sets x-axis label
if ~any(strcmpi(varargin,{'YLabel'}))
    if abs(yAxes(1) - yAxes(end)) < 10
        if ~any(strcmpi(varargin,{'RelabelY'})) && ~any(strcmpi(varargin,{'RelabelX'}))
            opt.YLabel = 'Photon Energy (eV)';
        end
        opt.FlipX = 1;
    elseif yAxes(1) == 0
        opt.YLabel = 'Pixel';
    end
end
% determine if linear plot is needed and set x-axis to linear or log
[~,timeMinIndex] = min(abs(xAxes));
if timeMinIndex < length(xAxes) && log10( (xAxes(end))/(xAxes(timeMinIndex+1)-xAxes(timeMinIndex)) ) < 2.5
    opt.TwoPlots = 0;
    opt.OnePlotScale = 'linear';
elseif xAxes(1) > 0
    opt.TwoPlots = 0;
    opt.OnePlotScale = 'log';
end
if ~useTime %time is not in this figure
    opt.TwoPlots = 0;
    opt.OnePlotScale = 'linear';
end

%% %%%%%%% USER OPTIONS SET %%%%%%%%%%%
% special f_opt check
i = find(strcmpi(varargin,'XLabel'));
if ~isempty(i) &&  strcmpi(varargin{i+1},'ignore')
    varargin(i:i+1) = [];
end
i = find(strcmpi(varargin,'YLabel'));
if ~isempty(i) &&  strcmpi(varargin{i+1},'ignore')
    varargin(i:i+1) = [];
end
i = find(strcmpi(varargin,'ZLabel'));
if ~isempty(i) &&  strcmpi(varargin{i+1},'ignore')
    varargin(i:i+1) = [];
end

[opt] = f_OptSet(opt, varargin);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Other options...
if opt.FlipX
    opt.V2 = opt.V2 - 180;
end
if strcmpi(opt.PointStyle,'.')
    opt.PointStyle = 'o';
end
if ~any(strcmpi(varargin,'FontSize')) && ishandle(axesName(end)) && strcmpi('axes', get(axesName(end),'type'))
    opt.FontSize = get(axesName(1),'FontSize');
end
if ~any(strcmpi(varargin,'TickWidth')) && ishandle(axesName(end)) && strcmpi('axes', get(axesName(end),'type'))
    opt.TickWidth = get(axesName(1),'LineWidth');
end
    
    
if plotSurf
    % Surface Only Options
else
    % Trace Only Options
    opt.DownSample = 0;
    opt.JetBar = 0;
    opt.OverlayAxis = 0;
    opt.ColorBar = 0;
    if any(strcmpi(varargin,{'YLim'})), opt.ZLim = opt.YLim; end
    if any(strcmpi(varargin,{'YLabel'})), opt.ZLabel = opt.YLabel; end
end

%% Defaults if not set by user
if ~isempty(opt.LinearBound)
    % linLog linear axis label
    if ~any(strcmpi(varargin,{'LinearLabel'}))
        prefix = num2strEng(opt.LinearBound);
        opt.LinearLabel = ['Time (',prefix(end),'s)'];
    end
    % fraction linear part of linlog axis
    if ~any(strcmpi(varargin,{'LinearFraction'}))
        if opt.LinearBound == 1E-12 && xAxes(end) > 1E-6
            opt.LinearFraction = 0.15;
        else
            opt.LinearFraction = 0.2;
        end
    end
end
% plot styles
if ~any(strcmpi(varargin,'PlotStyles')) && ~plotSurf
    if exist('f_ColorPicker','file')
        opt.PlotStyles = f_ColorPicker( size(data,2), opt.ColorOptions{:});
    elseif exist('f_Colorbrewer','file')
        opt.PlotStyles = f_Colorbrewer( size(data,2), opt.ColorOptions{:});
    end
end

if ~any(strcmpi(varargin,{'ZLabel'}))
    if [opt.ZLim(1) <-0.8 && opt.ZLim(1) > -3] || [opt.ZLim(2) <3 && opt.ZLim(2)  > 0.8]
        opt.ZLabel = 'Normalized \DeltaT/T'; %Intensity label
    else
        opt.ZLabel = '\DeltaT/T'; %Intensity label
    end
end

%% Log data
if opt.log_scale && plotSurf
    neg_data = data <= 0;
    data = log10(data);
    data(neg_data) = nan;
    
    %data = abs(data);
    
    % takes care of the limits!
    opt.ZLim = log10(opt.ZLim);
    opt.ZLim(1) = min(data(:));
    
    opt.JetType = 'logTRPL';
end

%% Checks Options
% X, Y, Z limits
opt.ZLim = opt.ZLim/opt.SqueezeZlim;

if opt.YLim(1) == opt.YLim(2), opt.YLim = [opt.YLim(1)*0.8, opt.YLim(1)*1.2]; end
if opt.ZLim(1) == opt.ZLim(2), opt.ZLim = [opt.ZLim(1)*0.8, opt.ZLim(1)*1.2]; end
if opt.XLim(1) == opt.XLim(2), opt.XLim = [opt.XLim(1)*0.8, opt.XLim(1)*1.2]; end
opt.XLim = sort(opt.XLim);
opt.YLim = sort(opt.YLim);
opt.ZLim = sort(opt.ZLim);
%if opt.ZLim(1) > 0, opt.ZLim(1) = 0; end

if ~plotSurf
    if opt.addspacingZ
        if opt.ZLim(1) < 0, opt.ZLim(1) = opt.ZLim(1)*opt.addspacingZ; else opt.ZLim(1) = opt.ZLim(1)/opt.addspacingZ; end
        if opt.ZLim(2) > 0, opt.ZLim(2) = opt.ZLim(2)*opt.addspacingZ; else opt.ZLim(2) = opt.ZLim(2)/opt.addspacingZ; end
    end
    if opt.addspacingY > 0
        if opt.YLim(1) < 0, opt.YLim(1) = opt.YLim(1)*opt.addspacingY; else opt.YLim(1) = opt.YLim(1)/opt.addspacingY; end
        if opt.YLim(2) > 0, opt.YLim(2) = opt.YLim(2)*opt.addspacingY; else opt.YLim(2) = opt.YLim(2)/opt.addspacingY; end
    end
    if opt.addspacingX > 0
        if opt.XLim(1) < 0, opt.XLim(1) = opt.XLim(1)/0.95; else opt.XLim(1) = opt.XLim(1)*0.95; end
        if opt.XLim(2) > 0, opt.XLim(2) = opt.XLim(2)/0.95; else opt.XLim(2) = opt.XLim(2)*0.95; end
    end
end

% Remove XLabel
if isempty(opt.XLabel), opt.LinearLabel = []; end
if ~isempty(opt.Title) && ischar(opt.Title)
    opt.Title = {opt.Title};
end

%% Rescale data and append label
if opt.RescaleData
    if ~any(strcmpi(varargin,{'SI_Scalar'}))
        opt.SI_Scalar = floor(log10(max(abs(opt.ZLim))));
    end
    if opt.Hold && ~any(strcmpi(varargin,{'SI_Scalar'}))
        scaler = axesName(1).YLabel.String;
        string = regexp(scaler,'\\times10\^{','split');
        if length(string) > 1
            string = regexp(string{2},'}','split');
            if length(string) > 1
                opt.SI_Scalar = str2num(string{1});
            end
        else
            opt.SI_Scalar = 1;
        end
    end
    if abs(opt.SI_Scalar) == 1
        if ~any(strcmpi(varargin,{'IntegerIntensity'}))
            opt.IntegerIntensity = 0;
        end
    elseif abs(opt.SI_Scalar) > 1
        data = data/10^(opt.SI_Scalar);
        opt.ZLim = opt.ZLim/10^(opt.SI_Scalar);
        if ~isempty(opt.ZLabel)
            opt.ZLabel = [opt.ZLabel, ' \times10^{',num2str(opt.SI_Scalar),'}'];
        end
    end
end

%% Rounds Intensity Limits
sigfig = 2;
opt.YLim = [ f_Round(opt.YLim(1),sigfig+1,'floor')  f_Round(opt.YLim(2),sigfig+1,'ceil')];
opt.ZLim = [ f_Round(opt.ZLim(1),sigfig+1,'floor')  f_Round(opt.ZLim(2),sigfig+1,'ceil')];
opt.XLim = [ f_Round(opt.XLim(1),sigfig+1,'floor')  f_Round(opt.XLim(2),sigfig+1,'ceil')];

%% Sets axes and labels for trace plotting
if ~plotSurf
    if ~useTime
        xAxes = yAxes;
        if ~any(strcmpi(varargin,{'XLim'})), opt.XLim = opt.YLim; end
        if ~any(strcmpi(varargin,{'XLabel'})), opt.XLabel = opt.YLabel; end
    end
    opt.YLim = opt.ZLim;
    opt.YLabel = opt.ZLabel;
    if ischar(opt.PointStyle), opt.PointStyle = {opt.PointStyle}; end
    if ischar(opt.LineStyle), opt.LineStyle = {opt.LineStyle}; end
    if ischar(opt.DisplayName), opt.DisplayName = {opt.DisplayName}; end
    if size(opt.PointStyle,2) >1 , opt.PointStyle = opt.PointStyle'; end
    if size(opt.LineStyle,2) >1 , opt.LineStyle = opt.LineStyle'; end
    if size(opt.DisplayName,2) >1 , opt.DisplayName = opt.DisplayName'; end
    
    if isnumeric(opt.LineStyle), opt.LineStyle = cell(size(opt.LineStyle)); end
    if isempty(opt.LineStyle), opt.LineStyle = cell(1); end
    
    opt.PointStyle(cellfun(@isempty,opt.PointStyle)) = {'none'};
    opt.LineStyle(cellfun(@isempty,opt.LineStyle)) = {'none'};
    opt.DisplayName(cellfun(@isempty,opt.DisplayName)) = {'none'};
    
    opt.PointStyle = repmat(opt.PointStyle,size(data,2),1);
    opt.LineStyle = repmat(opt.LineStyle,size(data,2),1);
    opt.DisplayName = repmat(opt.DisplayName,size(data,2),1);
    opt.PlotStyles = repmat(opt.PlotStyles,ceil(size(data,2)/size(opt.PlotStyles,1)),1);
    %if ~isempty(opt.PlotStyles), opt.PlotStyles = opt.PlotStyles(1:size(data,2),:); end
end

%% downsamples data points used in surface (reduce data set for latex
if opt.DownSample
    waveI =  interp1q( linspace(1,length(yAxes),length(yAxes))' , yAxes , linspace(1,length(yAxes),length(yAxes)*opt.DownSample+1)');
    dataI = interp1q(yAxes, data', waveI);
    dataI = dataI';
    data = dataI;
    yAxes = waveI;
end

%% Sets up axes for plotting
if ~isempty(opt.Title)
    opt.Title = regexprep(opt.Title,'\_(?!{)','\\_'); %removes extra character (?!x) is a negative look ahead for x
end
if isempty(opt.FigureTitle) && ~isempty(opt.Title)
    opt.FigureTitle = opt.Title(1);
end

if ~ishandle(axesName(end)) || ~strcmpi('axes', get(axesName(end),'type')) %if given figure or invalid handle
    if opt.TwoPlots
        [h, fh]  = f_MultiLinLogAxes( 1, axesName(1), 'rowStyles', {'LinLog'}, 'title', opt.Title, 'figTitle',  opt.FigureTitle,...
            'fontSize',opt.FontSize*opt.FontScaler, 'linLogFraction',opt.LinearFraction,...
            'xRightOffset', xRightOffset,'xPadding',xPadding,...
            opt.FigureOptions{:});
    else
        [h, fh]  = f_MultiLinLogAxes( 1, axesName(1), 'rowStyles', {'Linear'}, 'title', opt.Title, 'figTitle', opt.FigureTitle,...
            'fontSize',opt.FontSize*opt.FontScaler,...
            'xRightOffset', xRightOffset,'xPadding',xPadding,...
            opt.FigureOptions{:});
    end
else % loads the axes handles into variables
    if opt.TwoPlots && length(axesName) < 2
        opt.TwoPlots = 0;
    end
    h = axesName;
    fh = get(axesName(1),'parent');
end

%% Apply figure scaler to text and point sizes if necessary
if isfield(fh.UserData,'scaler');
    fig_scaler =  fh.UserData.scaler;
    
    opt.TickLength = opt.TickLength.*fig_scaler;
    opt.TickWidth = opt.TickWidth.*fig_scaler;
    opt.FontSize = opt.FontSize.*fig_scaler;
    opt.LineWidth = opt.LineWidth.*fig_scaler;
    opt.MarkerSize = opt.MarkerSize.*fig_scaler;
else
    fig_scaler = 1;
end

%% Sets Generic Axes properties
if ~opt.Hold
    %options for each axis
    for n = 1 : length(h)
        %cla(h(n),'reset')
        lh = get(h(n),'Children');
        lh = lh(strcmpi(get(lh,'type'),'line'));
        delete(lh);
        hold(h(n),'on')
        box(h(n), 'on');
        grid(h(n), 'on');
        if plotSurf
            view(h(n), [opt.V1, opt.V2]);
            zlabel(h(n), opt.ZLabel,'fontsize',opt.FontSize)
            set(h(n), 'CLim', opt.ZLim)
        else
            set(h(n), 'ColorOrder', opt.PlotStyles);
        end
        set(h(n), 'YLim', opt.YLim,'TickLength',opt.TickLength, 'LineWidth', opt.TickWidth);
    end
    ylabel(h(1), opt.YLabel,'fontsize',opt.FontSize/fig_scaler,'units','normalized');
    xlabh = xlabel(h(end), opt.XLabel,'fontsize',opt.FontSize/fig_scaler);
    if ~isempty(opt.AxesTitle)
        ath = title(h(end),opt.AxesTitle,'FontSize',opt.FontSize*opt.FontScaler);
        ath.Units = 'Normalized';
        if length(h) > 1
            % Center - keep in mind that label is relative to axes scale
            axes_length = h(1).Position(3)+h(2).Position(3);
            axes_mid = axes_length/2;
            
            axes_2_pos = axes_mid - h(1).Position(3);
            
            axes_2_pos_frac = axes_2_pos./h(2).Position(3);
            xLim = h(2).XLim;
            
            ath_pos = xLim(1) + axes_2_pos_frac*(xLim(2)-xLim(1));
            %center
            ath.Position(1) = ath_pos;
        end
    end
    if opt.ColorBar
        axesPos = get(h(end),'position');
        units = get(h(end),'units');
        colorbar(h(end),'off')
        ch = colorbar('peer',h(end),'eastoutside','units',units);
        ylabel(ch, opt.ZLabel,'fontsize',opt.FontSize);
        if opt.ColorBar && opt.IntegerIntensity
            YTickLabel = cellstr(get(ch, 'YTickLabel'));
            YTickLabel(cellfun(@length,YTickLabel)> 2) = {''};
            set(ch, 'YTickLabel',cellstr(YTickLabel));
        end
        set(ch, 'LineWidth', opt.TickWidth,'fontsize',opt.FontSize*opt.FontScaler);
        
        colorPos = get(ch, 'position');
        colorPos(3) = colorPos(3)/opt.colorShrink;
        
        if opt.ShrinkAxes
            axesPosNew =  axesPos(3) - colorPos(3)*1.5;
            if axesPosNew > 0
                axesPos(3) = axesPosNew;
            else
                axesPos(3) = axesPos(3) - 1.5*colorPos(3);
            end
            set(h(end),'position',axesPos);
            axesPos = get(h(end),'position');
        end
        colorPos(1) = axesPos(1) + axesPos(3) + 0.5*colorPos(3);
        set(ch,'position',colorPos);
    end
    %options if there are two plots
    if opt.TwoPlots %%
        set(h(2),'YTickLabel','',...
            'XLim', [opt.LinearBound, opt.XLim(2)], ...
            'xscale', 'log',...
            'XTickMode','manual');
        
        
        if opt.XLim(1) < -1*opt.LinearBound
            neg_lin_bound = -1*opt.LinearBound;
        else
            neg_lin_bound = opt.XLim(1);
        end
        set(h(1), 'XLim', [neg_lin_bound, opt.LinearBound], 'xscale', 'linear');
        pause(0.1)
        
        
        XTick = 10.^(-12:-1);
        XTick(XTick<=opt.LinearBound) = [];
        h(2).XTick = XTick;
        if h(end).XLim(end) < 10E-9
            XTickLabel_ps = XTick*1E12;
            h(2).XTickLabel = XTickLabel_ps;
            xlabh.String = 'Time (ps)';
            x_tick_scalar = 1E12;
        else
            XTickLabel = arrayfun(@(x) num2str(x,'%1.0E'),XTick,'UniformOutput',0);
            XTickLabel = strcat(strrep(XTickLabel,'1E-','10^{-'),'}');
            XTickLabel = strrep(XTickLabel,'-0','-');
            h(2).XTickLabel = XTickLabel;
            x_tick_scalar = 1;
        end
        pause(0.1)
        % Center - keep in mind that label is relative to axes scale
        axes_length = h(1).Position(3)+h(2).Position(3);
        axes_mid = axes_length/2;
        axes_2_pos = axes_mid - h(1).Position(3);
        axes_2_pos_frac = axes_2_pos./h(2).Position(3);
        xLim = log10(h(2).XLim);
        xLab_pos = xLim(1) + axes_2_pos_frac*(xLim(2)-xLim(1));
        xLab_pos = 10^(xLab_pos);
        xlabh.Position(1) = xLab_pos;
        
        h(1).XTickLabel{1} = '';
        linear_label = opt.LinearBound*x_tick_scalar;
        if linear_label >= 1
            linear_label = num2str(linear_label,0);
        else
            linear_label = num2str(linear_label,'%1.0E');
            linear_label = [strrep(linear_label,'E-','\times10^{-'),'}'];
            linear_label = strrep(linear_label,'1\times','');
            linear_label = strrep(linear_label,'-0','-');
        end
        h(1).XTickLabel{end} = linear_label;
        
        
    else
        % avoid warning about negative log scale
        set(h(1),'xscale', opt.OnePlotScale, 'XLim', opt.XLim)
    end
else
    for n = 1 : length(h)
        hold(h(n),'on')
        YLim = get(h(n),'YLim');
        if opt.YLim(1) > YLim(1), opt.YLim(1) = YLim(1); end
        if opt.YLim(2) < YLim(2), opt.YLim(2) = YLim(2); end
        if ~isempty(opt.PlotStyles)
            set(h(n), 'ColorOrder', opt.PlotStyles,'YLim',opt.YLim);
        end
    end
    if length(h) > 1
        % resets second label position
        xlabh = get(h(2),'XLabel');
        xlabh2 = get(h(1),'XLabel');
        xlabPos = get(xlabh,'Position');
        xlabPos2 = get(xlabh2,'Position');
        xlabPos2(2) = xlabPos(2);
        set(xlabh2,'Position', xlabPos2);
    end
end

% set label units
xlabh.Units = 'normalized';

%% Colors
% if opt.Hold
%     % gets current line handles
%     [ Line_h ] = axes_lines( h, 'skip', 0);
%    num_lines = size(Line_h,1);
%    %num_lines = floor(size(Line_h,1)/2);
% else
%     num_lines = 0;
% end



if opt.clear_marker
    opt.MarkerSize = opt.MarkerSize*0.8;
    opt.LineWidth = opt.LineWidth*0.5;
end

%% Plots either two or one plots
if opt.TwoPlots %linlog Plot
    opt.FlipX = 0;
    [~,lin_index_Minpos] = min(abs(-opt.LinearBound-xAxes));  %find indices of time range
    [~,lin_index_Maxpos] = min(abs(opt.LinearBound-xAxes));
    
    if lin_index_Minpos ~= 1
        lin_index_min = lin_index_Minpos - 1;
    else
        lin_index_min = lin_index_Minpos;
    end
    if lin_index_Maxpos ~= length(xAxes)
        lin_index_max = lin_index_Maxpos + 1;
    else
        lin_index_max = lin_index_Maxpos;
    end
    
    if plotSurf
        %linear plot
        s(1) = surf(h(1), xAxes((lin_index_min:lin_index_max+1),:),yAxes,data((lin_index_min:lin_index_max+1),:)');
        %log plot
        timeLog = xAxes((lin_index_Maxpos:end),:);
        s(2) = surf(h(2), timeLog , yAxes, data((lin_index_Maxpos:end),:)');
    else
        s = zeros(2,size(data,2));
        %Linear plot
        s_1 = plot(h(1), xAxes(lin_index_min:lin_index_max), data((lin_index_min:lin_index_max),:),...
            'linewidth', opt.LineWidth, 'markersize',opt.MarkerSize,'MarkerFaceColor','auto');
        %Log plot
        s_2 = plot(h(2),xAxes(lin_index_max-2:end), data((lin_index_max-2:end),:),...
            'linewidth', opt.LineWidth, 'markersize', opt.MarkerSize,'MarkerFaceColor',[0,0,0]);
        for n = 1 : length(s_1)
            if opt.clear_marker
                MarkerFaceColor = 'none';
                MarkerEdgeColor = opt.PlotStyles(n,:);
            else
                MarkerFaceColor = opt.PlotStyles(n,:);
                MarkerEdgeColor = 'none';
            end

            set(s_1(n),'Color',opt.PlotStyles(n,:),'MarkerFaceColor',MarkerFaceColor,...
                'MarkerEdgeColor',MarkerEdgeColor,'LineStyle',opt.LineStyle{n},'Marker',...
                opt.PointStyle{n},'DisplayName',opt.DisplayName{n});
            
            set(s_2(n),'Color',opt.PlotStyles(n,:),'MarkerFaceColor',MarkerFaceColor,...
                'MarkerEdgeColor',MarkerEdgeColor,'LineStyle',opt.LineStyle{n},'Marker',...
                opt.PointStyle{n},'DisplayName',opt.DisplayName{n});
        
        end
        if opt.RemoveLegend
            for j = 1 : size(s_1,1)
                s_1(j).Annotation.LegendInformation.IconDisplayStyle = 'off';
                s_2(j).Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
        end
    end
    
else %one plot
    if plotSurf
        s = surf(h(end), xAxes, yAxes, data');
    else
        s = plot(h(end), xAxes, data,...
            'linewidth', opt.LineWidth, 'markersize', opt.MarkerSize);
        for n = 1 : length(s)
            if opt.clear_marker
                MarkerFaceColor = 'none';
                MarkerEdgeColor = opt.PlotStyles(n,:);
            else
                MarkerFaceColor = opt.PlotStyles(n,:);
                MarkerEdgeColor = 'none';
            end
            
            set(s(n),'Color',opt.PlotStyles(n,:),'MarkerFaceColor',MarkerFaceColor,...
                'MarkerEdgeColor',MarkerEdgeColor,'LineStyle',opt.LineStyle{n},'Marker',...
                opt.PointStyle{n},'DisplayName',opt.DisplayName{n});
        
        end
        if opt.RemoveLegend
            annotation = get(s, 'Annotation');
            if length (annotation) > 1
                for n = 1 : length(annotation)
                    set(get(annotation{n}, 'LegendInformation'), 'IconDisplayStyle', 'off')
                end
            else
                set(get(annotation, 'LegendInformation'), 'IconDisplayStyle', 'off')
            end
        end
    end
end
if opt.JetBar
    f_JetBar('allAxes', h,'cMin',opt.ZLim(1),'cMax',opt.ZLim(2),'type',opt.JetType,'equalBlueRed',opt.JetSymmetric);
else
    for n = 1 : length(h)
        colormap(h(n),'Jet')
    end
end

%% turns off axees hold, and plotZero line if needed
for n = 1 : length(h)
    shading(h(n),char(opt.ShadingType));
    set(h(n), 'Layer','top')
    
    if opt.FlipX, set(h(n),'xdir','reverse'); end
    
    if opt.IntegerIntensity
        if plotSurf
            
        else
            YTickLabel = cellstr(get(h(n), 'YTickLabel'));
            YTickLabel(cellfun(@length,YTickLabel)> 2) = {''};
            %if sum(~cellfun(@isempty, YTickLabel)) > 3
            set(h(n), 'YTickLabel',cellstr(YTickLabel));
            %end
        end
    end
    
    if ~isempty(opt.RemoveXLabel)
        XTick = get(h(n),'XTick');
        XTick(opt.RemoveXLabel) = [];
        set(h(n),'XTick',XTick)
    end
    
    if opt.PlotZero
        xLimits = get(h(n), 'Xlim');
        yLimits = get(h(n), 'Ylim');
        zLimits = get(h(n), 'Zlim');
        minZ = min(zLimits);
        maxZ = max(zLimits);
        zh = plot3(h(n),xLimits,[0,0], [maxZ,maxZ],'color', opt.ZeroColor, 'linewidth', opt.TickWidth);
        uistack(zh,'top')
        set(get(get(zh, 'Annotation'), 'LegendInformation'), ...
            'IconDisplayStyle', 'off')
        zh = plot3(h(n),xLimits,[0,0], [minZ,minZ],'color', opt.ZeroColor, 'linewidth', opt.TickWidth);
        uistack(zh,'top')
        set(get(get(zh, 'Annotation'), 'LegendInformation'), ...
            'IconDisplayStyle', 'off')
        zh = plot3(h(n),[0,0],yLimits,[maxZ,maxZ],'color', opt.ZeroColor, 'linewidth', opt.TickWidth);
        uistack(zh,'top')
        set(get(get(zh, 'Annotation'), 'LegendInformation'), ...
            'IconDisplayStyle', 'off')
        zh = plot3(h(n),[0,0],yLimits,[minZ,minZ],'color', opt.ZeroColor, 'linewidth', opt.TickWidth);
        uistack(zh,'top')
        set(get(get(zh, 'Annotation'), 'LegendInformation'), ...
            'IconDisplayStyle', 'off')
    end
    
    
    if opt.RemoveXTick, set(h(n), 'XTickLabel',''); end
    if opt.RemoveYTick, set(h(n), 'YTickLabel',''); end
    
    hold(h(n),'off')
end

%% options for yLabes (i.e if in eV but want wavelength)
if opt.RelabelY
    numTick = length(get(h(1), 'YTick'));
    if numTick < 6, numTick = 6; end
    waveStart = [1240/yAxes(1),1024/yAxes(end)];
    waveEnd = max(waveStart);
    waveStart = min(waveStart);
    waveRange = waveEnd - waveStart;
    waveSpacing = waveRange/numTick-1;
    waveSpacing = round(waveSpacing/50)*50;
    waveStart2 = ceil(waveStart/50)*50;
    waveValues = waveSpacing*[0:numTick] + waveStart2;
    waveValues = fliplr(waveValues);
    
    eVValues = 1240./waveValues;
    waveValues = char(arrayfun(@num2str,waveValues,'UniformOutput',0));
    for n = 1:length(h)
        set(h(n), 'YTick',eVValues);
    end
    set(h(1), 'YTickLabel',waveValues);
end
%% options for xLabes (i.e if in eV but want wavelength)
if opt.RelabelX || opt.DualX
    numTick = length(get(h(1), 'XTick'));
    if numTick < 6, numTick = 6; end
    waveStart = [1240/xAxes(1),1024/xAxes(end)];
    waveEnd = max(waveStart);
    waveStart = min(waveStart);
    waveRange = waveEnd - waveStart;
    
    waveSpacing = waveRange/(numTick + 5);
    waveSpacing = round(waveSpacing/50)*50;
    waveStart2 = ceil(waveStart/50)*50;
    waveValues = waveSpacing*[0:(numTick+10)] + waveStart2;
    waveValues = fliplr(waveValues);
    
    eVValues = 1240./waveValues;
    waveValues = arrayfun(@num2str,waveValues,'UniformOutput',0);
    
    if any(strcmpi(waveValues,'900'))
       waveValues( ismember(waveValues,{'950','1000'})) = {''};
    end
    if any(strcmpi(waveValues,'1000'))
       waveValues( ismember(waveValues,{'1050','1100','1150'})) = {''};
    end
    if any(strcmpi(waveValues,'1100'))
       waveValues( ismember(waveValues,{'1150','1200','1250'})) = {''};
    end
    if any(strcmpi(waveValues,'1300'))
       waveValues( ismember(waveValues,{'1350','1400','1450','1500'})) = {''};
    end
    if any(strcmpi(waveValues,'1400'))
       waveValues( ismember(waveValues,{'1450','1500','1550','1600'})) = {''};
    end
    
    
    waveValues = char(waveValues);
    for n = 1:length(h)
        if opt.DualX
            h_new(n) = axes('Position',h(n).Position);
            pause(0.1)
            all_option = {
                'FontWeight'
                'XLim'
                'YLim'
                'ZLim'
                'XDir'
                'YDir'
                'ZDir'
                'TickLength'
                'LineWidth'
                'XTick'
                'YTick'
                'ZTick'
                'FontSize'
                };
            
            for j = 1 : length(all_option)
                h_new(n).(all_option{j}) = h(n).(all_option{j});
            end
            
            h_new(n).YLabel = [];
            h_new(n).YTickLabel = [];
            h_new(n).XAxisLocation = 'top';
            h_new(n).YAxisLocation = 'right';
            h_new(n).Color = 'none';
            
            
            h(n).Box = 'off';
            h_new(n).Units = 'Pixels';
            
            h(n).Units = 'Pixels';
        else
            h_new(n) = h(n);
        end
        
        set(h_new(n), 'XTick',flipud(eVValues));
        set(h_new(n), 'XTickLabel',waveValues);
    end
    if opt.DualX
        %fh.Position(4) = fh.Position(4)*1.15;
        xlabel(h_new(end), 'Wavelength (nm)','fontsize',opt.FontSize/fig_scaler,'units','normalized');
        
        pause(0.1)
        for n = 1 : length(h)
            h_new(n).Units = 'normalized';
            h(n).Units = 'normalized';
        end
        
    end
    set(h(1), 'XTickLabel',waveValues);
end

%% Plots new set of axis for tick labels
if opt.OverlayAxis
    tickH = zeros(size(h,1),1);
    for n = 1 : length(h)
        grid(h(n), 'off');
        box(h(n), 'on');
        axesPos = get(h(n),'position');
        tickH(n) = axes('position',axesPos,'fontsize',3,'parent',fh);
        view(tickH(n), [opt.V1, opt.V2]);
        
        grid(tickH(n), 'on');
        box(tickH(n), 'on');
        
        xLimits = get(h(n), 'Xlim');
        yLimits = get(h(n), 'Ylim');
        zLimits = get(h(n), 'Zlim');
        
        xTick = get(h(n), 'XTick');
        yTick = get(h(n), 'YTick');
        
        set(tickH(n), 'XLim', xLimits, 'YLim', yLimits, 'ZLim', zLimits, 'YTickLabel', '', 'XTickLabel', '', 'color', 'none', 'TickLength', opt.TickLength,'XTick',xTick,'YTick',yTick);
    end
    
    if opt.TwoPlots
        set(tickH(end), 'XScale', 'log');
    else
        set(tickH(end), 'XScale', opt.OnePlotScale);
    end
end

%% Adds Legend
if ~iscell(opt.Legend) && length(opt.Legend) > 1
    legHand = legend(h(end),'location', opt.LegendLocation);
    set(legHand,'Interpreter','tex')
    pause(0.000001)
elseif iscell(opt.Legend)
    legHand = legend(h(end),opt.Legend,'location', opt.LegendLocation);
    set(legHand,'Interpreter','tex')
    pause(0.000001)
else
    legHand = [];
end

%% add patch

if ~isempty(opt.patch)
    
    if size(opt.patch,1) > size(opt.patch_color,1)
        opt.patch_color = repmat(opt.patch_color,ceil(size(opt.patch,1)/size(opt.patch_color,1)),1);
    end
    
    axes_temp = h;
    
    for m = 1 : length(axes_temp)
        axes(axes_temp(m));
        lim = axes_temp(m).YLim;
        lim_x = axes_temp(m).XLim;
        for k = 1 : size(opt.patch,1)
            if opt.patch(k,1)<lim_x(2) || opt.patch(k,1)>lim_x(1)
                patch_h = patch([opt.patch(k,:),fliplr(opt.patch(k,:))]',[lim(1),lim(1),lim(2),lim(2)]',...
                    opt.patch_color(k,:),'LineStyle','none');
            end
        end
    end
    
    % moves pathc to back
    for m = 1 : length(axes_temp)
        ax_child = axes_temp(m).Children;
        ax_child_type = get(ax_child,'Type');
        
        i = strcmp(ax_child_type,'patch');
        
        [i_n,order] = sort(i);
        axes_temp(m).Children = axes_temp(m).Children(order);
    end
end

%% Update log_scale (do this last)
if opt.log_scale && plotSurf
    ch_ticks = ch.Ticks;
    ch_ticks = arrayfun(@(x) num2str(x,2),ch_ticks,'uniformoutput',0);
    ch_ticks = strcat('10^{',ch_ticks,'}');
    ch.TickLabels = ch_ticks;
end

%% Updates Figure data
%fig_data.Hold = 1;
%guidata(fh, fig_data);

opt_plot = opt;
