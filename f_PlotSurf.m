function [h, s] = f_PlotSurf( data, time, wave, axesName, varargin)
%f_PlotSurf Plots LinearLog or Linear plot depending on time covered
%   takes data and plots a surface on a linear (-1 to 1 1 ps) and log the
%   rest. If there is not an order of magnatude time points then only a
%   linear plot will be made

%% Check input varibales
if ~exist('data','var'), data = random('norm',2,160,[160,251]); end
if ~exist('time','var'), time =(exp(linspace(0, 10, size(data,1)))-2).*1E-12; end
if ~exist('wave','var'), wave = linspace(1, size(data,2), size(data,2)); end
if ~exist('axesName','var'), axesName = 100000000;end

% reshapes data, time, wave array.
if size(wave,1) ~= length(wave), wave = wave'; end
if size(time,1) ~= length(time), time = time'; end
if size(time,1) ~= size(data,1), data = data'; end

%% Sets Options
% default options
opt.title = [];
opt.axesTitle = [];
%opt.yTopOffset = 20;
opt.ZLabel = '\DeltaT/T'; %Color bar label
opt.XLabel = 'Time (s)';


opt.ZLim = [min(min(data)), max(max(data))]; %Color bar limits
opt.YLim = [min(wave) max(wave)];

opt.hold = 0;
opt.plotZero = 1;
opt.overlayAxis = 1;
opt.figPos = [];

opt.ZeroColor = [0 0 0];
opt.TickLength = [0.02, 0.02];
opt.TickWidth = 0.5;

opt.onePlotScale = 'log';

opt.v1 = 0;
opt.v2 = 270; %set this to 90 to flip wavelength

opt.downSample = 0;

opt.shadingType = 'interp';

opt.twoPlots = 1;
opt.colorbar = 1;
opt.JetBar = 1;
opt.removeXTick = 0;

opt.fontSize = 20;
opt.tickScaler = 0.7;

opt.relabelY = 0;


%% Logically Determins Options
[~,zeroIndex] = min(abs(time));
if time(zeroIndex+2)-time(zeroIndex+1) > 200E-15 %checks the minimum spacing between time points is greater than 200 fs
    opt.tlin = 1E-9;
else
    opt.tlin = 1E-12;
end

%Sets x-axis label
if abs(wave(1) - wave(end)) < 10 && ~opt.relabelY
    opt.YLabel = 'Energy (eV)';
    %opt.relabelY = 1;
elseif wave(1) == 0
    opt.YLabel = 'Pixel';
else
    opt.YLabel = 'Wavelength (nm)';
end


% determine if linear plot is needed and set x-axis to linear or log
[~,timeMinIndex] = min(abs(time));

if log10( (time(end))/(time(timeMinIndex+1)-time(timeMinIndex)) ) < 2.5
    opt.twoPlots = 0;
    opt.onePlotScale = 'linear';
elseif time(1) > 0
    opt.twoPlots = 0;
    opt.onePlotScale = 'log';
end




opt.tlinLabel = [];
opt.linLogFraction = [];

%% user input
[opt] = f_OptSet(opt, varargin);

%% Defaults after if not set by user
% linLog linear axis label
if ~any(strcmp(varargin,{'tlinLabel'}))
    prefix = num2strEng(opt.tlin);
    opt.tlinLabel = ['Time (',prefix(end),'s)'];
end

% fraction linear part of linlog axis
if ~any(strcmp(varargin,{'linLogFraction'}))
    if opt.tlin == 1E-12 && time(end) > 1E-6;
        opt.linLogFraction = 0.15;
    else
        opt.linLogFraction = 0.2;
    end
end

%% Checks Variables
%if iscell(opt.title), opt.title = opt.title{1}; end

if opt.YLim(1) == opt.YLim(2), opt.YLim = [opt.YLim(1)*0.8, opt.YLim(1)*1.2]; end
if opt.ZLim(1) == opt.ZLim(2), opt.ZLim = [opt.ZLim(1)*0.8, opt.ZLim(1)*1.2]; end
if sum(opt.YLim) == 0 , opt.YLim= [-1,1]; end
if sum(opt.ZLim) == 0 , opt.ZLim = [-1,1]; end

opt.YLim = sort(opt.YLim);
opt.ZLim = sort(opt.ZLim);

if isempty(opt.XLabel), opt.tlinLabel = []; end

%% Rescale data and append label

SI_Scalar = round(log10(max(abs(opt.ZLim))));
if abs(SI_Scalar) > 1
    data = data/10^(SI_Scalar);
    opt.ZLim = opt.ZLim/10^(SI_Scalar);
    opt.ZLabel = [opt.ZLabel, '(\times10^{',num2str(SI_Scalar),'})'];
end

