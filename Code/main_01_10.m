% **************************** Declaration Part *************************** %

%% ************************************************************************ %
clear all; close all; clc;

       % ******* User dashboard for "Flags" Choices (True = 1) ****** %
need_top_view = 1;                                      % Top view - Random plume field "flag"
need_Scatter_3D_show = 1;                               % 3D scatter "flag"
need_particle_transport = 1;                              % Particles Transport "flag" - Commencing promotion every step 
need_Plume_file_save = 1;                               % save Plume field "flag"
need_conc_calc = 1;                                     % Concentration calc "flag"
need_conc_show = 1;                                     % Concentration display "flag"
need_conc_file_save = 1;                                % save Concentration field "flag"
need_sensor_calc = 1;                                   % calculate and save sensor measurement "flag"
need_sensor_show = 1;                                   % Show sensor_t Graph
need_sensor_file_save = 1;                              % calculate and save sensor measurement "flag"

       % ********************** General definitions *********************** %
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
% K_boltz=1.38e-23;                                     % Boltzman Constant [m2*kg/(s2*K)] 
% w_Temp=293;                                           % Sea Water Temprature [K]
% w_rho= 1000;                                          % Sea Water Density [kg/m3]
% w_visc= 1.83e-3;                                      % Sea Water Dynamic Viscosity [m2/s]
% d_p=100e-6;                                           % Sea Sand particle diameter [m] < -- To be log normal distributed?
% D = K_boltz*w_Temp/( 3*pi*w_rho*w_visc*d_p);          % Diffusion coefficent %
% sigma = 100*(2*D*dt)^0.5;                             % Standard Deviation (cm) 
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
s_M_pl_i=1; s_Cc_i=1;                                                     % The saved files indexes. get Incremented every {t1, t2, t3...}
[address_1, address_2, address_3] = create_files_directory;               % Function call to obtain addresses for directories

       % ****** Initialize 3D matrices of (X,Y,Z) for concentration matrix ******* %
Ncx= Nc; Ncy= Nc; Ncz= Nc;                              % Temporary initialize to Nc
dxc= sqr_field_size/Ncx;       Xc=zeros(Ncz,Ncx,Ncy);   % dx_i = Distance between 2 measurement points
dyc= sqr_field_size/Ncy;       Yc=zeros(Ncz,Ncx,Ncy);
dzc= h/Ncz;                    Zc=zeros(Ncz,Ncx,Ncy);   % Initialize Concentration matrix with  
Cc(Ncx, Ncy, Ncz)=nan;         dVCc=dxc*dyc*dzc;        % dVCc = Concentration Control Volume             

%%              % ******************************************** %
% ***************************** Execution Part **************************** %
                % ******************************************** %

       % ************** Forming 3D matrices in Z, X, Y order ************** %
for ic=1:Ncx
    for jc=1:Ncy
        for kc=Ncz:-1:1
            Xc(kc,ic,jc)= ic*dxc-dxc/2-sqr_field_size;
            Yc(kc,ic,jc)= jc*dyc-dyc/2-sqr_field_size/2;
            Zc(kc,ic,jc)= kc*dzc-dzc/2;
        end
    end
end
Zc= flipud(Zc);   
                
        % ********** Random (Normal) distribution plume field by (t, X, Y) ********* %
pl_init_loc=zeros(num_plm,3);                                  % Initial Plume Location (to, Xo, Yo)     
for j=1:num_plm         % pl_init_loc - Reserves date: Time (1), X(2), Y(3) columns  
    [pl_init_loc(j,1), pl_init_loc(j,2), pl_init_loc(j,3)] = ...
        random_plume_generator(sqr_field_size, dt, total_run_time);     % Normal Distribution across the field
end;                                                    
pl_init_loc = sortrows(pl_init_loc);                    % Sorts plumes ascending by time

if( need_top_view==1 )                                  % Top view of X, Y, t plumes on field
    figure(fig_i);
    show_time_table( pl_init_loc, sqr_field_size, num_plm );
    fig_i=fig_i+1;
end

        % ****************** Sets clouds into locations ******************* %
M_pl = nan(N_particles, 3, num_plm);                    % Initialize n X Plumes Matrix
t_lin = linspace(dt, total_run_time, total_steps);      % Time Scale array along Loop 
pl_index=1;                                             % Number of "Active" plumes, being transported

%%
    % ************************* Main Program Loop ************************* %
