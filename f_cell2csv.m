
function f_cell2csv(filename, cellArray, delimiter, append)
% Writes cell array content into a *.csv file.
%
% CELL2CSV(filename,cellArray,delimiter)
%
% filename      = Name of the file to save. [ i.e. 'text.csv' ]
% cellarray    = Name of the Cell Array where the data is in
% delimiter = seperating sign, normally:',' (default)
%
% by Sylvain Fiedler, KA, 2004
% modified by Rob Kohr, Rutgers, 2005 - changed to english and fixed delimiter
if nargin<3
    delimiter = ',';
end
if nargin<4
    append = 0;
end
if isa(filename,'cell')
    filename = char(filename);
end

if isa(cellArray,'struct')
    fieldNames = fieldnames(cellArray);
    fieldSize = zeros(size(fieldNames,1),2);
    for n = 1 : size(fieldNames,1)
        fieldSize(n,:) = size(cellArray.(fieldNames{n}));
    end
    dataIndex = find(fieldSize(:,1) > 1 & fieldSize(:,2) > 1);
    data = cellArray.(fieldNames{dataIndex(1)});
    fieldSize(dataIndex(1),:) = [];
    fieldNames(dataIndex(1),:) = [];

    Xindex = find(fieldSize(:,1) == size(dataIndex,2) | fieldSize(:,2) == size(dataIndex,2));
    X = cellArray.(fieldNames{Xindex(1)});
    fieldSize(Xindex(1),:) = [];
    fieldNames(Xindex(1),:) = [];

    Yindex = find(fieldSize(:,1) == size(dataIndex,1) | fieldSize(:,2) == size(dataIndex,1));
    Y = cellArray.(fieldNames{Yindex(1)});

    if size(X,2) > 1, X = X'; end
    if size(Y,1) > 1, Y = Y'; end

    cellArray = [[NaN,Y];[X,data]];

    if ~isa(cellArray,'cell')
        cellArray = num2cell(cellArray);
    end
end

if append
    datei = fopen(filename,'a');
else
    datei = fopen(filename,'W');
end

if datei < 0
    if append
        datei = fopen([filename(1:end-9),'.csv'],'a');
    else
        datei = fopen([filename(1:end-9),'.csv'],'W');
    end
    
end

try
    for z=1:size(cellArray,1)
        for s=1:size(cellArray,2)
            
            var = eval(['cellArray{z,s}']);
            
            if size(var,1) == 0
                var = '';
            end
            
            if isnumeric(var) == 1
                var = num2str(var);
            else
                var = strrep(var, '%', '%%');
                var = strrep(var, '\', '\\');
            end
            fprintf(datei,var);
            if s ~= size(cellArray,2)
                fprintf(datei,[delimiter]);
            end
        end
        fprintf(datei,'\n');
    end
    fclose(datei);
catch ME
    fclose(datei);
    throw(ME)
end
