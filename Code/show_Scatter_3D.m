function show_Scatter_3D ( M_pl, pl_max, str )
% ************ This function responsible for 3D display from A-Z. ********* %
% *************** in order to reduce the main code volume ***************** %
hold on; set(gcf,'color','w');
% ****************** Scatter plume by its serial number  ****************** %
for pl_i=1:pl_max
    scatter3( M_pl(pl_i).x, M_pl(pl_i).y, M_pl(pl_i).z, 7, 'filled');
end

title(str, 'FontSize', 13);
xlabel('X [cm]'); ylabel('Y [cm]'); zlabel('Z [cm]');
grid on; pbaspect([1 1 1]); view(40,35);