%% downsamples data points used in surface (reduce data set for latex
if opt.downSample
    %timeI =  interp1q( linspace(1,length(time),length(time))' , time , linspace(1,length(time),length(time)*interpFactor+1)');
    waveI =  interp1q( linspace(1,length(wave),length(wave))' , wave , linspace(1,length(wave),length(wave)*opt.downSample+1)');
    
    %dataI = interp1q(time, data, timeI);
    dataI = interp1q(wave, data', waveI);
    dataI = dataI';
    
    data = dataI;
    %time = timeI;
    wave = waveI;
end

%% Sets up axes for plotting

if ~isempty(opt.title)
    opt.title = strrep(opt.title, '_', ' ');
end

if ~ishandle(axesName(end)) || ~strcmp('axes', get(axesName(end),'type')) %if given figure or invalid handle
    if opt.twoPlots
        h  = f_MultiLinLogAxes( 1, axesName(1), 'rowStyles', {'LinLog'}, 'title', opt.title, 'figTitle',  opt.title, 'fontSize',opt.fontSize*opt.tickScaler, 'linLogFraction',opt.linLogFraction, 'figPos', opt.figPos);
    else
        h  = f_MultiLinLogAxes( 1, axesName(1), 'rowStyles', {'Linear'}, 'title', opt.title, 'figTitle', opt.title, 'fontSize',opt.fontSize*opt.tickScaler, 'figPos', opt.figPos);
    end
else % loads the axes handles into variables
    if opt.twoPlots && length(axesName) < 2
        opt.twoPlots = 0;
    end
    h = axesName;
end

%% Sets Generic Axes properties
if ~opt.hold
    %options for each axis
    for n = 1 : length(h)
        %cla(h(n),'reset')
        hold(h(n),'on')
        box(h(n), 'on');
        view(h(n), [opt.v1, opt.v2]);
        set(h(n), 'CLim', opt.ZLim, 'ZLim', opt.ZLim, 'YLim', opt.YLim,...
            'TickLength',opt.TickLength, 'LineWidth', opt.TickWidth);
        zlabel(h(n), opt.ZLabel,'fontsize',opt.fontSize)
    end
    
    ylabel(h(1), opt.YLabel,'fontsize',opt.fontSize)
    xlabh = xlabel(h(end), opt.XLabel,'fontsize',opt.fontSize);
    if ~isempty(opt.axesTitle), title(h(end),opt.axesTitle); end
    if opt.colorbar
        axesPos = get(h(end),'position');
        ch = colorbar('eastoutside');
        %ch = colorbar('peer', h(end)); % adds color bar to end axes - DOES
        %NOT WORK IN 2014?
        ylabel(ch, opt.ZLabel,'fontsize',opt.fontSize);
        set(ch, 'LineWidth', opt.TickWidth,'fontsize',opt.fontSize*opt.tickScaler);
        colorPos = get(ch, 'position');
        colorPos(3) = colorPos(3)/2;
        colorPos(1) = colorPos(1) + colorPos(3);
        set(ch,'position',colorPos);
        axesPosNew =  colorPos(1) - axesPos(1)- colorPos(3)/2;
        if axesPosNew > 0
            axesPos(3) = axesPosNew;
        else
            axesPos(3) = axesPos(3) - 1.5*colorPos(3);
        end
        set(h(end),'position',axesPos);
    end
    %options if there are two plots
    if opt.twoPlots %%
        set(h(2),'YTickLabel','',...
            'XLim', [opt.tlin, max(time)], ...
            'xscale', 'log',...
            'XTickMode','manual',...
            'XTick',10.^(-12:-1));
        set(h(1), 'XLim', [-1*opt.tlin, opt.tlin], 'xscale', 'linear','XTick',-1*opt.tlin:opt.tlin/2:opt.tlin);
        XTicks = get(h(1), 'XTick');
        logbase=3*floor(log10(opt.tlin)/3);
        XTicks = XTicks/(10^logbase);
        XTickLabel = [arrayfun(@(X) num2str(X,3),XTicks(1:end-2),'UniformOutput',0),{''},{''}];
        XTickLabel{2} = '';
        set(h(1), 'XTickLabel', XTickLabel);
        pause(0.00000000001)
        xlabh2 = xlabel(h(1), opt.tlinLabel,'fontsize',opt.fontSize);
        xlabPos = get(xlabh,'Position');
        xlabPos2 = get(xlabh2,'Position');
        xlabPos2(2) = xlabPos(2);
        set(xlabh2,'Position', xlabPos2);
    else
        set(h(end), 'XLim', [min(time), max(time)], ...
            'xscale', opt.onePlotScale);
    end
else
    for n = 1 : length(h)
        hold(h(n),'on')
    end
end

%% Plots either two or one plots
if opt.twoPlots
    [~,lin_index_Minpos] = min(abs(-opt.tlin-time));  %find indices of time range
    [~,lin_index_Maxpos] = min(abs(opt.tlin-time));
    
    if lin_index_Minpos ~= 1
        lin_index_min = lin_index_Minpos - 1;
    else
        lin_index_min = lin_index_Minpos;
    end
    if lin_index_Maxpos ~= length(time)
        lin_index_max = lin_index_Maxpos + 1;
    else
        lin_index_max = lin_index_Maxpos;
    end
    
    %% linear plot
    s(1) = surf(h(1), time((lin_index_min:lin_index_max+1),:),wave,data((lin_index_min:lin_index_max+1),:)');
    %contour3(h(1), time((lin_index_min:lin_index_max+1),:)/(opt.tlin),wave,data((lin_index_min:lin_index_max+1),:)','k')
    %% log plot
    timeLog = time((lin_index_Maxpos:end),:);
    s(2) = surf(h(2), timeLog , wave, data((lin_index_Maxpos:end),:)');
    %contour3(h(2), timeLog , wave, data((lin_index_Maxpos-1:end),:)','k');
else %% one plot
    s(1) = surf(h(end), time, wave, data');
end

%% turns off axees hold, and plotZero line if needed
%NumTicks = 8;

for n = 1 : length(h)
    shading(h(n),char(opt.shadingType));
    set(h(n), 'Layer','top')
    if opt.removeXTick, set(h(n), 'XTickLabel',''); end
    if opt.plotZero
        xLimits = get(h(n), 'Xlim');
        yLimits = get(h(n), 'Ylim');
        zLimits = get(h(n), 'Zlim');
        minZ = min(zLimits);
        zh = plot3(h(n),xLimits,[0,0], [minZ,minZ],'color', opt.ZeroColor, 'linewidth', opt.TickWidth);
        uistack(zh,'top')
        set(get(get(zh, 'Annotation'), 'LegendInformation'), ...
            'IconDisplayStyle', 'off')
        zh = plot3(h(n),[0,0],yLimits,[minZ,minZ],'color', opt.ZeroColor, 'linewidth', opt.TickWidth);
        uistack(zh,'top')
        set(get(get(zh, 'Annotation'), 'LegendInformation'), ...
            'IconDisplayStyle', 'off')
        %set(h(n), 'YTick', linspace(yLimits(1),yLimits(2),NumTicks))
    end
    hold(h(n),'off')
end

%set(h(1), 'YTickLabel', round(10*linspace(yLimits(1),yLimits(2),NumTicks))/10);
if opt.JetBar
    f_JetBar('allAxes', h);
else
    for n = 1 : length(h)
        colormap(h(n),'Jet')
    end
end


%% options for yLabes (i.e if in eV but want wavelength)
    if opt.relabelY
        numTick = length(get(h(1), 'YTick')); 
        if numTick < 6, numTick = 6; end
        waveStart = [1240/wave(1),1024/wave(end)];
        waveEnd = max(waveStart);
        waveStart = min(waveStart);
        waveRange = waveEnd - waveStart;
        waveSpacing = waveRange/numTick-1;
        waveSpacing = round(waveSpacing/50)*50;
        waveStart2 = ceil(waveStart/50)*50;
        waveValues = waveSpacing*[0:numTick] + waveStart2;
%         if waveValues(1) > waveStart + waveSpacing*0.25
%             addValue = ceil(waveStart/10)*10;
%             waveValues = [addValue,waveValues];
%         end
        waveValues = fliplr(waveValues);
        
        
        eVValues = 1240./waveValues;
        waveValues = char(arrayfun(@num2str,waveValues,'UniformOutput',0));
        for n = 1:length(h)
            set(h(n), 'YTick',eVValues);
        end
        set(h(1), 'YTickLabel',waveValues);
    end
%% Plots new set of axis for tick labels
if opt.overlayAxis
    tickH = zeros(size(h,1),1);
    for n = 1 : length(h)
        axesPos = get(h(n),'position');
        tickH(n) = axes('position',axesPos,'fontsize',3);
        view(tickH(n), [opt.v1, opt.v2]);
        
        grid(tickH(n), 'on');
        box(tickH(n), 'on');
        
        xLimits = get(h(n), 'Xlim');
        yLimits = get(h(n), 'Ylim');
        zLimits = get(h(n), 'Zlim');
        
        xTick = get(h(n), 'XTick'); 
        yTick = get(h(n), 'YTick');
        
        set(tickH(n), 'XLim', xLimits, 'YLim', yLimits, 'ZLim', zLimits, 'YTickLabel', '', 'XTickLabel', '', 'color', 'none', 'TickLength', opt.TickLength,'XTick',xTick,'YTick',yTick);
    end
    
    if opt.twoPlots
        set(tickH(end), 'XScale', 'log');
    else
        set(tickH(end), 'XScale', opt.onePlotScale);
    end
end



