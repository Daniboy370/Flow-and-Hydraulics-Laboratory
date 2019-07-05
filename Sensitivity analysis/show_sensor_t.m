function show_sensor_t( sensor, font, str_sensor )
% *********** This function plots the data saved on the sensor *********** % 
% *********************** across the whole run-time ********************** %
hold on; grid on; set(gcf,'color','w');
plot(sensor(:,1), sensor(:,2), font);
xlabel('Time [s]', 'FontSize', 13); ylabel('Concentration [#/cm^3]','FontSize', 13);
title('Concentration measured at the sensor', 'FontSize', 13);

% *************************** Legend Definition *************************** %
if ( str_sensor ~= 0 )
    dim =  [0.05 .85 .1 .1];
    box = annotation('textbox', dim, 'String', str_sensor, 'FontSize', 13, 'Color', 'k', 'FitBoxToText', 'on');
    set(box, 'BackgroundColor', 'w');
end
hold off;

end