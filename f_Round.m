function [ xr, x ] = f_Round( x, sf, direction)
%[ xr, x ] = f_Round( x, sf, direction) 
%Rounds number to requested significant figure (sf) in requested 
%direction (ceil, floor, round)

if ~exist('sf','var'), sf = 2; end
if ~exist('direction','var'), direction = 'round'; end

zeroIndex = x == 0;

xr = eval([direction,'( x ./ 10.^( floor(log10(abs(x)))-sf+1) ) .* 10.^(floor(log10(abs(x)))-sf+1)']);

xr(zeroIndex) = 0;

end

