clear all;
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

figure
plot(tx_EEG(1:end-1),EEG1); %plot signal against time
hold
plot(tx_EEG(1:end-1),EEG2);

figure
plot(tx_EEG(1:end-1),EEG1/max(EEG1)); %plot rescale signal against time
hold
plot(tx_EEG(1:end-1),EEG2/max(EEG2));

[Y1,Ty1] = resample(EEG1,tx_EEG(1:end-1),fs_Acc); %resemple EEG2 to match ACC for adaptive filter
[Y2,Ty2] = resample(EEG2,tx_EEG(1:end-1),fs_Acc); %resemple EEG2 to match ACC for adaptive filter

n_acc = tot_t/ts_Acc; %number sample Acceleration
AccX = AccX(1:n_acc); %adjust the sample length to match EEG duration
AccY = AccY(1:n_acc); %adjust the sample length to match EEG duration
AccZ = AccZ(1:n_acc); %adjust the sample length to match EEG duration

Acc = AccX+AccY+AccZ;

Y1 = Y1/max(Y1); % scaled EEG as input signal
Y2 = Y2/max(Y2); % scaled EEG2 as input signal
x = AccX/max(AccX); % scaled acceleration as an estimate Noise

figure % plot both scaled AccX and noisy EEG1&2 to see correlation 
subplot(3,1,1)
plot(Ty1,Y1),title('undisturbed EEG')
subplot(3,1,2)
plot(Ty2,Y2),title(' noisy EEG ')
subplot(3,1,3)
plot(Ty2,x),title(' Acceleration');



   % EXAMPLE #1: System identification of an FIR filter
   
%    for i=0.97:0.01:1
%        rlsf1 = dsp.RLSFilter(11, 'ForgettingFactor', 1);
%        ffilt = dsp.FIRFilter('Numerator',fir1(10, [.5, .75]));% create Fir filter % Unknown System
%        x_filt = ffilt(x); %filter the acceleration
%        
%        d = x_filt + Y2; % desired signal
% 
%        [y,e] = rlsf1(d, Y2);
%        
%      
%        figure;
%        plot(Ty1, [Y2,y,e]);
%        title(['RMS filter with lambda = ',num2str(i)]);
%        legend('EEG2', 'Filtered EEG', ' noise estimate');
%        xlabel('time index'); ylabel('signal value');
%            
%         grid on
%         subplot(3,1,1)
%         plot(Ty2,[Y1,Y2]),title('EEG signal with motion artifacts'),xlabel('time(s)'),ylabel('amplitude')
%         legend({'undisturbed EEG','noisy EEG'},'Location','southeast')
%         subplot(3,1,2)
%         plot(Ty2,e),title('Motion artifacts estimate'),xlabel('time(s)'),ylabel('amplitude')
%         subplot(3,1,3)
%         plot(Ty2,[Y1,y]),title(['Adaptive filtered EEG signal, with lambda =',num2str(i)]),xlabel('time (s)'),ylabel('amplitude')
%         legend({'undisturbed EEG','filtered EEG'},'Location','southeast')
%   end

    % EXAMPLE #2: Noise cancellation
    

       rlsf2  = dsp.RLSFilter('Length', 11, 'Method', 'Householder RLS');% create RLS filter
       ffilt2 = dsp.FIRFilter('Numerator',fir1(10, [.5, .75]));% create Fir filter
      
      
       d = ffilt2(x) + Y2;     % Noise + Signal
       [y, err] = rlsf2(x, d);

       
        figure
        plot(Ty2,d,Ty2,err,Ty2,y);
        title('Noise Cancellation by the Sign-Data Algorithm ');
        legend('Noisy signal','error','Result of noise cancellation');
        xlabel('Time(s)')
        ylabel('Signal')
 
       figure
       plot(Ty1,Y1,Ty2,Y2,Ty2,y),legend('EEG1','EEG2','Filtered EEG2'),title('Before vs after')
     
    
figure
grid on
subplot(3,1,1)
plot(Ty2,[Y1,Y2]),title('EEG signal with motion artifacts'),xlabel('time(s)'),ylabel('amplitude')
legend({'undisturbed EEG','noisy EEG'},'Location','southeast')
subplot(3,1,2)
plot(Ty2,x),title('Acceleration data'),xlabel('time(s)'),ylabel('amplitude')
subplot(3,1,3)
plot(Ty2,[Y1,y]),title('Adaptive filtered EEG signal'),xlabel('time (s)'),ylabel('amplitude')
 legend({'undisturbed EEG','filtered EEG'},'Location','southeast')

%% STFT
figure
for i=1:4
   j=100*i;
   win = blackman(j,'periodic');
   subplot(2,2,i)
   stft(y,fs_Acc,'Window',win),title(['STFT of EEG signal,number of windows = ',num2str(j)])
   
end

      
       %% VIEW FIR filter effect on signal
       
%        x_filt = ffilt2(x); %filtered acceleration
%        Y_filt = ffilt2(Y); %filter the EEG
%        
%        figure
%        plot(Ty,Y_filt,Ty,x_filt),title('FIR filtered signal'),legend('EEG','Acc')
