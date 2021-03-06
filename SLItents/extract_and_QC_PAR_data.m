% extract_and_QC_hobo_data.m

% Extract hobo data from text file, and then QC the data.



clear all
close all

% folder path where text files are kept
folder = '/Users/sandicalhoun/Nighthumps/SLItents/raw_tent_text_files/';
% list of text file names for PAR data
txtfiles = {'flint_PAR.txt'
    'vostok_PAR.txt'
    'malden_PAR.txt'
    'millennium_PAR.txt'
    'starbuck_PAR.txt'
    'fanning_PAR.txt'
    'jarvis_PAR.txt'
    'kingman_PAR.txt'
    'palmyra_PAR.txt'
    'washington_PAR.txt'};


for i = 1:length(txtfiles)
    island_name = txtfiles{i};
    island_name = island_name(1:end-4);
    switch txtfiles{i}
        case 'flint_PAR.txt'
            daterange = [datenum(2013,10,18,10,0,0) datenum(2013,10,21,9,20,0)];
        case 'vostok_PAR.txt'
            daterange = [datenum(2013,10,22,8,30,0) datenum(2013,10,24,8,25,0)];
        case 'malden_PAR.txt'
            daterange = [datenum(2013,10,31,5,24,0) datenum(2013,11,2,10,59,0)];
        case 'millennium_PAR.txt'
            daterange = [datenum(2013,11,6,3,10,0) datenum(2013,11,7,13,50,0)];
        case 'starbuck_PAR.txt'
            daterange = [datenum(2013,10,26,9,45,0) datenum(2013,10,29,9,30,0)];
        case 'fanning_PAR.txt'
            daterange = [datenum(2010,11,4,8,0,0) datenum(2010,11,7,11,45,0)];
        case 'jarvis_PAR.txt'
            daterange = [datenum(2010,11,12,11,0,0) datenum(2010,11,14,14,55,0)];
        case 'kingman_PAR.txt'
            daterange = [datenum(2010,10,30,15,55,0) datenum(2010,11,1,14,45,0)];
        case 'palmyra_PAR.txt'
            daterange = [datenum(2010,10,25,15,0,0) datenum(2010,10,28,10,25,0)];
        case 'washington_PAR.txt'
            daterange = [datenum(2010,11,8,11,0,0) datenum(2010,11,10,10,45,0)];
    end
    
    filepath = [folder,txtfiles{i}];
    trex = manta2mat(filepath);

    
    % interpolate onto 5min intervals
    
    par.SDN = [daterange(1):datenum(0,0,0,0,5,0):daterange(end)]';
    
    %iuse = inrange(trex.SDN(:), [par.SDN(1) par.SDN(end)]);
    par.PAR = interp1(trex.SDN, trex.PAR, par.SDN,'linear',0);
    par.StdDev = interp1(trex.SDN, trex.StdDev, par.SDN,'linear',0);
    
    
    % low pass filter PAR data
    %*****smooth data with a low pass filter*****
    n = 5; % filter order
    period = 80;% cutoff period. when 1/period = 1, it is half of the sampling rate (butter)
                % so that means period = 6 is one hour. 30 hours = 180.
    Wn = 1/(period); % cutoff frequency
    [b,a] = butter(n,Wn);


    par.PAR_lpf = filtfilt(b, a, par.PAR);

    par.PAR_runavg = runmean(par.PAR,3);
    % take derivative.
    par.dPAR_lpf = diff(par.PAR_lpf);
    % recored peak heights of dDOXY.
    PARmax = findpeaks(par.PAR_lpf,'MinPeakDistance',datenum(0,0,0,6,0,0));
    means = mean(par.PAR);
    stdevs = std(par.PAR);
    peaksPAR.(island_name(1:end-4)).PARmax = PARmax;
    peaksPAR.(island_name(1:end-4)).means = means;
    peaksPAR.(island_name(1:end-4)).stdevs = stdevs;
    
    % normalize PAR data by two methods
    base = mean(par.PAR);
  
    par.PAR_norm=par.PAR/base;
    stdev=std(par.PAR);
    par.PAR_norm2=(par.PAR-base)/stdev;
   
  
% plotvar = 'PAR_lpf';
%     
%     fsize = 10;
%     lwidth = 2;
% 
% 
%     f1 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
%     hold on
%     plot(par.SDN(1:end), par.(plotvar), 'linewidth', lwidth);
% %     plot(manta.SDN(dDOXYmax_locs{1}), dDOXYmax{1},'rv','MarkerFaceColor','r');
% %     plot(manta.SDN(dDOXYmin_locs{1}), dDOXYmin{1},'rs','MarkerFaceColor','b');
%     title(island_name(1:end-4), 'fontsize', fsize);
%     ylabel('LPF PAR [\mumol cm^-^2 s^-^1]', 'fontsize', fsize);
% %     ylim([150 220]);
% %     ylim([-2.0 2.0]);
%     datetick('x', 'HH:MM');
% %     legend('1', '2', '3', '4', '5', '6','peaks','troughs','Location','eastoutside');
%     set(gca, 'fontsize', fsize);
%     
%     plotname = [island_name(1:end-4),'_',plotvar,'.png'];
%     saveas(f1, plotname);
%     %movefile(plotname, 'plots', 'f');
    
%     plotvar = 'dPAR_lpf';
    
%     f2 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
%     hold on
%     plot(par.SDN(2:end), par.(plotvar), 'linewidth', lwidth);
% %     plot(manta.SDN(DOXYmax_locs{1}), DOXYmax{1},'rv','MarkerFaceColor','r');
% %     plot(manta.SDN(DOXYmin_locs{1}), DOXYmin{1},'rs','MarkerFaceColor','b');
%     title(island_name(1:end-4), 'fontsize', fsize);
%     ylabel('Derivative LPF PAR [\mumol/m^2/s]', 'fontsize', fsize);
% %     ylim([140 220]);
% %     ylim([-0.6 0.6]);
%     datetick('x', 'mm/dd');
% %     legend('1', '2', '3', '4', '5', '6', 'peaks', 'troughs','Location','eastoutside');
%     set(gca, 'fontsize', fsize);
%     
%     plotname = [island_name(1:end-4),'_',plotvar,'.png'];
%     saveas(f2, plotname);
 
    f_name = [island_name,'.mat'];
    
    save(f_name, 'par', 'island_name');
    close all
    
    
    clearvars -except folder txtfiles peaksPAR
    
    
end

save('peaksPAR.mat','peaksPAR');





