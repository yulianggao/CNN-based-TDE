function [ BER ] = dem_ofdm( rxSig, equalizer, flag, qamIn )

global ofdm;

% TDE
if flag
	rxSig_eq = equalize(equalizer,rxSig);
else
	rxSig_eq = rxSig;
end

% S2P
rxSig_s2p = s2p(rxSig_eq,ofdm.test,ofdm.Nt);

% Remove CP
rxSig_remove_cp = rxSig_s2p(:, ofdm.Ncp+1:end);

% FFT
Y1 = fft(rxSig_remove_cp*ofdm.nc, [], 2);

% IDFT Spread (IDFT-S)
Y2 = Y1(:, 2 : (ofdm.Nf / 2));
Y3 = ifft(Y2, [], 2);

% QAM Demapping
demOut = qamdemod(Y3, ofdm.M);

% Comput BER
BER = error_rate(qamIn, demOut);
