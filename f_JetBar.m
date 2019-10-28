function [ colourInfo ] = f_JetBar( varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%% Sets Options
opt.numIntervals = 200;

opt.allAxes = findall(gcf,'type','axes');
opt.type = 'JET';
%opt.type = 'RdBu';
opt.saturation = 100/255;
opt.value = 100/255;
opt.HSVLimits = [-5/255, 205/255];
opt.cMin = [];
opt.cMax = [];
opt.squeezeLimits = 0;
opt.ZeroValue = [0.95, 0.95, 0.95];
%opt.ZeroValue = [0.9, 0.9, 0.9];
opt.GreenMax = 0.8;
opt.commonClim = 0;
opt.equalBlueRed = 1;

opt.no_zero = 1;

opt.flipUD = 0;

% user input (after autodetection to allow user options)
[opt] = f_OptSet(opt, varargin);

% Checks if colorbars have been passed and then removes them
index = zeros(size(opt.allAxes,1),1);
for n = 1 : length(opt.allAxes)
    index(n) = ~isa(handle(opt.allAxes(n)),'scribe.colorbar'); %colour bars return 'scribe.colorbar' instead of 'axes'
end
opt.allAxes = opt.allAxes(logical(index));

c = zeros(size(opt.allAxes,1),2);
for n = 1 : size(opt.allAxes,1)
    c(n,:) = get(opt.allAxes(n),'CLim');
end

opt.cMin = c(:,1);
opt.cMax = c(:,2);

% user input (after autodetection to allow user options)
[opt] = f_OptSet(opt, varargin);

if opt.squeezeLimits
    opt.cMin = opt.cMin./opt.squeezeLimits;
    opt.cMax = opt.cMax./opt.squeezeLimits;
end

if opt.commonClim
    opt.cMin = min(opt.cMin);
    opt.cMax = max(opt.cMax);
else
    zeroIndex = opt.cMax == 0; %incase there are zero in cMax
    cMinScaler = min(bsxfun(@rdivide,opt.cMin(~zeroIndex),opt.cMax(~zeroIndex)));
    opt.cMin(~zeroIndex) = opt.cMax(~zeroIndex)*cMinScaler;
    %opt.cMin(zeroIndex) = min(opt.cMin(~zeroIndex));
    %opt.cMax(zeroIndex) = max(opt.cMax(~zeroIndex));
end


if length(opt.cMin) < length(opt.allAxes), opt.cMin = opt.cMin(end)*ones(length(opt.allAxes),1); end
if length(opt.cMax) < length(opt.allAxes) opt.cMax = opt.cMax(end)*ones(length(opt.allAxes),1); end

if opt.equalBlueRed
    value = max(abs([opt.cMin(:);opt.cMax(:)]));
    opt.cMin(:) = -value;
    opt.cMax(:) = value;
end

%% Sets all axes Clims
for n = 1 : length(opt.allAxes)
    set(opt.allAxes(n), 'Clim', [opt.cMin(n), opt.cMax(n)]);
end

opt.cMin = opt.cMin(end);
opt.cMax = opt.cMax(end);

opt.cMin(isnan(opt.cMin)) = 0;
opt.cMax(isnan(opt.cMax)) = 0;


%% Changes clim for log set...
if strcmpi(opt.type(1:3), 'log')
    opt.cMax = abs(opt.cMin);
    opt.cMin = 0;
    opt.type = opt.type(4:end);
    %opt.flipUD = 0;
end

%%
if strcmp(opt.type, 'TRPLredblue')
    opt.ZeroValue(2) = 0;
    opt.type = 'Jet';
end

%% Calculates color map with zero as green, red positive, blue negative
colourInfo = zeros(opt.numIntervals,3);
zeroPos = ceil(abs(opt.cMin/(opt.cMax - opt.cMin))*opt.numIntervals);

% Allows min or max to be zero
if ~zeroPos
    if ~opt.cMin % have numbers from 0 -> positive
        zeroPos = 1;
    else % have numbers from negative -> 0
        zeroPos = opt.numIntervals;
    end
elseif zeroPos > opt.numIntervals
    zeroPos = opt.numIntervals;
end


if strcmp(opt.type, 'HSV')
    
    colourInfo = bsxfun(@times,colourInfo+1,[0,opt.saturation,opt.value]);
    
    colourInfo(1:zeroPos,1) = linspace(opt.HSVLimits(2),mean(abs(opt.HSVLimits)), zeroPos);
    
    colourInfo(zeroPos:end,1) = linspace(mean(abs(opt.HSVLimits)), opt.HSVLimits(1), length(colourInfo(zeroPos:end,1)));
    
    colourInfo(colourInfo<0) = colourInfo(colourInfo<0)+1;
    
    colourInfo(:,2) = sin(linspace(0,2*pi(),opt.numIntervals))./8 + 0.8;
    colourInfo(:,3) = cos(linspace(0,2*pi(),opt.numIntervals))./8 + 0.5;
    
    %% Coverst to HSV
    colourInfo = hsl2rgb(colourInfo);
    
elseif strcmp(opt.type, 'RdBu')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  max - dark red (0.5,   0,   0) %%%
    %%%                                 %%%
    %%%  P2 - red       (  1,   0,   0) %%%
    %%%                                 %%%
    %%%   (zeroPos)     (0.5, 0.5, 0.5) %%%
    %%%                                 %%%
    %%%  P1 - blue      (  0,   0,   1) %%%
    %%%                                 %%%
    %%%  1 - dark blue  (  0,   0, 0.5) %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    colorMax = 0.4;
    divider = 1.7;
    
    P1 = ceil(zeroPos/divider);
    P2 = ceil(opt.numIntervals - (opt.numIntervals - zeroPos)/divider);
    
    %1 (min) -> P1
    colourInfo(1:P1,1) = linspace(0,0,P1);      %Red
    colourInfo(1:P1,2) = linspace(0,0,P1);      %Green
    colourInfo(1:P1,3) = linspace(colorMax,1,P1);    %Blue
    %P1 - > zeroPos
    colourInfo(P1:zeroPos,1) = linspace(0,opt.ZeroValue(1),zeroPos-P1+1);      %Red
    colourInfo(P1:zeroPos,2) = linspace(0,opt.ZeroValue(2),zeroPos-P1+1);      %Green
    colourInfo(P1:zeroPos,3) = linspace(1,opt.ZeroValue(3),zeroPos-P1+1);      %Blue
    %zeroPos - > P2
    colourInfo(zeroPos:P2,1) = linspace(opt.ZeroValue(1),1,P2-zeroPos+1);      %Red
    colourInfo(zeroPos:P2,2) = linspace(opt.ZeroValue(2),0,P2-zeroPos+1);      %Green
    colourInfo(zeroPos:P2,3) = linspace(opt.ZeroValue(3),0,P2-zeroPos+1);      %Blue
    %P2 - > end (max)
    colourInfo(P2:end,1) = linspace(1,colorMax,opt.numIntervals-P2+1);    %Red
    colourInfo(P2:end,2) = linspace(0,0,opt.numIntervals-P2+1);      %Green
    colourInfo(P2:end,3) = linspace(0,0,opt.numIntervals-P2+1);      %Blue
    
elseif strcmp(opt.type, 'TRPL')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  max - dark red       [150,  0,  0]  %%%
    %%%                                      %%%
    %%%  P5 - red             [255,  0,  0]  %%%
    %%%                                      %%%
    %%%  P4 - yellow          [255,255,  0]  %%%
    %%%                                      %%%
    %%%  P3 - green           [150,255,150]  %%%
    %%%                                      %%%
    %%%  P2 - teal            [  0,255,255]  %%%
    %%%                                      %%%
    %%%  P1 - blue            [  0,  0,255]  %%%
    %%%                                      %%%
    %%% (zeroPos) - grey      [150,150,150]  %%%
    %%%                                      %%%
    %%%  1 - purple           [230,230,230]  %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    posValues = zeroPos:opt.numIntervals;
    P6 = posValues(end);
    P5 = posValues(round(5/6*length(posValues)));
    P4 = posValues(round(4/6*length(posValues)));
    P3 = posValues(round(3/6*length(posValues)));
    i_u = round(2/6*length(posValues));
    if i_u <=0, i_u = 1; end
    P2 = posValues(i_u);
    i_u = round(1/6*length(posValues));
    if i_u <=0, i_u = 1; end
    P1 = posValues(i_u);
    
    
    
    %1 (min) -> (zeroPos)
    colourInfo(1:zeroPos,1) = linspace(200/255,245/255,zeroPos);      %Red
    colourInfo(1:zeroPos,2) = linspace(200/255,245/255,zeroPos);            %Red
    colourInfo(1:zeroPos,3) = linspace(200/255,245/255,zeroPos);      %Blue
    % zeroPos -> P1
    num = P1 - zeroPos + 1;
    colourInfo(zeroPos:P1,1) = linspace(245/255,0,num);            %Red
    colourInfo(zeroPos:P1,2) = linspace(245/255,0,num);            %Green
    colourInfo(zeroPos:P1,3) = linspace(245/255,1,num);      %Blue
    %P1 - > P2
    num = P2 - P1 + 1;
    colourInfo(P1:P2,1) = linspace(0,0,num);      %Red
    colourInfo(P1:P2,2) = linspace(0,1,num);      %Green
    colourInfo(P1:P2,3) = linspace(1,1,num);      %Blue
    %P2 - > P3
    num = P3 - P2 + 1;
    colourInfo(P2:P3,1) = linspace(0,150/255,num);      %Red
    colourInfo(P2:P3,2) = linspace(1,1,num);      %Green
    colourInfo(P2:P3,3) = linspace(1,150/255,num);      %Blue
    %P3 - > P4
    num = P4 - P3 + 1;
    colourInfo(P3:P4,1) = linspace(150/255,1,num);      %Red
    colourInfo(P3:P4,2) = linspace(1,1,num);      %Green
    colourInfo(P3:P4,3) = linspace(150/255,0,num);      %Blue
    %P4 - > P5
    num = P5 - P4 + 1;
    colourInfo(P4:P5,1) = linspace(1,1,num);      %Red
    colourInfo(P4:P5,2) = linspace(1,0,num);      %Green
    colourInfo(P4:P5,3) = linspace(0,0,num);      %Blue
    %P5 - > max
    num = P6 - P5 + 1;
    colourInfo(P5:P6,1) = linspace(1,150/255,num);      %Red
    colourInfo(P5:P6,2) = linspace(0,0,num);            %Green
    colourInfo(P5:P6,3) = linspace(0,0,num);            %Blue
    
elseif strcmp(opt.type, 'TRPLblue')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                                      %%%
    %%%  P2 - teal            [  0,255,255]  %%%
    %%%  P2 - dark blue       [  0,  0,150]  %%%
    %%%                                      %%%
    %%%  P1 - blue            [  0,  0,255]  %%%
    %%%                                      %%%
    %%% (zeroPos) - grey      [150,150,150]  %%%
    %%%                                      %%%
    %%%  1 - purple           [230,230,230]  %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    posValues = zeroPos:opt.numIntervals;
    %P6 = posValues(end);
    %P5 = posValues(round(5/6*length(posValues)));
    %P4 = posValues(round(4/6*length(posValues)));
    
    P2 = posValues(end);
    P1 = posValues(round(3/6*length(posValues)));
    
    
    
    %1 (min) -> (zeroPos)
    colourInfo(1:zeroPos,1) = linspace(200/255,245/255,zeroPos);      %Red
    colourInfo(1:zeroPos,2) = linspace(200/255,245/255,zeroPos);      %Red
    colourInfo(1:zeroPos,3) = linspace(200/255,245/255,zeroPos);      %Blue
    
    
    % zeroPos -> P1
    num = P1 - zeroPos + 1;
    colourInfo(zeroPos:P1,1) = linspace(245/255,0,num);            %Red
    colourInfo(zeroPos:P1,2) = linspace(245/255,0,num);            %Green
    colourInfo(zeroPos:P1,3) = linspace(245/255,1,num);      %Blue
    %P1 - > P2
    num = P2 - P1 + 1;
    colourInfo(P1:P2,1) = linspace(0,0,num);      %Red
    colourInfo(P1:P2,2) = linspace(0,0,num);      %Green
    colourInfo(P1:P2,3) = linspace(1,0,num);      %Blue
    
    max_blue = 150/255; %0 black
    [~,i_max] = min(abs(colourInfo(:,3)-max_blue));
    colourInfo(i_max:end,:) = [];
    
    %
    if false
        blue = colourInfo(:,3);
        red = colourInfo(:,1);
        %
        colourInfo(:,3) = red;
        colourInfo(:,1) = blue;
    end
else % Jet
    %%%%%%%%%%%%%%%%%%%%%%%%
    %%%  max - dark red  %%%
    %%%                  %%%
    %%%  P4 - red        %%%
    %%%                  %%%
    %%%  P3 - yellow     %%%
    %%%                  %%%
    %%%   (zeroPos)      %%%
    %%%                  %%%
    %%%  P2 - teal       %%%
    %%%                  %%%
    %%%  P1 - blue       %%%
    %%%                  %%%
    %%%  1 - dark blue   %%%
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    posValues = zeroPos:opt.numIntervals;
    negValues = 1:zeroPos;
    
    P4 = posValues(round(4/5*length(posValues)));
    P3 = posValues(ceil(2/5*length(posValues)));
    P2 = negValues(round(3/5*length(negValues)));
    P1 = negValues(ceil(1/5*length(negValues)));
    
    %1 (min) -> P1
    colourInfo(1:P1,1) = linspace(0,0,P1);                                 %Red
    colourInfo(1:P1,2) = linspace(0,0,P1);                                 %Green
    colourInfo(1:P1,3) = linspace(0.5,1,P1);                               %Blue
    %P1 (min) -> P2
    colourInfo(P1:P2,1) = linspace(0,0,P2-P1+1);                           %Red
    colourInfo(P1:P2,2) = linspace(0,opt.GreenMax,P2-P1+1);                           %Green
    colourInfo(P1:P2,3) = linspace(1,1,P2-P1+1);                           %Blue
    %P2 - > zeroPos
    colourInfo(P2:zeroPos,1) = linspace(0,opt.ZeroValue(1),zeroPos-P2+1);  %Red
    colourInfo(P2:zeroPos,2) = linspace(opt.GreenMax,opt.ZeroValue(2),zeroPos-P2+1);  %Green
    colourInfo(P2:zeroPos,3) = linspace(1,opt.ZeroValue(3),zeroPos-P2+1);  %Blue
    %zeroPos - > P3
    colourInfo(zeroPos:P3,1) = linspace(opt.ZeroValue(1),1,P3-zeroPos+1);  %Red
    colourInfo(zeroPos:P3,2) = linspace(opt.ZeroValue(2),opt.GreenMax,P3-zeroPos+1);  %Green
    colourInfo(zeroPos:P3,3) = linspace(opt.ZeroValue(3),0,P3-zeroPos+1);  %Blue
    %P3 - > P4
    colourInfo(P3:P4,1) = linspace(1,1,P4 - P3 + 1);                       %Red
    colourInfo(P3:P4,2) = linspace(opt.GreenMax,0,P4 - P3 + 1);                       %Green
    colourInfo(P3:P4,3) = linspace(0,0,P4 - P3 + 1);                       %Blue
    %P4 - > end (max)
    colourInfo(P4:end,1) = linspace(1,0.5,opt.numIntervals - P4 +1);       %Red
    colourInfo(P4:end,2) = linspace(0,0,opt.numIntervals - P4 +1);         %Green
    colourInfo(P4:end,3) = linspace(0,0,opt.numIntervals - P4 +1);         %Blue
end

%% if opt.flipUD
if opt.flipUD
    colourInfo = flipud(colourInfo);
end
%% Sets color map
if nargout == 0
    
    for n = 1 : length(opt.allAxes)
        colormap(opt.allAxes(n), colourInfo);
    end
end

end


function rgb=hsl2rgb(hsl_in)
%Converts Hue-Saturation-Luminance Color value to Red-Green-Blue Color value
%
%Usage
%       RGB = hsl2rgb(HSL)
%
%   converts HSL, a M [x N] x 3 color matrix with values between 0 and 1
%   into RGB, a M [x N] X 3 color matrix with values between 0 and 1
%
%See also rgb2hsl, rgb2hsv, hsv2rgb

% (C) Vladimir Bychkovsky, June 2008
% written using:
% - an implementation by Suresh E Joel, April 26,2003
% - Wikipedia: http://en.wikipedia.org/wiki/HSL_and_HSV

hsl=reshape(hsl_in, [], 3);

H=hsl(:,1);
S=hsl(:,2);
L=hsl(:,3);

lowLidx=L < (1/2);
q=(L .* (1+S) ).*lowLidx + (L+S-(L.*S)).*(~lowLidx);
p=2*L - q;
hk=H; % this is already divided by 360

t=zeros([length(H), 3]); % 1=R, 2=B, 3=G
t(:,1)=hk+1/3;
t(:,2)=hk;
t(:,3)=hk-1/3;

underidx=t < 0;
overidx=t > 1;
t=t+underidx - overidx;

range1=t < (1/6);
range2=(t >= (1/6) & t < (1/2));
range3=(t >= (1/2) & t < (2/3));
range4= t >= (2/3);

% replicate matricies (one per color) to make the final expression simpler
P=repmat(p, [1,3]);
Q=repmat(q, [1,3]);
rgb_c= (P + ((Q-P).*6.*t)).*range1 + ...
    Q.*range2 + ...
    (P + ((Q-P).*6.*(2/3 - t))).*range3 + ...
    P.*range4;

rgb_c=round(rgb_c.*10000)./10000;
rgb=reshape(rgb_c, size(hsl_in));

end
