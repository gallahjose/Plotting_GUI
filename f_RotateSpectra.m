function [ Spectra_New, w, offset, Target ] = f_RotateSpectra( Spectra, Target, Wave, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

opt.offset = 1;
opt.PlotD = 0;
opt.PlotR = 1;
opt.Non_Negtaive = 1;
% user input 
[opt] = f_OptSet(opt, varargin);

if size(Spectra,1) < size(Spectra,2), Spectra = Spectra'; end
if size(Target,1) < size(Target,2), Target = Target'; end

% rotate and offset to find matching spectra
if opt.offset
    offsetTrial = -15:0.25:15;
    res = zeros(length(offsetTrial),1);
    for j = 1 : length(offsetTrial)
        Target_temp = interp1(Wave,Target,Wave + offsetTrial(j));
        
        removeNaN = sum(isnan(Target_temp),2) > 0;
        Target_temp = Target_temp(~removeNaN,:);
        Spectra_temp = Spectra(~removeNaN,:);
        Wave_temp = Wave(~removeNaN);
        
        %
        
        %X = A\B A*X = B
        w = zeros(size(Spectra_temp,2),size(Target_temp,2));
        Spectra_New = zeros(size(Target_temp));
        for n = 1 : size(Target_temp,2)
            if opt.Non_Negtaive
                w(:,n) = lsqnonneg(Spectra_temp,Target_temp(:,n));
            else
                w(:,n) = Spectra_temp\Target_temp(:,n);
            end
            Spectra_New(:,n) = Spectra_temp*w(:,n);
        end
        
        if opt.PlotD
            f_Plot([Target_temp,Spectra_New], Wave_temp,1,'PlotStyles',[0.5,0.5,0.5;0,0,0;1,0.5,0.5;0.5,0.5,1]);
            pause(0.1)
        end
        res(j) = sum(sum((Target_temp - Spectra_New(:,1:size(Target_temp,2))).^2));
    end
    
    [~, I] = min(res);
    offset = offsetTrial(I);
    Target = [interp1(Wave,Target,Wave +offset)];
    Target(isnan(Target)) = 0;
else
   offset = 0; 
end

removeNaN = sum(isnan(Target),2) > 0;
Target_temp = Target(~removeNaN,:);
Spectra_temp = Spectra(~removeNaN,:);
%X = A\B A*X = B
w = zeros(size(Spectra,2),size(Target,2));
Spectra_New = zeros(size(Target));
for n = 1 : size(Target,2)
    if opt.Non_Negtaive
        w(:,n) = lsqnonneg(Spectra_temp,Target_temp(:,n));
    else
        w(:,n) = Spectra_temp\Target_temp(:,n);
    end
    Spectra_New(:,n) = Spectra*w(:,n);
end

if opt.PlotR
    Target_temp = Target./max(Target(:));
    Spectra_temp = Spectra./max(Spectra(:));
    [ h, fh, positions] = f_MultiLinLogAxes( 2, 1, 'rowStyles',{'Linear'});
    f_Plot([Target_temp,Spectra_temp],Wave,h(1),'PlotStyles',[0.5,0.5,0.5;0,0,0;1,0.5,0.5;0.5,0.5,1]);
    f_Plot([Target,Spectra_New], Wave,h(2),'PlotStyles',[0.5,0.5,0.5;0,0,0;1,0.5,0.5;0.5,0.5,1]);
end
end

