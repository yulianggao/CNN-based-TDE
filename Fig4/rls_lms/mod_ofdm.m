function [ txSig ] = mod_ofdm( qammod_in )

global ofdm;

% QAM Mapping
qammod_out = qammod(qammod_in, ofdm.M);
Ns = size(qammod_out,1);

% DFT Spread (DFT-S)
dfts = fft(qammod_out, ofdm.Nd, 2);

% Hermitian symmetry
subcarriers = [zeros(Ns,1),dfts,zeros(Ns,1),conj(dfts(:,end:-1:1))];

% IFFT
txSig_ifft = ifft(subcarriers, ofdm.Nf, 2);

% Insert CP
txSig_cp = [txSig_ifft(:, end-ofdm.Ncp+1:end), txSig_ifft];

% Normalization
ofdm.nc = max(abs(txSig_cp(:)));
txSig_nc = txSig_cp / ofdm.nc;

% P2S
txSig = p2s(txSig_nc);
