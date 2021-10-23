clear all;close all;clc
%% load EEG data
load ('Trial7.csv')
AccX = Trial7(:,5);
AccY = Trial7(:,6);
AccZ = Trial7(:,7);
EEG1 = Trial7(:,2);
EEG2 = Trial7(:,3);

%sampling freq
fs_EEG = 2048; %Hz
fs_Acc = 200; %Hz
N = length(EEG1); %no sample EEG
t_EEG = (1/fs_EEG) * N; % duration second
timeVec = linspace(0,t_EEG,N);
acc_length = fs_Acc*t_EEG;
timeVecAcc = linspace(0,t_EEG,acc_length);

%% load ECG data
load('ECG.mat');
plot(ECG);
ts = 20e-3; %sampling time
fs_ecg = 1/ts; %sampling frequency
[pks,locs]=findpeaks(ECG,'MinPeakHeight',150);

%% signal processing ECG
%notch filter- remove base line & interference
% LPF removes 50Hz noise 
LPF=designfilt('lowpassiir', 'PassbandFrequency', 10, 'StopbandFrequency', 20, 'PassbandRipple', 1, 'StopbandAttenuation', 60, 'SampleRate', 50);
fvtool(LPF);
%HPF 
HPF=designfilt('highpassiir', 'StopbandFrequency', 0.05, 'PassbandFrequency', .55, 'StopbandAttenuation', 60, 'PassbandRipple', 1, 'SampleRate', 50);
fvtool(HPF);

filteredECG=filter(LPF,ECG);
filteredECG=filter(HPF,filteredECG);
figure
subplot(2,1,1);
plot(ECG(500:2000));
title('original signal')
subplot(2,1,2);
plot(filteredECG(500:2000));
title('filtered signal')

%adaptive filter- motion artifact

%determine heart rate
[pk,loc]=findpeaks(filteredECG(500:2000),'MinPeakHeight',90);
interval=0;
aveHR=0;

for i=1:length(loc)-1
    interval(i)=loc(i+1)-loc(i);
end
interval=interval*ts;


for i=1:length(interval)-5
    aveHR(i)= (interval(i)+interval(i+1)+interval(i+2)+interval(i+3)+interval(i+4))/5;
end
aveHR=aveHR*60;

figure
plot(linspace(0,ts*length(ECG),length(aveHR)),aveHR(1:end));
title('Hearate (BPM)')
xlabel('time(s)')
ylabel('BPM')


figure
spectrogram(ECG,128,120,128,fs_ecg,'yaxis');title('spectogram ECG')
figure
spectrogram(filteredECG,128,120,128,fs_ecg,'yaxis');title('spectogram Filtered ECG')

%workout zone

%% signal processing EEG
%plot eeg
figure
subplot(2,1,1)
plot(timeVec,EEG1)
title('Clean EEG')
xlabel('time(s)')
ylabel('voltage()')
subplot(2,1,2)
plot(timeVec,EEG2)
title('Raw EEG')
xlabel('time(s)')
ylabel('voltage()')
% plot acceleration
figure
plot(timeVecAcc,AccX(1:acc_length))
hold
plot(timeVecAcc,AccY(1:acc_length))
plot(timeVecAcc,AccZ(1:acc_length))
xlabel('time(s)')
ylabel('voltage()')
legend('AccX','AccY','AxxZ')
title('Accelation data')
%plot ecg and acc
figure
subplot(2,1,1)
plot(timeVec,EEG2)
title('Raw EEG')
xlabel('time(s)')
ylabel('voltage()')
subplot(2,1,2)
plot(timeVecAcc,AccX(1:acc_length))
title('X Acceleration')
xlabel('time(s)')
ylabel('voltage()')

% fourier

%notch filter- remove base line & interference
Fnotch = 0.67; % Notch Frequency
BW = 5; % Bandwidth
Apass = 1; % Bandwidth Attenuation
[b, a] = iirnotch (Fnotch/ (fs_EEG/2), BW/(fs_EEG/2), Apass);
Hd = dfilt.df2 (b, a);
figure
subplot (3, 1, 1), plot(EEG2), title ('EEG Signal with baseline wander'), grid on
y0=filter (Hd, EEG2);
subplot (3, 1, 2), plot(y0), title ('EEG signal with low-frequency noise (baseline wander) Removed'), grid on

Fnotch = 60; % Notch Frequency
BW = 10; % Bandwidth
Apass = 1; % Bandwidth Attenuation
[b, a] = iirnotch (Fnotch/ (fs_EEG/2), BW/ (fs_EEG/2), Apass);
Hd1 = dfilt.df2 (b, a);
y1=filter (Hd1, y0);
subplot (3, 1, 3), plot (y1), title ('EEG signal with power line noise Removed'), grid on

%adaptive filter- remove motion artifact
EEG2 = downsample(EEG2,10); %downsample EEG so it match ACC data
n=110000;
EEG1 = EEG1(1:n); %make EEG and acceleration length equal 
EEG2 = EEG2(1:n);
Acc = AccX(1:n);

rlsf2  = dsp.RLSFilter('Length', 11, 'Method', 'Householder RLS');
ffilt2 = dsp.FIRFilter('Numerator',fir1(10, [.5, .75]));
x = Acc; % Noise
d = ffilt2(x) + EEG2; % Noise + Signal
[y, err] = rlsf2(x, d);

