clc, clearvars, close all
%% Configuration %%

run("config.m");

readChannelID = cnfg.channelID;
field_latitude = cnfg.latitude_fieldID;
field_longtitude = cnfg.longtitude_fieldID;
readAPIKey = cnfg.read_api_key;

%% Read Data %%

ndays = 3; %odczyt z n ostatnich dni
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
meters_res = 50; %chcę mieć 50 m
step = res * meters_res/1000;
Lat = grid_min_lat:step:grid_max_lat;
Lon = grid_min_lon:step:grid_max_lon;
% Utworzenie siatki
[LonMatrix, LatMatrix] = meshgrid(Lon, Lat);

%na razie probne liczby
values = rand(numel(Lat) * numel(Lon),1);
% wrzucmy wartosci do macierzy
ValuesMatrix = reshape(values(:), numel(Lat), numel(Lon));
%wyswietlmy losowe wartosci
figure()
%tiledlayout(1,2)
%nexttile
%h = geodensityplot(LatMatrix(:), LonMatrix(:), ValuesMatrix(:), 'Radius', 100);
%nexttile
h = geodensityplot(LatMatrix(:), LonMatrix(:), ValuesMatrix(:), 'Radius', 100, 'FaceColor','interp');

% teraz trzeba zliczyc punkty w danym zakresie

%{
%rozdzielczość siatki
res = 0.01; %ta wartości obliczone dla Warszawy - czesc dziesietna stopnia odpowiadajaca 1 km
meters_res = 50; %chcę mieć 50 m
grid_res_lat = ((max_lat - min_lat)/res)*1000/50;
grid_res_lon = ((max_lon - min_lon)/res)*1000/50;

% Utworzenie siatki
vect_lat = linspace(min_lat, max_lat, grid_res_lat); %utworzenie wektora dla szerokosci
vect_lon = linspace(min_lon, max_lon, grid_res_lon); %utworzenie wektora dla długości
[grid_lon, grid_lat] = meshgrid(vect_lon, vect_lat); %utworzenie siatki

% policzenie punktów w danej komórce siatki
num_points = hist3([data.Longitude, data.Latitude], 'Edges', {vect_lon, vect_lat}); %tutaj automatycznie kwadrat 10x10
%% Visualize Data %%

plot(data.Longitude, data.Latitude, 'o');
xlabel('Longitude');
ylabel('Latitude');
title('Geographical Data from ThingSpeak');
hold on
%wyswietlenie siatki
plot(grid_lon, grid_lat, 'k');
hold on;
plot(grid_lon', grid_lat', 'k');
%heatmapa
figure;
imagesc(grid_lon(1,:), grid_lat(:,1), num_points');
axis xy;
colorbar;
hold on;
plot(grid_lon, grid_lat, 'k');
hold on;
plot(grid_lon', grid_lat', 'k');


data.Value = ones(height(data), 1);
[LatMatix, LonMatrix] = ndgrid(data.Latitude, data.Longitude);
%}

