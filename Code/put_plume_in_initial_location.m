function M_pl = put_plume_in_initial_location ( M_pl, pl_i )

M_pl(pl_i).data(:,1) = M_pl(pl_i).data(:,1) + pl_init_loc(pl_i,2);
M_pl(pl_i).data(:,2) = M_pl(pl_i).data(:,2) + pl_init_loc(pl_i,3);

end