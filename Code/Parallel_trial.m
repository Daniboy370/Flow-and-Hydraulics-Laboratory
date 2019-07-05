clear all; clc;

       % ***********************  Clouds definition *********************** %
total_run_time=100;                                     % Total "Run Time". Must put in seconds [sec]
dt = 0.1;                                               % Step Duration / Sampling Period [sec]
total_steps = total_run_time/dt;                        % Number of steps during Run-Time [#]
num_plm = 8;                                            % Total number of plumes [#]
sqr_field_size = 10;                                    % Field X / Y length [cm]
fig_i=1;                                                % Initializing the figure index

       % ***********************  Clouds definition *********************** %
h= 50;                                                  % The height of the plume [cm]
W= .1*h;                                                % The width of the plum [cm]
N_particles = 1000;                                     % # particles at each Resuspension event [#]

       % ****************** Sensor location and volume of measurement volume ******************* %
xs= 0; ys= 0; zs= 0.5*h;                                % Defining sensor's location [cm]
sensor_t(total_steps,2)=zeros;                          % Initialize sensor length array

       % **********************  Transport properties ********************* %
u_x = 0.1;                                              % Horizontal velocity in the x-direction (drift) [cm/sec]
w_z = -0.25;                                            % Settling velocity [cm/sec]

% *** Diffusion of submicrometer particles model: Sutherland et al. (1993) *** %
sigma=0.01;             % < -- Temporary Value (For convenience)
dif_func = makedist('Normal','mu',0,'sigma', sigma);    % Random Walk Function (Normal Distribution)

       % ******* Definitions needed to calculate the concentration fields ******** %
Nc = 15;                                                % Size of concentration 3D matrix in each direction
dVs = 1;                                                % Sensor control volume; Equilateral cube size [cm]
start_transport=0;                                      % Threshold for plume transport

       % ******* Enter Sampling times to be saved during run-time ******** %
s_loc = [ 10, 50, 90];                                  % Time at which M_pl is saved [s]
s_conc = [ 33, 66, 99];                                 % Time at which Cc is saved [s]

saved_M_pl( N_particles,1:3,num_plm, length(s_loc) )=nan;                 % Initialize Nans array to be saved
saved_Cc( N_particles,1:3,num_plm, length(s_conc) )=nan;                  % Initialize Nans array to be saved
saved_Sensor_t( total_steps, 2 )=zeros;                                   % Initialize ZERO array - for default none concentration
s_M_pl_i=1; s_Cc_i=1;                                                     % The saved files indices get Incremented every {t1, t2, t3...}
[address_1, address_2, address_3] = create_files_directory;               % Function call to obtain addresses for directories

       % ****** Initialize 3D matrices of (X,Y,Z) for concentration matrix ******* %
Ncx= Nc; Ncy= Nc; Ncz= Nc;                              % Temporary initialize to Nc
dxc= sqr_field_size/Ncx;       Xc=zeros(Ncz,Ncx,Ncy);   % dx_i = Distance between 2 measurement points
dyc= sqr_field_size/Ncy;       Yc=zeros(Ncz,Ncx,Ncy);
dzc= h/Ncz;                    Zc=zeros(Ncz,Ncx,Ncy);   % Initialize Concentration matrix with  
Cc(Ncx, Ncy, Ncz)=nan;         dVCc=dxc*dyc*dzc;        % dVCc = Concentration Control Volume             

M_pl = struct;                                          % ***** Define M_pl as a struct

        % ********************** Initial Plume Field ********************** %
pl_init_loc=zeros(num_plm,3);                                  % Initial Plume Location (to, Xo, Yo)     
for j=1:num_plm         % pl_init_loc - Reserves date: Time (1), X(2), Y(3) columns  
    [pl_init_loc(j,1), pl_init_loc(j,2), pl_init_loc(j,3)] = ...
        random_plume_generator(sqr_field_size, dt, total_run_time);     % Normal Distribution across the field
end;                                                    
pl_init_loc = sortrows(pl_init_loc);

        % ****************** Sets clouds into locations ******************* %
% M_pl = nan(N_particles, 3, num_plm);                  % Initialize n X Plumes Matrix
resuspension_t = pl_init_loc(:,1);                      % Resuspension times array to be used inside 'parfor' 
%M_pl(pl_index).particles = nan(N_particles, 3, num_plm); % *** Initialize each plume's dimensions with nans
   
% ************************************************************************ % 
% *********************** Execution Run-time part ************************ %
%t_lin =  linspace(dt, total_run_time, total_steps);

parfor pl_i=1:num_plm            % *** PARALLEL COMPUTING for loop *** %
    
    [ M_pl(pl_i).data(:,1), M_pl(pl_i).data(:,2) , M_pl(pl_i).data(:,3) ] = generate_single_plume( N_particles, h, W);
    M_pl = put_plume_in_initial_location( M_pl(pl_i), pl_i );
    t_lin(pl_i).data(:,1) = linspace(dt, total_run_time, total_steps);     % Loop Timescale array - MUST be re-declared every pl_i step
    
end


% end
% 
%     for t=1:total_run_time
%         % **************** Plume Generation of CURRENT plume. Executed only once every  ****************** %
%         if ( t_lin(t) >= resuspension_t( pl_index )                      % Threshold for total plume number
%             M_pl(pl_index).data = generate_single_plume( N_particles, h, W);
%             M_pl(pl_index).data = trans_particle_par(M_pl(:,:,pl_index), u_x, w_z, dt, dif_step);
%         
%         
%         end
%     end
% end
     
    
  %% ********************************************************************** %% 
% **************************** Secondary Part **************************** %

% %             [M_pl(:,1,pl_index), M_pl(:,2,pl_index), M_pl(:,3,pl_index)] = generate_single_plume( N_particles, h, W);
% %             M_pl(:,1,pl_index) = M_pl(:,1,pl_index) + pl_init_loc(pl_index,2);
% %             M_pl(:,2,pl_index) = M_pl(:,2,pl_index) + pl_init_loc(pl_index,3);
%         end
%     
%     % ***************** Particle transport EVERY time step **************** %
%     if ( need_particle_transport == 1 && start_transport==1 )           % need_particle_trans = Particles Transport "flag" - Commencing promotion every step 
%         for trans_i=1:pl_index-1                                        % trans_i = Loop index responsible to apply calculation on cells
%             % Contains particles already generated, and avoids spending calc_time on NaNs cells
%             dif_step = random(dif_func, N_particles, 3);                % Random Walk single step vector, for the whole Plume column
%             M_pl = trans_particle ( M_pl, trans_i, u_x, w_z, dt, dif_step);
%         end
%     end
%     
%     % *********************** Sensor activity "flag" ********************** %
%     if (need_sensor_calc == 1)
%     % ************ Sensor indication inside measurement volume ************ %
%     sensor_t(t,1) = t*dt;                               % First column contains dt steps [s]
%         for n_i=1:pl_index-1                            % Second column contains [#particles/cm^3]
%             sensor_t(t,2) = sensor_t(t,2)+(nansum (M_pl(:,1,n_i)>(xs-dVs/2) & M_pl(:,1,n_i)<(xs+dVs/2)...
%                 & M_pl(:,2,n_i)>(ys-dVs/2) & M_pl(:,2,n_i)<(ys+dVs/2)...
%                 & M_pl(:,3,n_i)>(zs-dVs/2) & M_pl(:,3,n_i)<(zs+dVs/2)))/(dVs^3);
%         end
%     end
% 
%     % ****************** plume_field FILE EXPORT "flag" ******************* %
%     if (need_Plume_file_save == 1)
%         % ***************** plume_field FILE EXPORT module **************** %
%         if( s_M_pl_i <= length(s_loc) && t*dt > s_loc(s_M_pl_i) )           % Threshold for indices
%             file_name = ['Plume field (t=', num2str(s_loc(s_M_pl_i)), ' [s])'];
%             save( fullfile( address_1, [file_name '.mat']) ,'M_pl');
%             s_M_pl_i=s_M_pl_i+1;
%         end
%     end
% 
%     % ******************* Conc_field FILE EXPORT "flag" ******************* %
%     if ( need_conc_file_save == 1 )  
%     % ************** Concentration CALCULATION desired times ************** %
%         if ( s_Cc_i <= length(s_conc) && t*dt > s_conc(s_Cc_i) )                                    % Time threshold for conc_calc
%             Cc = conc_calculation (M_pl, dVs, Xc, Yc, Zc, Ncx, Ncy, Ncz, dxc, dyc, dzc); 
%     % **************** Conc_field save FILE EXPORT "flag" ***************** %
%             if( s_Cc_i <= length(s_conc) && t*dt > s_conc(s_Cc_i) )
%                 file_name = ['Concentration field at t=' num2str(s_conc(s_Cc_i)) ' [s]'];
%                 save(fullfile( address_2, [file_name '.mat']), 'Cc','Xc','Yc','Zc' );
%                 s_Cc_i=s_Cc_i+1;
%             end
%         end
%     end
%     t           % Running (t) during run-time. Might slow down... But very handy
% end
%     
%     
%     
%     
%     
%     
%     
% end
% 
% 
% toc