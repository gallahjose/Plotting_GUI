function [ finalData ] = f_readFile( fullpath, delimiter, formatspec )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2, delimiter = ','; end
if nargin < 3, formatspec = '%s'; end

if iscell(fullpath), fullpath = fullpath{1}; end

fid = fopen(fullpath,'r');
A = textscan(fid, '%s', 'delimiter', '\n', 'MultipleDelimsAsOne', 0,'EmptyValue',Inf);
fclose(fid);

fid = fopen(fullpath,'r');
B = fread(fid);
fclose(fid);
fid = fopen(fullpath,'r');
C = textscan(fid, '%s', 'delimiter', '\t', 'MultipleDelimsAsOne', 0);
fclose(fid);
C = C{1,1};
B = char(B);
NLfeed = regexp(B','[\n\r]');
delimiter = regexp(B','\t');
Index = zeros(length(NLfeed)+1,1);
for n = 2 : length(NLfeed);
    Index(n) = sum(delimiter < NLfeed(n));
end
Index = unique(Index);
D = cell(length(Index)-1,1);
for n = 2 : length(Index);
    D{n-1} = C(Index(n-1)+1:Index(n));
end
SizeArray = cellfun(@length,D);
finalData = cell(size(D,1),max(SizeArray));
for n = 1 : length(D);
    finalData(n,1:SizeArray(n)) = D{n,1}';
end

%% Removes empty values
A = A{1,1};
A = A(~cellfun('isempty',A));

%% phrases file into cells
try
if strcmp(formatspec,'%f')
    B = textscan(A{1,1}, formatspec, 'delimiter', delimiter, 'MultipleDelimsAsOne', 0,'EmptyValue',Inf);
    B = B{1,1};
    finalData = zeros(size(A,1),size(B,1));
    for n = 1 : size(finalData,1)
        B =  textscan(A{n,1}, formatspec, 'delimiter', delimiter, 'MultipleDelimsAsOne', 0,'EmptyValue',Inf);
        finalData(n,:) = B{1,1}';
    end
else
    for n = 1 : length(A)
        I = regexp(A{n,1},delimiter);
        A(n,1) = textscan(A{n,1}, formatspec, 'delimiter', delimiter, 'MultipleDelimsAsOne', 0,'EmptyValue',Inf)';
    end
    
    SizeArray = cellfun(@length,A);
    finalData = cell(size(A,1),max(SizeArray));
    for n = 1 : length(A);
        finalData(n,1:length(A{n,1})) = A{n,1}';
    end
end
catch
end
end

