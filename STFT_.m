% clear all;
close all;clc

load ('Trial7.csv')
AccX = Trial7(:,5);
AccY = Trial7(:,7);
AccZ = Trial7(:,8);
EEG1 = Trial7(:,2);
EEG2 = Trial7(:,3);

fs_EEG = 2048; %Hz
fs_Acc = 200; %Hz

ts_EEG = 1/fs_EEG;
ts_Acc = 1/fs_Acc;

n = length(EEG1); % number of sample EEG
tot_t = (n)*ts_EEG; %total signal time in second

tx_EEG = 0:ts_EEG:tot_t; % time vector for EEG
tx_EEG = transpose(tx_EEG); %transpose time vector for debugging

[Y1,Ty1] = resample(EEG1,tx_EEG(1:end-1),fs_Acc); %resemple EEG2 to match ACC for adaptive filter
[Y2,Ty2] = resample(EEG2,tx_EEG(1:end-1),fs_Acc); %resemple EEG2 to match ACC for adaptive filter

stft(Y1,fs_Acc)
figure
stft(Y2,fs_Acc)
