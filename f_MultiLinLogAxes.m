function [ h, fh, positions] = f_MultiLinLogAxes( numColumns, figH, varargin)
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

opt.xPadding = 70; %px
opt.xLeftOffset = 0; %px
opt.xRightOffset = 20; %px

opt.yPadding = 80; %px
opt.yTopOffset = 10; %px
opt.yBottomOffset = 0; %px

opt.rowStyles = [{'Linear'};'LinLog';'Residual'];
opt.title = [];
opt.figTitle = [];

opt.linLogFraction = 0.2;

opt.figPos = [];
opt.figScaler = 1;
opt.figUnits = 'pixels';
opt.paddingUnits = 'pixels';
opt.fontSize = 10;
opt.titleSize = 10;
opt.keepFigSize = 0;
opt.numberTitle = 'on';

opt.numAxes = 0;
opt.axesNumTxt = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R'};
opt.numAxesfontSize = 0;
opt.numAxesYoffset = 0;

[opt] = f_OptSet(opt, varargin);

%% Checking options
if iscell(opt.figTitle), opt.figTitle = opt.figTitle{1}; end
if opt.numAxesfontSize == 0
    opt.numAxesfontSize = opt.fontSize*2;
end
% rowStyles is n by (numColumns)
if size(opt.rowStyles,2) ~= numColumns && size(opt.rowStyles,2) > 1, opt.rowStyles = opt.rowStyles'; end
if size(opt.rowStyles,2) ~= numColumns
    opt.rowStyles = repmat(opt.rowStyles,1,numColumns);
end


%% Select/make figure
fh = figure(figH(1));
clf(fh);

%% Sets fig position property
ratio = 1.618;
figHeight = 500;
figWidth = figHeight*ratio;
figHeight = figHeight*size(opt.rowStyles,1);
figWidth = figWidth*numColumns;

scnsize = get(0,'ScreenSize');
if opt.keepFigSize
    opt.figPos = get(fh,'position');
else
    if ~isempty(opt.figPos)
        if length(opt.figPos) ~= 4
            if opt.figPos(1) <=1 % normalized units
                opt.figPos = [scnsize(3)*opt.figPos(1), scnsize(4)*opt.figPos(end), figWidth, figHeight];
            else % pixel units
                opt.figPos = [opt.figPos(1), opt.figPos(end), figWidth, figHeight];
            end
        elseif opt.figPos(1) <=1 && strcmp(opt.figUnits, 'normalized')% normalized units
            opt.figPos = scnsize.*opt.figPos;
        end
    else
        opt.figPos = [(scnsize(3)-figWidth)/2, (scnsize(4)-figHeight)/2, figWidth, figHeight];
    end
    
    % rescales figure
    opt.figPos = [ opt.figPos(1) - (opt.figPos(3)*opt.figScaler(1) - opt.figPos(3))*0.5,...
                    opt.figPos(2) - (opt.figPos(4)*opt.figScaler(end)- opt.figPos(4))*0.5,...
                    opt.figPos(3)*opt.figScaler(1), opt.figPos(4)*opt.figScaler(end)];
end

%% Sets up figure
%Sets figure parameters
set(fh,'color','w', 'units', opt.figUnits, 'position', opt.figPos,...
    'PaperUnits','points','PaperPosition',[0,0,opt.figPos(3),opt.figPos(4)],'PaperPositionMode','auto');
%Sets paper size to match figure size

%Changes figure box header
if ~isempty(opt.figTitle), 
    opt.figTitle = regexprep(opt.figTitle,'\_(?!{)','\\_');
    opt.figTitle = regexprep(opt.figTitle,'\\..{','');
    opt.figTitle = regexprep(opt.figTitle,'(?<!\\)}','');
    set(fh,'name', opt.figTitle, 'NumberTitle', opt.numberTitle); 
end

% Makes space for figure title about axis
if ~isempty(opt.title)
    opt.title = regexprep(opt.title,'\_(?!{)','\\_'); %removes extra character (?!x) is a negative look ahead for x
    titleH = annotation(fh,'textbox',[0 0.955 1 0.04],'LineStyle','none','HorizontalAlignment', 'center', 'VerticalAlignment', 'top','FontSize', opt.titleSize,...
        'String', opt.title, 'FitBoxToText', 'on');
    pause(0.00001);
    titlePosition = get(titleH,'position');
    %r = annotation('rectangle','position',titlePosition); %draws box around title
    opt.yTopOffset(end) = opt.yTopOffset(end) + (1-titlePosition(2))*opt.figPos(end);
