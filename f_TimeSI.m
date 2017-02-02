function [ time ] = f_TimeSI( time )
%[ time ] = f_TimeSI( time )
%   Converts value in TIME (string) to into time in seconds (double). i.e 1n -> 1E-9
%
%   %%Returned Values
%   time                TIME in secounds as a double
%
%   %%Options
%
%   inital updated 02-04-14 - Shyamal

if ischar(time) % checks if TIME contains a string
    time = char(time);
    unit = time(end);
    % Converts from sting to number and multiplies by appropriate units
    if isempty(str2num(unit))
        time = time(1:regexp(time,'[0-9.][^0-9.]')); %^ make it look for any character not 0-9
        time = str2num(time);
        if strcmp(unit, 'm')
            time = time*10^(-3); end
        if strcmp(unit, 'u')
            time = time*10^(-6); end
        if strcmp(unit, 'n')
            time = time*10^(-9); end
        if strcmp(unit, 'p')
            time = time*10^(-12); end
        if strcmp(unit, 'f')
            time = time*10^(-15); end
    else
        time = str2num(time);
    end
end
end

