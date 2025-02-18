% this script is a test to decide which logic is best for trail_project.m 

clc, clearvars, close all

% create values table in range 0-20
rand_val_lat = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10];
rand_val_lon = [1; 1; 1; 1; 1; 1; 5; 5; 5; 5];
var_table = table(rand_val_lat, rand_val_lon, 'VariableNames', {'latitude', 'longitude'});

% create simple matrix for latitude and longitude - this is the mesh
lat = [0 0 0 0 0; 5 5 5 5 5; 10 10 10 10 10; 15 15 15 15 15; 20 20 20 20 20];
lon = [0 5 10 15 20; 0 5 10 15 20; 0 5 10 15 20; 0 5 10 15 20; 0 5 10 15 20];

% counting the values in specified bins
N = histcounts2(var_table.latitude, var_table.longitude, lat(:,1), lon(1,:)); %lat matrix is upside down becasue values must increase 
N = flipud(N); %matrix is upside donw - effect of the histcounts2 function

% define center points of the top-left (0) and bottom-right (1) mesh cells
step = 5; %in this script step is a magic value but in the main script it is calculated
x0 = lon(1,1) + step/2;
y0 = lat(size(lat,1), 1) - step/2;
x1 = lon(1, size(lon,2)) - step/2;
y1 = lat(1,1) + step/2;

% display values on mesh 
imagesc([x0, x1], [y0, y1], N); % proper location of pixels
set(gca, 'YDir', 'normal'); %set the proper direction of y-axis (imagesc uses the opposite direction)
colorbar;
hold on
% plot the mesh
h = plot(lat, lon, 'k'); %horizontal lines
hold on 
plot(lon,lat, 'k'); %vertical lines
