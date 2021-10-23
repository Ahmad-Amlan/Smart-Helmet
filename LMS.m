% clear cll;
close all;clc

load ('Trial15.csv')
AccX = Trial7(:,5);
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

figure
plot(tx_EEG(1:end-1),EEG1); %plot signal against time
hold
plot(tx_EEG(1:end-1),EEG2);

figure
plot(tx_EEG(1:end-1),EEG1/max(EEG1)); %plot rescale signal against time
hold
plot(tx_EEG(1:end-1),EEG2/max(EEG2));

[Y,Ty] = resample(EEG2,tx_EEG(1:end-1),fs_Acc); %resemple EEG to match ACC for adaptive filter

n_acc = tot_t/ts_Acc; %number sample Acceleration
AccX = AccX(1:n_acc); %adjust the sample length to match EEG duration
AccY = AccY(1:n_acc); %adjust the sample length to match EEG duration
AccZ = AccZ(1:n_acc); %adjust the sample length to match EEG duration

Acc = AccX+AccY+AccZ;

figure % plot both scaled AccX and noisy EEG to see correlation 
plot(Ty,Y/max(Y)) 
hold
plot(Ty,Acc/max(Acc))
title('Correlation of scaled EEG and Acceleration'),legend('noisy EEG','Total Acceleration');

Y=Y/max(Y); % scaled EEG as input signal
x = Acc/max(Acc); % scaled acceleration as an estimate Noise



%% Noise Cancellation Using Sign-Data LMS Algorithm

%add correlated white noise to signal. To ensure that the noise is correlated,
%pass the noise through a lowpass FIR filter and then add the filtered noise to the signal.
filt = dsp.FIRFilter;
filt.Numerator = fir1(11,0.4);
fnoise = filt(AccX);
d = Y + fnoise;

coeffs = (filt.Numerator).'-0.01; % Set the filter initial conditions.
mu = 0.05; % Set the step size for algorithm updating.

lms = dsp.LMSFilter(12,'Method','Sign-Data LMS',...
   'StepSize',mu,'InitialConditions',coeffs);
[y,e] = lms(AccX,d);

figure
plot(Ty,Y,Ty,e,Ty,y);
title('Noise Cancellation by the Sign-Data Algorithm');
legend('Noisy signal','error','Result of noise cancellation');
xlabel('Time index')
ylabel('Signal values')



%% EXAMPLE #2: Noise cancellation
 
% %     FrameSize = 100; NIter = 10;
%     lmsfilt2 = dsp.LMSFilter('Length',11,'Method','Normalized LMS', ...
%               'StepSize',0.05);
%     firfilt2 = dsp.FIRFilter('Numerator', fir1(10,[.5, .75]));
% %     sinewave = dsp.SineWave('Frequency',0.01, ...
% %         'SampleRate',1,'SamplesPerFrame',FrameSize);
% 
%     TS = dsp.TimeScope('TimeSpan',FrameSize*NIter,'TimeUnits','Seconds',...
%          'YLimits',[-3 3],'BufferLength',2*FrameSize*NIter, ...
%          'ShowLegend',true,'ChannelNames', ...
%          {'Noisy signal', 'Filtered signal'});
%     % Stream
%     for k = 1:NIter
% %         x = x;       % Input signal
%         d = firfilt2(x) + Y; % Noise + Signal
%         [y,e,w] = lmsfilt2(x,d);
%         TS([d,Y]);          % Noisy = channel 1; Filtered = channel 2
%     end
    
        %% EXAMPLE #3: LMS with full adaptive weights history output
        
%     FrameSize = 15000;
%     lmsfilt3 = dsp.LMSFilter('Length', 63, 'Method', 'LMS', ...
%               'StepSize', 0.001, 'LeakageFactor', 0.99999, ...
%               'WeightsOutput', 'All'); % full Weights history
%     w_actual = fir1(64,[.5, .75]);
%     firfilt3 = dsp.FIRFilter('Numerator',w_actual);
%     sinewave = dsp.SineWave('Frequency', 0.01, ...
%         'SampleRate',1,'SamplesPerFrame',FrameSize);
%     TS = dsp.TimeScope('TimeSpan',FrameSize,'TimeUnits','Seconds',...
%          'YLimits',[-0.25 0.75],'BufferLength',2*FrameSize, ...
%          'ShowLegend', true, 'ChannelNames', ...
%          {'Coeff 33 Estimate','Coeff 34 Estimate','Coeff 35 Estimate', ...
%           'Coeff 33 Actual',  'Coeff 34 Actual',  'Coeff 35 Actual'});
%     % Run one frame and plot full adaptive weights history
%     x = randn(FrameSize,1);       % Input signal
%     d = firfilt3(x) + sinewave(); % Noise + Signal
%     [~,~,w] = lmsfilt3(x,d);
%     % Plot convergence of Weights indices 33, 34, 35
%     idxBeg = 33; idxEnd = 35;
%     TS([w(:,idxBeg:idxEnd), repmat(w_actual(idxBeg:idxEnd),FrameSize,1)]);
 