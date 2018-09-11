clear; clc; close all; dbstop if error

% Parameters of OFDM
global ofdm;
% Normalization
ofdm.nc = 0;
% BER
ofdm.ber = 1;
% Modulation order
ofdm.M = 16;
ofdm.bit = log2(ofdm.M);
% Number of pilots
ofdm.Np = 11;
% FFT/IFFT points
ofdm.Nf = 64;
% Number of subcarriers
ofdm.sub = ofdm.Nf/2 - 1;
ofdm.ge = (ofdm.sub - ofdm.Np) / (ofdm.Np - 1);
% Number of data
ofdm.Nd = ofdm.sub - ofdm.Np;
% Pilots
ofdm.pilot = 11;
% Index of pilots
ofdm.pindex = 0;
% Total symbols
ofdm.Ns = 100;
% SNR
ofdm.snr = 0;
% Length of channel
ofdm.channel = 5;
% Cut-off frequency
ofdm.fc = 45e6;
% Sample rate
ofdm.fs = 200e6;
% Impulse response of channel
ofdm.h = fir1(ofdm.channel-1, ofdm.fc./(ofdm.fs/2), hamming(ofdm.channel)).';
H = fft(ofdm.h, ofdm.Nf);

ber_omp = zeros(3, 7);
for k = 1 : 3
    ofdm.snr = 0;
    for i = 1 : 7
        qamIn  = prbs(0);
        qamOut = zeros(ofdm.Ns, ofdm.Nd);
        for j = 1 : ofdm.Ns
            % Modulation
            txSig = mod_ofdm(qamIn(j, :));
            % Impulse response + AWGN
            txSig_lp = ifft(fft(txSig, ofdm.Nf).*H, ofdm.Nf);
            spow = norm(txSig_lp, 2)^2 / numel(txSig_lp);
            npow = sqrt(spow * 10^(-ofdm.snr/10));
            rxSig = txSig_lp + npow * randn(size(txSig_lp));
            % Demodulation
            qamOut(j, :) = dem_ofdm(rxSig, ofdm.channel);
        end
        ber_omp(k,i) = error_rate(qamIn, qamOut);
        if ber_omp(k,i) == 0
            ber_omp(k,i) = 1e-5;
        end
        fprintf('%dQAM: SNR = %d, BER = %f\n', ofdm.M, ofdm.snr, ber_omp(k,i));
        ofdm.snr = ofdm.snr + 5;
    end
    ofdm.M = ofdm.M * 2;
    ofdm.bit = log2(ofdm.M);
    fprintf('\n');
end

% save('ber_omp.mat', 'ber_omp');
