function [data, background] = f_SubtractBG(data, time, presignal, varargin)
%[ data ] = f_SubtractBG(data, time, presignal, options)
%   Subtracts signal before time given by PRESIGNAL for the DATA set.
%
%   %%Returned Values
%   data                nxm matrix of intensity values with background
%                       subtracted.
%
%   %%Options
%   'threshold'         If pixel background value is below this it is set
%                       to zero.
%                       default = 1E-15
%   'minIndex'          index to start averaging to give background signal
%                       default = 1
%
%   inital updated 02-04-14 - Shyamal

%% Check input varibales
if ~exist('presignal','var')
    if max(time) < 3.2E-9 % detect if long time data
        presignal = -1.5E-12; % -1.5 ps
    else
        presignal = -1.5E-9; % -1.5 ns
    end
end

%% Sets Options
% default options
opt.threshold = 1E-15;
opt.minIndex = 1;
opt.BGdata = data;
% user input
[opt] = f_OptSet(opt, varargin);

if size(opt.BGdata,2) == length(time)
    opt.BGdata = opt.BGdata';
end

%% Calculated background
%find index of nearest time to PRESIGNAL
[~,maxIndex] = min(abs(presignal - time));
%calculates the average background spectrum
background = nanmean(opt.BGdata(opt.minIndex:maxIndex,:));
BGdata = opt.BGdata(opt.minIndex:maxIndex,:);
%sets values below threshold to zero
background(abs(background) < opt.threshold) = 0;

%% Keeps zero values as zero (zero likely due to chirp)
dataChirp = data;
dataChirp(abs(dataChirp) > 0 ) = 1;

%% Subtract Background from data
data = bsxfun(@minus,data,background);
data = data.*dataChirp;
end

