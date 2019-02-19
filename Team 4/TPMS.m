%% Constants
rng(randi(100));
sampleRateHz = 433e6; % Sample rate
samplesPerSymbol = 8;
frameSize = 8;
numFrames = 64;
numSamples = numFrames*frameSize; % Samples to simulate
modulationOrder = 2;
filterSymbolSpan = 4;
Ts = 1/sampleRateHz;
R = (sampleRateHz/samplesPerSymbol);

%% Setup visualization object(s)
sa = dsp.SpectrumAnalyzer('SampleRate',sampleRateHz,'ShowLegend',true);

%% Impairments
snr = 18;
timingOffset = samplesPerSymbol*0.01;

%% Input decimal Pressure and Temperature
pres_num = 30;
temp_num = 27;

pres_bin = dec2bin(pres_num,8);
temp_bin = dec2bin(temp_num,8);
pres = [];
temp = [];
%convert from dec to array of bin, where each digit is individual element
for i=1:length(pres_bin)
    pres = [pres str2num(pres_bin(i))];
end

for i=1:length(temp_bin)
    temp = [temp str2num(temp_bin(i))];
end
%% Generate symbols
preamble = [1 1 0 1 1 0 1 0 1 1 1 0 0 0 1 1 0 1 0 1 0 1 0];
ID = [1 0 0 0 0 0 0 1 0 1 1 1 1 0 0 0 1 1 1 0 0 1 0 1 0 1 1 0 0 0 0 1];
flags = [1 1 1 0 0 0 0 1];
crc = [0 1 1 0 1 1 1 1];
signal = [pres temp ID flags crc];
data = randi([0 modulationOrder-1], numSamples*2, 1)';
%index = 80;
index = randi([1,length(data)-86]);
%index=length(data)-86;
data_with_sig = [data(1:index-1) signal data(index+1:length(data)-63)];
man_data = man_encode(data_with_sig);
man_data_with_preamble = [man_data(1:index*2-2) preamble man_data(index*2-1:length(man_data)-23)]';
modu = comm.FSKModulator('ModulationOrder',2, 'FrequencySeparation', 6, 'SymbolRate', 100, 'SamplesPerSymbol', 17);
demod = comm.FSKDemodulator('ModulationOrder',2, 'FrequencySeparation', 6, 'SymbolRate', 100, 'SamplesPerSymbol', 17);
modulatedData = step(modu,man_data_with_preamble);
%% Add TX/RX Filters
TxFlt = comm.RaisedCosineTransmitFilter(...
    'Shape',                  'Square root', ...
    'RolloffFactor',          0.1, ...
    'OutputSamplesPerSymbol', samplesPerSymbol,...
    'FilterSpanInSymbols', filterSymbolSpan);

RxFlt = comm.RaisedCosineReceiveFilter(...
    'Shape',                  'Square root', ...
    'RolloffFactor',          0.1, ...
    'InputSamplesPerSymbol', samplesPerSymbol,...
    'FilterSpanInSymbols', filterSymbolSpan,...
    'DecimationFactor', 8);% Set to filterUpsample/2 when introducing timing estimation
RxFltRef = clone(RxFlt);
%% Add noise source
chan = comm.AWGNChannel( ...
    'NoiseMethod',  'Signal to noise ratio (SNR)', ...
    'SNR',          snr, ...
    'SignalPower',  1, ...
    'RandomStream', 'mt19937ar with seed');

%% Add delay
varDelay = dsp.VariableFractionalDelay;

%% Phase Offset Corrector

poc = comm.CarrierSynchronizer(...
    'NormalizedLoopBandwidth', 0.01, ...   
    'DampingFactor', 0.707, ...
    'Modulation', 'PAM', ...
    'ModulationPhaseOffset', 'Auto');

%% Recover Signal
pfo = comm.PhaseFrequencyOffset('PhaseOffset', 20, 'SampleRate',1e6);
modulatedData_phase = step(pfo, modulatedData);

transmitted_data = step(TxFlt, modulatedData_phase);

noisy_data = step(chan, transmitted_data);

offsetData = step(varDelay, noisy_data, timingOffset);

received_data = step(RxFlt, offsetData);

received_data_phase_corr = step(poc, received_data);

demodulated_data = step(demod, received_data_phase_corr);

signal_rec = find_preamble(demodulated_data);

%% Display Results
signal
signal_rec
sum(signal==signal_rec)==64
sum(signal==signal_rec)/64 
[sum(man_data_with_preamble==demodulated_data)/2048 bin2dec(num2str(signal_rec(1:8))) bin2dec(num2str(signal_rec(9:16)))]