for t=1:total_steps                                     % Total steps along run time
    % ************************* Plume Generation ************************** %
    if ( pl_index <= num_plm    &&   t_lin(t) >= pl_init_loc(pl_index,1) )  % Threshold for total plume number
        [M_pl(:,1,pl_index), M_pl(:,2,pl_index), M_pl(:,3,pl_index)] = generate_single_plume( N_particles, h, W);
        M_pl(:,1,pl_index) = M_pl(:,1,pl_index) + pl_init_loc(pl_index,2);
        M_pl(:,2,pl_index) = M_pl(:,2,pl_index) + pl_init_loc(pl_index,3);
        start_transport=1;                              % ! Threshold for plume transport only from 1st plume !
        pl_index=pl_index+1;                            % Plume Index increment
    end
    
    % **************** Particle transport EVERY time step ***************** %
    if ( need_particle_transport == 1 && start_transport==1 )           % need_particle_trans = Particles Transport "flag" - Commencing promotion every step 
        for trans_i=1:pl_index-1                                        % trans_i = Loop index responsible to apply calculation on cells
            % Contains particles already generated, and avoids spending calc_time on NaNs cells
            dif_step = random(dif_func, N_particles, 3);                % Random Walk single step vector, for the whole Plume column
            M_pl = trans_particle ( M_pl, trans_i, u_x, w_z, dt, dif_step);
        end
    end
    
    % *********************** Sensor activity "flag" ********************** %
    if (need_sensor_calc == 1)
    % ************ Sensor indication inside measurement volume ************ %
    sensor_t(t,1) = t*dt;                               % First column contains dt steps [s]
        for n_i=1:pl_index-1                            % Second column contains [#particles/cm^3]
            sensor_t(t,2) = sensor_t(t,2)+(nansum (M_pl(:,1,n_i)>(xs-dVs/2) & M_pl(:,1,n_i)<(xs+dVs/2)...
                & M_pl(:,2,n_i)>(ys-dVs/2) & M_pl(:,2,n_i)<(ys+dVs/2)...
                & M_pl(:,3,n_i)>(zs-dVs/2) & M_pl(:,3,n_i)<(zs+dVs/2)))/(dVs^3);
        end
    end

    % ****************** plume_field FILE EXPORT "flag" ******************* %
    if (need_Plume_file_save == 1)
        % ***************** plume_field FILE EXPORT module **************** %
        if( s_M_pl_i <= length(s_loc) && t*dt > s_loc(s_M_pl_i) )           % Threshold for indices
            file_name = ['Plume field (t=', num2str(s_loc(s_M_pl_i)), ' [s])'];
            save( fullfile( address_1, [file_name '.mat']) ,'M_pl');
            s_M_pl_i=s_M_pl_i+1;
        end
    end

    % ******************* Conc_field FILE EXPORT "flag" ******************* %
    if ( need_conc_file_save == 1 )  
    % ************** Concentration CALCULATION desired times ************** %
        if ( s_Cc_i <= length(s_conc) && t*dt > s_conc(s_Cc_i) )                                    % Time threshold for conc_calc
            Cc = conc_calculation (M_pl, dVs, Xc, Yc, Zc, Ncx, Ncy, Ncz, dxc, dyc, dzc); 
    % **************** Conc_field save FILE EXPORT "flag" ***************** %
            if( s_Cc_i <= length(s_conc) && t*dt > s_conc(s_Cc_i) )
                file_name = ['Concentration field at t=' num2str(s_conc(s_Cc_i)) ' [s]'];
                save(fullfile( address_2, [file_name '.mat']), 'Cc','Xc','Yc','Zc' );
                s_Cc_i=s_Cc_i+1;
            end
        end
    end
    t           % Running (t) during run-time. Might slow down... But very handy
end

% ************** Concentration field DISPLAY "flag" *************** %
if (need_conc_show == 1)                                  % need_conc_show - Concentration field map
    for conc_i=1:3                                        % 1:3 = XY, XZ, YZ cross sections
        figure(fig_i);
        show_conc( Cc, sqr_field_size, h, Ncx, Ncy, Ncz, conc_i, s_conc(2) );  % *** s_conc(2): Desired timeframe
        fig_i=fig_i+1;
    end
    need_conc_calc = need_conc_calc-1;                    % TEMPORARY - shown only once, otherwise; lots of figures
end

% ************** Sensor_t activity display (shows last one) *************** %   
if ( need_sensor_file_save == 1 )
    file_name = 'Sensor measurement';
    save(fullfile(address_3, [file_name '.mat']), 'sensor_t');
end

% ******************* Sensor_t activity display [#/cm^3] ****************** %   
if ( need_sensor_show==1 )
    figure(fig_i); fig_i=fig_i+1;
    show_sensor_t( sensor_t(:,2) );
end

% ************* 3D Scatter of Plume field at end of Run-time ************** %
if ( need_Scatter_3D_show == 1 )                         % Scatter 3D display "flag"
    figure(fig_i); fig_i=fig_i+1;
    show_Scatter_3D (M_pl, num_plm, total_run_time);  % Last input argument is the desired display time 
end