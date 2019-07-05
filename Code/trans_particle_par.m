function M_pl = trans_particle_par(M_pl, u_x, w_z, dt, dif_step)

% ******************* X Axis promotion ******************** %
M_pl(:,1,trans_i) = M_pl(:,1,trans_i)+u_x*dt;                   % X Direction Advection

% ******************* Z Axis promotion ******************** %
M_pl(:,3,trans_i) = M_pl(:,3,trans_i)+w_z*dt;                   % Z Direction settling

% ********** (X, Y, Z) Diffusion - Random Walk ************ %
M_pl(:,1,trans_i) = M_pl(:,1,trans_i)+dif_step(:,1);            % X Direction - Diffusive Step
M_pl(:,2,trans_i) = M_pl(:,2,trans_i)+dif_step(:,2);            % Y Direction - Diffusive Step
M_pl(:,3,trans_i) = M_pl(:,3,trans_i)+dif_step(:,3);            % Z Direction - Diffusive Step

% ******* Truncate Z<=0 particles that exceed the ground threshold ******* %
[Jset,~,~] = find( M_pl(:,3,trans_i) <=0 );             % Xset, Pset - Needed?
M_pl(Jset, :, trans_i)=NaN;

end