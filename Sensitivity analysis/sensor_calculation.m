function sensor_particles_summation = sensor_calculation ( Mat, xs, ys, zs, dVs )

% ************** • Particle_Location = X, Y, Z coordinates • ************** %
% ******** The sensor sums particles location and adds it to stack ******** %
sensor_particles_summation = (sum (...
    ( Mat.x(:) > (xs-dVs/2) & Mat.x(:) < (xs+dVs/2) ) & ...
    ( Mat.y(:) > (ys-dVs/2) & Mat.y(:) < (ys+dVs/2) ) & ...
    ( Mat.z(:) > (zs-dVs/2) & Mat.z(:) < (zs+dVs/2) ) ) )/(dVs^3);
% **** NOTE: The function returns concentration. dVs = sensor Cubic measurement **** %

end