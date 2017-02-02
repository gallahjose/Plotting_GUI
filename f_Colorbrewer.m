function [colormap]= f_Colorbrewer(ncol, ctype, cname, interp_method)
%
% CBREWER - This function produces a colorbrewer table (rgb data) for a
% given type, name and number of colors of the colorbrewer tables.
% For more information on 'colorbrewer', please visit
% http://colorbrewer2.org/
%
% The tables were generated from an MS-Excel file provided on the website
% http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html
%
% INPUT:
%   - ncol:  number of color in the table. It changes according to ctype and
%            cname
%   - ctype: type of color table 'seq' (sequential), 'div' (diverging), 'qual' (qualitative)
%   - cname: name of colortable. It changes depending on ctype.
%   - interp_method: if the table need to be interpolated, what method
%                    should be used for interp1? Default='cubic'.
%
% A note on the number of colors: Based on the original data, there is
% only a certain number of colors available for each type and name of
% colortable. When 'ncol' is larger then the maximum number of colors
% originally given, an interpolation routine is called (interp1) to produce
% the "extended" colormaps.
%
% Example:  To produce a colortable CT of ncol X 3 entries (RGB) of
%           sequential type and named 'Blues' with 8 colors:
%                   CT=f_Colorbrewer(8, 'seq', 'Blues');

%
ncol_input = ncol;
% load colorbrewer data
load('colorbrewer.mat')
% initialise the colormap is there are any problems
colormap=[];
if (~exist('interp_method', 'var'))
    interp_method='PCHIP';
end

% If no arguments
if ~exist('ncol', 'var')
    ncol = 3;
    disp('Number of colours required not given, set to 3 as default.')
end

if (~exist('ctype', 'var') ) || isempty(ctype)
    Div = {'BrBG', 'PiYG', 'PRGn', 'PuOr', 'RdBu', 'RdGy', 'RdYlBu', 'RdYlGn', 'Spectral'};
    Seq = {'Blues','BuGn','BuPu','GnBu','Greens','Greys','Oranges','OrRd','PuBu','PuBuGn','PuRd',...
         'Purples','RdPu', 'Reds', 'YlGn', 'YlGnBu', 'YlOrBr', 'YlOrRd'};
    Qual = {'Accent', 'Dark2', 'Paired', 'Pastel1', 'Pastel2', 'Set1', 'Set2', 'Set3'};
    
    if strmatch(cname, Div)
      ctype = 'div';  
      
    elseif strmatch(cname, Seq)
      ctype = 'seq';  
      
    elseif strmatch(cname, Qual)
      ctype = 'qual';  
    end
end
    
% 
%     disp(' ')
%     disp('INPUT:')
%     disp('  - ctype: type of color table *seq* (sequential), *div* (divergent), *qual* (qualitative)')
%     disp('  - cname: name of colortable. It changes depending on ctype.')
%     disp('  - ncol:  number of color in the table. It changes according to ctype and cname')
%     
%     disp(' ')
%     disp('Sequential tables:')
%     z={'Blues','BuGn','BuPu','GnBu','Greens','Greys','Oranges','OrRd','PuBu','PuBuGn','PuRd',...
%         'Purples','RdPu', 'Reds', 'YlGn', 'YlGnBu', 'YlOrBr', 'YlOrRd'};
%     z(:)
%     
%     disp('Divergent tables:')
%     z={'BrBG', 'PiYG', 'PRGn', 'PuOr', 'RdBu', 'RdGy', 'RdYlBu', 'RdYlGn'};
%     z(:)
%     
%     disp(' ')
%     disp('Qualitative tables:')
%     z={'Accent', 'Dark2', 'Paired', 'Pastel1', 'Pastel2', 'Set1', 'Set2', 'Set3'};
%     z(:)
%     
%     plot_brewer_cmap

if ~exist ('cname', 'var')
    if strcmp(ctype, 'seq')
        cname = 'Blues';
    elseif strcmp(ctype, 'div')
        cname = 'Spectral';
    elseif strcmp(ctype, 'qual')
        cname = 'Set1';
    end
end

% Verify that the input is appropriate
ctype_names={'div', 'seq', 'qual', ''};
if (~ismember(ctype,ctype_names))
    disp('ctype must be either: *div*, *seq* or *qual*')
    colormap=[];
    return
end

if (~isfield(colorbrewer.(ctype),cname))
    disp(['The name of the colortable of type *' ctype '* must be one of the following:'])
    getfield(colorbrewer, ctype)
    colormap=[];
    return
end
%Alters the number of colours needed for removing unwanted colours
if ncol==1
    flip = 0;
    cRemove = [1,2];
    ncol = 3;
else
    if strcmp(ctype, 'div')
        flip = 1;
        if mod(ncol,2)
            cRemove = [(ncol+1)/2,(ncol+3)/2]; %remove centre white colour
            ncol = ncol+2;
        else
            cRemove = (ncol+2)/2; %removes centre white colour
            ncol = ncol+1;
        end
    elseif strcmp(ctype, 'seq')
        flip = 1;
        ncol = ncol+1; %remove lightest sequence colour
        cRemove = 1;
    else
        flip = 0;
        cRemove = [];
    end
    
end

if (ncol>length(colorbrewer.(ctype).(cname)))
%     disp(' ')
%     disp('----------------------------------------------------------------------')
%     disp(['The maximum number of colors for table *' cname '* is ' num2str(length(colorbrewer.(ctype).(cname)))])
%     disp(['The new colormap will be extrapolated from these ' num2str(length(colorbrewer.(ctype).(cname))) ' values'])
%     disp('----------------------------------------------------------------------')
%     disp(' ')
    cbrew_init=colorbrewer.(ctype).(cname){length(colorbrewer.(ctype).(cname))};
    colormap=interpolate_cbrewer(cbrew_init, interp_method, ncol);
    colormap=colormap./255;
    
    %Removes colours that are too light
    colormap(cRemove,:) = [];
    if flip
        colormap = flipud(colormap);
    end
    colormap = colormap(1:ncol_input,:);
    return
end



if (isempty  (colorbrewer.(ctype).(cname){ncol}))
    
    while(isempty(colorbrewer.(ctype).(cname){ncol}))
        ncol=ncol+1;
    end
%     disp(' ')
%     disp('----------------------------------------------------------------------')
%     disp(['The minimum number of colors for table *' cname '* is ' num2str(ncol)])
%     disp('This minimum value shall be defined as ncol instead')
%     disp('----------------------------------------------------------------------')
%     disp(' ')
end

colormap=(colorbrewer.(ctype).(cname){ncol})./255;

%Removes colours that are too light
colormap(cRemove,:) = [];
if flip
colormap = flipud(colormap);
end
colormap = colormap(1:ncol_input,:);
end

