function [ finalData ] = f_readCSV( fullpath, delimiter )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


fid = fopen(fullpath,'r');
A = textscan(fid, '%s', 'delimiter', '\n', 'MultipleDelimsAsOne', 0);
fclose(fid);

%% Removes empty values
A = A{1,1};
A = A(~cellfun('isempty',A));

%% phrases file into cells
for n = 1 : length(A)
    A(n,1) = textscan(A{n,1}, '%s', 'delimiter', delimiter, 'MultipleDelimsAsOne', 0)';
end
SizeArray = cellfun(@length,A);
finalData = cell(size(A,1),max(SizeArray));
for n = 1 : length(A);
    finalData(n,1:length(A{n,1})) = A{n,1}';
end

end

