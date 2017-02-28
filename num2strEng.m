function xstr=num2strEng(x,varargin)

% function xstr=num2strEng(x,[n])
%
% Converts the vector of numbers in x to a string array with mantissa and
% metric prefix, e.g. 1e-10 -> '100 p'
%
% Numbers out of the range 1e-24 <= x < 1e27 are left unscaled
% Enforces a column result
% Can optionally specify length for num2str

prefices={'Y','Z','E','P','T','G','M','k','','m','\mu','n','p','f','a','z','y'};


%x=x(:);
logx=log10(x);
logbase=3*floor(logx/3);

inrange=(logbase>=-24)&(logbase<=24);
logbase(~inrange)=0;

ibase=1-(logbase-24)/3; %

if ~isempty(varargin)
    n=varargin{1};
else
    n=-1;
end

if length(varargin) > 1
    prefices{11} = 'u';
end

%xstr=[feval('num2str',x./10.^logbase,n) repmat(' ',length(x),1) strvcat(prefices{ibase})];
if size(x,2) > 1
    xstr=strcat(strtrim(cellstr(num2str(x(:,1)./10.^max(logbase,[],2),n))),'-',strtrim(cellstr(num2str(x(:,2)./10.^max(logbase,[],2),n))),strcat({' '},prefices(min(ibase,[],2))'));
else
    if length(varargin) > 1
        
    xstr=strcat(num2str(x./10.^logbase,n),strcat({' '},prefices(ibase)'));
    else
        xstr=strtrim(strcat(num2str(x./10.^logbase,n),strcat({' '},prefices(ibase)')));
    end
end

if length(xstr) == 1
    xstr = xstr{1};
end
if  isempty(xstr)
    xstr = '';
end

xstr = strtrim(xstr);