end

%% creates padding vectors
xPaddingNew = ones(numColumns+1,1).*opt.xPadding(end);
xPaddingNew(1:length(opt.xPadding)) = opt.xPadding;
xPaddingNew(1) = xPaddingNew(1) + opt.xLeftOffset;
xPaddingNew(end) = opt.xRightOffset;
opt.xPadding = xPaddingNew;

yPaddingNew = ones(length(opt.rowStyles)+1,1).*opt.yPadding(end);
yPaddingNew(1:length(opt.yPadding)) = opt.yPadding;
yPaddingNew(1) = yPaddingNew(1) + opt.yBottomOffset;
yPaddingNew(end) = opt.yTopOffset;
opt.yPadding = yPaddingNew;

%% checks offsets are normalized
set(fh, 'units', opt.paddingUnits);
innerPos = get(fh,'Position');
if sum(opt.xPadding) >= 1, opt.xPadding = opt.xPadding/innerPos(3); end
if sum(opt.yPadding) >= 1, opt.yPadding = opt.yPadding/innerPos(4); end

%% Calculates Variables
numRows = size(opt.rowStyles,1);
width = (1-sum(opt.xPadding))/numColumns;
widthLin = width*opt.linLogFraction;
widthLog = width*(1-opt.linLogFraction);
height = (1 - sum(opt.yPadding))/numRows;

numAxes = sum(sum(strcmp(opt.rowStyles,'Linear')) + sum(strcmp(opt.rowStyles,'LinLog'))*2 + sum(strcmp(opt.rowStyles,'Residual'))*2);
positions = zeros(size(numAxes,1),4);


%% Creates Plots
axisPlotted = 0;
for j = 1 : numRows
    y = 1  - height*j - sum(opt.yPadding(end-j+1:end));
    for n = 1 : numColumns
        x =  width*(n-1) + sum(opt.xPadding(1:n));
        if strcmp(opt.rowStyles(j,n),'Linear') % One Plot
            positions(axisPlotted + 1,:) = [x,y,width,height];
            h(axisPlotted + 1) = axes('position',positions(axisPlotted + 1,:),'fontsize',opt.fontSize);
        elseif strcmp(opt.rowStyles(j,n),'LinLog') % LinLog Plot
            % Linear Plot
            positions(axisPlotted + 1,:) = [x,y,widthLin,height];
            h(axisPlotted + 1) = axes('position',positions(axisPlotted + 1,:),'fontsize',opt.fontSize);
            % Log Plot
            positions(axisPlotted + 2,:) = [x+widthLin,y,widthLog,height];
            h(axisPlotted + 2) = axes('position',positions(axisPlotted + 2,:),'fontsize',opt.fontSize);
        elseif strcmp(opt.rowStyles(j,n),'Residual') % Residual Plot
            positions(axisPlotted + 1,:) = [x,y,width,(height - height/20)*1/4];
            h(axisPlotted + 1) = axes('position',positions(axisPlotted + 1,:),'fontsize',opt.fontSize);
            % Data Plot
            positions(axisPlotted + 2,:) = [x,y+height*1/4,width,height*3/4];
            h(axisPlotted +2) = axes('position',positions(axisPlotted + 2,:),'fontsize',opt.fontSize);
        end
        if opt.numAxes
            tbh = annotation(fh,'textbox',[x - opt.xPadding(n), y + height, 0.2, 0.04,],...
                'VerticalAlignment','top','FaceAlpha',0,'EdgeColor','w','HorizontalAlignment', 'left', 'FontSize', opt.numAxesfontSize, 'FontWeight', 'bold',...
                'Margin',0,'LineStyle','none','String', opt.axesNumTxt{(j-1)*numColumns + n});
            textPos = get(tbh,'position');
            set(tbh, 'FitBoxToText','on', 'position', [textPos(1), y+height-textPos(4)/2+ opt.numAxesYoffset,textPos(3),textPos(4)]);
        end
        axisPlotted = sum(arrayfun(@isgraphics,h(:)));   
    end
end

h = h(arrayfun(@isgraphics,h(:)));
