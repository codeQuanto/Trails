clc, clearvars, close all
%% Configuration %%

run("config.m");

readChannelID = cnfg.channelID;
field_latitude = cnfg.latitude_fieldID;
field_longtitude = cnfg.longtitude_fieldID;
readAPIKey = cnfg.read_api_key;

smooth_flag = 1; %if flag is set data on the plot is smooth 
geo_flag = 0; %if flag is set geodensity subplot is created
three_dim_flag = 1; %if flag is set 3D subplot is created

boundaries_flag = 1; %if flag is set user can specify the boundaries of the mesh

%% Read Data %%

ndays = 30; %odczyt z n ostatnich dni
[data] = thingSpeakRead(readChannelID, 'Fields', [field_latitude, field_longtitude], ...
            'NumDays', ndays, 'OutputFormat', 'timetable', 'ReadKey', readAPIKey);

%% Postproceed Data %%

% Określenie maksymalnych wartości danych
if boundaries_flag == 0
    max_lat = max(data.Latitude);
    min_lat = min(data.Latitude);
    max_lon = max(data.Longitude);
    min_lon = min(data.Longitude);
else
    max_lat = max(data.Latitude);
    min_lat = 52.21;
    max_lon = 21.052;
    min_lon = 20.94;
end

% Określenie maksymalnych zakresów siatki
grid_max_lat = round(max_lat + 0.005, 2); %zaokraglenie do 2 miejsc - zawsze w gore
grid_min_lat = round(min_lat - 0.006, 2); %zawsze w dol
grid_max_lon = round(max_lon + 0.005, 2);
grid_min_lon = round(min_lon - 0.006, 2);

% Utworzenie wektorów zawierajacych kolejne linie siatki
res = 0.01; %ta wartości obliczone dla Warszawy - czesc dziesietna stopnia odpowiadajaca 1 km
meters_res = 50; %chcę mieć n metrow
step = res * meters_res/1000;
Lat = grid_min_lat:step:grid_max_lat;
Lon = grid_min_lon:step:grid_max_lon;
% Utworzenie siatki
[LonMatrix, LatMatrix] = meshgrid(Lon, Lat);

% counting the values in specified bins
N = histcounts2(data.Latitude, data.Longitude, LatMatrix(:,1), LonMatrix(1,:)); %no need to upside down the LatMatrix like in the matrix_test.m
N = flipud(N); %matrix is upside donw - effect of the histcounts2 function

if smooth_flag == 1
    N = smoothdata2(N, "gaussian", 10);
end

% preparing data to displaying
N = N + 1;
N_log = log(N);
N_log = sqrt(N_log);

%preparing data to displaying as geodensity plot
if geo_flag == 1 || three_dim_flag == 1
    LatGeo = LatMatrix(1:end-1,1:end-1); %delete last column and row
    LatGeo  = LatGeo + step/2; %shift matrix
    LonGeo = LonMatrix(1:end-1,1:end-1); %delete last column and row
    LonGeo  = LonGeo + step/2; %shift matrix
    N_geo_log = flipud(N_log);
end

%% Display values %%

% define center points of the top-left (0) and bottom-right (1) mesh cells
x0 = LonMatrix(1,1) + step/2;
y0 = LatMatrix(size(LatMatrix,1), 1) - step/2;
x1 = LonMatrix(1, size(LonMatrix,2)) - step/2;
y1 = LatMatrix(1,1) + step/2;

% display values
figure()
tiledlayout(1, 1 + geo_flag + three_dim_flag);

nexttile
imagesc([x0, x1], [y0, y1], N_log); % proper location of pixels
set(gca, 'YDir', 'normal'); %set the proper direction of y-axis (imagesc uses the opposite direction)
colorbar;
colormap turbo;
hold on
%plot the mesh
plot(LonMatrix', LatMatrix', 'k'); %horizontal lines
hold on 
plot(LonMatrix,LatMatrix, 'k'); %vertical lines

if geo_flag == 1
    nexttile
    geodensityplot(LatGeo(:), LonGeo(:), N_geo_log(:), 'Radius', 200, 'FaceColor', 'interp');
end

if three_dim_flag == 1
    nexttile
    surf(LonGeo, LatGeo, N_geo_log, 'EdgeColor', 'none'); % 3D plot
    view(3); % Set 3D view
end