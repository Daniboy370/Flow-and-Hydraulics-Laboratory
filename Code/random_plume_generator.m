function  [t_rand, x_rand, y_rand] = random_plume_generator(field_length, field_width, dt, run_time, time_edge )

% ***** This function creates random (X, Y, time) values in a given range *****
% ******** that later will be used later on to GENERATE olumes on it **********
% **** NOTICE: time_edge [0~1] = Desired size of Run-time fracture 
    
t_rand=round(100*( run_time*(time_edge)*rand+dt ) )/100;        % Generates random initial time. (!) 100 for a decimal point
x_rand=field_length*(-rand() );                                   % Generates random X coordintates
y_rand=field_width*(-.5+rand() );                                 % Generates random Y coordintates

end