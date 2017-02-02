function [fullpaths, name, photoFullpaths, pathname, filenames] = f_GetPath(directory, varargin)
%[fullpaths, Name, photoFullpaths, pathname, filenames] = f_GetPath(directory, varargin)
%   Returnes list of fullpaths to user selected data files. Options for
%   filltering paths by containing string.
%
%   %%Returned Values
%   fullpaths           cell containing fullpaths to selected files (cell)
%   name                name from file or folder depending on number of
%                       selected files. (char)
%   photoFullpaths      nx1 row of time points
%   pathname            fullpath to folder containing files
%   filenames           list of filenames relative to pathname
%
%   %%Options
%   'type'              filter based on type of file
%                       default = '*.csv'
%   'headStr'           string in title of select box
%                       default = 'Open file/s'
%   'dataType'          Fillters selected files by string or rules for given string
%                       default = []
%
%   inital updated 27-03-14 - Shyamal

%% Check input varibales
if ~exist('directory','var'), directory = 'S:\SkyDrive\Documents\Uni\Molelec\TA Data\'; end

%% Sets Options
% default options
opt.type = '*.csv';
opt.headStr = 'Open file/s';
opt.dataType = '';

% user input
[opt] = f_OptSet(opt, varargin);

%% Generates needed variabls
photoFullpaths = [];

%% fall back directories if the default, or user selected one doesn't exist
while ~ischar(directory)
    directory = directory{1};
end

if ~exist(directory,'dir')
    directory = 'S:\SkyDrive\Documents\Uni\Molelec\TA Data\';
end
if ~exist(directory,'dir')
    directory = 'S:\SkyDrive\Documents\Uni\Molelec\TA Data\';
end

if ~exist(directory,'dir')
    directory = 'H:\Shyamal\TA Data';
end

if ~exist(directory,'dir')
    directory = 'D:\OneDrive\Documents\Uni\Molelec\TA Data';
end

%% Checks inputs are correct

%checks type is *.XXX format
if opt.type(1) == '.'
    opt.type = strcat('*', opt.type);
elseif opt.type(1) ~= '*'
    opt.type = strcat('*.', opt.type);
end

%% Import data%
[filenames, pathname] = uigetfile(opt.type,opt.headStr,directory,'MultiSelect', 'on');

fullpaths = strcat(pathname,filenames);

pathname = cellstr(pathname);


if  ischar(fullpaths) %for single data file
    fullpaths = cellstr(fullpaths);
    filenames = cellstr(filenames);
    
    %Find the Name of dataset
    C = textscan(fullpaths{1},'%s', 'Delimiter', '\\');
    C = C{1,1}{end,1};
    loc = strfind(C,'Averaged');
    if isempty(loc)
        name = C(1:(end-4));
    else
        name = C(1:(loc-2));
    end
    
else %multiple files
    
    if ~isempty(opt.dataType) % Special processing if requested
    %Special processing for TA data 
        if strcmp(opt.dataType, 'TA')
            fullpaths = fullpaths(~cellfun(@isempty, strfind(fullpaths,'Camera'))); %returns Camera files
            photoFullpaths = fullpaths(~cellfun(@isempty, strfind(fullpaths,'PhotoDiodes'))); %returns PD files
        else
            %Processing for other string just searches for that string in
            %files and returns only those containing string
            if ischar(opt.dataType)
                fullpaths = fullpaths(~cellfun(@isempty, strfind(fullpaths,char(opt.dataType)))); 
            end
        end
    end
    
    %Find the Name of dataset
    C = textscan(fullpaths{1},'%s', 'Delimiter', '\\');
    C = C{1,1}{end-1,1};
    loc = strfind(C,'Averaged');
    if isempty(loc)
        name = C;
    end
end

if isa(name,'char')
    name = {name};
end


end
