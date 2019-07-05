function show_time_table ( pl_init_loc, num_plm, str_time_table, field_width, field_length )

% ***** This function shows TOP VIEW distribution of initial PLUMES ***** %
    % ********** location with its resuspension random time ********** %
% field_ratio = field_length / field_width;         Calculation for real % size apcest ratio
    
    hold on; grid on; set(gcf,'color','w');
rectangle('Position', [-.5 -.5 1 1]); plot(0,0,'X');  % *** Sensor Location *** %

% *********** Top view display - [X,Y,t] of resuspension ********** %
for pl_i=1:num_plm
    text(pl_init_loc(pl_i).x, pl_init_loc(pl_i).y, ['t(' num2str(pl_i) ')='...
        num2str(pl_init_loc(pl_i).t) ' [s]'], 'HorizontalAlignment','center','FontSize', 13);
    plot(pl_init_loc(pl_i).x, pl_init_loc(pl_i).y, 'r*');
end

xlabel('\bfX Axis [cm]'); ylabel('\bfY Axis [cm]');
title('\bfTop View - Plumes Initial Generation', 'FontSize', 13);
txt = text(1,0,'\bf\itSensor (0,0)','HorizontalAlignment','center','FontSize', 15);
set(txt,'Rotation', 90);
% *************************** Legend Definition *************************** %
dim =  [0.05 .85 .1 .1]; 
box = annotation('textbox', dim, 'String', str_time_table, 'FontSize',13,'Color','k','FitBoxToText','on');
set(box, 'BackgroundColor', 'w'); hold off;         % 21/10/2017 - Daniel Canceled real acpect ratio of Field ( pbaspect([field_ratio 1 1]); )
axis([-field_length,0, -field_width/2, field_width/2]);
end