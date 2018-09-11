function [ txSig ] = ofdm( qammod_in )

global M;
global Ns;
global Nf;
global Ncp;

% QAM Mapping
qammod_out = qammod(qammod_in, M);

% Insert zeros and Hermitian symmetry
subcarriers = [zeros(Ns, 1), qammod_out, zeros(Ns, 1), conj(qammod_out(:, end:-1:1))];

% Modulation
txSig_ifft = ifft(subcarriers, Nf, 2);

% Insert cyclic prefix
txSig_cp = [txSig_ifft(:, Nf-Ncp+1:Nf), txSig_ifft];

% Normalization
nc = max(max(abs(txSig_cp)));
txSig = txSig_cp ./ nc;
