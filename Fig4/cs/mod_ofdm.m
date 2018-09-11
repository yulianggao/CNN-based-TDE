function [ txSig ] = mod_ofdm( qammod_in )

global ofdm;

% QAM Mapping
qammod_out = qammod(qammod_in, ofdm.M);

% DFT Spread (DFT-S)
dfts = fft(qammod_out, ofdm.Nd);

% Insert pilots
dfts_pilots = zeros(1, ofdm.sub);
index = 1 : (ofdm.ge+1) : ofdm.sub;
dfts_pilots(index) = ofdm.pilot;
dfts_pilots(dfts_pilots == 0) = dfts;

% Hermitian symmetry
txSig_hs = [0, dfts_pilots, 0, conj(dfts_pilots(:, end:-1:1))];
ofdm.pindex = [index+1, ofdm.Nf-index(end:-1:1)+1];

% IFFT
txSig_ifft = ifft(txSig_hs, ofdm.Nf);

% Normalization
ofdm.nc = max(abs(txSig_ifft));
txSig = txSig_ifft.' / ofdm.nc;
