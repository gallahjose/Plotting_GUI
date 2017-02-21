function [ handles ] = ProcessGUI_updater( handles, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Undo
opt.undo = 0;

%Zero data
opt.zero_data_region = handles.zero_data_region.Value;

%Altering data (scaling/normalising)
opt.scale_wave = [];

%Visualising data (make plots)
opt.make = [];
opt.concatenate = [];
opt.plot = [];
opt.plot_handles = [];
opt.plot_surf = [];
opt.add_patch = [];

%Saving data
opt.update_subdir = [];
opt.make_path = [];
opt.save = [];

[opt] = f_OptSet(opt, varargin);


%Set main items
data = handles.data;
time = handles.time;
wave = handles.wave;
data_name = handles.data_name_box.String;
save_dir_parent = handles.save_path_parent.String;

%% Undo 

if opt.undo
    opt.plot = handles.prev_plot;
    opt.plot_handles = handles.prev_plot_handle;
    string = strtrim(handles.trace_menu.String{handles.trace_menu.Value,:});
    handles = handles.prev_handles;
else
   handles.prev_handles = handles;
end

%% Zero data region

if handles.zero_data_region.Value
    
    zero_data = [str2num(handles.zero_data_limits.Data{1}), str2num(handles.zero_data_limits.Data{2})];
    
    [~, wave_min_index] = min(abs(wave-zero_data(1)));
    [~, wave_max_index] = min(abs(wave-zero_data(2)));
    
    data(:, wave_min_index:wave_max_index ) = NaN;
    handles.data = data;
end

%% Scale the wavelength array

if ~isempty(opt.scale_wave)
    wave = 1240./wave;
    wave = flipud(wave);
    data = fliplr(data);
    handles.data = data;
    handles.wave = wave;
    
    if wave(1) < 10
        handles.data_config.Data{1,3} = 'Energy (eV)';
    else
        handles.data_config.Data{1,3} = 'Wavelength (nm)';
    end
    
    handles.zero_data_limits.Data{1} = num2str(1240./(str2num(handles.zero_data_limits.Data{1})));
    handles.zero_data_limits.Data{2} = num2str(1240./(str2num(handles.zero_data_limits.Data{2})));
    
    x_range_1 = 1240./str2num(handles.data_config.Data{1,1});
    x_range_2 = 1240./str2num(handles.data_config.Data{1,2});
    
    handles.data_config.Data{1,1} = num2str(min(x_range_1, x_range_2));
    handles.data_config.Data{1,2} = num2str(max(x_range_1, x_range_2));
    
    kinetics_table = handles.traces_menu_data.Kinetics.trace_table(:,1:2);
    
    for n=1:size(kinetics_table, 1)
        if ~isempty(kinetics_table{n,1})
            kinetics_table{n,1} = num2str(1240./str2num(kinetics_table{n,1}));
            percentLoc = ~cellfun(@isempty,(regexp(kinetics_table(:,2),'.*\%')));
            if ~percentLoc(n)
                kinetics_table{n,2} = num2str(1240./str2num(kinetics_table{n,2}));
            end
        end
    end
    
    handles.traces_menu_data.Kinetics.trace_table = [kinetics_table, handles.traces_menu_data.Kinetics.trace_table(:,3)];
    cla(handles.axis_spectra, 'reset')
    pause(0.01)
    cla(handles.axis_kinetics1, 'reset')
    pause(0.01)
    cla(handles.axis_kinetics2, 'reset')
    pause(0.01)
    
end

%% Make traces
if ~isempty(opt.make)
    string = strtrim(handles.trace_menu.String{handles.trace_menu.Value,:});
    if strcmp(string, 'Kinetics')
        axes_handles = [handles.axis_kinetics1; handles.axis_kinetics2];
        trace_axes = wave;
        x_axes = time;
        units_config = 1;
        crop_values = [f_TimeSI(handles.data_config.Data{2,1}), f_TimeSI(handles.data_config.Data{2,2})];
    elseif strcmp(string, 'Spectra')
        axes_handles = [handles.axis_spectra];
        trace_axes = time;
        x_axes = wave;
        units_config = 2;
        crop_values = [str2num(handles.data_config.Data{1,1}), str2num(handles.data_config.Data{1,2})];
    end
    
    % Units come from the data_config, so they are responsive to user
    % changes.
    units = regexp(handles.data_config.Data{units_config,3},'\w*(?=\))','match'); 
    units = units{end};
    
    if isfield(handles,string), handles.(string) = []; end
    
    %make trace axes a column (downwards)
    if size(data, 1) ~= length(trace_axes)
        data = data';
    end
    
    %Organise table with data slice information
    % Wrapped in function to use elsewhere
    [table, table_num] = getGUItable(handles.trace_table.Data);
    % Updates GUI
    handles.trace_table.Data = [table;cell(6-size(table,1),3)];
    
    traces = zeros(size(x_axes,1),size(table_num,1));
    label = cell(4,1);
    
    %Type def
    for n = 1 : size(table,1)
        str = table{n,3};
        if isempty(str)
            table{n,3} = 'none';
        else
            table{n,3} = genvarname(str);
        end
    end
    
    
    %Crop data (only for traces, leaves data handle intact)
    [~, data_min_index] = min(abs(x_axes-crop_values(1)));
    [~, data_max_index] = min(abs(x_axes-crop_values(2)));
    x_axes_crop = x_axes(data_min_index:data_max_index);
    
    for n=1:size(table_num,1)
        min_index = table_num{n,1};
        max_index = table_num{n,2};
        
        [~, min_index] = min(abs(trace_axes-min_index));
        [~, max_index] = min(abs(trace_axes-max_index));
        
        % Make label for trace
        % $ options
        % one make true range str
        label{1} = [num2strEng(trace_axes(min_index),3),'-',num2strEng(trace_axes(max_index),3),...
            ' ', units, ' (',num2str(max_index-min_index+1),')' ];
        label{2} = [num2strEng(mean(trace_axes([min_index,max_index])),3),' ',units];
        label{3} = data_name;
        label{4} = [label{2}, ' (',data_name,')'];
        
        if max_index == min_index
            trace = data(min_index:max_index,:)';
        else
            difference = abs(trace_axes(max_index)-trace_axes(min_index));
            trace = (trapz(trace_axes(min_index:max_index), data(min_index:max_index,:))./difference)';
        end
        
        %Normalize data (if required)
        if handles.trace_norm_checkbox.Value
            norm_type = handles.traces_norm_menu.Value;
            if norm_type == 4 %Scalar normalization
                norm_scalar =  f_TimeSI(handles.trace_norm_min.String);
                index_norm = [];
            elseif norm_type == 3 %Point normalization
                [~,index_norm] =  min(abs(x_axes-f_TimeSI(handles.trace_norm_min.String)));
                norm_scalar = trace(index_norm);
                norm_scalar = norm_scalar;
            else
                
                [~,index_norm(1)] =  min(abs(x_axes-f_TimeSI(handles.trace_norm_min.String)));
                [~,index_norm(2)] =  min(abs(x_axes-f_TimeSI(handles.trace_norm_max.String)));
                norm_range = trace(index_norm(1):index_norm(2));
                if norm_type == 2 %Normalize by average value in range
                    norm_scalar = abs(mean(norm_range));
                else %Normalize by maximum value in range
                    [norm_scalar, index_norm(3)] = max(abs(norm_range));
                    index_norm = index_norm(3) + index_norm(1) - 1;
                    %norm_scalar = norm_scalar.*-1;
                end
                
                
            end
            
            if strcmp(string, 'Kinetics') && ~isempty(index_norm) %flips kinetics to all positive traces
                check_value = mean(trace(index_norm(1):index_norm(end)));
                %[~ , norm_max_index] = max(abs(norm_range));
                if (check_value <0)
                    norm_scalar = norm_scalar*-1;
                end
            end
            
            trace = trace./norm_scalar;
        end
        
        handles.(string).(table{n,3})(n).trace_original = trace;
        handles.(string).(table{n,3})(n).x_axis_original = x_axes;
        handles.(string).(table{n,3})(n).trace = trace(data_min_index:data_max_index);
        handles.(string).(table{n,3})(n).x_axis = x_axes_crop;
        handles.(string).(table{n,3})(n).label = label;
        
        %Get drawing styles from GUI table
        handles.(string).(table{n,3})(n).hue = handles.trace_plot_config.Data(1);
        handles.(string).(table{n,3})(n).linestyle = handles.trace_plot_config.Data(2);
        handles.(string).(table{n,3})(n).markerstyle = handles.trace_plot_config.Data(3);
        handles.(string).(table{n,3})(n).markersize = str2num(handles.trace_plot_config.Data{4});
        handles.(string).(table{n,3})(n).linewidth = str2num(handles.trace_plot_config.Data{4});
        
    end
    
    %% Remove current patches
    for m = 1 : length(axes_handles)
        ax_child = [axes_handles(m).Children];
        remove_patch = strcmp(get(ax_child,'type'),'patch');
        delete(ax_child(remove_patch));
    end
    
    opt.add_patch = 0;
    opt.plot = [opt.plot,string];
    opt.plot_handles = [opt.plot_handles,axes_handles];
end

%% Concantenate
if ~isempty(opt.concatenate)
    
    string = strtrim(handles.trace_menu.String{handles.trace_menu.Value,:});
    structName = [string,'_external_', handles.trace_sendto_fig.String];
    
    
    target_handles = str2num(handles.trace_sendto_fig.String);
    
    if isfield(handles,structName) && target_handles == handles.([structName,'_handles']) && ~handles.reset_figure_handle.Value
        
        new_traces = handles.(string);
        
        types = fields(new_traces);
        
        for n=1:length(types)
            
            if isfield(handles.(structName),types{n})
                handles.(structName).(types{n}) = [handles.(structName).(types{n}),new_traces.(types{n})];
            else
                handles.(structName).(types{n}) = new_traces.(types{n});
            end
            
        end
        
    else
        handles.(structName) = handles.(string);
        handles.([structName,'_handles']) = target_handles;
        %reset tick box
    end
    
    opt.plot = structName;
    opt.plot_handles = handles.([structName,'_handles']);
    
end

%% Plot
% %Make colours
if ~isempty(opt.plot)
    traces_plot = handles.(opt.plot).none;
    label_type = handles.legend_label_type.Value;
    FontSize = 24;
    if strcmp(opt.plot,'Kinetics') || strcmp(opt.plot,'Spectra')
        FontSize = 10;
    end
    
    hues = [traces_plot.hue]';
    hue_types = unique([hues]');
    
    for n=1:length(hue_types)
        hue_loc = find(cellfun(@(x) ~isempty(strfind(x, hue_types{n})), hues));
        colors = f_Colorbrewer(length(hue_loc), [], hue_types{n}, 'PCHIP');
        
        for k=1:size(colors,1)
            traces_plot(hue_loc(k)).color = colors(k,:);
            traces_plot(hue_loc(k)).ZLimits = [min(traces_plot(hue_loc(k)).trace ),max(traces_plot(hue_loc(k)).trace )];
        end
    end
    
    if handles.trace_norm_checkbox.Value
        ZLim = 1.1*[min([traces_plot.ZLimits]), max([traces_plot.ZLimits])];
    else
        
        ZLim = [max([min([traces_plot.ZLimits]), str2num(handles.data_config.Data{3,1})]),...
            min([max([traces_plot.ZLimits]),str2num(handles.data_config.Data{3,2})]) ];
        
    end
    
    if strfind(opt.plot,'Spectra')
        XLim = [max([min(wave),str2num(handles.data_config.Data{1,1})]),...
            min([max(wave),str2num(handles.data_config.Data{1,2})])];
        
    elseif strfind(opt.plot,'Kinetics')
        XLim = [max([min(time),f_TimeSI(handles.data_config.Data{2,1})]),...
            min([max(time),f_TimeSI(handles.data_config.Data{2,2})])];
    end
    
    if handles.trace_norm_checkbox.Value
       ZLabel = [handles.data_config.Data{3,3}, ' (Normalized)'];
    else
        ZLabel = [handles.data_config.Data{3,3}]; 
    end
    
    for n=1:size(traces_plot,2)
        hold_state = 1;
        if n==1, hold_state =0; end
        
        opt.plot_handles = f_Plot(traces_plot(n).trace, traces_plot(n).x_axis, opt.plot_handles, 'PlotStyles', traces_plot(n).color ,...
            'Hold', hold_state,'YLim',ZLim,'FontSize',FontSize,'DisplayName',traces_plot(n).label{label_type},...
            'PointStyle',traces_plot(n).markerstyle, 'LineStyle', traces_plot(n).linestyle, 'MarkerSize', traces_plot(n).markersize,...
            'LineWidth', traces_plot(n).linewidth, 'FigureTitle', string, 'XLim', XLim, 'ZLabel', ZLabel);
    end
    
    if strfind(opt.plot,'external')
        legend('show', 'Location', 'best')
    end
end

%% Plot Surf

if ~isempty(opt.plot_surf)
    
    if opt.plot_surf == 1000000
        font_size = 20;
        shrink = 1;
    else
        font_size = 10;
        shrink = 0;
        cla(opt.plot_surf(1), 'reset')
        pause(0.01)
        cla(opt.plot_surf(2), 'reset')
        pause(0.01)
    end
    
    waveLim = [max([min(wave),str2num(handles.data_config.Data{1,1})]),...
        min([max(wave),str2num(handles.data_config.Data{1,2})])];
    
    timeLim = [max([min(time),f_TimeSI(handles.data_config.Data{2,1})]),...
        min([max(time),f_TimeSI(handles.data_config.Data{2,2})])];
    
    if handles.autoscale_signal.Value
        [~,wave_min_ind] = min(abs(wave-waveLim(1)));
        [~,wave_max_ind] = min(abs(wave-waveLim(2)));
        
        [~,time_min_ind] = min(abs(time-timeLim(1)));
        [~,time_max_ind] = min(abs(time-timeLim(2)));
        
        ZLim = [max([min(min(data(time_min_ind:time_max_ind, wave_min_ind:wave_max_ind))), str2num(handles.data_config.Data{3,1})]),...
            min([max(max(data(time_min_ind:time_max_ind, wave_min_ind:wave_max_ind))),str2num(handles.data_config.Data{3,2})]) ];
        
        handles.data_config.Data{3,1} = num2str(ZLim(1),'%.1E');
        handles.data_config.Data{3,2} = num2str(ZLim(2), '%.1E');
        
    else
        
        ZLim = [max([min(min(data)), str2num(handles.data_config.Data{3,1})]),...
            min([max(max(data)),str2num(handles.data_config.Data{3,2})]) ];
    end
    
    surf_handle = f_Plot(data, time, wave, opt.plot_surf, 'FontSize', font_size, 'ShrinkAxes', shrink, 'ZLim', ZLim, 'XLim', timeLim, 'YLim', waveLim);
    
    
end

%% Get save Dir and contents
if ~isempty(opt.update_subdir)
    new_folder = handles.save_path_sub_custom;
    handles.save_path_sub.String = {'{none}'};
    %Get contents (folders only)
    sub_dir = dir(save_dir_parent);
    sub_dir = {sub_dir([sub_dir.isdir]).name}';
    remove = regexp(sub_dir,'^\.*$'); %^ - beginning of line, \.* - any number of '.', $ - end of line
    sub_dir(~cellfun(@isempty,remove)) = [];
    sub_dir = sort(sub_dir);
    
    %add default strings and update popup menu
    sub_dir = [new_folder;{'Figures'}; '{none}'; sub_dir];
    handles.save_path_sub.String = sub_dir;
    
    if ~isempty(new_folder)
        handles.save_path_sub.Value = 1;
    else
        handles.save_path_sub.Value = 2;
    end
    
end

%% Make 'Directory Path' string

if ~isempty(opt.make_path)
    
    path_components = [save_dir_parent; handles.save_path_sub.String(handles.save_path_sub.Value)];
    
    %Check for any components that end with '\', and remove if so
    for n=1:size(path_components,1)
        if path_components{n}(end) == '\'
            path_components{n} = path_components{n}(1:end-1);
        end
        
        if strcmp(path_components{n}, '{none}')
            path_components{n} = [];
        else
            path_components{n} = [path_components{n},'\'];
        end
    end
    
    handles.save_dir = [path_components{1}, path_components{2}];
    
end

%% Save (figure and data)
if ~isempty(opt.save)
    
    if ~exist(handles.save_dir,'dir')
        mkdir(handles.save_dir);
    end
    
    if opt.save == 1000000; %if saving surface
        saveas(opt.save,[handles.save_dir,handles.data_name_box.String, '_Surface.fig'])
        print(opt.save,[handles.save_dir,handles.data_name_box.String,'_Surface'], '-dpng', '-r0')
        
        close(1000000);
    else %saving traces
        
        %savehandle = handles.([opt.save,'_handles']);
        savehandle = str2num(handles.trace_sendto_fig.String);
        %traces = handles.([opt.save,'_', handles.trace_sendto_fig.String]);
        traces = handles.(opt.save);
        
        saveas(savehandle,[handles.save_dir,handles.data_name_box.String, '_', handles.trace_save_name.String,'.fig'])
        print(savehandle,[handles.save_dir,handles.data_name_box.String,'_', handles.trace_save_name.String], '-dpng', '-r0')
        
        if handles.save_data_checkbox.Value %saving trace data
            string = strtrim(handles.trace_menu.String{handles.trace_menu.Value,:});
            if strfind(string, 'Kinetics')
                x_label = handles.data_config.Data(2,3);
            elseif strfind(string, 'Spectra')
                x_label = handles.data_config.Data(1,3);
            else
                x_label = {'{none}'};
            end
            
            colStart = 1;
            save_array = repmat({NaN},max(cellfun(@length,{traces.none.x_axis}))+1,2*(size(traces.none,2)));
            while size(traces.none,2) > 0
                current_axis = traces.none(1).x_axis;
                match = [cellfun(@length,{traces.none.x_axis})' == length(current_axis)];

                difference = bsxfun(@minus,[traces.none(match).x_axis],current_axis);
                match = ~logical(sum(difference))';

                temp_save_traces = [current_axis,[traces.none(match).trace]];
                temp_save_labels = [traces.none(match).label];
                temp_save_labels = [x_label,temp_save_labels(handles.legend_label_type.Value,:)];
                
                rowEnd = size(temp_save_traces,1)+1;
                colEnd = size(temp_save_traces,2) + colStart - 1;
                save_array(2:rowEnd, colStart:colEnd) = num2cell(temp_save_traces);
                save_array(1, colStart:colEnd) = temp_save_labels;
                
                traces.none(match) = [];
                colStart = colEnd + 1;
            end
            
            test_array = save_array(1,:);
            remove = cellfun(@(x) any(isnan(x(1,:))), test_array);
            save_array(:,remove) = [];
            cell2csv([handles.save_dir,handles.data_name_box.String, '_', handles.trace_save_name.String,'.csv'],save_array)
        end
    end
end

%% Add patch onto spectra window to help with selection
if ~isempty(opt.add_patch)
    
    % what is the start
    string = strtrim(handles.trace_menu.String{handles.trace_menu.Value,:});
    for n = 1 : 2
        % options for both data sets
        if strcmp(string, 'Kinetics') % update kinetics data
            axes_handles = [handles.axis_spectra];
            trace_axes = wave;
            x_axes = time;
            other_string = 'Spectra';
        elseif strcmp(string, 'Spectra')
            axes_handles = [handles.axis_kinetics1; handles.axis_kinetics2];
            trace_axes = time;
            x_axes = wave;
            other_string = 'Kinetics';
        end
        
        %% Remove current patches
        for m = 1 : length(axes_handles)
            ax_child = [axes_handles(m).Children];
            remove_patch = strcmp(get(ax_child,'type'),'patch');
            delete(ax_child(remove_patch));
        end
        %pause(0.1)
        %% Add new pathces
        if n == 1
            % first do current table data
            [table, table_num, I] = getGUItable(handles.trace_table.Data);
        else
            % second do other table data
            [table, table_num, I] = getGUItable(handles.traces_menu_data.(string).trace_table);
        end
        if opt.add_patch <= length(I) && opt.add_patch > 0
            opt.add_patch = I(opt.add_patch);
        else
            opt.add_patch = 0;
        end
        patch_color_std = [0.7,0.7,0.7];
        patch_color_cur = [0.3,0.3,0.3];
        
        for m = 1 : length(axes_handles)
            axes(axes_handles(m));
            lim = axes_handles(m).YLim;
            lim_x = axes_handles(m).XLim;
            for k = 1 : size(table_num,1)
                if k == opt.add_patch
                    patch_color = patch_color_cur;
                else
                    patch_color = patch_color_std;
                end
                if table_num(k,1)<lim_x(2) || table_num(k,1)>lim_x(1)
                    patch([table_num(k,:),fliplr(table_num(k,:))]',[lim(1),lim(1),lim(2),lim(2)]',...
                        patch_color,'LineStyle','none');
                end
            end
        end
        string = other_string;
        opt.add_patch = 0;
    end
end

%% Undo options

handles.prev_plot = opt.plot;
handles.prev_plot_handle = opt.plot_handles;

end


function [table, table_num, I] = getGUItable(table)

    %clean table
    set_default = cellfun(@isempty,table(:,2));
    table(set_default,2) = {'5%'};
    remove = cellfun(@isempty,table(:,1));
    table(remove,:) = [];
    %find indexes
    percentLoc = ~cellfun(@isempty,(regexp(table(:,2),'.*\%')));
    percentLoc = find(percentLoc);
    percent = arrayfun(@(x) table{x,2}(1:end-1),percentLoc,'UniformOutput',false);
    percent = cellfun(@str2num,percent)./100;
    
    table_num = cellfun(@f_TimeSI,table(:,1:2),'UniformOutput',false);
    
    for n=1:length(percentLoc)
        table_num(percentLoc(n),1:2) = {table_num{percentLoc(n),1}*(1-percent(n)),table_num{percentLoc(n),1}*(1+percent(n))};
    end
    
    % Sorts based on min value
    [~, I] = sort([table_num{:,1}]');
    table = table(I,:);
    table_num = table_num(I,:);
    % make into array of numbers.
    table_num = [[table_num{:,1}]',[table_num{:,2}]'];
    


end
