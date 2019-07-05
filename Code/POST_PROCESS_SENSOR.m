% ************************************************************************* %
%% ************ POST_PROCESS_SENSOR - Loads The sensor FILE ! ************* %
% ********** Press Run and Choose file from directory to upload *********** %
clear all; close all; clc;
% ********************* Choose Only Sensor File !!! *********************** %
[file_name, directory] = uigetfile();
load( fullfile(directory, file_name) );
% ********* NOTICE: Sensor_FILE - is the super-position indication = shows all plumes simultaneously
Sensor_temp = Sensor_FILE;
str_sensor=0;
% ************ Superposition of CONCENTRATION & PLUMES structs' *********** %
% *********** Plotting each plume BLACK, and Super-position RED *********** %

show_sensor_t( Sensor_temp, 'r-', str_sensor );      % ****** Display SUPER-POSITION only