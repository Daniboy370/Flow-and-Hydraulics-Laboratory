function [Xc, Yc, Zc] = make_axis_grid( field_length, field_width, Xc, Yc, Zc, Ncx, Ncy, Ncz, dxc, dyc, dzc )
% ********** NOTICE: Cc Matrix indices are sorted by (Z, X, Y) ************ %
% ************ Profile of (:,:,col_i) is moving from -y to +y ************* %

for ic=1:Ncx
    for jc=1:Ncy
        for kc=Ncz:-1:1
            Xc(kc,ic,jc)= ic*dxc-dxc/2-field_length;
            Yc(kc,ic,jc)= jc*dyc-dyc/2-field_width/2;
            Zc(kc,ic,jc)= kc*dzc-dzc/2;
        end
    end
end
Zc = flipud(Zc);
end