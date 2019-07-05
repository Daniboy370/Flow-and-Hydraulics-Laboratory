% ************************************************************************* %
%% *************** POST_PROCESS_M_PL - Loads THE M_pl File ! ************** %
% ********** Press Run and Choose file from directory to upload *********** %
clear all; clc; close all;
% ******************* Choose Only Plume Field Files !!! ******************* %
[file_name, directory] = uigetfile();
load( fullfile(directory, file_name) );

M_pl_temp = M_pl_FILE;                         % **** M_pl_temp - a local struct variable
pl_max = size(M_pl_temp, 2 );                  % **** pl_max - Get Number of Total plumes 
% ********* NOTICE: X-section = 1; Y-section = 2; Z-section = 3; ********** %
str = file_name; str = str(1:end-4);
show_Scatter_3D ( M_pl_temp, pl_max, str);     % M_pl_temp.x, M_pl_temp.y, M_pl_temp.z, pl_max );