function Mat = trans_particle( Mat, u_x, w_z, dt, dif_step, need_particle_dispersion ) % ! dif_step - is temporary cancelled

% ******* NOTICE: Diffusion and Settling been temporarily disabled ******** %
% **************************** X Axis promotion *************************** %
Mat.x = Mat.x + u_x*dt;                    % X Direction Advection
% **************************** Z Axis promotion *************************** %
Mat.z = Mat.z + w_z*dt;                    % Z Direction settling

if ( need_particle_dispersion == 1 )
    % ***************** (X, Y, Z) Diffusion - Random Walk ***************** %
    Mat.x = Mat.x + dif_step(:,1);         % X Direction - Diffusive Step
    Mat.y = Mat.y + dif_step(:,2);         % Y Direction - Diffusive Step
    Mat.z = Mat.z + dif_step(:,3);         % Z Direction - Diffusive Step
end

% ********* Zset - Settling beyond ground level Condition ********* %
% ***** If certain particle reached the floor, Particle being nullify ****** %

%[Zset,~,~] = find( Mat.z <=0 );   % ***** Zset - Z serial number of setteld particles
% 2017 Oct 21 Daniel and I replaced teh above line with teh next one:
Zset = find( Mat.z <=0 );   % ***** Zset - Z serial number of setteld particles

Mat.x(Zset, :) = NaN;
Mat.y(Zset, :) = NaN;
Mat.z(Zset, :) = NaN;

end