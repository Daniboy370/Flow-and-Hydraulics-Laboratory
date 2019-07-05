function show_conc (Cc, Xc, Yc, Zc, file_name, plane_display)
% ******** This function Show desired Plane section of Cc Matrix ********** %
% ******* Creating One Dimension Linear Vector to use as Plot Axes ******** %
x_lin = squeeze( Xc(1,:,1) )';
y_lin = squeeze( Yc(1,1,:) );
z_lin = squeeze( Zc(:,1,1) );

% ******** (x)_section = Specific (x)lin location of Axis section ********* %
% *** !! For simplicity, I chose all sections to be in the mid-Axis !! **** %    
x_section = round( length(x_lin)/2 );                
y_section = round( length(y_lin)/2 );
z_section = round( length(z_lin)/2 );

% *** Switch-case  for each case of the different plane-section *** %    
hold on; grid on; set(gcf,'color','w');

switch (plane_display)
    case 1          % ************** Show X - Y Plane Section ************* %
        contourf (y_lin, x_lin, squeeze( Cc(z_section,:,:) ));
        txt_title = 'X - Y '; txt_sub = ', Z = '; sec_val = x_section; X_label= 'Y [cm]'; Y_label= 'X [cm]';
    case 2          % ************** Show Y - Z Plane Section ************* %
        contourf (y_lin, z_lin, squeeze( Cc(:,x_section,:) ));
        txt_title = 'Y - Z '; txt_sub = ', X = '; sec_val = y_section; X_label= 'Y [cm]'; Y_label= 'Z [cm]';
    case 3          % ************** Show X - Z Plane Section ************* %
        contourf (x_lin, z_lin, squeeze( Cc(:,:,y_section) ));
        txt_title = 'X - Z '; txt_sub = ', Y = '; sec_val = z_section; X_label= 'X [cm]'; Y_label= 'Z [cm]';
end

str = file_name; str = str(1:end-4);
xlabel(X_label, 'FontSize', 13); ylabel(Y_label,'FontSize', 13);
c=colorbar; c.Label.String = 'Particles per Cube [#/m^3]';
c.Label.FontSize = 13;
title([txt_title str txt_sub num2str(sec_val) ' [cm]'], 'FontSize', 13);
hold off;