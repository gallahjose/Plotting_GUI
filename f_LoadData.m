function [ data, time, wave ] = f_LoadData( fullpath )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1, fullpath = f_GetPath(); end

GData = 1;
GTime = 1;
GWave = 1;

S = importdata(char(fullpath));

if isa(S,'struct')
    if GData
        data = S.data(:, 2:end);
    end
    if GTime
        time = S.data(:, 1:1);
        time = 1e-15*time;
    end
    if GWave
        wave = S.textdata(2:2, 2:end);
        for n=1:length(wave)
            wave(n) = strtok(wave(n), 'nm');
        end
        wave = char(wave);
        wave = str2num(wave);
    end
end

if isa(S,'float')
    if GData
        data = S(2:end, 2:end);
    end
    if GTime
        time = S(2:end, 1:1);
    end
    if GWave
        wave = (S(1:1, 2:end))';
    end
end

end

