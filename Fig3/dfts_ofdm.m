function [ txSig ] = dfts_ofdm( qammod_in )

global M;
global Ns;
global Nd;
global Nf;
global Ncp;

% QAM Mapping
qammod_out = qammod(qammod_in, M);

% DFT Spread
dfts = fft(qammod_out, Nd, 2);

% Insert zeros and Hermitian symmetry
subcarriers = [zeros(Ns, 1), dfts, zeros(Ns, 1), conj(dfts(:, end:-1:1))];

% Modulation
txSig_ifft = ifft(subcarriers, Nf, 2);

% Insert cyclic prefix
txSig_cp = [txSig_ifft(:, Nf-Ncp+1:Nf), txSig_ifft];

% Normalization
nc = max(max(abs(txSig_cp)));
txSig = txSig_cp ./ nc;
