function [ h, fh, positions,titleH,fontSize,tbh] = f_MultiLinLogAxes( numColumns, figH, varargin)
%f_MultiLinLogAxes
%|-------------------------------------------------------
%|Title                                                 |
%|yTopOffset                                            |
%|   |-----------------------|-----------------------   |
%|x  |x  |                  ||x  |                  | x |
%|L  |P  |     Axis1        ||P  |     Axis2        | R |
%|e  |A  |                  ||A  |                  | i |
%|f  |D  |                  ||D  |                  | g |
%|t  |   -------------------||   -------------------| h |
%|O  |YPAD                  ||YPAD                  | O |
%|f  -----------------------|-----------------------| f |
%|f  |-----------------------|----------------------- f |
%|s  |x  |                  ||x  |                  | s |
%|e  |P  |     Axis3        ||P  |     Axis4        | e |
%|t  |A  |                  ||A  |                  | t |
%|   |D  |                  ||D  |                  |   |
%|   |   -------------------||   -------------------|   |
%|   |YPAD                  ||YPAD                  |   |
%|   -----------------------|-----------------------|   |
%|yBottomOffset                                         |
%--------------------------------------------------------

opt.xPadding = 90; %px
opt.xLeftOffset = 0; %px
opt.xRightOffset = 20; %px

opt.yPadding = 100; %px
opt.yTopOffset = 50; %px
opt.yBottomOffset = 0; %px

opt.rowStyles = {'Linear'};
opt.title = [];
opt.figTitle = [];

opt.linLogFraction = 0.2;

opt.axes_head = [];

opt.figPos = [];
opt.figScaler = 1;

opt.fontSize = 16;
opt.titleSize = 20;
opt.numberTitle = 'on';

opt.numAxes = 0;
    
