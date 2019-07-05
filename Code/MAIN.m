%% ******************** DECLERATION OF VARIABLES STAGE ******************** %
%% ************************************************************************ %

clear all; close all; clc;
% ************************ Dashboard Flags  ************************ %
need_conc_calc = 1;                                     % Concentration Calculation "flag"
need_sensor_calc = 1;                                   % Sensor Activity "flag"
need_sensor_show = 1*need_sensor_calc;                  % (!) Assures: No Calcultion = No Sensor Display
need_particle_dispersion = 0;                           % Particles' Dispersion "flag"
need_particle_settling = 1;                             % Particles' Settling "flag"
need_files_save = 1;                                    % Export saved time frames to EXTERNAL directory "flag"

% ***********************  Clouds definition *********************** %
h = 50;                                                 % The height of the plume [cm]
W = .1*h;                                              % The width of the plum [cm]
N_particles = 5000;                                    % # particles at each Resuspension event [#]

% ***********************  Process definition *********************** %
run_time = 100;                                         % Total "Run Time". Must put in seconds [sec]
time_edge = 0.6;       %0.6                             % The fruction of run_time that suspension events can occur (0:time_edge*run_time).
dt = 0.1;                                               % Step Duration / Sampling Period [sec]
total_steps = run_time/dt;                              % Number of steps during Run-Time [#]
num_plm = 10;                                           % Total number of plumes [#]
field_width = W;%3*W;                                        % Field Size - General width of field size [cm]
field_length = 3*W; %2000; % 3*W;                             % General length (3 x Width)  [cm]

% **********************  Transport properties ********************* %
u_x =  0.15;                                            % Horizontal velocity in the x-direction (drift) [cm/sec]
w_z = -0.10;                                            % Settling velocity [cm/sec]
          % *** Diffusion of submicrometer particles model: Sutherland et al. (1993) *** %
sigma=0.01;             % < -- Temporary Value without inner details (For convenience)
dif_func = makedist('Normal','mu',0,'sigma', sigma);    % Random Walk Function (Normal Distribution)

% **** Setting FILES' DIRECTORIES addresses in desired desktop location *** %
% ********* dir_i - Open folder on designated Directory location ********** %
[dir_1, dir_2, dir_3, dir_4, dir_5] = create_files_directory;   % Function call to obtain addresses for directories

% *********** Sensor location and volume of measurement volume ************ %
xs= 0; ys= 0; zs= 0.5*h;                                % Defining sensor's location [cm]
dVs = 1;                                                % Sensor control volume; Equilateral cube size [cm]

% **** The times at which the program saves BOTH concentration and scatter FIELD **** %
len_save_f = run_time*[15/100 50/100 85/100 99/100];

% ****** Initialize 3D matrices of (X,Y,Z) for concentration matrix ******* %
Nc = 15;                                                % Temporary Size of concentration 3D matrix in each direction
Ncx= Nc; Ncy= Nc; Ncz= Nc;                              % Temporary initialize to Nc
dxc= field_length/Ncx;       Xc=zeros(Ncz,Ncx,Ncy);     % dxc = Distance between 2 X-axis measurement points
dyc= field_width/Ncy;        Yc=zeros(Ncz,Ncx,Ncy);     % dyc = Distance between 2 Y-axis measurement points
dzc= h/Ncz;                  Zc=zeros(Ncz,Ncx,Ncy);     % dzc = Distance between 2 Z-axis measurement points
dVCc=dxc*dyc*dzc;                                       % dVCc = Concentration Control Volume

% **************** Initialize 3D matrices in Z, X, Y order **************** %
% ************ Profile of (:,:,col_i) is moving from -y to +y ************* %
[Xc, Yc, Zc] = make_axis_grid( field_length, field_width, Xc, Yc, Zc, Ncx, Ncy, Ncz, dxc, dyc, dzc );

% ******************* Misc. Initialization of Variables ******************* %
fig_i=1;                                                    % Initializing the figure index

% *************** Declare Structs for PARFOR data management ************** %
M_pl = struct;                      M_pl_SAVE = struct;     % M_pl - Plume field Matrix with particle locations
Cc_i = struct;                      Cc_SAVE = struct;       % Cc - Concentration field Matrix
sensor_t = struct;                  Pl_init_loc = struct;   % Plume Initial locations, and Sensor - Plume field with particle locations
t_lin = struct;                     save_f=struct;          % Time line and desired timeframes array
gen_plume_only_once = struct;       s_ti=struct;            % Simple Increments defined as structs

%% *********************** Main program PARFOR Loops ********************** %
%% ***************** (1) PARFOR : INITIALIZATION STAGE (1) **************** %

parfor pl_i=1:num_plm
    % **** ! INITIALIZATION STAGE - Executed only ONCE for each Plume ! *** %
    % ************** !! PARFOR can work only with structs !! ************** %
    t_lin(pl_i).data = linspace(dt, run_time, total_steps); % Time scale, as STRUCT
    gen_plume_only_once(pl_i).data = 1;                     % Individual generation INDEX for each plume, as STRUCT
    s_ti(pl_i).ix = 1;                                      % Time frame index, as STRUCT
    % ********** Field Initialized with random plumes' locations ********** %
    % **************** Generate Plume with (X, Y, t) data ***************** %
    % **** NOTICE: time_edge [0~1] = Run-time fracture that's taken off the end total run-time
    
    [Pl_init_loc(pl_i).t, Pl_init_loc(pl_i).x, Pl_init_loc(pl_i).y] = random_plume_generator(field_length, field_width, dt, run_time, time_edge);
  
    % ***** save_f - "time frames" contains desired times to be saved ***** %
    % ********** Enter Sampling times to be saved during run-time ********* %
    save_f(pl_i).frames = len_save_f;   % Time array for FILE saving [s]
    save_f(pl_i).length = length(len_save_f);               
  
    % *** M_pl.initial initialized with nans to ensure "0" indication at sensor *** %
    M_pl( pl_i ).initial.x    = nan(N_particles, 1);
    M_pl( pl_i ).initial.y    = nan(N_particles, 1);
    M_pl( pl_i ).initial.z    = nan(N_particles, 1);
    % *** M_pl.transport initialized with nans to ensure "0" indication at sensor *** %
    M_pl( pl_i ).transport.x  = nan(N_particles, 1);
    M_pl( pl_i ).transport.y  = nan(N_particles, 1);
    M_pl( pl_i ).transport.z  = nan(N_particles, 1);
    % *** M_pl.time_frame initialized with nans to ensure "0" indication at sensor *** %
    M_pl( pl_i ).time_frame.x = nan(N_particles, 1);
    M_pl( pl_i ).time_frame.y = nan(N_particles, 1);
    M_pl( pl_i ).time_frame.z = nan(N_particles, 1); 
end

%% ******************* (2) PARFOR : EXECUTION STAGE (2) ******************* %   
parfor pl_i=1:num_plm
    % *********************** dt steps - INNER LOOP *********************** %
    for t=1:total_steps
        % ************ PUT PLUME ON LOCATION DESIRED LOCATION ************* %
        if ( t_lin(pl_i).data(t) > Pl_init_loc(pl_i).t )
            % ******** Ensure ONE time generation for each plume ********** %
            if ( gen_plume_only_once(pl_i).data == 1 )
                % *************** Generating the PLUMES ONCE ************** %
                % Uniform distribution is used in z and theta directions
                % To test a normal distribution in z goto generate_single_plume
                [M_pl(pl_i).initial.x, M_pl(pl_i).initial.y, M_pl(pl_i).initial.z] = generate_single_plume( N_particles, h, W);
                % ****** Initialize Location just as in MAIN script ******* %
                M_pl(pl_i).initial = put_in_initial_loc ( M_pl(pl_i).initial, Pl_init_loc(pl_i).x, Pl_init_loc(pl_i).y );
                % ***** 22/10/2017 - Daniel Added sub-field in M_Pl struct
                % ***** to save M_pl initial location (Total) Plume (for SENESITIVIY ANALYSIS)
                M_pl(pl_i).transport = M_pl(pl_i).initial;
                gen_plume_only_once(pl_i).data = 0;                     % *** Nullify value to ensure one-time PLUME generation
            end
            % *********** TRANSPORT PARTICLES COLUMN every step *********** %
            dif_step = random(dif_func, N_particles, 3);                % by the Random walk theory
            M_pl(pl_i).transport = trans_particle( M_pl(pl_i).transport, u_x, w_z, dt, dif_step, need_particle_dispersion );
        end
        
        %  ***** WE ARE DONE WITH THE TRANSPORT OF PARTICLES. FROM HERE WE PROVIDE
        %  ***** DATA THAT WE NEED SUCH AS CONCENTRATION AND SENSOR MEASUREMENTS
        
        % ************** PLUME & CONCENTRATION CRITERION ************** %
        % ********* !! Has to be inside GENERERATION LOOP !!! ********* %
        
        % Plugging the sactter at predifined times:
        if( s_ti(pl_i).ix <= save_f(pl_i).length && t_lin(pl_i).data(t) >= save_f(pl_i).frames( s_ti(pl_i).ix ) )           % Threshold for indices
            % ** M_pl.transport - Plume Matrix with particles being transported and overriden
            % ** M_pl.time_frame - X, Y, Z columns being saved on desire time frames ** %
            M_pl( pl_i ).time_frame( s_ti(pl_i).ix ) = M_pl( pl_i ).transport;
        
        % Calculating concentration:   
            if ( need_conc_calc == 1 )
                % ****** NOTICE: Cc Matrices' indices are sorted by (Z, X, Y) ****** %
                % **** Cc_i - Concentration of EACH PLUME at desired time frame **** %
                Cc_i( pl_i ).plume( s_ti(pl_i).ix ).time_frame = conc_calculation( M_pl(pl_i).transport, dVCc, Xc, Yc, Zc, Ncx, Ncy, Ncz, dxc, dyc, dzc );
                % CODE: CHECK SUM OF PLUME: sum ( Cc(9).plume( 1 ).time_frame(:) )*dVCc
            end
            s_ti( pl_i ).ix = s_ti( pl_i ).ix + 1;                   % Increment index for relevant time frames
        end
        
        % Calculating the sensor concentration:    
        if (need_sensor_calc == 1)
            % ************* Measure sensor activity every step ************ %
            sensor_t( pl_i ).dt(t,1) = t_lin(pl_i).data(t) ;     % First column contains dt steps [s]
            sensor_t( pl_i ).conc(t,1) = sensor_calculation( M_pl(pl_i).transport, xs, ys, zs, dVs );
            
            % ***** TIME module: Saves Plumes data on desired time sections ***** %
            % ****** since M_pl data being constantly overiden inside loop ****** %
        end
    end
end

%% **************************** SENSOR DISPLAY **************************** %
% ************ Superposition of CONCENTRATION & PLUMES structs' *********** %
% *********** Plotting EACH plume BLACK, and Super-position RED *********** %
if (need_sensor_calc == 1)                                       % *** save details to FILE "flag"
    Sensor_FILE(:,1) = linspace(dt, run_time, total_steps);      % *** Local time scale for the sensor
    Sensor_FILE(:,2) = zeros( total_steps, 1);                   % *** Initialize sensor array with zeros
    sensor_each(:,1) = linspace(dt, run_time, total_steps);      % *** Local time scale for the sensor
    sensor_each(:,2) = zeros( total_steps, 1);                   % *** Initialize sensor array with zeros
    figure(fig_i);                                               % *** figure() to stay on the same figure display
    
    for pl_i=1:num_plm                                           % ****** summation of all structs' arrays
        show_legend=0;                                           % *** Temporary flag to avoid Legend box in function
        sensor_each(:,2) = sensor_t(pl_i).conc(:,1);             % *** SUPERPOSITION sum of Columns of EACH PLUME;
        Sensor_FILE(:,2) = Sensor_FILE(:,2) + sensor_each(:,2);
        if ( need_sensor_show == 1)
            show_sensor_t( sensor_each, 'k--', show_legend);     % ****** Display EACH PLUME seperately (black)
        end
    end

    show_legend = sprintf('Total Run-time: %d [s] \nActual generation-time: %d [s]\nTotal steps: %d \ndt: %.1f [s]',...
        run_time, run_time*(time_edge), total_steps, dt);        % String to show in Figure
    
    if ( need_sensor_show == 1)
        show_sensor_t( Sensor_FILE, 'r-', show_legend );         % ****** Display SUPER-POSITION seperately (red)
    end
    fig_i=fig_i+1;                                               % **** Figure local Index
end

%% ********************** SAVE DATA TO FILE - SECTION ********************* %
% ***** NOTICE: Saved Files on directory need to be deleted manually  ***** %

if ( need_files_save == 1)
    for saving_time_index=1:save_f(1).length                              % 1:Length of total desired time frames
        Cc_SAVE(saving_time_index).time_save = zeros(Ncx, Ncy, Ncz);      % Initialize Cc_save before superposiotion
        % ********** Create new Struct divided to time frames ************* %
        for pl_i=1:num_plm               % *** summation of all structs' arrays
            M_pl_SAVE(saving_time_index).time_save(pl_i) = M_pl(pl_i).time_frame(saving_time_index);
            if ( need_conc_calc == 1)
                Cc_SAVE(saving_time_index).time_save = Cc_SAVE(saving_time_index).time_save + Cc_i(pl_i).plume(saving_time_index).time_frame;
            end
        end
        % *************** Conc Field save FILE SAVE call ************** %
        if ( need_conc_calc == 1)
            Cc_FILE = Cc_SAVE(saving_time_index).time_save;        % *** Temporarily - to be saved in FILE
            file_name = ['Conc Field at t = ' num2str( save_f(1).frames(saving_time_index) ) ' [s]'];
            save(fullfile( dir_2, [file_name '.mat']), 'Cc_FILE', 'Xc', 'Yc', 'Zc' );
        end
        % **************** Plume Field save FILE SAVE call **************** %
        M_pl_FILE = M_pl_SAVE(saving_time_index).time_save;    % *** Temporarily - to be saved in FILE
        file_name = ['Plume Field at t = ' num2str( save_f(1).frames(saving_time_index) ) ' [s]'];
        save(fullfile( dir_1, [file_name '.mat']), 'M_pl_FILE' );
    end
    % ***************** Sensor Indication FILE SAVE call ****************** %
    file_name = 'Sensor total Indication';
    save(fullfile( dir_3, [file_name '.mat']), 'Sensor_FILE' );
end

% *************** arrays by time desired frames {t1, t2, t3} ************** %
figure(fig_i); fig_i=fig_i+1;
str_time_table = sprintf('# Plumes: %d\n# Particles: %d\nPlume Width: %.1f [cm]\nU_x = %.2f [cm/s]\nW_Z = %.2f [cm/s]', ...
    num_plm, N_particles, W, u_x, w_z);
show_time_table( Pl_init_loc, num_plm, str_time_table, field_width, field_length);
% ************** Save Initial Plume Location Matrix (t, X, Y) ************* %
file_name = 'Plume_Initial_Location';
save(fullfile( dir_4, [file_name '.mat']), 'Pl_init_loc' );%% ******** Save all Variables in Workspace at the end of Run-time ******** %%
% ************** Save Total Workspace at the end of run-time ************** %
save((fullfile( dir_5, 'Workspace.mat' ) ));

%% ************* Attache' : Comments & Explanations along code ************* %%
% [^1]: Files cannot be saved inside PARFOR loop, therefore the usage in
% temporary arrays, and then saving them outside Loop.
% [^2]: Program "QA" - when checking reliablity of Concentration & M_pl functions,
% better off disabling u_x, w_z and diffusion.