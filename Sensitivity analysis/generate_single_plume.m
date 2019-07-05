function [x, y, z] = generate_single_plume( N_particles, h, W)
% **** This function is responsible for the distribution of plume particles 
% **** The user can control on the mean distribution, 
% **** Truncation edges, and values of the standard deviation. ****** %

[z] = h.*rand(N_particles,1);               % Uniform Distribution of particles along z
% to test a normal distribution, use random instead of rand 

theta = 2*pi*rand(N_particles,1);           % Uniform Distribution along theta
pd = makedist('Normal','mu',0,'sigma',0.3*W); % Normal distribution function along r
rt = truncate(pd,0,0.5*W);        % No particles beyond W by trancating the normal bell.
radii = random(rt,N_particles,1);           % Normal distribution along r
[x,y] = pol2cart(theta,radii);              % transforming (r,theta) to (x,y)

end