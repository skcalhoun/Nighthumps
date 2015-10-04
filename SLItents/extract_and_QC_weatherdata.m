% extract_and_QC_weatherdata.m

clear all
close all

% folder path where text files are kept
folder = '/Users/Sandi/Documents/Nighthumps/SLItents/raw_tent_text_files/';
% list of text file names for physical data
txtfiles = ls([folder,'Curacao*.csv']);
weather.SDN = [];
weather.TF = [];
weather.Hum = [];
weather.Pres = [];
weather.Wind = [];
weather.WindDir = [];


for i = 1:size(txtfiles,1)
    island_name = txtfiles(i,:);
    date = island_name(1,8:end-4);
    island_name = island_name(1:end-13);
    
    trex = readtable([folder,txtfiles(i,:)]);
    time = trex.TimeAST;
    SDN = cell(size(time));
    for ii = 1:length(time)
        SDN{ii} = [date,' ',time{ii}];
    end
    SDN = datetime(SDN,'InputFormat','M-dd-yyyy h:mm a');
    
    check = nanmean(weather.TF);
    iuse = inrange(weather.TF, [(check-100) (check+100)]);
    weather.TF(~iuse,1) = NaN;
    check = nanmean(weather.TF);
    iuse = isnan(weather.TF);
    weather.TF(iuse,1) = check;
    
    check = nanmean(weather.Hum);
    iuse = inrange(weather.Hum, [(check-100) (check+100)]);
    weather.Hum(~iuse,1) = NaN;
    check = nanmean(weather.Hum);
    iuse = isnan(weather.Hum);
    weather.Hum(iuse,1) = check;
    
    check = nanmean(weather.Pres);
    iuse = inrange(weather.Pres, [(check-100) (check+100)]);
    weather.Pres(~iuse,1) = NaN;
    check = nanmean(weather.Pres);
    iuse = isnan(weather.Pres);
    weather.Pres(iuse,1) = check;

    check = nanmean(weather.Wind);
    iuse = inrange(weather.Wind, [(check-100) (check+100)]);
    weather.Wind(~iuse,1) = NaN;
    check = nanmean(weather.Wind);
    iuse = isnan(weather.Wind);
    weather.Wind(iuse,1) = check;
    
    weather.SDN = [weather.SDN;SDN];
    weather.TF = [weather.TF;trex.TemperatureF];
    weather.Hum = [weather.Hum;trex.Humidity];
    weather.Pres = [weather.Pres;trex.SeaLevelPressureIn];
    weather.Wind = [weather.Wind;trex.WindSpeedMPH];
    weather.WindDir = [weather.WindDir;trex.WindDirDegrees];

clearvars -except weather folder island_name txtfiles

end


f_name = [island_name,'_weather.mat'];
save(f_name, 'weather', 'island_name');
close all





