function [output, dataAll, dataPredAll] = f_LoadLL( directory, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


waveToCheck = [350,450,550,650,750,850,1000,1200,1400,1600];

opt.plotR = 1;
opt.iEnd = [];
opt.removeOutliers = 1;
opt.outlier_scalar = 0.0001;
opt.outlier_fwhm = 2.5; %z-score
% user input (after autodetection to allow user options)
[opt] = f_OptSet(opt, varargin);

if exist(directory,'dir')
    allFiles = dir(directory);
else
    warning(['Wavelength directory doesn''t exists. ',directory])
end

match = regexp({allFiles.name},'^L{0,2}[0-9]{3,4}'); %^<-new line, {x,y}<-between x and y matches, [0-9]<- any number between  0 and 9
match = ~cellfun(@isempty,match);
% check configuration folder
if isempty(match)
    
end
% check calib folder
if isempty(match)
    
end

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
            iStart = 1;
            if isempty(opt.iEnd)
                iEnd = 1024;
            else
                iEnd = opt.iEnd;
            end
        else
            iStart = 1;
            iEnd = 240;
        end
        [output(n).tragetPixel, output(n).FWHM, scaler, dataPred] = f_GaussianFit(data(iStart:iEnd,2), data(iStart:iEnd,1),'plotR',0, 'name', notchFiles{n});
        output(n).tragetPixel = output(n).tragetPixel + iStart - 1;
        output(n).scaler = scaler(1);
        output(n).residual = sum([data(iStart:iEnd,2)- dataPred].^2);
        rWave = regexp(notchFiles{n},'[0-9]+','match');
        output(n).refrenceWave = str2num(rWave{1});
        output(n).Date = notchDate(n);
        notch_name = regexp(notchFiles{n},'.csv','split');
        output(n).Name = notch_name{1};
        
        if n == 1
            dataAll = zeros(size(data(iStart:iEnd,1),1),length(notchFiles)+1);
            dataAll(:,1) = data(iStart:iEnd,1);
            dataAll(:,2) = data(iStart:iEnd,2) - scaler(2);
            dataPredAll = nan(size(data(iStart:iEnd,1),1),length(notchFiles)+1);
            dataPredAll(:,1) = data(iStart:iEnd,1);
            dataPredAll(iStart:iEnd,2) = dataPred - scaler(2);
        else
            dataAll(1:size(data(iStart:iEnd,1),1),n+1) = data(iStart:iEnd,2) - scaler(2);
            dataPredAll(iStart:iEnd,n+1) = dataPred - scaler(2);
        end
    end
    %% Removes outliers
    if opt.removeOutliers
        
        remove = find([output.scaler] < opt.outlier_scalar);
        output(remove) = [];
        dataAll(:,remove+1) = [];
        dataPredAll(:,remove+1) = [];
        
        z_score = zscore([output.FWHM]);
        remove = find(abs(z_score)>opt.outlier_fwhm);
        
        output(remove) = [];
        dataAll(:,remove+1) = [];
        dataPredAll(:,remove+1) = [];
        
        
    end
    
    %% Sorts output
    refrenceWave = [output.refrenceWave];
    %if max(refrenceWave) > 1200
    %    refrenceWave = refrenceWave/1000;
    %    unit = {' \mum'};
    %else
        unit = {' nm'};
    %end
    [refrenceWave, I] = sort(refrenceWave);
    output = output(I);
    dataPredAll(:,2:end) = dataPredAll(:,I+1);
    dataAll(:,2:end) = dataAll(:,I+1);
    %% Makes single plot with all results
    scaler = max(dataPredAll(:,2:end));
    scaler(scaler==0) = 1; % remove zero;
    Legend = strcat(arrayfun(@num2str,[refrenceWave],'UniformOutput',0),unit);
    h = f_Plot(bsxfun(@rdivide,dataAll(:,2:end),scaler),dataAll(:,1),opt.plotR,'Ylim',[-0.05,1.2],...
        'FontScaler',1,'Ylabel','Normalized Intensity','Legend',Legend,'axestitle','Notch Positions');
    f_Plot(bsxfun(@rdivide,dataPredAll(:,2:end),scaler),dataAll(:,1),h,'Hold',1,'LineStyle','-','PointStyle','','RemoveLegend',1);
else
    
    output.tragetPixel = [];
    output.refrenceWave = [];
    output.residual = [];
    output.Date = [];
    dataAll = [];
end

end

