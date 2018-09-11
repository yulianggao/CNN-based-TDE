clear; clc; close all;

global M;        % Modulation order
global Nf;       % Length of FFT/IFFT
global Ncp;      % Length of cyclic prefix
global Nd;       % Length of data subcarriers
global Ns;       % Total symbols
M = 32;
Nf = 64;
Ncp = 8;
Nd = Nf/2 - 1;
Ns = 1e4;

qammod_in = randi([0, M-1], Ns, Nd);

ofdm = ofdm(qammod_in);

dfts = dfts_ofdm(qammod_in);

clip = [0.1, 0.2];
clip1 = clip_ofdm(qammod_in, clip(1));
clip2 = clip_ofdm(qammod_in, clip(2));

D = [2, 4];
slm1 = slm_ofdm(qammod_in, D(1));
slm2 = slm_ofdm(qammod_in, D(2));

cdf  = zeros(Ns+1, 6);
papr = zeros(Ns+1, 6);
[cdf(:, 1), papr(:, 1)] = ecdf(getPAPR(ofdm));
[cdf(:, 2), papr(:, 2)] = ecdf(getPAPR(dfts));
[cdf(:, 3), papr(:, 3)] = ecdf(getPAPR(clip1));
[cdf(:, 4), papr(:, 4)] = ecdf(getPAPR(clip2));
[cdf(:, 5), papr(:, 5)] = ecdf(slm1);
[cdf(:, 6), papr(:, 6)] = ecdf(slm2);

save('papr_ccdf.mat', 'cdf', 'papr', 'clip', 'D');