opt.figureSize = 'fixed_axes';
opt.axesRatio = 1.618;
opt.axesHeight = 370;
opt.axesWidth = [];
opt.axesNumTxt = [{'A'},'B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
% never again will there be no labels for axis (aslong as there is less than 104 axis)
opt.axesNumTxt = [opt.axesNumTxt, strcat('A',opt.axesNumTxt),strcat('B',opt.axesNumTxt),strcat('C',opt.axesNumTxt)];
opt.axesNumTxtAppend = [];
opt.axesNumTxtPre = [];
opt.LeftLabel = [];
opt.LeftLabelOffset = 12;
opt.numAxesfontSize = 0;
opt.numAxesYoffset = 0;
opt.numAxesXoffset = 0;

opt.external_labels = 0;

opt.xfigShift = 0;
opt.xfigIncrease = 0;

opt.defaultMonitor = 2;
opt.maxAxes = inf;

opt.lowerNumAxes = 1;

opt.LineWidth = 1.5;
%%%%% User options set
[opt] = f_OptSet(opt, varargin);
if ~any(strcmp('titleSize',opt))
    opt.titleSize = opt.fontSize*1.25;
end

titleH = [];

if ~strcmp(varargin,'numAxes')
    if numColumns > 1 || length(opt.rowStyles) > 1
        opt.numAxes = 1;
    else
        opt.numAxes = 0;
    end
end

%% Checking options
if iscell(opt.figTitle), opt.figTitle = opt.figTitle{1}; end
if opt.numAxesfontSize == 0
    opt.numAxesfontSize = opt.fontSize;
end
% rowStyles is n by (numColumns)
if size(opt.rowStyles,2) ~= numColumns && size(opt.rowStyles,2) > 1, opt.rowStyles = opt.rowStyles'; end
if size(opt.rowStyles,2) ~= numColumns
    opt.rowStyles = repmat(opt.rowStyles,1,numColumns);
end
numRows = size(opt.rowStyles,1);
% adds in escape characters for title
if ~isempty(opt.figTitle)
    %opt.figTitle = regexprep(opt.title,'\_(?!{)','\\_'); % repace '_' not followed by '{' with '\-'
    opt.figTitle = regexprep(opt.figTitle,'\\..{','');
    opt.figTitle = regexprep(opt.figTitle,'(?<!\\)}','');
end

%% Lower case axes number text
if opt.lowerNumAxes
    opt.axesNumTxt = lower(opt.axesNumTxt);
    opt.axesNumTxt = strcat(opt.axesNumTxt,'.');
end
%% append additional axes number text
if ~isempty(opt.axesNumTxtAppend) && ~opt.external_labels
    if size(opt.axesNumTxtAppend,1) > 1 opt.axesNumTxtAppend = opt.axesNumTxtAppend'; end
    opt.axesNumTxt(1:length(opt.axesNumTxtAppend)) =...
        strcat(opt.axesNumTxt(1:length(opt.axesNumTxtAppend)),{' '},opt.axesNumTxtAppend);
end
opt.axesNumTxt = [opt.axesNumTxtPre,opt.axesNumTxt];

%% Select/make figure
fh = figure(figH(1));
fh.Units = 'pixel';
clf(fh);
pause(100/1000);

% Get screen size
screen_size = get(0, 'MonitorPositions');
if opt.defaultMonitor > size(screen_size,1), opt.defaultMonitor = size(screen_size,1); end
% pick largest monios
pixels = screen_size(:,3).*screen_size(:,4);
if length(pixels) > 1
    [max_value, max_i] = max(pixels);
    max_i = find(max_i);
    if pixels(opt.defaultMonitor) ~= max_value
        opt.defaultMonitor = max_i(1);
    end
end
screen_size = screen_size(opt.defaultMonitor,:);
% Set title
if ~isempty(opt.figTitle), set(fh,'name', opt.figTitle, 'NumberTitle', opt.numberTitle); end

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start by working with units as pixels %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Makes space for figure title about axis
if ~isempty(opt.title)
    opt.title = regexprep(opt.title,'\_(?!{)','\\_'); %removes extra character (?!x) is a negative look ahead for x
    titleH = annotation(fh,'textbox',[0 0.955 1 0.04],'LineStyle','none','HorizontalAlignment', 'center', 'VerticalAlignment', 'top','FontSize', opt.titleSize,...
        'String', opt.title, 'FitBoxToText', 'on','Units','Pixel');
    pause(1/1000) % needs to draw title to find height
    opt.yTopOffset(end) = opt.yTopOffset(end) + titleH.Position(4);
end

%% Creates padding vectors
xPaddingNew = ones(numColumns+1,1).*opt.xPadding(end);
xPaddingNew(1:length(opt.xPadding)) = opt.xPadding;
xPaddingNew(1) = xPaddingNew(1) + opt.xLeftOffset;
xPaddingNew(end) = opt.xRightOffset;
opt.xPadding = xPaddingNew;

yPaddingNew = ones(size(opt.rowStyles,1)+1,1).*opt.yPadding(end);
yPaddingNew(1:length(opt.yPadding)) = opt.yPadding;

yPaddingNew(1) = yPaddingNew(1) + opt.yBottomOffset;
yPaddingNew(end) = opt.yTopOffset;

opt.yPadding = yPaddingNew;


opt = rmfield(opt,'xLeftOffset');
opt = rmfield(opt,'xRightOffset');
opt = rmfield(opt,'yTopOffset');
opt = rmfield(opt,'yBottomOffset');

%% checks for half size axes
correct = false(numRows,numColumns);
for j = 1 : numRows
    for n = 1 : numColumns
        if ~isempty(regexpi(opt.rowStyles{j,n},'half'))
            correct(j,n) = true;
            temp = regexpi(opt.rowStyles{j,n},'half','split');
            temp(cellfun(@isempty,temp)) = [];
            opt.rowStyles(j,n) = temp;
        end
    end
end

%% Sets fig position property
if ~any(strcmpi(varargin,'figPos'))
    if ~isempty(regexpi(opt.figureSize,'fill','once'))
        buffer =  fh.OuterPosition - fh.Position;
        edges = [-buffer(1), buffer(4)];
        opt.figPos = screen_size + [edges(1),edges(1),-edges(1)*2,-edges(2)];
        opt.figPos = screen_size - [-5,-50,buffer(3:end)+buffer(1:2)+[10,140]];
        if ~isempty(regexpi(opt.figureSize,'left','once'))
            opt.figPos(3) = opt.figPos(3)/2;
        elseif ~isempty(regexpi(opt.figureSize,'right','once'))
            opt.figPos(3) = opt.figPos(3)/2;
            opt.figPos(1) = opt.figPos(1) + opt.figPos(3);
        end
        
    elseif ~isempty(regexpi(opt.figureSize,'keep','once'))
        opt.figPos = get(fh,'position');
    else
        opt.axesWidth = opt.axesHeight*opt.axesRatio;
        
        opt.figPos(3) = opt.axesWidth*numColumns + sum(opt.xPadding);
        opt.figPos(4) = opt.axesHeight*(size(opt.rowStyles,1)-0.5*sum(all(correct,2))) + sum(opt.yPadding);
    end
end

%% Check if figure is bigger than screen
scaler = 1;
if opt.figPos(3) > screen_size(3)
    scaler = scaler*((screen_size(3)-30)/opt.figPos(3));
end
if opt.figPos(4) > screen_size(4)
    scaler = scaler*((screen_size(4)-100)/opt.figPos(4));
end

% Make it so 150 dpi is integer scaler
s = floor(150./scaler);
scaler = 150/s;
%out_str = arrayfun(@(x) num2str(round(x,0)), opt.figPos, 'UniformOutput', 0);
opt.figPos = round(opt.figPos*scaler);
%out_str = [out_str; arrayfun(@(x) num2str(round(x,0)), opt.figPos, 'UniformOutput', 0)]
%scaler

% resize title
if exist('titleH','var') && ~isempty(titleH)
    titleH.FontSize = titleH.FontSize.*scaler;
end
% apply scaler to other properties
opt.fontSize = opt.fontSize*scaler;
opt.titleSize = opt.titleSize*scaler;
opt.numAxesfontSize = opt.numAxesfontSize*scaler;
opt.xPadding = opt.xPadding.*scaler;
opt.yPadding = opt.yPadding.*scaler;
% adds to figure data (propergate through other functions)
fh.UserData.scaler = scaler;

%% Centers on screen
if any(strcmpi(varargin,'figPos')) || any(strcmpi(varargin,'figureSize'))
    
else
    opt.figPos(1) = screen_size(1)+0.5*screen_size(3) - opt.figPos(3)/2;
    opt.figPos(2) = screen_size(2)+0.5*screen_size(4) - (opt.figPos(4)+50)/2;
    opt.figPos(1) = opt.figPos(1) - opt.xfigShift;
    opt.figPos(3) = opt.figPos(3) + opt.xfigIncrease;
end

set(fh,'color','w', 'units', 'Pixels', 'position', opt.figPos,...
    'PaperUnits','points','PaperPosition',[0,0,opt.figPos(3),opt.figPos(4)],'PaperPositionMode','auto');
pause(100/1000)
% Fixes title position
if ~isempty(opt.title)
    titleH.Position(2) = fh.Position(4) - titleH.Position(4) + 5;
    titleH.Position(1) = 0;
    titleH.Position(3) = fh.Position(3);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% From this point everything is in relative size %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fh, 'units', 'normalized');
