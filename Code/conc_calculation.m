function Cc = conc_calculation (Mat, dVCc, Xc, Yc, Zc, Ncx, Ncy, Ncz, dxc, dyc, dzc)

% ******** This function creates the X, Y, Z axis by the desired ***********
% ********* Division scales (Ncx, Ncy, Ncz), and uses it in the ************
% ****** concentration matrix to detect particle in current Control Volume (dVCc)

% ********** NOTICE: Cc Matrix indices are sorted by (Z, X, Y) ************ %
for ic=1:Ncx
    for jc=1:Ncy
        for kc=Ncz:-1:1
            x= Xc(kc,ic,jc); y= Yc(kc,ic,jc); z= Zc(kc,ic,jc);    % Early declaration for shortening
            % ******** find(...) - returns vector with the cells that fit
            % ******** the condition specified below
            [row,~] = find ( Mat.x > (x-dxc/2) & Mat.x < (x+dxc/2)...
                           & Mat.y > (y-dyc/2) & Mat.y < (y+dyc/2)...  % NOTE: Check if better off sum()
                           & Mat.z > (z-dzc/2) & Mat.z < (z+dzc/2) );
            % ******** length - returns number of particles in whole column
            Cc(kc,ic,jc) = length(row) / dVCc;           % NOTE: dVCc=dxc*dyc*dzc;
        end
    end
end