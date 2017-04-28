
opt.noise_limit = 0.5E-3;

dir = 'V:\Shyamal Prasad\Raw Data\20170406 - FTAZ_Zhan\SP220J (3) FTAZ-IDIC-DIO-ZnO [Film] 8uW (712-fs) DUAL\';
config_dir = 'V:\Shyamal Prasad\Raw Data\20170406 - FTAZ_Zhan\Configuration\';

load([config_dir,'experimental_paramaters.mat']);

file(1).name = 'Labview_Processing_LightWiseCMOS_04.csv';
file(1).type = 'LightWiseCMOS';
file(2).name = 'Labview_Processing_Stressing_04.csv';
file(2).type = 'Stressing';

wave_limits = [experimental_paramaters.wavelength.limits];
wave_limits = [round(min(wave_limits),3,'significant'),round(max(wave_limits),3,'significant')];

wave_new = flipud([wave_limits(1):0.002:wave_limits(2)]');
    
    
for j = 1 : length(file)
    [data_temp,time_temp] = f_LoadTA([dir,file(j).name]);
    if j == 1
        time = time_temp;
        data_working = nan(length(time),length(wave_new),length(file));
        background = nan(length(wave_new),length(file));
        weightings = nan(length(wave_new),length(file));
        data_points = nan(length(wave_new),length(file));
    else
        data_temp = interp1(time_temp,data_temp,time);
    end
    %% Pick out wavelength
    i = strcmp({experimental_paramaters.wavelength.type},file(j).type);
    wave_temp = experimental_paramaters.wavelength(i).wave;
    %% Subtract Background
    [data_temp, background_temp] = f_SubtractBG(data_temp, time_temp, -1E-12);
    %% Estimate SD
    [~,neg_time] = min(abs(time_temp - -1E-12));
    SD = std(data_temp(1:neg_time,:),1);
    %% Trim data
    remove = SD > opt.noise_limit;
    if sum(remove) >= size(data_temp,2)*0.5
        remove = ~remove;
        warning('50% wavelengths are below the requested S/N threshold. Processing without trimming data.')
    end
    data_temp(:,remove) = [];
    SD(remove) = [];
    wave_temp(remove) = [];
    %% Put on common wave axis
    [data_working(:,:,j),data_points(:,j)] = f_AverageInterpolate(wave_temp, data_temp, wave_new);
    weightings(:,j) = f_AverageInterpolate(wave_temp, 1./(SD.^2), wave_new);
end

%NaN values with high ratio (probably noise in one camera)
if size(weightings,2) > 1
    wt_threshold = 10;
    w_ratio = weightings(:,1)./weightings(:,2);
    weightings(w_ratio>wt_threshold,2) = nan; % 2 times larger
    w_ratio = weightings(:,2)./weightings(:,1);
    weightings(w_ratio>wt_threshold,1) = nan;% 2 times larger
end

weightings_save = weightings;

data_working_weighted = bsxfun(@times, permute(data_working,[2,3,1]), weightings);
data_final = squeeze(nansum(data_working_weighted,2));
data_final = bsxfun(@rdivide,data_final,nansum(weightings,2));
data_final = data_final';

f_Plot(data_final,time,wave_new,1,'zLim',f_zLim(data_final,'nth',30));