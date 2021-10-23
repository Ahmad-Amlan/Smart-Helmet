% clear all;close all;clc
% 
% load ('Trial7.csv')
% AccX = Trial7(:,5);
% EEG1 = Trial7(:,2);
% EEG2 = Trial7(:,3);
% 
% fs_EEG = 2048; %Hz
% fs_Acc = 200; %Hz
% 
% ts_EEG = 1/fs_EEG;
% ts_Acc = 1/fs_Acc;
% 
% n = length(EEG1); % number of sample EEG
% tot_t = (n)*ts_EEG; %total signal time in second
% 
% tx_EEG = 0:ts_EEG:tot_t; % time vector for EEG
% tx_EEG = transpose(tx_EEG); %transpose time vector for debugging
% 
% figure
% plot(tx_EEG(1:end-1),EEG1); %plot signal against time
% hold
% plot(tx_EEG(1:end-1),EEG2);
% 
% figure
% plot(tx_EEG(1:end-1),EEG1/max(EEG1)); %plot rescale signal against time
% hold
% plot(tx_EEG(1:end-1),EEG2/max(EEG2));
% 
% [Y1,Ty1] = resample(EEG1,tx_EEG(1:end-1),fs_Acc); %resemple EEG2 to match ACC for adaptive filter
% [Y2,Ty2] = resample(EEG2,tx_EEG(1:end-1),fs_Acc); %resemple EEG2 to match ACC for adaptive filter
% 
% n_acc = tot_t/ts_Acc; %number sample Acceleration
% Acc = AccX(1:n_acc); %adjust the sample length to match EEG duration
% 
% figure % plot both scaled AccX and noisy EEG1&2 to see correlation 
% plot(Ty1,Y1/max(Y1))
% hold
% plot(Ty2,Y2/max(Y2)) 
% plot(Ty2,Acc/max(Acc))
% title('Correlation of scaled EEG and Acceleration'),legend('noisy EEG','clean EEG','Acceleration-X');
% 
% Y1 = Y1/max(Y1); % scaled EEG as input signal
% Y2 = Y2/max(Y2); % scaled EEG2 as input signal
% x = Acc/max(Acc); % scaled acceleration as an estimate Noise

%wavelet transform analysis
N=length(Y1);
waveletFunction = 'db8';
[C,L] = wavedec(y,8,waveletFunction); %1D wavelet decomposition 
% The output vector, C, contains the wavelet decomposition. 
% L containsthe number of coefficients by level.

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
figure; subplot(5,1,1); plot(Ty1,Gamma);title('GAMMA 30-60Hz');xlabel('time(s)');ylabel('ampllitude');

Beta = D6;
subplot(5,1,2); plot(Ty1, Beta); title('BETA 15-30Hz');xlabel('time(s)');ylabel('ampllitude');

Alpha = D7;
subplot(5,1,3); plot(Ty1,Alpha); title('ALPHA 8-15Hz'); xlabel('time(s)');ylabel('ampllitude');

Theta = D8;
subplot(5,1,4); plot(Ty1,Theta);title('THETA 4-8Hz');xlabel('time(s)');ylabel('ampllitude');
D8 = detrend(D8,0);

Delta = A8;
subplot(5,1,5);plot(Ty1,Delta);title('DELTA 0.5-4Hz');xlabel('time(s)');ylabel('ampllitude');

D5 = detrend(D5,0);
xdft = fft(D5);
freq = 0:N/length(D5):N/2;
xdft = xdft(1:length(D5)/2+1);
figure;subplot(221);plot(freq/25,abs(xdft));title('GAMMA-FREQUENCY');xlabel('frequency (Hz)'), ylabel('amplitude');
[~,I] = max(abs(xdft));
fprintf('Gamma:Maximum occurs at %3.2f Hz.\n',freq(I));

D6 = detrend(D6,0);
xdft2 = fft(D6);
freq2 = 0:N/length(D6):N/2;
xdft2 = xdft2(1:length(D6)/2+1);
subplot(222);plot(freq2/30,abs(xdft2));title('BETA');xlabel('frequency (Hz)'), ylabel('amplitude');
[~,I] = max(abs(xdft2));
fprintf('Beta:Maximum occurs at %3.2f Hz.\n',freq2(I));

D7 = detrend(D7,0);
xdft3 = fft(D7);
freq3 = 0:N/length(D7):N/2;
xdft3 = xdft3(1:length(D7)/2+1);
subplot(223);plot(freq3/55,abs(xdft3));title('ALPHA');xlabel('frequency (Hz)'), ylabel('amplitude');
[~,I] = max(abs(xdft3));
fprintf('Alpha:Maximum occurs at %f Hz.\n',freq3(I));

xdft4 = fft(D8);
freq4 = 0:N/length(D8):N/2;
xdft4 = xdft4(1:length(D8)/2+1);
subplot(224);plot(freq4/63,abs(xdft4));title('THETA');xlabel('frequency (Hz)'), ylabel('amplitude');
[~,I] = max(abs(xdft4));
fprintf('Theta:Maximum occurs at %f Hz.\n',freq4(I));

% A8 = detrend(A8,0);
% xdft5 = fft(A8);
% freq5 = 0:N/length(A8):N/2;
% xdft5 = xdft5(1:length(A8)/2+1);
% subplot(515);plot(freq3,abs(xdft5));title('DELTA');xlabel('frequency (Hz)'), ylabel('amplitude');
% [~,I] = max(abs(xdft5));
% fprintf('Delta:Maximum occurs at %f Hz.\n',freq5(I));

