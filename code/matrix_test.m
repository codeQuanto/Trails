% this script is a test to decide which logic is best for trail_project.m 

clc, clearvars, close all

% create simple matrix for latitude and longitude - this is the mesh
lat = [3 3 3; 2 2 2; 1 1 1];
lon = [1 2 3; 1 2 3; 1 2 3];

% create values matrix - 1 element for each mesh CELL (not VERTEX)
values2 = [1 2; 3 4];

% define center points of the top-left (0) and bottom-right (1) mesh cells
step = 1; %in this script step is a magic value but in the main script it is calculated
x0 = lon(1,1) + step/2;
y0 = lat(1,1) - step/2;
x1 = lon(1, size(lon,2)) - step/2;
y1 = lat(size(lat,1), 1) + step/2;

% display values on mesh 
imagesc([x0, y0], [x1, y1], values2); % proper location of pixels
set(gca, 'YDir', 'normal'); %set the proper direction of y-axis (imagesc uses the opposite direction)
colorbar;
hold on
% plot the mesh
h = plot(lat, lon, 'k'); %horizontal lines
hold on 
plot(lon,lat, 'k'); %vertical lines