function [data, time, wave, RunDetails] = f_LoadTA( fullpath, varargin)

%% Options
opt.check_eV = 1;
unit_string = {'m'};

%% Loads csv files
[fid,msg] = fopen(fullpath,'r');
A = textscan(fid, '%s', 'delimiter', '\n', 'MultipleDelimsAsOne', 0,'EmptyValue',Inf);
fclose(fid);
%% Finds data details split
A = A{1,1};
split_index = find(cellfun(@isempty, A));
if isempty(split_index)
    split_index = find(~cellfun(@isempty,regexp(A,'^,+$')));
end
if ~isempty(split_index)
    data_input = A(1:split_index-1);
    run_details = A(split_index+1:end);
else
    data_input = A;
    run_details = [];
end
%% Loads Data
for n = 1 : size(data_input,1)
    data_1 = [textscan(data_input{n}, '%f', 'delimiter', ',', 'MultipleDelimsAsOne', 0,'EmptyValue',NaN)]';
    data_1 = data_1{1,1};
    if n == 1
        data = nan(size(data_input,1),size(data_1,1));
    end
    data(n,:) = data_1';
end

time = data(2:end,1);
% wavelength -> alwasy output in nm (not eV)
wave = [data(1,2:end)]';
if max(wave) < 10, wave = 1240./wave; end

data = data(2:end,2:end);

%% Loads Details
for n = 1 : length(run_details)
    run_details_temp = [textscan(run_details{n}, '%s', 'delimiter', ',', 'MultipleDelimsAsOne', 1,'EmptyValue',NaN)]';
    run_details_temp = run_details_temp{1,1};
    % Finds Name
    name = run_details_temp{1,1};
    run_details_temp = run_details_temp(2:end);
    % Processe details (if any)
    if ~isempty(run_details_temp)
        % If not wavelength dependent data
        if length(run_details_temp) < 100
            % Could have units as more than one value
            if length(run_details_temp) >1
                % units are always character, and if character values there
                % will only be units with length < 50
                if length(run_details_temp{end}) < 50 && isa(run_details_temp{end},'char')
                    unit =  run_details_temp{end};
                    run_details_temp = run_details_temp(1:end-1);
                end
            end
        end
        % checks if the deatils are a double (or interger)
        if ~isempty(regexp(run_details_temp{1},'^-?\d+\.?\d*(E|e)?-?\d*$','once')) || strcmp(run_details_temp{1},'NaN')
            % remove edn vlaue if it is a unit string.
            if any(strcmp(unit_string,run_details_temp{end}))
                run_details_temp(end) = [];
            end
            run_details_temp = cellfun(@str2num,run_details_temp);
        elseif length(run_details_temp) == 1
            % if string and only 1 value removes from cell
            run_details_temp = run_details_temp{1};
        end
        % Assigns to RunDetails structure
        RunDetails.(name) = run_details_temp;
    end
end

if ~exist('RunDetails','var')
    RunDetails = [];
end

%% Load wavelength in eV
if opt.check_eV && min(wave) > 100
        %wave = 1240./wave;
end

end