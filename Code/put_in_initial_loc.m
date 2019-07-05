function Mat = put_in_initial_loc ( Mat, pl_init_loc_x, pl_init_loc_y )
% generate_single_plume calculates the x,y,z wrt the origina (0,0,0)
% Here we move the x and y wrt the floor location where the plume was generated

Mat.x = Mat.x + pl_init_loc_x ;
Mat.y = Mat.y + pl_init_loc_y ;

end