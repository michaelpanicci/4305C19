%% Receiver Loop For Channel 1 "ON" and "OFF"
clear

ds = 25;

on_ref = load('on_var.mat');
on_ref = on_ref.received_dup;
on_ref = [on_ref' 0 0 0];
on_ref = downsample(on_ref', ds);

off_ref = load('off_var.mat');
off_ref = off_ref.received_dup;
off_ref = [off_ref' 0 0 0];
off_ref = downsample(off_ref', ds);

rx = sdrrx('Pluto','CenterFrequency', 433.975e6, 'SamplesPerFrame', 56000, 'BasebandSampleRate', 1e6);

%% Loop to Find Current Transmitted Signal
while 1
%rx = sdrrx('Pluto','CenterFrequency', 433.975e6, 'SamplesPerFrame', 56000, 'BasebandSampleRate', 1e6);
received_dup = rx();
received_dup1 = received_dup;

%Threshold value to differentiate between a pseudo "1" and "0"
threshold = 15;
received_dup(abs(real(received_dup))<threshold)=0;
received_dup(abs(real(received_dup))>=threshold)=1;

%% test
trigger1 = 0;
for i=51:length(received_dup)-50
    
if and(received_dup(i)==1,trigger1 < 1)
    trigger1 = i;
    i = i+50;
end
    
if and(sum(received_dup(i-50:i))==0,trigger1 > 1)
    received_dup(trigger1:i-50)=1;
    trigger1 = 0;   
end
end
dup_Shift = received_dup;
received_dup = downsample(received_dup, ds);

max_sum_on=0;
max_sum_off=0;

bound = 18650/ds-1;

for i=1:length(received_dup)-bound

corr_on = sum(received_dup(i:i+bound)==on_ref);
corr_off = sum(received_dup(i:i+bound)==off_ref);

if corr_on>max_sum_on
max_sum_on = corr_on;
end

if corr_off>max_sum_off
max_sum_off = corr_off;
end


end

final_on_corr = max_sum_on;
final_off_corr = max_sum_off;

corr_bound = round(0.724 * (bound+1));

if and(final_on_corr > corr_bound, final_off_corr > corr_bound)
    if (final_on_corr > final_off_corr)
        result = 'ON'
    else
        result = 'OFF'
    end
else
    result = 'No Signal'
end
end
%% plot original
plt_int = 1:length(real(received_dup1))-1;
plot(plt_int, real(received_dup1(plt_int)));
ylim([-500 500]);

%% plot original
plt_int = 1:length(real(dup_Shift))-1;
plot(plt_int, real(dup_Shift(plt_int)));
ylim([-2 2]);


%% modified
plt_int = 1:length(received_dup)-1;
plot(plt_int, received_dup(plt_int));
ylim([-1 2]);

%% plot ref
plt_int = 1:length(on_ref);
plot(plt_int, on_ref);
ylim([-0.5 1.5]);