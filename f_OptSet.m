function [opt] = f_OptSet(opt, newOpt)
%[opt] = f_OptSet(opt, newOpt)
%   Detailed explanation goes here


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