if ~isempty(opt.title), set(titleH, 'units', 'normalized'); end
pause(100/1000)
% Checks padding is normalized
if sum(opt.xPadding) >= 1, opt.xPadding = opt.xPadding/opt.figPos(3); end
if sum(opt.yPadding) >= 1, opt.yPadding = opt.yPadding/opt.figPos(4); end

%% Calculates Variables
width = (1-sum(opt.xPadding))/numColumns;
widthLin = width*opt.linLogFraction;
widthLog = width*(1-opt.linLogFraction);
height = (1 - sum(opt.yPadding))/(numRows-0.5*sum(all(correct,2)));

numAxes = sum(sum(strcmp(opt.rowStyles,'Linear')) + sum(strcmp(opt.rowStyles,'LinLog'))*2 + sum(strcmp(opt.rowStyles,'Residual'))*2);
positions = zeros(size(numAxes,1),4);
%% Axes head
axes_head = zeros(numRows,numColumns);
axes_head(1:size(opt.axes_head,1),1:size(opt.axes_head,2)) = opt.axes_head;

%%
axes_options = {
    'fontsize'
    opt.fontSize
    'LineWidth'
    opt.LineWidth
    };


%% Creates Plots
axisPlotted = 0;
half_correction = 0;
axisPlot_type = [];
y = 1 - opt.yPadding(end);
for j = 1 : numRows
    %y = 1  - height*j - sum(opt.yPadding(end-j+1:end)) + half_correction;
    for n = 1 : numColumns
        height_temp = height - axes_head(j,n);
        %disp(['y=',num2str(y_temp),' height=',num2str(height_temp)])
        if correct(j,n)
            y_temp = y - height*0.5;
            height_temp = height_temp - height*0.5;
        else
            y_temp = y - height;
        end
        x =  width*(n-1) + sum(opt.xPadding(1:n));
        if strcmp(opt.rowStyles(j,n),'Linear') % One Plot
            positions(axisPlotted + 1,:) = [x,y_temp,width,height_temp];
            h(axisPlotted + 1) = axes('position',positions(axisPlotted + 1,:),axes_options{:});
        elseif strcmp(opt.rowStyles(j,n),'LinLog') % LinLog Plot
            % Linear Plot
            positions(axisPlotted + 1,:) = [x,y_temp,widthLin,height_temp];
            h(axisPlotted + 1) = axes('position',positions(axisPlotted + 1,:),axes_options{:});
            % Log Plot
            positions(axisPlotted + 2,:) = [x+widthLin,y_temp,widthLog,height_temp];
            h(axisPlotted + 2) = axes('position',positions(axisPlotted + 2,:),axes_options{:});
        elseif strcmp(opt.rowStyles(j,n),'Residual') % Residual Plot
            positions(axisPlotted + 1,:) = [x,y_temp,width,(height_temp - height_temp/20)*1/4];
            h(axisPlotted + 1) = axes('position',positions(axisPlotted + 1,:),axes_options{:});
            % Data Plot
            positions(axisPlotted + 2,:) = [x,y_temp+height_temp*1/4,width,height_temp*3/4];
            h(axisPlotted +2) = axes('position',positions(axisPlotted + 2,:),axes_options{:});
        end
        
        if n == 1 && ~isempty(opt.LeftLabel) && length(opt.LeftLabel) >= j
            if ~exist('ht_index','var')
                ht_index = 1;
            end
                
            xlim=get(gca,'XLim');
            ylim=get(gca,'YLim');
            axSize = get(gca,'position');
            
            pixelScaler = axSize(3)/(xlim(2)-xlim(1));
            zeroPos = -axSize(1)/pixelScaler;
            
            ht(ht_index) = text(zeroPos + (opt.LeftLabelOffset/opt.figPos(3))/pixelScaler,(ylim(2)-ylim(1))*0.5,...
                opt.LeftLabel{j},'Rotation',90,'HorizontalAlignment','center','FontWeight','bold','FontSize', opt.fontSize);
            set(ht(ht_index),'units','normalized')
            ht_index = ht_index + 1;
        end
        
        if opt.numAxes
            if ~isempty(opt.axesNumTxt{(j-1)*numColumns + n})
                if ~exist('tbh_index','var')
                    tbh_index = 1;
                end
                tbh(tbh_index) = annotation(fh,'textbox',[x, y_temp + height_temp, 0.013, 0.028,],...
                    'VerticalAlignment','middle','FaceAlpha',0.9,'EdgeColor',...
                    'w','HorizontalAlignment', 'left', 'FontSize', opt.numAxesfontSize,...
                    'FontWeight', 'bold','Interpreter','tex','Margin',0,'LineStyle','none',...
                    'FitBoxToText', 'on','BackgroundColor',[1,1,1],'String',strtrim(opt.axesNumTxt{(j-1)*numColumns + n}));  
                pause(1/1000)
                
                if opt.external_labels
                    % outside top
                    if ~isempty(opt.axesNumTxtAppend)
                        add_str = opt.axesNumTxtAppend{(j-1)*numColumns + n};
                        if ~isempty(add_str)
                            tbh_2(tbh_index) = annotation(fh,'textbox',[x, y_temp + height_temp, 0.2, 0.01,],...
                                'VerticalAlignment','middle','FaceAlpha',0.9,'EdgeColor',...
                                'w','HorizontalAlignment', 'left', 'FontSize', opt.numAxesfontSize,...
                                'FontWeight', 'bold','Interpreter','tex','Margin',0,'LineStyle','none',...
                                'FitBoxToText', 'on','BackgroundColor',[1,1,1],'String',strtrim(add_str));
                            tbh_2(tbh_index).FitBoxToText = 'on';
                            pause(1/1000);
                            
                            tbh_2(tbh_index).Position(4) = tbh_2(tbh_index).Position(4)*0.8;
                            h_tbh_pos = h(axisPlotted+1).Position(2) + h(axisPlotted+1).Position(4) - tbh_2(tbh_index).Position(4) - 0.035*h(axisPlotted+1).Position(4);
                            
                            tbh_2(tbh_index).Position(2) = h_tbh_pos;
                            
                            tbh_2(tbh_index).Position(1) = h(axisPlotted+1).Position(1) + 10/opt.figPos(3);
                            
                            h_tbh_height = tbh_2(tbh_index).Position(4);
                            
                            font_scalar = 1;
                        end
                    else
                        h_tbh_pos = h(axisPlotted+1).Position(2) + h(axisPlotted+1).Position(4) - 4/opt.figPos(4);
                        h_tbh_height = 0;
                        font_scalar = 1.2;
                    end
                    tbh_width = tbh(tbh_index).Position(3);
                    tbh(tbh_index).Position(3) = 0;
                    tbh(tbh_index).Position(4) = h_tbh_height;
                    tbh(tbh_index).FontSize = tbh(tbh_index).FontSize.*font_scalar;
                    tbh(tbh_index).Position(2) = h_tbh_pos;
                    tbh(tbh_index).Position(1) = h(axisPlotted+1).Position(1) - tbh_width/0.75;
                else
                    tbh(tbh_index).Position(2) = h(axisPlotted+1).Position(2) + h(axisPlotted+1).Position(4) - tbh(tbh_index).Position(4) - 0.01*h(axisPlotted+1).Position(4);
                    tbh(tbh_index).Position(1) = h(axisPlotted+1).Position(1) + 10/opt.figPos(3);
                end
                tbh_index = tbh_index + 1;
                pause(1/1000); 
            end
        else
           tbh = []; 
        end
        axisPlotted = sum(arrayfun(@isgraphics,h(:)));
        axisPlot_type = [axisPlot_type,opt.rowStyles(j,n)];
        offset = sum(strcmp(axisPlot_type,'LinLog')) + sum(strcmp(axisPlot_type,'Residual'));
        if axisPlotted - offset >= opt.maxAxes
            break
        end
    end
    y = y_temp - opt.yPadding(end-j);
    %half_correction = 0.5*height*sum(all(correct(1:j),2));
end

%% Reposition left labesl
% if exist('ht_index','var')
% end

%% Trims to just h plotted
h = h(arrayfun(@isgraphics,h(:)));
fontSize = opt.fontSize;


