clc, clearvars, close all
%% Configuration %%

run("config.m");

readChannelID = cnfg.channelID;
field_latitude = cnfg.latitude_fieldID;
field_longtitude = cnfg.longtitude_fieldID;
readAPIKey = cnfg.read_api_key;

%% Read Data %%

ndays = 30; %odczyt z n ostatnich dni
[data] = thingSpeakRead(readChannelID, 'Fields', [field_latitude, field_longtitude], ...
            'NumDays', ndays, 'OutputFormat', 'timetable', 'ReadKey', readAPIKey);

%% Postproceed Data %%

% Określenie maksymalnych wartości danych
max_lat = max(data.Latitude);
min_lat = min(data.Latitude);
max_lon = max(data.Longitude);
min_lon = min(data.Longitude);

% Określenie maksymalnych zakresów siatki
grid_max_lat = round(max_lat + 0.005, 2); %zaokraglenie do 2 miejsc - zawsze w gore
grid_min_lat = round(min_lat - 0.006, 2); %zawsze w dol
grid_max_lon = round(max_lon + 0.005, 2);
grid_min_lon = round(min_lon - 0.006, 2);

% Utworzenie wektorów zawierajacych kolejne linie siatki
res = 0.01; %ta wartości obliczone dla Warszawy - czesc dziesietna stopnia odpowiadajaca 1 km
meters_res = 100; %chcę mieć n metrow
step = res * meters_res/1000;
Lat = grid_min_lat:step:grid_max_lat;
Lon = grid_min_lon:step:grid_max_lon;
% Utworzenie siatki
[LonMatrix, LatMatrix] = meshgrid(Lon, Lat);

% counting the values in specified bins
N = histcounts2(data.Latitude, data.Longitude, LatMatrix(:,1), LonMatrix(1,:)); %no need to upside down the LatMatrix like in the matrix_test.m

%% Display values on mesh %%

% define center points of the top-left (0) and bottom-right (1) mesh cells
x0 = LonMatrix(1,1) + step/2;
y0 = LatMatrix(size(LatMatrix,1), 1) - step/2;
x1 = LonMatrix(1, size(LonMatrix,2)) - step/2;
y1 = LatMatrix(1,1) + step/2;

% Define the limits for x and y axes
xlim([LonMatrix(1, 1), LonMatrix(1, end)]); % Oś X: od pierwszej do ostatniej wartości w pierwszym wierszu LonMatrix
ylim([LatMatrix(1, 1), LatMatrix(end, 1)]);

imagesc([x0, y0], [x1, y1], N); % proper location of pixels
set(gca, 'YDir', 'normal'); %set the proper direction of y-axis (imagesc uses the opposite direction)
colorbar;

hold on
%plot the mesh
plot(LonMatrix', LatMatrix', 'k'); %horizontal lines
hold on 
plot(LonMatrix,LatMatrix, 'k'); %vertical lines


% Old version of displaying
%{
%wyswietlmy losowe wartosci
figure()
tiledlayout(1, 2);
nexttile
plot(LonMatrix, LatMatrix, 'k'); %wyswietlenie siatki - linie pionowe
hold on;
plot(LonMatrix', LatMatrix', 'k'); %linie poziome
nexttile
geodensityplot(LatMatrix(:), LonMatrix(:), ValuesMatrix(:), 'Radius', 100, 'FaceColor','interp');
%}