figure
subplot(3,1,1), plot(d), title('Noise + EEG');
subplot(3,1,2), plot(err), title('clean EEG');
subplot(3,1,3), plot(EEG1), title('Undisturbed EEG');

cleanEEG = y;

%fourier transform analysis

%wavelet transform analysis
fs = fs_EEG/10;
N=length(cleanEEG);
waveletFunction = 'db8';
[C,L] = wavedec(cleanEEG,8,waveletFunction); %1D wavelet decomposition 

cD1 = detcoef(C,L,1); %1D detail coeficient
cD2 = detcoef(C,L,2);
cD3 = detcoef(C,L,3);
cD4 = detcoef(C,L,4);
cD5 = detcoef(C,L,5); %GAMA
cD6 = detcoef(C,L,6); %BETA
cD7 = detcoef(C,L,7); %ALPHA
cD8 = detcoef(C,L,8); %THETA

cA8 = appcoef(C,L,waveletFunction,8); %DELTA %	1-D approximation coefficients

D1 = wrcoef('d',C,L,waveletFunction,1); %Reconstruct single branch from 1-D wavelet coefficients
D2 = wrcoef('d',C,L,waveletFunction,2);
D3 = wrcoef('d',C,L,waveletFunction,3);
D4 = wrcoef('d',C,L,waveletFunction,4);
D5 = wrcoef('d',C,L,waveletFunction,5); %GAMMA
D6 = wrcoef('d',C,L,waveletFunction,6); %BETA
D7 = wrcoef('d',C,L,waveletFunction,7); %ALPHA
D8 = wrcoef('d',C,L,waveletFunction,8); %THETA
A8 = wrcoef('a',C,L,waveletFunction,8); %DELTA

Gamma = D5;
figure; subplot(5,1,1); plot(1:1:length(Gamma),Gamma);title('GAMMA');

Beta = D6;
subplot(5,1,2); plot(1:1:length(Beta), Beta); title('BETA');

Alpha = D7;
subplot(5,1,3); plot(1:1:length(Alpha),Alpha); title('ALPHA'); 

Theta = D8;
subplot(5,1,4); plot(1:1:length(Theta),Theta);title('THETA');
D8 = detrend(D8,0);

Delta = A8;
subplot(5,1,5);plot(1:1:length(Delta),Delta);title('DELTA');

D5 = detrend(D5,0);
xdft = fft(D5);
freq = 0:N/length(D5):N/2;
xdft = xdft(1:length(D5)/2+1);
figure;subplot(511);plot(freq,abs(xdft));title('GAMMA-FREQUENCY');
[~,I] = max(abs(xdft));
fprintf('Gamma:Maximum occurs at %3.2f Hz.\n',freq(I));

D6 = detrend(D6,0);
xdft2 = fft(D6);
freq2 = 0:N/length(D6):N/2;
xdft2 = xdft2(1:length(D6)/2+1);
subplot(512);plot(freq2,abs(xdft2));title('BETA');
[~,I] = max(abs(xdft2));
fprintf('Beta:Maximum occurs at %3.2f Hz.\n',freq2(I));

D7 = detrend(D7,0);
xdft3 = fft(D7);
freq3 = 0:N/length(D7):N/2;
xdft3 = xdft3(1:length(D7)/2+1);
subplot(513);plot(freq3,abs(xdft3));title('ALPHA');
[~,I] = max(abs(xdft3));
fprintf('Alpha:Maximum occurs at %f Hz.\n',freq3(I));

xdft4 = fft(D8);
freq4 = 0:N/length(D8):N/2;
xdft4 = xdft4(1:length(D8)/2+1);
subplot(514);plot(freq4,abs(xdft4));title('THETA');
[~,I] = max(abs(xdft4));
fprintf('Theta:Maximum occurs at %f Hz.\n',freq4(I));

A8 = detrend(A8,0);
xdft5 = fft(A8);
freq5 = 0:N/length(A8):N/2;
xdft5 = xdft5(1:length(A8)/2+1);
subplot(515);plot(freq3,abs(xdft5));title('DELTA');
[~,I] = max(abs(xdft5));
fprintf('Delta:Maximum occurs at %f Hz.\n',freq5(I));

% short time fourier transform
figure
stft(cleanEEG,fs,'Window',kaiser(256,5),'OverlapLength',220,'FFTLength',512);
view(-45,65)
colormap jet

%% Emperical mode decomposition
[imf,residual,info] = emd(cleanEEG,'Interpolation','pchip');
hht(imf,fs); %Hilbert spectrum plot 
pspectrum(EEG1,1000,'spectrogram','TimeResolution',4)
emd(EEG1,'Interpolation','pchip','Display',1)%Visualize Residual and Intrinsic Mode Functions of Signal
%% acceleration
% integrator is a filter with transfer function 1/(1-Z^2-1)
Nr=1;
Dr=[1,-1];
VeloX=filter(Nr,Dr,AccX)/fs_Acc;

% integrae velocity to get displacement
DispX=filter(Nr,Dr,VeloX)/fs_Acc;

% plot velocity
figure
plot(VeloX)
title('velocity horiontal')
xlabel('time(s)')
% plot distance 
figure
plot(DispX)
title('displacement horiontal ')
xlabel('time(s)')
ylabel('distance(m)')
