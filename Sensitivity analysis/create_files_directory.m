function [dir_1, dir_2, dir_3, dir_4, dir_5] = create_files_directory ()

% ****** This function was made to reduce commands on main screen ******** %
% **** It gives the full directory address to be filled for savedfiles *** %

if ~exist('Se','dir')
    mkdir(pwd, 'Sensor ')
end

if ~exist('Field_Concentration','dir')
    mkdir(pwd,'Field_Concentration')
end

if ~exist('Field_sensor','dir')
    mkdir(pwd,'Field_sensor')
end

if ~exist('Plume_Initial_Location','dir')
    mkdir(pwd,'Plume_Initial_Location')
end

if ~exist('Workspace','dir')
    mkdir(pwd,'Workspace')
end

    % ******** The function OUTPUT is the directory addresses ******** %

dir_1= [pwd(), '\Field_Plumes'];
dir_2= [pwd(), '\Field_Concentration'];
dir_3= [pwd(), '\Field_sensor'];
dir_4= [pwd(), '\Plume_Initial_Location'];
dir_5= [pwd(), '\Workspace'];

end