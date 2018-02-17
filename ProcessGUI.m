function varargout = ProcessGUI(varargin)
% PROCESSGUI MATLAB code for ProcessGUI.fig
%      PROCESSGUI, by itself, creates a new PROCESSGUI or raises the existing
%      singleton*.
%
%      H = PROCESSGUI returns the handle to a new PROCESSGUI or the handle to
%      the existing singleton*.
%
%      PROCESSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCESSGUI.M with the given input arguments.
%
%      PROCESSGUI('Property','Value',...) creates a new PROCESSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProcessGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProcessGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProcessGUI

% Last Modified by GUIDE v2.5 31-Aug-2017 12:52:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProcessGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ProcessGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ProcessGUI is made visible.
function ProcessGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProcessGUI (see VARARGIN)

% Choose default command line output for ProcessGUI
handles.output = hObject;
%% Remove path for testing
path_dir = {path};
path_dir = strsplit(path_dir{:},';');
path_dir = path_dir';

%% Set Defaults
if exist('f_UserPref','file')
    handles.directory = f_UserPref( 'ProcessGUI' );
else
    handles.directory = [pwd,'\'];
end

handles.autoscale_signal.Value = 1;
handles.save_path_sub_custom = [];

handles.data_config.Data = {'300','1600','Wavelength (nm)';...
    '-3n','9n','Time (s)';...
    '-3E-3','3E-3','\DeltaT/T'};

handles.traces_menu_data.('Spectra').('trace_table') ={...
    '200f','5%','';...
    '1p','5%','';...
    '5p','5%','';...
    '50p','5%','';...
    '500p','5%','';...
    '2n','5%','';...
    '6n','5%','';...
    };
handles.traces_menu_data.('Spectra').('trace_plot_config') = {'Spectral', '-', '', '3'};
handles.traces_menu_data.('Spectra').('trace_save_name') = 'Spectra';
handles.traces_menu_data.('Spectra').('trace_sendto_fig') = '11';
handles.traces_menu_data.('Spectra').('save_data_checkbox') = 1;
handles.traces_menu_data.('Spectra').('trace_norm_checkbox') = 0;
handles.traces_menu_data.('Spectra').('trace_norm_min')= '300';
handles.traces_menu_data.('Spectra').('trace_norm_max') = '1600';
handles.traces_menu_data.('Spectra').('traces_norm_menu') = 1;
handles.traces_menu_data.('Spectra').('reset_figure_handle') = 1;

handles.trace_table.Data = {...
    '400','5%','';...
    '500','5%','';...
    '600','5%','';...
    '700','5%','';...
    '800','5%','';...
    };

handles.trace_plot_config.Data = {'Spectral', '', 'o', '5'};

handles.save_data_checkbox.Value = 1;
handles.trace_norm_checkbox.Value = 0;
handles.trace_norm_min.String = '100f';
handles.trace_norm_max.String = '1p';
handles.traces_norm_menu.Value = 2;
handles.reset_figure_handle.Value = 1;

handles.trace_save_name.String = 'Kinetics';

handles.traces_menu_current = strtrim(handles.trace_menu.String{handles.trace_menu.Value,:});
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ProcessGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProcessGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in data_reset.
function data_reset_Callback(hObject, eventdata, handles)
% hObject    handle to data_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data_config.Data = {...
    num2str(min(handles.wave),3),num2str(max(handles.wave),3),handles.data_config.Data{1,3};...
    num2strEng(min(handles.time),'%0.2f'),num2strEng(max(handles.time),'%0.2f'),handles.data_config.Data{2,3};...
    num2str(min(min(handles.data)),'%.0E'),num2str(max(max(handles.data)),'%.0E'),handles.data_config.Data{3,3};...
    };

[ handles ] = ProcessGUI_updater( handles,'plot_surf',[handles.axis_surf1;handles.axis_surf2]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in trace_update.
function trace_update_Callback(hObject, eventdata, handles)
% hObject    handle to trace_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[ handles] = ProcessGUI_updater( handles,'make','kinetics');

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in trace_norm_checkbox.
function trace_norm_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to trace_norm_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trace_norm_checkbox



function trace_norm_min_Callback(hObject, eventdata, handles)
% hObject    handle to trace_norm_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trace_norm_max as text
%        str2double(get(hObject,'String')) returns contents of trace_norm_max as a double


% --- Executes during object creation, after setting all properties.
function trace_norm_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trace_norm_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trace_norm_max_Callback(hObject, eventdata, handles)
% hObject    handle to trace_norm_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trace_norm_max as text
%        str2double(get(hObject,'String')) returns contents of trace_norm_max as a double


% --- Executes during object creation, after setting all properties.
function trace_norm_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trace_norm_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trace_norm_reset.
function trace_norm_reset_Callback(hObject, eventdata, handles)
% hObject    handle to trace_norm_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

string = strtrim(handles.trace_menu.String{handles.trace_menu.Value,:});

if strcmp(string, 'Spectra')
   data_config_row = 1; 
elseif strcmp(string, 'Kinetics')
   data_config_row = 2;  
end

handles.trace_norm_min.String = handles.data_config.Data{data_config_row,1};
handles.trace_norm_max.String = handles.data_config.Data{data_config_row,2};

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in trace_sendto.
function trace_sendto_Callback(hObject, eventdata, handles)
% hObject    handle to trace_sendto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[ handles ] = ProcessGUI_updater( handles,'concatenate',1);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in trace_save.
function trace_save_Callback(hObject, eventdata, handles)
% hObject    handle to trace_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


string = strtrim(handles.trace_menu.String{handles.trace_menu.Value,:});
structName = [string,'_external_',handles.trace_sendto_fig.String];
        
if ~isfield(handles,structName) || ~ishandle(handles.([structName,'_handles']))
   [ handles ] = ProcessGUI_updater( handles,'concatenate',1); 
end

[ handles ] = ProcessGUI_updater( handles,'save',structName); 


% Update handles structure
guidata(hObject, handles);


function trace_save_name_Callback(hObject, eventdata, handles)
% hObject    handle to trace_save_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trace_save_name as text
%        str2double(get(hObject,'String')) returns contents of trace_save_name as a double


% --- Executes during object creation, after setting all properties.
function trace_save_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trace_save_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trace_sendto_fig_Callback(hObject, eventdata, handles)
% hObject    handle to trace_sendto_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trace_sendto_fig as text
%        str2double(get(hObject,'String')) returns contents of trace_sendto_fig as a double


% --- Executes during object creation, after setting all properties.
function trace_sendto_fig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trace_sendto_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trace_clear.
function trace_clear_Callback(hObject, eventdata, handles)
% hObject    handle to trace_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.trace_table.Data = cell(7,3);

% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function TA_load_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to TA_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.filename, handles.directory] = uigetfile('.csv', 'May the force be with you', handles.directory);
handles.fullpath = [handles.directory, handles.filename];
handles.data_original_name = char(regexp(handles.filename, '^[^_]*','match'));
handles.data_name = handles.data_original_name;
handles.data_name_box.String = handles.data_original_name;
%handles.save_path_parent.String = handles.directory;

% Update handles structure
guidata(hObject, handles);


%[ handles.data, handles.time, handles.wave ] = f_LoadData( handles.fullpath );
% updated loading to replace above. Updated file storage to include run
% details.
[ handles.data, handles.time, handles.wave, handles.RunDetails] = f_LoadTA( handles.fullpath );

handles.data_original.data = handles.data;

% handles.data_config.Data = {...
%     num2str(min(handles.wave),'%0.0f'),num2str(max(handles.wave),'%0.0f'),'Wavelength (nm)';...
%     num2strEng(min(handles.time),'%0.2f'),num2strEng(max(handles.time),'%0.2f'),'Time (s)';...
%     num2str(min(min(handles.data)),'%.1E'),num2str(max(max(handles.data)),'%.1E'),'\DeltaT/T';...
%     };


[ handles ] = ProcessGUI_updater( handles,'plot_surf',[handles.axis_surf1;handles.axis_surf2]);

handles.save_path_parent.String = handles.directory;
handles.data_name = handles.data_original_name;
handles.data_name_box.String = handles.data_name;
handles.save_path_sub_custom = [];
[ handles ] = ProcessGUI_updater( handles, 'update_subdir', 1, 'make_path', 1 );



% Update handles structure
guidata(hObject, handles);



function to_workspace_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to TA_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[~,wave_min] = min(abs(handles.wave - str2num(handles.data_config.Data{1,1})));
[~, wave_max] = min(abs(handles.wave - str2num(handles.data_config.Data{1,2})));

[~,time_min] = min(abs(handles.time - f_TimeSI(handles.data_config.Data{2,1})));
[~, time_max] = min(abs(handles.time - f_TimeSI(handles.data_config.Data{2,2})));

assignin ('base','data',handles.data(time_min:time_max, wave_min:wave_max))
assignin ('base','wave',handles.wave(wave_min:wave_max))
assignin ('base','time',handles.time(time_min:time_max))
assignin ('base','data_name',handles.data_name)
assignin ('base','data_directory',handles.directory)
assignin ('base','GUI_handles',handles)

if isfield(handles,'Kinetics')
   assignin ('base','kinetics',handles.Kinetics) 
end

if isfield(handles,'Kinetics_external')
   assignin ('base','kinetics_external',handles.Kinetics_external) 
end

if isfield(handles,'Spectra')
   assignin ('base','spectra',handles.Spectra) 
end

if isfield(handles,'Spectra_external')
   assignin ('base','spectra_external',handles.Spectra_external) 
end



% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in trace_menu.
function trace_menu_Callback(hObject, eventdata, handles)
% hObject    handle to trace_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_type = {...
    'trace_table', 'Data';...
    'trace_sendto_fig', 'String';...
    'trace_save_name', 'String';...
    'reset_figure_handle', 'Value';...
    'save_data_checkbox', 'Value';...
    'trace_norm_checkbox', 'Value';...
    'traces_norm_menu', 'Value';...
    'trace_norm_min', 'String';...
    'trace_norm_max', 'String';...
    'trace_plot_config', 'Data';...
    };


for n=1:size(data_type,1)
  handles.traces_menu_data.(handles.traces_menu_current).(data_type{n,1}) = handles.(data_type{n,1}).(data_type{n,2});
end

string = strtrim(handles.trace_menu.String{handles.trace_menu.Value,:});
if isfield(handles.traces_menu_data,string)
   for n=1:size(data_type,1)
       if isfield(handles.traces_menu_data.(string), (data_type{n,1}))
        handles.(data_type{n,1}).(data_type{n,2}) = handles.traces_menu_data.(string).(data_type{n,1});
       end
   end 
end

handles.traces_menu_current = string;

% Update handles structure
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns trace_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trace_menu


% --- Executes during object creation, after setting all properties.
function trace_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trace_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in wave_energy_scalar.
function wave_energy_scalar_Callback(hObject, eventdata, handles)
% hObject    handle to wave_energy_scalar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[ handles ] = ProcessGUI_updater( handles,'scale_wave', 1, 'plot_surf',[handles.axis_surf1;handles.axis_surf2]);

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in data_norm.
function data_norm_Callback(hObject, eventdata, handles)
% hObject    handle to data_norm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of data_norm



function data_OD_Callback(hObject, eventdata, handles)
% hObject    handle to data_OD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_OD as text
%        str2double(get(hObject,'String')) returns contents of data_OD as a double


% --- Executes during object creation, after setting all properties.
function data_OD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_OD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spot_x_Callback(hObject, eventdata, handles)
% hObject    handle to spot_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spot_x as text
%        str2double(get(hObject,'String')) returns contents of spot_x as a double


% --- Executes during object creation, after setting all properties.
function spot_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spot_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spot_y_Callback(hObject, eventdata, handles)
% hObject    handle to spot_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spot_y as text
%        str2double(get(hObject,'String')) returns contents of spot_y as a double


% --- Executes during object creation, after setting all properties.
function spot_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spot_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function data_power_Callback(hObject, eventdata, handles)
% hObject    handle to data_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_power as text
%        str2double(get(hObject,'String')) returns contents of data_power as a double


% --- Executes during object creation, after setting all properties.
function data_power_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function data_name_box_Callback(hObject, eventdata, handles)
% hObject    handle to data_name_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_name_box as text
%        str2double(get(hObject,'String')) returns contents of data_name_box as a double

handles.data_name = handles.data_name_box.String;


% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function data_name_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_name_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function save_path_parent_Callback(hObject, eventdata, handles)
% hObject    handle to save_path_parent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_path_parent as text
%        str2double(get(hObject,'String')) returns contents of save_path_parent as a double

[ handles ] = ProcessGUI_updater( handles, 'update_subdir', 1, 'make_path', 1 );

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function save_path_parent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_path_parent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_get_dir.
function save_get_dir_Callback(hObject, eventdata, handles)
% hObject    handle to save_get_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.save_path_parent.String = uigetdir(handles.save_path_parent.String, 'Select save directory');
[ handles ] = ProcessGUI_updater( handles, 'update_subdir', 1, 'make_path', 1 );

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in save_path_sub.
function save_path_sub_Callback(hObject, eventdata, handles)
% hObject    handle to save_path_sub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[ handles ] = ProcessGUI_updater( handles, 'make_path', 1 );

% Update handles structure
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns save_path_sub contents as cell array
%        contents{get(hObject,'Value')} returns selected item from save_path_sub


% --- Executes during object creation, after setting all properties.
function save_path_sub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_path_sub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_path_sub_new.
function save_path_sub_new_Callback(hObject, eventdata, handles)
% hObject    handle to save_path_sub_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.save_path_sub_custom = inputdlg('New Folder','New folder name',1);


[ handles ] = ProcessGUI_updater( handles, 'update_subdir', 1, 'make_path', 1);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in save_path_reset.
function save_path_reset_Callback(hObject, eventdata, handles)
% hObject    handle to save_path_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.save_path_parent.String = handles.directory;
handles.data_name = handles.data_original_name;
handles.data_name_box.String = handles.data_name;
handles.save_path_sub_custom = [];

[ handles ] = ProcessGUI_updater( handles, 'update_subdir', 1, 'make_path', 1 );

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in surf_update.
function surf_update_Callback(hObject, eventdata, handles)
% hObject    handle to surf_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes when entered data in editable cell(s) in data_config.
function data_config_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to data_config (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

[ handles ] = ProcessGUI_updater( handles,'plot_surf',[handles.axis_surf1;handles.axis_surf2]);

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in legend_label_type.
function legend_label_type_Callback(hObject, eventdata, handles)
% hObject    handle to legend_label_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns legend_label_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from legend_label_type


% --- Executes during object creation, after setting all properties.
function legend_label_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to legend_label_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_data_checkbox.
function save_data_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to save_data_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save_data_checkbox


% --- Executes on button press in traces_norm_range.
function traces_norm_range_Callback(hObject, eventdata, handles)
% hObject    handle to traces_norm_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of traces_norm_range


% --- Executes on button press in traces_norm_max.
function traces_norm_max_Callback(hObject, eventdata, handles)
% hObject    handle to traces_norm_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of traces_norm_max


% --- Executes on selection change in traces_norm_menu.
function traces_norm_menu_Callback(hObject, eventdata, handles)
% hObject    handle to traces_norm_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns traces_norm_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from traces_norm_menu

if handles.traces_norm_menu.Value == 3 || handles.traces_norm_menu.Value == 4
   handles.trace_norm_max.Enable = 'off'; 
else
   handles.trace_norm_max.Enable = 'on';  
end

handles.trace_norm_checkbox.Value = 1;

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function traces_norm_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to traces_norm_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in autoscale_signal.
function autoscale_signal_Callback(hObject, eventdata, handles)
% hObject    handle to autoscale_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.autoscale_signal.Value
[ handles ] = ProcessGUI_updater( handles,'plot_surf',[handles.axis_surf1;handles.axis_surf2]);
end



% Update handles structure
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of autoscale_signal


% --- Executes on button press in save_surf.
function save_surf_Callback(hObject, eventdata, handles)
% hObject    handle to save_surf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ishandle(1000000), close(1000000); end

[ handles ] = ProcessGUI_updater( handles,'plot_surf',1000000, 'save', 1000000 );


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in reset_figure_handle.
function reset_figure_handle_Callback(hObject, eventdata, handles)
% hObject    handle to reset_figure_handle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of reset_figure_handle


% --------------------------------------------------------------------
function undo_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[ handles ] = ProcessGUI_updater( handles,'undo', 1);

% Update handles structure
guidata(hObject, handles);



function zero_region_min_Callback(hObject, eventdata, handles)
% hObject    handle to zero_region_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zero_region_min as text
%        str2double(get(hObject,'String')) returns contents of zero_region_min as a double


% --- Executes during object creation, after setting all properties.
function zero_region_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zero_region_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zero_region_max_Callback(hObject, eventdata, handles)
% hObject    handle to zero_region_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zero_region_max as text
%        str2double(get(hObject,'String')) returns contents of zero_region_max as a double


% --- Executes during object creation, after setting all properties.
function zero_region_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zero_region_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in zero_data_region.
function zero_data_region_Callback(hObject, eventdata, handles)
% hObject    handle to zero_data_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zero_data_region

if handles.zero_data_region.Value
    [ handles ] = ProcessGUI_updater( handles,'zero_data_region', 1, 'plot_surf',[handles.axis_surf1;handles.axis_surf2]);
else
    handles.data = handles.data_original.data;
    [ handles ] = ProcessGUI_updater( handles,'plot_surf',[handles.axis_surf1;handles.axis_surf2]);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in zero_data_limits.
function zero_data_limits_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to zero_data_limits (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

if handles.zero_data_region.Value
    handles.data = handles.data_original.data;
    [ handles ] = ProcessGUI_updater( handles,'zero_data_region', 1, 'plot_surf',[handles.axis_surf1;handles.axis_surf2]);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in trace_table.
function trace_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to trace_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% Edit this table and we will draw some patches onto the other graph type!

[ handles ] = ProcessGUI_updater( handles,'add_patch', eventdata.Indices(1));


% --- Executes on button press in spectra_bg_show.
function spectra_bg_show_Callback(hObject, eventdata, handles)
% hObject    handle to spectra_bg_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spectra_bg_show


% --- Executes on button press in leg_beside.
function leg_beside_Callback(hObject, eventdata, handles)
% hObject    handle to leg_beside (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of leg_beside


% --- Executes on button press in dual_xLabels.
function dual_xLabels_Callback(hObject, eventdata, handles)
% hObject    handle to dual_xLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dual_xLabels
