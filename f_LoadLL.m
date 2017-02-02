function [output, dataAll] = f_LoadLL( directory )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


waveToCheck = [350,450,550,650,750,850,1000,1200,1400,1600];

opt.plotR = 0;

allFiles = dir(directory);
match = regexp({allFiles.name},'^L{0,2}[0-9]{3,4}'); %^<-new line, {x,y}<-between x and y matches, [0-9]<- any number between  0 and 9
match = ~cellfun(@isempty,match);
notchFiles = {allFiles(match).name}';
notchDate = {allFiles(match).date}';
notchDate = cellfun(@datenum,notchDate);

if ~isempty(notchFiles)
    output(length(notchFiles),1).tragetPixel = [];
    output(length(notchFiles),1).FWHM = [];
    output(length(notchFiles),1).refrenceWave = [];
    output(length(notchFiles),1).residual = [];
    output(length(notchFiles),1).Date = [];
    for n = 1 : length(notchFiles)
        data = importdata([directory,notchFiles{n}]);
        
        if size(data,1) > 1000
            iStart = 20;
            iEnd = 950;
        else
            iStart = 1;
            iEnd = size(data,1);
        end
        [output(n).tragetPixel, output(n).FWHM, ~, dataPred] = f_GaussianFit(data(iStart:iEnd,2), data(iStart:iEnd,1),'plotR',n*opt.plotR, 'name', ['LL',num2str(waveToCheck(n))]);
        output(n).tragetPixel = output(n).tragetPixel + iStart - 1;
        output(n).residual = sum([data(iStart:iEnd,2)- dataPred].^2);
        rWave = regexp(notchFiles{n},'[0-9]+','match');
        output(n).refrenceWave = str2num(rWave{1});
        output(n).Date = notchDate(n);
        
        if n == 1
            dataAll = zeros(size(data,1),length(notchFiles)+1);
            dataAll(:,1:2) = data;
        else
            dataAll(:,n+1) = data(:,2);
        end
    end
    
    if size(dataAll,2) > 3
        remove = [output(:).FWHM] > length(dataAll)/10;
        output(remove) = [];
        dataAll = dataAll(:,[true,~remove]);
    end
else
    
    output.tragetPixel = [];
    output.refrenceWave = [];
    output.residual = [];
    output.Date = [];
    dataAll = [];
end

end

