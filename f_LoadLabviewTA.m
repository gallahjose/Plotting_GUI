function [Results] = f_LoadLabviewTA(file_pointer, previous_output,varargin)
%[Results] = f_LoadLabviewTA(file_pointer, previous_output)
%   Detailed explanation goes here
new_data = 0;
opt.save = 1;
opt.flip_data = [0,0];



[opt] = f_OptSet(opt, varargin);
%% Looks for directory
if ~exist('file_pointer','var') || isempty(file_pointer)
    file_pointer = '\\resstococifs001.res.vuw.ac.nz\SCPS_UltraFast_01\';
end

if ~exist('previous_output','var')
    refresh_data = 1;
    Results.Directory = '';
else
    refresh_data = 0;
    if ~isfield(previous_output,'Directory'), previous_output.Directory = ''; end
    Results = previous_output;
end

if exist([file_pointer,'UltrafastTA.csv'],'file')
    [ run_details ] = f_readCSV( [file_pointer,'UltrafastTA.csv'], ',');
    folderName = strsplit(run_details{1,2},'\');
    folderName = folderName{end};
    directory = run_details{1,2};
else
    if strcmp('\',file_pointer(end)), file_pointer(end) = []; end
    directory = file_pointer;
    folderName = regexp(directory,'\\(?!.*\\)');
    folderName = directory(folderName+1:end);
end

%% Extracts Name
directory = [directory,'\'];
index1 = regexp(folderName,')');
index2 = regexp(folderName,'[');
try
    index1 = index1(1)+2;
    index2 = index2(1)-1;
    Name = folderName(index1:index2);
catch
    Name = folderName;
end
Results.Name = Name;

%% Sets Status
Results.New_data = 0;

%% Extracts Data Files of Interest
files = dir(directory);
files([files.isdir]) = [];

file_size = [files.bytes]';
files = {files.name}';

%% Checks for to refresh data
if ~strcmp(directory,Results.Directory)
    refresh_data = 1;
end

%% If loading from new dataset
if refresh_data
    Results.Directory = directory;
    Results.Camera = [];
    
    camera_types = regexp(files,'^[^_]*_(?=.*Write Raw Data)','match');
    camera_types(cellfun(@isempty,camera_types)) = [];
    camera_types = cellfun(@(x) x{1}(1:end-1),camera_types,'UniformOutput',0);
    camera_types = unique(camera_types);
    for n = 1 : length(camera_types)
    Results.Camera(n).Type = camera_types{n};
    Results.Camera(n).Writer = {};
    Results.Camera(n).Old_Size = [];
    Results.Camera(n).New_Size = [];
    Results.Camera(n).Pixels = [];
    Results.Camera(n).Data = [];
    end
    
    % Phrases Configuration File
    index = ~cellfun(@isempty,regexp(files,'.*Configuration.csv'));
    config_file = files(index);
    config = f_readCSV([Results.Directory,config_file{1}],',');
    index = cellfun(@(x) all(isstrprop(x,'digit')),config(:,2));
    numbers = cellfun(@str2double,config(index,2),'Uniformoutput',0);
    config(index,2) = numbers;
    config(:,1) = strrep(config(:,1),'(','');
    config(:,1) = strrep(config(:,1),')','');
    Results.RunDetails = cell2struct(config(:,2),config(:,1));
end

%% Find matching files description
for n = 1 : length(Results.Camera)
    writer_index = find(~cellfun(@isempty,regexp(files,[Results.Camera(n).Type,'.*_Write Raw Data'])));
    writer_index(~cellfun(@isempty,regexp(files(writer_index),'Static'))) = [];
    writer = files(writer_index);
    
    current_writers = Results.Camera(n).Writer;
    for j = 1 : length(writer)
        if ~isempty(current_writers)
            match = strcmp(writer{j},current_writers(:,1));
        else
            match = false;
        end
        if any(match)
            Results.Camera(n).New_Size(match,1) = file_size(writer_index(match));
        else
            pos = size(Results.Camera(n).Writer,1)+1;
            Results.Camera(n).Writer{pos,1} = writer{j};
            Results.Camera(n).Old_Size(pos,1) = 0;
            Results.Camera(n).New_Size(pos,1) = file_size(writer_index(j));
        end
    end
    
    timing_index = find(~cellfun(@isempty,regexp(files,[Results.Camera(n).Type,'.*TimingData'])));
    timing_index(~cellfun(@isempty,regexp(files(timing_index),'Static'))) = [];
    Results.Camera(n).Timing_File = files(timing_index);
end

%% Loads data
for n = 1 : length(Results.Camera)
    new_data = 0;
    % make writer field
    if ~isfield(Results.Camera(n).Data,'Writer')
        Results.Camera(n).Data.Writer = [];
    end
    % make field correct size
    if size(Results.Camera(n).Data,1) < size(Results.Camera(n).Writer,1)
        Results.Camera(n).Data(size(Results.Camera(n).Writer,1)).Writer = [];
    end
    
    for j = 1 : size(Results.Camera(n).Writer,1)
        
        if Results.Camera(n).Old_Size(j) ~= Results.Camera(n).New_Size(j)
            % Remove info pixels
            if Results.Camera(n).Old_Size(j) == 0
                fileID = fopen([Results.Directory,Results.Camera(n).Writer{j}],'r');
                Results.Camera(n).Pixels(j) = fread(fileID,1,'double');
                fclose(fileID);
                Results.Camera(n).Old_Size(j,1) = 80;
            end
            
            numPixels = Results.Camera(n).Pixels(j);
            numShots = ((Results.Camera(n).New_Size(j) - Results.Camera(n).Old_Size(j))/8)/numPixels;
            
            new_data = multibandread([Results.Directory,Results.Camera(n).Writer{j}],...
                [numShots, numPixels, 1], 'double', Results.Camera(n).Old_Size(j,1),...
                'bsq','ieee-le',...
                {'Column', 'Range', [1 numPixels]});
            
            if opt.flip_data(n)
                new_data(:,2:end) = new_data(:,2:end)*-1;
            end
            
            Results.Camera(n).Data(j).Writer = [new_data; Results.Camera(n).Data(j).Writer];
            Results.Camera(n).Old_Size(j) = Results.Camera(n).New_Size(j);
            
            Results.New_data = 1;
            new_data = 1;
        end
    end
    
    %% Add wavelength calibration
    if ~isfield(Results.Camera(n),'Wave')
        %wave_dir{n} = 'V:\Shyamal Prasad\Raw Data\20160113 - Monash Polymer Blends\Configuration\';
        %wave_temp = f_WavelengthFit(wave_dir{n},'plotR',1,'camera_type',Results.Camera(n).Type);
    end
    %% Process new data
    if  new_data
       % working_data = Results.Camera(n).Data(:,2:end);
       for j = 1 : length(Results.Camera(n).Data)
         start(j) = Results.Camera(n).Data(j).Writer(1,1);
         row(j) = size(Results.Camera(n).Data(j).Writer,1);
         column(j) = size(Results.Camera(n).Data(j).Writer,2);
       end
       [~,I] = sort(start);
       working_data = nan(max(row),sum(column));
       start_col = 1;
       for j = 1 : length(Results.Camera(n).Data)
           temp_data = Results.Camera(n).Data(I(j)).Writer;
           end_col = start_col + size(temp_data,2)-1;
           working_data(1:size(temp_data,1),start_col:end_col) = temp_data;
           start_col = end_col + 1;
       end
       working_data = working_data'; 
       working_data = reshape(working_data(:),column(1),[])'; 

        time = working_data(:,1)*1E-15;
        working_data = working_data(:,2:end);
        
        if max(abs(time)) < 10E-9 % using delay generator (if untrue)
            if min(time) > -15E12
                time = time*2;
            end
        end
        % Removes bad time points
        remove = time == 0 ;
        remove(isnan(time)) = true;
        working_data(remove,:) = [];
        time(remove) = [];
        
        [time,~,IC] = unique(time);
        [bins,index] = hist(IC,length(time));
        DeltaTT = nan(length(time),numPixels-1,max(bins(1:end-1)));
        for j = 1 : size(DeltaTT,1)
            I = sum(IC==j);
            DeltaTT_temp = [working_data(IC==j,:)]';
            if I > size(DeltaTT,3)
                I = size(DeltaTT,3); 
            end
            DeltaTT(j,:,1:I) = DeltaTT_temp(:,1:I);
        end
        
        %assignin('base',['power_data_',num2str(n)],DeltaTT);
        %assignin('base',['power_time_',num2str(n)],time);
        
        Results.Camera(n).DeltaTT_All = DeltaTT;
        
        % add in a filter..
        data_filter = Results.Camera(n).DeltaTT_All;
        
        z_score = zscore(data_filter,0,3);
        
        data_filter(abs(z_score) > 3) = nan;
        
        
        DeltaTT = nanmean(data_filter,3);
        
        Results.Camera(n).DeltaTT = DeltaTT;
        Results.Camera(n).Time = time;
        
        %% Loads timing data
        Results.Camera(n).Timing_Data = [];
        time_loaded = [];
        for j = 1 : length(Results.Camera(n).Timing_File)
            timing_path = [Results.Directory,Results.Camera(n).Timing_File{j}];
            [ timing_data ] = f_readCSV( timing_path, ',' );
            time_loaded_temp = [
                cellfun(@(x) str2num(x(1:end-3)),timing_data(2:end,1))*1E-15,...
                cellfun(@(x) datenum(x,'HH:MM:SS.FFF ddmmyyyy')*24*60*60,timing_data(2:end,2)),...
                cellfun(@str2num,timing_data(2:end,3)),...
                ];
            time_loaded = [time_loaded; time_loaded_temp];
        end
        Results.Camera(n).Timing_Last = time_loaded(end,2) + time_loaded(end,3);
        time_loaded(2:end,2) = time_loaded(2:end,2) - time_loaded(1:end-1,2);
        time_loaded(1,2) = 0;
        Results.Camera(n).Timing_Data = time_loaded;
    end
end

%% Saves data
if new_data && opt.save
    for n = 1 : length(Results.Camera)
        % checks if there is more than 5 pervious versions
        current_camear = Results.Camera(n);
        save_name = ['Labview_Processing_', current_camear.Type];
        %saved_data = files(~cellfun(@isempty,regexp(files,[save_name,'.*\.csv'])));
        
        number_runs = size(current_camear.DeltaTT_All,3);
        
        %save_name = [save_name,'_',num2str(number_runs,'%02d'),' [',datestr(now,'HHMM.SS dd-mm-YY'),'].csv'];
        save_name = [save_name,'_',num2str(number_runs,'%02d'),'.csv'];
        try
            wave = [1:size(current_camear.DeltaTT,2)]';
            output_file = [NaN,wave';current_camear.Time,current_camear.DeltaTT];
            csvwrite([directory,save_name],output_file);
        catch ME
            
        end
    end
end
end
