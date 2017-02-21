function [opt] = f_OptSet(opt, newOpt, outputWarning)
%[opt] = f_OptSet(opt, newOpt)
%   updates options (opt.'...') for functions writen by Shyamal
%
%   %%Inputed Values
%   'opt'               structure containing current options
%   'newOpt'            cell array with (from varargin) that has option
%                       name, then new value.
%   'outputWarning'     set if display of warnings for options that don't
%                       exist
%
%   %%Returned Values
%   'opt'               structure containing the updated options
%
%   %%Options
%   'warning'            Label for plot x-axis
%                       default = auto detect [Pixel, Time (s), Wavelength (nm)]
%
%   18-04-14 Shyamal - inital updated


% user input
for i = 1 : floor(length(newOpt)/2)
    if any(strcmp(newOpt{2*i-1},fieldnames(opt))) %Checks if field exists
        par = newOpt{2*i};
        if ~isempty(par) || strcmp(par,'');
        opt.(newOpt{2*i-1}) = par; %set option
        end
    else % Warning if field doesnt exist
        if isa(newOpt{2*i-1}, 'char')
            warning(['Option "', newOpt{2*i-1}, '" does not exist, ignoring'])
        else
            warning(['Option "', num2str(newOpt{2*i-1}), '" does not exist, ignoring'])
        end
    end
end

%varargin = [];

end

