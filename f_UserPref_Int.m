function [ dir ] = f_UserPref( str )
%[ dir ] = f_UserPref( str )
%   Fill in the fields inside this function to give nice default options
%   across multiple scripts. Also add in PushBullet default API (will
%   probably change these to slack direct messages at some point)

look_up_table = {
    'Default',''
    'Raw_Data',''
    'Project',''
    'ProcessGUI',''
    'PushBulletAPI',''
    'PushBulletAPI_Phone',''
    };

i = find(strcmpi(look_up_table(:,1),str));

%% Standardize look-up table i.e no ' ' only _
look_up_table(:,1) = strrep(look_up_table(:,1),' ','_');

%% Try with replacing ' ' with _
if isempty(i)
    str = strrep(str,' ','_');
    i = find(strcmpi(look_up_table(:,1),str));
end

%% remove on an 's' on end
if isempty(i) && str(end) == 's'
    str = str(1:end-1);
    i = find(strcmpi(look_up_table(:,1),str));
end

%% Adding on an 's'
if isempty(i)
    i = find(strcmpi(look_up_table(:,1),[str,'s']));
end

%% Still empty give back default with warning
if isempty(i)
    i = 1; 
    warning(['''',str,''' not found, Returning ''',look_up_table{i,2},''' (default)'])
end

dir = look_up_table{i,2};

end

