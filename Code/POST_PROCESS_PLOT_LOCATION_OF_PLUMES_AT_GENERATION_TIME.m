% This plot a location map of teh plumes instant of generation (location % and time)
% make sure to be inside the program directory
% must upload the workspace

clc; close all;
% ************* Choose Plume_Initial_Location File Only !!! *************** %
[file_name, directory] = uigetfile();
load( fullfile(directory, file_name) );

str_time_table = sprintf('# Plumes: %d\n# Particles: %d\nPlume Width: %.1f [cm]\nU_x = %.2f [cm/s]\nW_Z = %.2f [cm/s]', ...
    num_plm, N_particles, W, u_x, w_z);
show_time_table( Pl_init_loc, num_plm, str_time_table, field_width, field_length);