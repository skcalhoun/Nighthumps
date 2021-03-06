% analyze_DOXY_signal.m

% Analyze manta and PAR data to isolate the nighthump phenomena.

clear all
close all

% folder path where .mat files are kept
folder = '/Users/sandicalhoun/Nighthumps/AnalyzedData';
% list of file names for manta data
mantafiles = {'flint.mat'
    'vostok.mat'
    'malden.mat'
    'millenium.mat'
    'starbuck.mat'};
% list of file names for PAR data
parfiles = {'flint_PAR.mat'
    'vostok_PAR.mat'
    'malden_PAR.mat'
    'millennium_PAR.mat'
    'starbuck_PAR.mat'};

for i = 1:length(mantafiles)
    name = mantafiles{i};
    name = name(1:end-4);
    load(mantafiles{i});
    load(parfiles{i});
    
    analysis.DOXY_norm2=manta.DOXY_Norm2AVE;
    analysis.PAR_norm=interp1(par.SDN, par.PAR_norm, manta.SDN,'linear',0);
    analysis.PAR_norm2=interp1(par.SDN, par.PAR_norm2, manta.SDN,'linear',0);

% *****smooth data with a low pass filter*****
    n1 = 5; % filter order
    n2 = 5;
    period1 = 80;% cutoff period. when 1/period = 1, it is half of the sampling rate (butter)
    period2 = 24;% so that means period = 6 is one hour. 30 hours = 180
                   
    Wn1 = 1/period1; % cutoff frequency
    Wn2 = 1/period2;
        
    [b,a] = butter(n1,Wn1);
    [d,c] = butter(n2,Wn2);
    

    analysis.PAR_norm2lpf = filtfilt(b, a, analysis.PAR_norm2);
    analysis.PAR_normlpf = filtfilt(b, a, analysis.PAR_norm);
    
    %Subtract normalized, smoothed PAR data from normalized DO data
    analysis.DOXYminusPAR = manta.DOXY_Norm2AVE - analysis.PAR_norm2lpf;
    
    analysis.DOXYminusPAR_lpf = filtfilt(d,c,analysis.DOXYminusPAR);
      
    f1 = figure;
    hold
    plot(analysis.SDN, manta.DOXY_NormAVE,'c');
    plot(analysis.SDN, analysis.DOXYminusPAR,'m');
    plot(analysis.SDN, analysis.DOXYminusPAR_lpf,'r');
    plot(analysis.SDN, manta.diffDOXY_Norm2AVE,'b');
    plot(analysis.SDN, manta.diffDOXY_Norm2AVElpf,'k');
    title(island_name);
    ylabel('DOXY minus PAR');
    datetick('x', 'mm/dd');
    filename=[island_name,'_analysis'];
    saveas(f1, filename, 'png');
end
