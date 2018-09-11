function [ qamOut ] = dem_ofdm( rxSig, K)

global ofdm;

nc = max(abs(rxSig));
rxSig = rxSig / nc;

% FFT
I = eye(ofdm.Nf);
F = fft(I);
Y = F * rxSig;

% OMP-based estimator
S = I(ofdm.pindex, :);
A = S * F;
b = Y(ofdm.pindex) ./ ofdm.pilot;
h_estimate = omp(A, b, K);
H_estimate = F * h_estimate;

% Recovery
Y1 = Y ./ (H_estimate + eps);

% Extract data
mask = true(1, ofdm.Nf);
mask([1, ofdm.pindex]) = false;
mask((ofdm.Nf/2+1) : ofdm.Nf) = false;
Y2 = Y1(mask);

% IDFT Spread (IDFT-S)
Y3 = ifft(Y2, ofdm.Nd);

% QAM Demapping
qamOut = qamdemod(Y3, ofdm.M);
