% ************************************************************************* %
%% ********* POST_PROCESS_CONC - Loads THE Concentration File ! *********** %
% ********** Press Run and Choose file from directory to upload *********** %
clear all; close all; clc;
% ******************* Choose Only Concentration Files !!! ***************** %
[file_name, directory] = uigetfile();
load( fullfile(directory, file_name) );
Cc_temp = Cc_FILE;

% ********* NOTICE: X-section = 1; Y-section = 2; Z-section = 3; ********** %
fig_i=1; figure(fig_i); % ******************** Show X - Y Plane Section *** %
show_conc (Cc_temp, Xc, Yc, Zc, file_name, 1); 
fig_i=fig_i+1; figure(fig_i); % ************** Show Y - Z Plane Section *** %
show_conc (Cc_temp, Xc, Yc, Zc, file_name, 2);
fig_i=fig_i+1; figure(fig_i); % ************** Show X - Z Plane Section *** %
show_conc (Cc_temp, Xc, Yc, Zc, file_name, 3);