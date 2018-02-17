function [ plotStyles ] = f_ColorPicker( numColors, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Sets Options

opt.type = ''; % qualitative jet sequential
opt.hue = 'red';
opt.minSaturation = 0.5; %0 is black
opt.minValue = 0.3; %0 is black
opt.initialSize = 1000;
opt.reverse = 0;
opt.offset = 1;
opt.forceSingle = 0;
% user input (after autodetection to allow user options)
[opt] = f_OptSet(opt, varargin);

%% Wonky hue options
if strcmp(opt.hue,'spectral')
    opt.type = 'qualitative';
end
if strcmp(opt.hue,'redblue')
    opt.type = 'redblue';
    opt.flip_rb = 0;
end
if strcmp(opt.hue,'bluered')
    opt.type = 'redblue';
    opt.flip_rb = 1;
end


%% hue lookup table
hueTable = {
    'red',      0/360
    'orange',   40/360
    'green',    100/360
    'teal',     170/360
    'blue',     200/360
    'purple',   270/360
    'pink',     320/360
    'black',    nan
    };

if ~isnumeric(opt.hue)
    [~, index] = max(strcmpi(opt.hue, hueTable(:,1)));
    opt.hue = hueTable{index,2};
end

if opt.hue > 1
    opt.hue = opt.hue/360;
end

%% Make Huse
plotStyles = ones(opt.initialSize,3);
if strcmp(opt.type, 'divergent')
    
elseif strcmpi(opt.type, 'qualitative')
    
    plotStyles = [0.6196,0.0039,0.2588; 0.8353,0.2431,0.3098; 0.9569,0.4275,0.2627; 0.9922,0.6824,0.3804; 0.6706,0.8667,0.6431; 0.4000,0.7608,0.6471; 0.1961,0.5333,0.7412; 0.3686,0.3098,0.6353];
    
    if numColors > size(plotStyles,1)
        plot_x = [1:size(plotStyles,1)]';
        num_x = [0:numColors-1]'.*((size(plotStyles,1)-1)/(numColors-1)) + 1;
        
        plotStyles = interp1(plot_x,plotStyles,num_x);
        
    else
        plotStyles = plotStyles(round(linspace(1,length(plotStyles),numColors)),:);
    end
elseif strcmpi(opt.type, 'redblue')
    maxGreen = 1;
    maxRed = 1;
    maxGreen_blue = 0.9;
    maxBlue = 1;
    
    ps_red = specialred(floor(opt.initialSize/2),maxGreen,maxRed);
    ps_blue = specialblue(floor(opt.initialSize/2),maxGreen_blue,maxBlue);
    
    plotStyles = [
        flipud(ps_red)
        ps_blue
        ];
    
    
    if numColors > 1
        plotStyles = plotStyles(round(linspace(1, size(plotStyles,1), numColors)),:);
    else
        plotStyles = plotStyles(round(opt.initialSize/2),:);
    end
    
    if opt.flip_rb 
        plotStyles = flipud(plotStyles);
    end
    
elseif strcmpi(opt.type, 'sequential')
    %% Sequential
    inhsv = 0;
    
    if isnan(opt.hue)
        
        plotStyles = zeros(opt.initialSize,3);
        plotStyles(:,1) = linspace(0.3,0.7,opt.initialSize);
        plotStyles(:,2) = plotStyles(:,1);
        plotStyles(:,3) = plotStyles(:,1);
        opt.reverse = ~opt.reverse;
        
    elseif opt.hue == 0/360 && ~opt.forceSingle
        %% Special Red
        maxGreen = 1;
        maxRed = 1;
        plotStyles = specialred(opt.initialSize,maxGreen,maxRed);
        
        
    elseif opt.hue == 200/360 && ~opt.forceSingle
        %% Special Blue
        maxGreen = 0.95;
        maxBlue = 1;
        plotStyles = specialblue(opt.initialSize,maxGreen,maxBlue);
    else
        splitPosition = round(opt.minSaturation/(opt.minSaturation + opt.minValue)*opt.initialSize);
        %% Genrates HSV values that span the bounds of given hue with opt.intitialSize steps
        plotStyles(:,1) = plotStyles(:,1)*opt.hue;
        plotStyles(1:splitPosition,2) = linspace(opt.minSaturation + (+0.125-opt.hue/4) ,1, splitPosition);
        plotStyles(splitPosition:end,3) = linspace(1, opt.minValue + (+0.125-opt.hue/4), opt.initialSize - splitPosition + 1);
        inhsv = 1;
    end
    
    if numColors > 1
        plotStyles = plotStyles(round(linspace(1, opt.initialSize, numColors)),:);
    else
        plotStyles = plotStyles(round(opt.initialSize/2),:);
    end
    
    if inhsv
        plotStyles = hsv2rgb(plotStyles);
    end
else
    %plotStyles(:,1) = logspace(0, log10(0.9), opt.initialSize) + opt.offset;
    plotStyles(:,1) = linspace(0.1, 0.85, opt.initialSize).^(1.5);
    plotStyles(:,1) = plotStyles(:,1) - min(plotStyles(:,1));
    plotStyles(:,1) = plotStyles(:,1)*(0.78/max(plotStyles(:,1))) + 0.04;
    while any(plotStyles(:,1)>1)
        plotStyles(plotStyles(:,1)>1 ,1) = plotStyles(plotStyles(:,1)>1 ,1) -1;
    end
    plotStyles(:,2) = linspace(1, 0.7, opt.initialSize).^(0.5);
    plotStyles(:,3) = linspace(1, 0.7, opt.initialSize);
    if numColors > 1
        plotStyles = plotStyles(round(linspace(1, opt.initialSize, numColors)),:);
    else
        plotStyles = plotStyles(round(opt.initialSize/2),:);
    end
    plotStyles = hsv2rgb(plotStyles);
    
end


if opt.reverse
    plotStyles = flipud(plotStyles);
end

function plotStyles = specialred(initialSize,maxGreen,maxRed)

numIntervals = initialSize*1.8;


%%%%%%%%%%%%%%%%%%%%%%%%
%%%5  max - dark red  %%%
%%%                  %%%
%%%4  P4 - red        %%%
%%%                  %%%
%%%2  P3 - yellow     %%%
%%%                    %%%
%%%0 (zeroPos)- white  %%%
%%%%%%%%%%%%%%%%%%%%%%%%

P4 = round(numIntervals*4/5);
P3 = round(numIntervals*2/5);
zeroPos = 1;

plotStyles = zeros(numIntervals,3);
%zeroPos - > P3
len = P3-zeroPos+1;
plotStyles(zeroPos:P3,1) = linspace(0.7,maxRed,len);  %Red
plotStyles(zeroPos:P3,2) = linspace(0.7,maxGreen,len);  %Green
plotStyles(zeroPos:P3,3) = linspace(0.7,0,len);  %Blue
%P3 - > P4
len = P4-P3+1;
plotStyles(P3:P4,1) = linspace(maxRed,maxRed,len);            %Red
plotStyles(P3:P4,2) = linspace(maxGreen,0,len);            %Green
plotStyles(P3:P4,3) = linspace(0,0,len);            %Blue
%P4 - > end (max)
len = numIntervals-P4+1;
plotStyles(P4:end,1) = linspace(maxRed,0.7,len);       %Red
plotStyles(P4:end,2) = linspace(0,0,len);         %Green
plotStyles(P4:end,3) = linspace(0,0,len);         %Blue

extraPoints = numIntervals - initialSize;
plotStyles = plotStyles(extraPoints:end,:);


function plotStyles = specialblue(initialSize,maxGreen,maxBlue)


numIntervals = initialSize*1.1;

P4 = round(numIntervals*4/5);
P3 = round(numIntervals*2/5);
zeroPos = 1;

plotStyles = zeros(numIntervals,3);
%zeroPos - > P3
len = P3-zeroPos+1;
plotStyles(zeroPos:P3,1) = linspace(0.8,0,len);  %Red
plotStyles(zeroPos:P3,2) = linspace(0.8,maxGreen,len);  %Green
plotStyles(zeroPos:P3,3) = linspace(0.8,maxBlue,len);  %Blue
%P3 - > P4
len = P4-P3+1;
plotStyles(P3:P4,1) = linspace(0,0,len);            %Red
plotStyles(P3:P4,2) = linspace(maxGreen,0,len);            %Green
plotStyles(P3:P4,3) = linspace(maxBlue,maxBlue,len);            %Blue
%P4 - > end (max)
len = numIntervals-P4+1;
plotStyles(P4:end,1) = linspace(0,0,len);       %Red
plotStyles(P4:end,2) = linspace(0,0,len);         %Green
plotStyles(P4:end,3) = linspace(maxBlue,0.7,len);         %Blue

extraPoints = numIntervals - initialSize;
if extraPoints > 0
    plotStyles = plotStyles(extraPoints:end,:);
end