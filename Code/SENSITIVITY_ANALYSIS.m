%% ****************** SENSITIVITY ANALYSIS - INSTRUCTIONS ***************** %
%% ******************************* PURPOSE ******************************** % 
% **** The Script takes ready made set-up of plumes from previous RUNs 
% **** (with locations and times). After declaring new desired variables, 
% **** it plots graphs based on the SAME DATA SET, hence, allows Comparison.

%% ****************************** INSTRUCTIONS **************************** % 
% **** In order to conduct SENSITIVITY ANALYSIS do to the following;
% **** 1. Open regular plume-field file and run it (!Disable Dispersion!)
% **** 2. Make sure Workspace Directory & File have been saved
% **** 3. Open SENSITIVITY ANALYSIS file. Run Workspace.
% **** 4. define dt, Nc, ... and Run SENSITIVITY ANALYSIS

%% ******************* SENSITIVITY DECLARATION - SECTION ****************** %   

clc; % ask shai: load( fullfile(directory, file_name) );
% ************************ Dashboard Flags  ************************ %
need_conc_calc = 1;                                     % Concentration Calculation "flag"
need_sensor_calc = 1;                                   % Sensor Activity "flag"
need_sensor_show = 1*need_sensor_calc;                  % (!) Assures: No Calcultion = No Sensor Display
need_particle_dispersion = 0;                           % Particles' Dispersion "flag"
need_particle_settling = 1;                             % Particles' Settling "flag"
need_files_save = 1;                                    % Export saved time frames to EXTERNAL directory "flag"

% ***********************  Process definition *********************** %
dt = 0.1;                                               % Step Duration / Sampling Period [sec]
total_steps = run_time/dt;                              % Number of steps during Run-Time [#]

% ****** Initialize 3D matrices of (X,Y,Z) for concentration matrix ******* %
Nc = 15;                                                % Temporary Size of concentration 3D matrix in each direction
Ncx= Nc; Ncy= Nc; Ncz= Nc;                              % Temporary initialize to Nc
dxc= field_length/Ncx;       Xc=zeros(Ncz,Ncx,Ncy);     % dxc = Distance between 2 X-axis measurement points
dyc= field_width/Ncy;        Yc=zeros(Ncz,Ncx,Ncy);     % dyc = Distance between 2 Y-axis measurement points
dzc= h/Ncz;                  Zc=zeros(Ncz,Ncx,Ncy);     % dzc = Distance between 2 Z-axis measurement points
dVCc=dxc*dyc*dzc;                                       % dVCc = Concentration Control Volume

% ******************* Misc. Initialization of Variables ******************* %
fig_i=1;                                                    % Initializing the figure index
dif_step = 0;
M_pl = struct;

%% ***************** (1) PARFOR : INITIALIZATION STAGE (1) **************** %
parfor pl_i=1:num_plm
    % **** ! INITIALIZATION STAGE - Executed only ONCE for each Plume ! *** %
    % ************** !! PARFOR can work only with structs !! ************** %
    t_lin(pl_i).data = linspace(dt, run_time, total_steps); % Time scale, as STRUCT
    gen_plume_only_once(pl_i).data = 1;                     % Individual generation INDEX for each plume, as STRUCT
    s_ti(pl_i).ix = 1;                                      % Time frame index, as STRUCT
    % ********** Field Initialized with random plumes' locations ********** %
    % **************** Generate Plume with (X, Y, t) data ***************** %
    
    % *** M_pl.transport initialized writh nans to ensure "0" indication at sensor *** %
    M_pl( pl_i ).transport.x  = nan(N_particles, 1);
    M_pl( pl_i ).transport.y  = nan(N_particles, 1);
    M_pl( pl_i ).transport.z  = nan(N_particles, 1);
    % *** M_pl.time_frame initialized with nans to ensure "0" indication at sensor *** %
    M_pl( pl_i ).time_frame.x = nan(N_particles, 1);
    M_pl( pl_i ).time_frame.y = nan(N_particles, 1);
    M_pl( pl_i ).time_frame.z = nan(N_particles, 1);
end

%% ***************** (2) PARFOR : INITIALIZATION STAGE (2) **************** %
parfor pl_i=1:num_plm
    % *********************** dt steps - INNER LOOP *********************** %
    for t=1:total_steps
        % ************ PUT PLUME ON LOCATION DESIRED LOCATION ************* %
        if ( t_lin(pl_i).data(t) > Pl_init_loc(pl_i).t )
            % *********** TRANSPORT PARTICLES COLUMN every step *********** %
            M_pl(pl_i).transport = trans_particle( M_pl(pl_i).transport, u_x, w_z, dt, dif_step, need_particle_dispersion );
        end
        
        % Plugging the sactter at predifined times:
        if( s_ti(pl_i).ix <= save_f(pl_i).length && t_lin(pl_i).data(t) >= save_f(pl_i).frames( s_ti(pl_i).ix ) )           % Threshold for indices
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
            sensor_t_analysis( pl_i ).dt(t,1) = t_lin(pl_i).data(t) ;     % First column contains dt steps [s]
            sensor_t_analysis( pl_i ).conc(t,1) = sensor_calculation( M_pl(pl_i).transport, xs, ys, zs, dVs );
            
            % ***** TIME module: Saves Plumes data on desired time sections ***** %
            % ****** since M_pl data being constantly overiden inside loop ****** %
        end
    end
end

%% **************************** SENSOR DISPLAY **************************** %
% ************ Superposition of CONCENTRATION & PLUMES structs' *********** %
% *********** Plotting EACH plume BLACK, and Super-position RED *********** %
if (need_sensor_calc == 1)                                       % *** save details to FILE "flag"
    Sensor_FILE_analysis(:,1) = linspace(dt, run_time, total_steps);      % *** Local time scale for the sensor
    Sensor_FILE_analysis(:,2) = zeros( total_steps, 1);                   % *** Initialize sensor array with zeros
    sensor_each_analysis(:,1) = linspace(dt, run_time, total_steps);      % *** Local time scale for the sensor
    sensor_each_analysis(:,2) = zeros( total_steps, 1);                   % *** Initialize sensor array with zeros
    figure(fig_i);                                                        % *** figure() to stay on the same figure display
    
    for pl_i=1:num_plm                                           % ****** summation of all structs' arrays
        sensor_each_analysis(:,2) = sensor_t_analysis(pl_i).conc(:,1);             % *** SUPERPOSITION sum of Columns of EACH PLUME;
        Sensor_FILE_analysis(:,2) = Sensor_FILE_analysis(:,2) + sensor_each_analysis(:,2);
    end
    
    show_legend = sprintf('Total Run-time: %d [s] \nActual generation-time: %d [s]\nTotal steps: %d \ndt: %.1f [s]',...
        run_time, run_time*(time_edge), total_steps, dt);        % String to show in Figure
    
    if ( need_sensor_show == 1)
        show_sensor_t( Sensor_FILE_analysis, 'r-', show_legend );          % ****** Display SUPER-POSITION seperately (red)
    end
    fig_i=fig_i+1;                                               % **** Figure local Index
end