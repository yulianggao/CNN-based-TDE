function [ txSig ] = clip_ofdm( qammod_in, clip )

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

% Clipping
txSig_clip = zeros(Ns, Nf+Ncp);
for i = 1 : Ns
    t = txSig_cp(i, :);
    Bu = max(t) * (1 - clip);
    Bl = min(t) * (1 - clip);
    t(t > Bu) = Bu;
    t(t < Bl) = Bl;
    txSig_clip(i, :) = t;
end

% Normalization
nc = max(max(abs(txSig_clip)));
txSig = txSig_clip ./ nc;
