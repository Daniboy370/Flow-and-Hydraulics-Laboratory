function Particle_Location = put_plume_in_initial_location ( Particle_Location , pl_i, pl_init_loc )
	% ********** Positioning each plume on its specific Location ********** %
    Particle_Location(:,1) = Particle_Location(:,1) + pl_init_loc(pl_i,2);
    Particle_Location(:,2) = Particle_Location(:,2) + pl_init_loc( pl_i,3);
end