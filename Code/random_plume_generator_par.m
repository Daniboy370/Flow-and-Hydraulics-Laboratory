function  [t_rand, x_rand, y_rand] = random_plume_generator_par(square_field_size, dt, total_t)

% ***** This function creates random (X, Y, time) values in a given range *****
% ******** that later will be used later on to GENERATE olumes on it **********

x_rand=square_field_size*(-rand() );           % Generates random X coordintates
y_rand=square_field_size*(-.5+rand() );        % Generates random Y coordintates
t_rand=round(100*total_t*rand+dt )/100;        % Generates random initial time. 100 for decimal point

end