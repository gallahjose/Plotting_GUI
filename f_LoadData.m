function [ data, time, wave, units] = f_LoadData( fullpath )
%[ data, time, wave ] = f_LoadData( fullpath )
% Loads data that has been created by Labview or Matlab
%
%   %%Inputted Values
%   fullpath            path/s to files to be loaded
%
%   %%Returned Values
%   data                nxm matrix of intensity values
%   wave                mx1 row of wavelengths (or pixel)
%   time                nx1 row of time points
%
%   %%Options
%
%   06-07-14 Shyamal - inital updated


%% Check input varibales
if ~exist('fullpath','var') 
    fullpath = f_GetPath(f_UserPref( 'Project' ), 'dataType', 'TA'); 
end

%% Uses matlab to import the file in fullpath
S = importdata(char(fullpath));

%% Loads Data
if isa(S,'struct') %TA data saved by Labview
    if size(S.textdata,2) > 1
        data = S.data(:, 2:end);
        time = S.data(:, 1:1);
        wave = S.textdata(2:2, 2:end);
        wave = cell2mat(cellfun(@(x) str2num(x(1:end-2)),wave,'UniformOutput',false))'; % converts wave to double and removes nm from end
        units = '\DeltaT/T';
    else
        data = S.data(2:end, :);
        time = S.textdata(2:end, 1);
        wave = S.data(1, :)';
        time = cellfun(@str2num,time); % converts wave to double and removes nm from end
        units = S.textdata{1,1};
    end
elseif isa(S,'float') % TA data saved by matlab
    units = '\DeltaT/T';
    data = S(2:end, 2:end);
    time = S(2:end, 1:1);
    wave = (S(1:1, 2:end))';
end


%% Checks for unused pixel values
data = data(:,sum(data,1)~=0);
wave = wave(sum(data,1)~=0,1);

%% Process ChannelAChannelB
if size(data,2) == 504
    data = data(:,1:252);
    wave = wave(1:252);
end

%% Correction options for different datasets
if abs(time(1)) > 100 %checks if data is in fs or s
    time = time.*1E-15;
end
% Checks that wave and time arrays are ordered highest to lowerst
if wave(1) > wave(end)
    wave = wave(linspace(length(wave),1, length(wave)));
    data = data(:,linspace(length(wave),1, length(wave)));
end
if time(1) > time(end)
    time = time(linspace(length(time),1, length(time)));
    data = data(linspace(length(time),1, length(time)),:);
end

if ~sum(wave)
    wave = 1:length(wave);
end
