function [fullpaths, name, photoFullpaths, pathname, filenames] = f_GetPath(directory, varargin)
%[fullpaths, Name, photoFullpaths, pathname, filenames] = f_GetPath(directory, options)
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
%   'loadDir'           Allows selection of directory rather than
%                       individual files. This loads all files in directory
%                       default = 0 (select individual files)
%
%   27-03-14 Shyamal - inital update
%   03-07-14 Shyamal - added option to selectr directory

%% Check input varibales
if ~exist('directory','var'), directory = f_UserPref( 'Project' );; end

%% Sets Options
% default options
opt.type = '*.csv;*.dat;*.mat';
opt.headStr = 'Open file/s';
opt.dataType = '';
opt.loadDir = 0;

% user input
[opt] = f_OptSet(opt, varargin);

%% Generates needed variabls
photoFullpaths = [];

%% Checks inputs are correct
%checks type is *.XXX format
if opt.type(1) == '.'
    opt.type = strcat('*', opt.type);
elseif opt.type(1) ~= '*'
    opt.type = strcat('*.', opt.type);
end
%makes directory a char
while ~ischar(directory) %using 'char' on nested cell doesn't work
    directory = directory{1};
end

%% fall back directories if the default, or user selected one doesn't exist
if ~exist(directory,'dir'), directory = f_UserPref( 'Project' ); end
if ~exist(directory,'dir'), directory = f_UserPref( 'Raw_Data' ); end

%% Asks user for paths or directory data%
if opt.loadDir
    pathname = uigetdir(directory, opt.headStr);
    pathname = [pathname,'\'];
    
    fileStructure = dir([pathname,'*',opt.type]);
    
    filenames = cell(size(fileStructure,1),1);
    for n = 1 : size(fileStructure,1)
        filenames{n,1} = fileStructure(n,1).name;
    end
else
    [filenames, pathname] = uigetfile(opt.type,opt.headStr,directory,'MultiSelect', 'on');
    if iscell(pathname), pathname = cellstr(pathname); end
end

%% Combines pathname and filenames to give fullpaths
if ischar(pathname)
    fullpaths = strcat(pathname,filenames);
    if length(fullpaths) == 1
        fullpaths = fullpaths{1};
    end
    
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
        
        %% Selects only files that match selected criteria (enabled by opt.dataType)
        if ~isempty(opt.dataType) % Special processing if requested
            %Special processing for TA data
            if strcmp(opt.dataType, 'TA')
                fullpaths = fullpaths(~cellfun(@isempty, strfind(fullpaths,'Camera'))); %returns Camera files
                photoFullpaths = fullpaths(~cellfun(@isempty, strfind(fullpaths,'PhotoDiodes'))); %returns PD files
            elseif strcmp(opt.dataType, 'RawTA')
                fullpaths = fullpaths(~cellfun(@isempty, strfind(fullpaths,'RawCamData'))); %returns Camera files
            else
                %Processing for other string just searches for that string in
                %files and returns only those containing string
                if ischar(opt.dataType)
                    fullpaths = fullpaths(~cellfun(@isempty, strfind(fullpaths,char(opt.dataType))));
                end
            end
        end
        
        %% Find the Name of dataset
        C = textscan(fullpaths{1},'%s', 'Delimiter', '\\');
        parentFolder = C{1,1}{end-1,1};
        fileName = C{1,1}{end,1};
        loc = strfind(fileName,'PlotData');
        if isempty(loc)
            loc = strfind(fileName,'_Timeseries');
            if isempty(loc), loc = length(fileName); end
            name = fileName(1:(loc(1)-1));
        else
            name = parentFolder;
        end
    end
else
    fullpaths = [];
    name = [];
    photoFullpaths = [];
    pathname = [];
    filenames = [];
end

%% Returns name as cell (always)
if isa(name,'char')
    name = {name};
end
if isa(pathname,'char')
    pathname ={pathname};
end

end
